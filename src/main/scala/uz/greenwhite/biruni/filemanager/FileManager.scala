package uz.greenwhite.biruni.filemanager

import jakarta.servlet.http.HttpServletResponse
import net.coobird.thumbnailator.Thumbnails
import oracle.jdbc.{OracleCallableStatement, OracleTypes}
import uz.greenwhite.biruni.connection.DBConnection
import uz.greenwhite.biruni.lazyreport.ReportType
import uz.greenwhite.biruni.s3.{S3Client, S3Util}
import uz.greenwhite.biruni.util.FileUtil

import java.io.{BufferedOutputStream, ByteArrayInputStream, ByteArrayOutputStream, File, FileOutputStream, InputStream, OutputStream}
import java.net.URLEncoder
import java.nio.file.{Files, Paths}
import java.sql.{PreparedStatement, ResultSet, SQLException}
import java.util.zip.{ZipEntry, ZipOutputStream}

object FileManager {
  def uploadFileEntity(bytes: Array[Byte], contentType: String, sha: String): Unit = {
    try {
      if ("S".equals(FileUtil.getFileStoreKind)) {
        S3Util.uploadObject(new ByteArrayInputStream(bytes), sha, contentType, bytes.length)
      } else {
        uploadFileToDatabase(sha, bytes)
      }
    } catch {
      case e: Exception =>
        throw new RuntimeException(e.getMessage)
    }
  }

  def uploadFileEntity(inputStream: InputStream, contentType: String, sha: String, size: Long): Unit = {
    try {
      if ("S".equals(FileUtil.getFileStoreKind)) {
        S3Util.uploadObject(inputStream, sha, contentType, size)
      } else {
        uploadFileToDatabase(sha, inputStream)
      }
    } catch {
      case e: Exception =>
        throw new RuntimeException(e.getMessage)
    }
  }

  def uploadFileEntity(bytes: Array[Byte], contentType: String): String = {
    val sha = FileUtil.calcSHA(bytes)
    uploadFileEntity(bytes, contentType, sha)
    sha
  }

  def uploadFileEntity(inputStream: InputStream, contentType: String): String = {
    val bytes = FileUtil.readInputStream(inputStream)
    uploadFileEntity(bytes, contentType)
  }

  def uploadFileEntityAndSaveProperties(bytes: Array[Byte], fileName: String, contentType: String): String = {
    val sha = FileUtil.calcSHA(bytes)
    saveFileProperties(sha, bytes.length, fileName, contentType)
    uploadFileEntity(bytes, contentType, sha)
    sha
  }

  def uploadFileEntityAndSaveProperties(inputStream: InputStream, fileName: String, contentType: String): String = {
    val bytes = FileUtil.readInputStream(inputStream)
    uploadFileEntityAndSaveProperties(bytes, fileName, contentType)
  }

  private def saveFileProperties(sha: String, fileSize: Int, fileName: String, contentType: String): Unit = {
    var conn = DBConnection.getPoolConnection
    var st: PreparedStatement = null

    try {
      st = conn.prepareStatement("BEGIN Biruni_File_Manager.Save_File_Properties(?,?,?,?,?); END;")
      st.setString(1, sha)
      st.setLong(2, fileSize)
      st.setString(3, fileName)
      st.setString(4, contentType)
      st.setString(5, FileUtil.getFileStoreKind)
      st.execute
    } catch {
      case ex: SQLException =>
        throw new RuntimeException("Biruni File: error saving file properties " + ex.getMessage)
    } finally {
      if (st != null) st.close()
      conn.close()
      conn = null
    }
  }

  // easy report
  def uploadEasyReportEntityAndSaveProperties(bytes: Array[Byte], fileName: String, contentType: String): String = {
    val sha = FileUtil.calcSHA(bytes)
    saveEasyReportProperties(sha, bytes.length, fileName, contentType)
    uploadFileEntity(bytes, contentType, sha)
    sha
  }

  def uploadEasyReportEntityAndSaveProperties(inputStream: InputStream, fileName: String, contentType: String): String = {
    val bytes = FileUtil.readInputStream(inputStream)
    uploadEasyReportEntityAndSaveProperties(bytes, fileName, contentType)
  }

