package uz.greenwhite.biruni.filemanager

import jakarta.servlet.http.HttpServletRequest
import org.apache.commons.fileupload2.core.DiskFileItem
import org.apache.commons.fileupload2.core.DiskFileItemFactory
import org.apache.commons.fileupload2.jakarta.{JakartaFileCleaner, JakartaServletDiskFileUpload}
import uz.greenwhite.biruni.conf.Setting
import uz.greenwhite.biruni.util.FileUtil

import java.io.File
import java.nio.charset.StandardCharsets
import scala.collection.JavaConverters._

class ServletFileUploadEntity(request: HttpServletRequest, setting: Setting) {
  private val items: List[DiskFileItem] = extractFilesFromRequest
  private var param: String = items.find(x => x.isFormField && "param" == x.getFieldName).map(_.getString(StandardCharsets.UTF_8)).getOrElse("")

  if (param.isEmpty) throw new RuntimeException("param is not found in uploading file")

  private val files: Seq[FileParam] = prepareFiles()

  def getFiles: Seq[FileParam] = files

  def getParam: String = param

  /**
   * This method uploads the file to the database or S3 and deletes the file from the temporary folder.
   */
  def uploadFile(fileParam: FileParam): Unit = try {
    FileManager.uploadFileEntity(fileParam.fileItem.getInputStream, fileParam.properties("content_type"), fileParam.sha, fileParam.properties("file_size").toLong)
  } finally {
    fileParam.fileItem.delete()
  }

  /**
   * This method uploads all files to the database or S3 and deletes the files from the temporary folder.
   */
  def uploadFiles(): Unit = for (fileParam <- files) uploadFile(fileParam)

  def deleteFiles(): Unit = for (fileParam <- files) fileParam.fileItem.delete()

  private def prepareFiles(): Seq[FileParam] = {
    for (x <- items if !x.isFormField) yield {
      val index = x.getFieldName.filter(_.isDigit)
      val sha = FileUtil.calcSha(x.getInputStream)

      param = param.replace("\"\\u0000" + index + "\"", "\"" + sha + "\"")

      val m: Map[String, String] =
        Map("file_name" -> x.getName,
          "content_type" -> x.getContentType,
          "file_size" -> x.getSize.toString,
          "sha" -> sha,
          "store_kind" -> FileUtil.getFileStoreKind)

      FileParam(x, sha, m)
    }
  }

  private def extractFilesFromRequest: List[DiskFileItem] = {
    // Create a new file upload handler
    val fileUpload = new JakartaServletDiskFileUpload(newDiskFileItemFactory)
    fileUpload.setHeaderCharset(StandardCharsets.UTF_8)

    // Set overall request size constraint
    if (setting.maxUploadSize.isDefined) fileUpload.setSizeMax(setting.maxUploadSize.get)

    fileUpload.parseRequest(request).asScala.toList
  }

  private def newDiskFileItemFactory: DiskFileItemFactory = {
    val fileCleaningTracker = JakartaFileCleaner.getFileCleaningTracker(request.getServletContext)

    val repository = new File(setting.filesPath + "temp/")
    if (!repository.exists()) {
      repository.mkdirs()
    }

    DiskFileItemFactory.builder()
      .setBufferSize(DiskFileItemFactory.DEFAULT_THRESHOLD * 10)
      .setPath(repository.toPath)
      .setCharset(StandardCharsets.UTF_8)
      .setFileCleaningTracker(fileCleaningTracker)
      .get()
  }

  case class FileParam(fileItem: DiskFileItem, sha: String, properties: Map[String, String])
}