  private def saveEasyReportProperties(sha: String, fileSize: Int, fileName: String, contentType: String): Unit = {
    var conn = DBConnection.getPoolConnection
    var st: PreparedStatement = null

    try {
      st = conn.prepareStatement("BEGIN Biruni_Easy_Report.Save_Easy_Report_Properties(?,?,?,?,?); END;")
      st.setString(1, sha)
      st.setLong(2, fileSize)
      st.setString(3, fileName)
      st.setString(4, contentType)
      st.setString(5, FileUtil.getFileStoreKind)
      st.execute
    } catch {
      case ex: SQLException =>
        throw new RuntimeException("Biruni File: error saving file properties " + ex.getMessage)
    } finally {
      if (st != null) st.close()
      conn.close()
      conn = null
    }
  }

  private def uploadFileToDatabase(sha: String, bytes: Array[Byte]): Unit = {
    var conn = DBConnection.getPoolConnection
    var cs: OracleCallableStatement = null
    var st: PreparedStatement = null

    try {
      conn.setAutoCommit(false)
      cs = conn.prepareCall("BEGIN Biruni_File_Manager.Lock_File_Uploading(?,?,?); END;").asInstanceOf[OracleCallableStatement]

      cs.setString(1, sha)
      cs.registerOutParameter(2, OracleTypes.VARCHAR)
      cs.registerOutParameter(3, OracleTypes.VARCHAR)

      cs.execute

      val action = cs.getString(2)
      val errorMessage = cs.getString(3)

      // uploading
      if (action == "U") {
        st = conn.prepareStatement("INSERT INTO biruni_filespace VALUES(?,?)")
        st.setString(1, sha)
        st.setBytes(2, bytes)
        st.execute
      } else if (action == "E") {
        throw new Exception(errorMessage)
      }

      conn.commit()
    } catch {
      case ex: Exception =>
        conn.rollback()
        println("File upload error. Error message " + ex.getMessage)
    } finally {
      if (cs != null) cs.close()
      if (st != null) st.close()
      conn.close()
      conn = null
    }
  }

  private def uploadFileToDatabase(sha: String, inputStream: InputStream): Unit = {
    uploadFileToDatabase(sha, FileUtil.readInputStream(inputStream))
  }

  private def saveFileAccessLink(sha: String, kind: String, link: String): Unit = {
    var conn = DBConnection.getPoolConnection
    var st: PreparedStatement = null

    try {
      st = conn.prepareStatement("BEGIN Biruni_File_Manager.Save_File_Download_Link(?,?,?,?); END;")
      st.setString(1, sha)
      st.setString(2, kind)
      st.setString(3, link)
      st.setLong(4, S3Client.getLinkExpireInHours)
      st.execute
    } catch {
      case ex: SQLException =>
        println("Biruni File: saving download link error " + ex.getMessage)
    } finally {
      if (st != null) st.close()
      conn.close()
      conn = null
    }
  }

  /////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////// Send file to client (download) ////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////

  private def loadFileInfo(file: FazoFileData): Unit = {
    var conn = DBConnection.getPoolConnection
    var cs: OracleCallableStatement = null

    try {
      cs = conn.prepareCall("BEGIN Biruni_File_Manager.Get_File_Info(?,?,?,?); END;").asInstanceOf[OracleCallableStatement]
      cs.setString(1, file.sha)
      cs.setString(2, file.redirectKind)
      cs.registerOutParameter(3, OracleTypes.VARCHAR)
      cs.registerOutParameter(4, OracleTypes.VARCHAR)
      cs.execute()

      file.storeKind = cs.getString(3)
      file.downloadLink = cs.getString(4)
    } catch {
      case _: Exception => throw new Exception("Downloading error")
    } finally {
      if (cs != null) cs.close()
      conn.close()
      conn = null
    }
  }

  private def loadFileInfo(sha: String): FazoFileData = {
    val fd = FazoFileData(sha, "", redirect = false, "", "", None, None, cache = false, None, None)
    loadFileInfo(fd)
    fd
  }

  private def loadFileFromDatabase(sha: String): Array[Byte] = {
    var conn = DBConnection.getPoolConnection
    var st: PreparedStatement = null
    var rs: ResultSet = null

    try {
      st = conn.prepareStatement("SELECT file_content FROM biruni_filespace WHERE sha = ?")
      st.setString(1, sha)
      st.execute()

      rs = st.getResultSet
      rs.next()
      rs.getBytes(1)
    } catch {
      case _: Exception => throw new Exception("Downloading error")
    } finally {
      if (rs != null) rs.close()
      if (st != null) st.close()
      conn.close()
      conn = null
    }
  }

  def loadFile(fd: FazoFileData): Array[Byte] = {
    if (fd.storeKind == "D") FileManager.loadFileFromDatabase(fd.sha)
    else S3Util.getObject(fd.sha)
  }

  def loadFileAsInputStream(fd: FazoFileData): InputStream = {
    new ByteArrayInputStream(loadFile(fd))
  }

  def loadFile(sha: String): Array[Byte] = {
    loadFile(loadFileInfo(sha))
  }

  def loadFileAsInputStream(sha: String): InputStream = {
    new ByteArrayInputStream(loadFile(sha))
  }

  def deleteFile(sha: String): Unit = {
    val storeKind = deleteFileFromDatabase(sha)
    if ("S".equals(storeKind)) S3Util.removeObject(sha)
  }

  private def deleteFileFromDatabase(sha: String): String = {
    var conn = DBConnection.getPoolConnection
    var cs: OracleCallableStatement = null

    try {
      cs = conn.prepareCall("BEGIN Biruni_File_Manager.Delete_File(?,?); END;").asInstanceOf[OracleCallableStatement]
      cs.setString(1, sha)
      cs.registerOutParameter(2, OracleTypes.VARCHAR)
      cs.execute()

      cs.getString(2)
    } catch {
      case _: Exception => throw new Exception("Delete file from database error")
    } finally {
      if (cs != null) cs.close()
      conn.close()
      conn = null
    }
  }

  def deleteEasyReport(sha: String): Unit = {
    var conn = DBConnection.getPoolConnection
    var cs: OracleCallableStatement = null

    try {
      cs = conn.prepareCall("BEGIN Biruni_Easy_Report.Delete_Easy_Report(?); END;").asInstanceOf[OracleCallableStatement]
      cs.setString(1, sha)
      cs.execute()
    } catch {
      case _: Exception => throw new Exception("Delete file from database error")
    } finally {
      if (cs != null) cs.close()
      conn.close()
      conn = null
    }
  }

  def sendReport(reportType: ReportType, sha: String, filename: String, response: HttpServletResponse): Unit = {
    try {
      response.setCharacterEncoding("UTF-8")

      if (reportType == ReportType.HTML) {
        response.setContentType("text/html;charset=UTF-8")
        response.setHeader("Content-Disposition", "filename*=UTF-8''" + URLEncoder.encode(filename, "UTF-8") + (if (filename.endsWith(".html")) "" else ".html"))
      } else {
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;charset=UTF-8")
        response.setHeader("Content-Disposition", "attachment;filename*=UTF-8''" + URLEncoder.encode(filename, "UTF-8") + (if (filename.endsWith(".xlsx")) "" else ".xlsx"))
      }

      if (FileUtil.getFileStoreKind.equals("D")) response.getOutputStream.write(FileManager.loadFileFromDatabase(sha))
      else response.getOutputStream.write(S3Util.getObject(sha))
    } catch {
      case e: Exception => sendFileNotFound(e.getMessage, response)
    }
  }

  def sendFileNotFound(text: String, response: HttpServletResponse): Unit = {
    response.setStatus(410)
    response.setContentType("text/plain")
    response.getWriter.write(text)
  }

  def sendFileNotFound(response: HttpServletResponse): Unit = {
    sendFileNotFound("File is not found", response)
  }
}

case class FileManager(filesPath: String, response: HttpServletResponse) {
  private val DEFAULT_IMG_QUALITY = 1.0
  private val DEFAULT_IMG_FORMAT = "PNG"

  def sendFile(ff: FazoFile): Unit = ff.files match {
    case Nil => FileManager.sendFileNotFound(response)
    case fd :: Nil => sendSingleFile(fd)
    case _ => sendZipFile(ff)
  }

  private def sendSingleFile(fd: FazoFileData): Unit = {
    if (response.containsHeader("content-disposition")) {
      response.setHeader("content-disposition",
        response.getHeader("content-disposition")
          .split(';')
          .map(x => {
            val v = x.trim
            if (v.startsWith("filename"))
              "filename=" + URLEncoder.encode(v.substring(v.indexOf("=") + 1, v.length), "UTF-8")
            else v
          })
          .reduce((a, b) => a + "; " + b)
      )
    }

    try {
      FileManager.loadFileInfo(fd)

      if (fd.width.isDefined && fd.height.isDefined && !fd.name.endsWith(".webp")) {
        val imagePath = Paths.get(getPath(fd))

        if (Files.exists(imagePath)) Files.copy(imagePath, response.getOutputStream)
        else sendImage(fd, FileManager.loadFile(fd), response.getOutputStream)
      } else {
        if (fd.storeKind == "D") {
          response.getOutputStream.write(FileManager.loadFileFromDatabase(fd.sha))
        } else {
          if (fd.redirect) {
            if (fd.downloadLink == null || fd.downloadLink.isEmpty) {
              fd.downloadLink = {
                if (fd.redirectKind.equals("L")) S3Util.getLoadLink(fd.sha, fd.name)
                else S3Util.getDownloadLink(fd.sha, fd.name)
              }

              FileManager.saveFileAccessLink(fd.sha, fd.redirectKind, fd.downloadLink)
            }

            response.sendRedirect(fd.downloadLink)
          } else {
            response.getOutputStream.write(S3Util.getObject(fd.sha))
          }
        }
      }
    } catch {
      case ex: Exception => FileManager.sendFileNotFound(ex.getMessage, response)
    }
  }

  private def sendZipFile(ff: FazoFile): Unit = {
    val fileName = URLEncoder.encode(ff.attachmentName.getOrElse("archive"), "UTF-8")
    response.setContentType("application/zip")
    response.setHeader("Content-Disposition", "attachment;filename=" + fileName + ".zip")

    val zip = new ZipOutputStream(new BufferedOutputStream(response.getOutputStream, 16384))

    for (fd <- ff.files) {
      try {
        FileManager.loadFileInfo(fd)
        zip.putNextEntry(new ZipEntry(fd.name))

        if (fd.width.isDefined && fd.height.isDefined) {
          val imagePath = Paths.get(getPath(fd))

          if (Files.exists(imagePath)) Files.copy(imagePath, zip)
          else sendImage(fd, FileManager.loadFile(fd), zip)
        } else {
          zip.write(FileManager.loadFile(fd))
        }

        zip.closeEntry()
      } catch {
        case _: Exception =>
      }
    }

    zip.close()
  }

  private def sendImage(fd: FazoFileData, fileStream: InputStream, os: OutputStream): Unit = {
    val DEFAULT_IMG_SIZE = 600

    val image = new File(getPath(fd))
    val parentFile = image.getParentFile
    if (!parentFile.exists()) parentFile.mkdirs()

    val byteArray = new ByteArrayOutputStream()

    Thumbnails.of(fileStream)
      .size(fd.width.getOrElse(DEFAULT_IMG_SIZE), fd.height.getOrElse(DEFAULT_IMG_SIZE))
      .outputFormat(fd.format.getOrElse(DEFAULT_IMG_FORMAT))
      .outputQuality(fd.quality.getOrElse(DEFAULT_IMG_QUALITY))
      .toOutputStream(byteArray)

    val outStream = new FileOutputStream(image)
    outStream.write(byteArray.toByteArray)
    outStream.close()

    byteArray.writeTo(os)
  }

  private def sendImage(fd: FazoFileData, file: Array[Byte], os: OutputStream): Unit = {
    val buf = new ByteArrayInputStream(file)
    sendImage(fd, buf, os)
  }

  private def getPath(sha: String, width: Int, height: Int, quality: Double, format: String) = {
    if (quality.equals(DEFAULT_IMG_QUALITY))
      s"$filesPath/images/${sha.substring(0, 2)}/${sha.substring(2, 4)}/${width}x$height/$sha.$format"
    else
      s"$filesPath/images/${sha.substring(0, 2)}/${sha.substring(2, 4)}/${width}x${height}x$quality/$sha.$format"
  }

  private def getPath(fazoFileData: FazoFileData): String = {
    getPath(fazoFileData.sha, fazoFileData.width.get, fazoFileData.height.get, fazoFileData.quality.getOrElse(DEFAULT_IMG_QUALITY), fazoFileData.format.getOrElse(DEFAULT_IMG_FORMAT))
  }
}