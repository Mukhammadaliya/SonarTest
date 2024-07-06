package uz.greenwhite.biruni.dev

import com.google.auth.oauth2.GoogleCredentials
import jakarta.servlet.http.HttpServletResponse._
import jakarta.servlet.http.{HttpServletRequest, HttpServletResponse}
import org.apache.commons.io.IOUtils
import uz.greenwhite.biruni.conf.SettingDev
import uz.greenwhite.biruni.fazo_sync.FazoSync
import uz.greenwhite.biruni.json.JSON

import java.io.{File, FileInputStream}
import java.net.{HttpURLConnection, URI, URLDecoder}
import java.nio.charset.StandardCharsets
import java.nio.file.{Files, Path, Paths, StandardCopyOption}
import javax.net.ssl.HttpsURLConnection
import scala.concurrent.{ExecutionContextExecutor, Future}
import scala.io.{Codec, Source}
import scala.util.control.NonFatal

case class ProjectHandler(request: HttpServletRequest, response: HttpServletResponse, devSetting: SettingDev) {
  val uri: String = URLDecoder.decode(request.getRequestURI.substring(request.getContextPath.length + request.getServletPath.length), StandardCharsets.UTF_8.name)

  private def sendOk(text: String): Unit = {
    response.setStatus(SC_OK)
    response.getWriter.println(text)
  }

  private def sendFile(path: Path, contentType: String): Unit = {
    var cType = contentType;
    if (request.getMethod.equals("GET")) {
      val ct = request.getParameter("ct")
      if (ct != null && ct.nonEmpty) cType = ct
    }
    response.setContentType(cType)
    val out = response.getOutputStream
    Files.copy(path, out)
    out.flush()
  }

  private def sendError(text: String, status: Int = SC_INTERNAL_SERVER_ERROR): Unit = {
    response.setStatus(status)
    response.getWriter.println(text)
  }

  def processFile(): Unit = try {
    request.getServletPath match {
      case "/devtrans" => processTranslate()
      case "/page" => loadPage()
      case "/dev" => processDev()
    }
  } catch {
    case NonFatal(ex) =>
      sendError(ex.getMessage)
      ex.printStackTrace()
  }

  private def processTranslate(): Unit = {
    val googleProjectNumber = devSetting.googleProjectNumber
    val googleServiceAccountKeyFilePath = devSetting.googleServiceAccountKeyFilePath
    val cloudTranslationScope = "https://www.googleapis.com/auth/cloud-translation"

    var conn: HttpsURLConnection = null
    try {
      response.setCharacterEncoding(Codec.UTF8.toString)

      val url = URI.create(s"https://translation.googleapis.com/v3/projects/$googleProjectNumber/locations/us-central1:translateText").toURL

      conn = url.openConnection().asInstanceOf[HttpsURLConnection]
      conn.setRequestMethod("POST")
      conn.setDoOutput(true)

      // retrieve credentials scoped for google cloud translations v3 and generate an auth 2.0 token
      val credentials = GoogleCredentials.fromStream(new FileInputStream(googleServiceAccountKeyFilePath))
                                         .createScoped(cloudTranslationScope)
      credentials.refreshIfExpired()
      val tokenValue = credentials.getAccessToken.getTokenValue

      conn.setRequestProperty("Authorization", s"Bearer $tokenValue")
      conn.setRequestProperty("Content-Type", "application/json; charset=utf-8")
      conn.setRequestProperty("x-goog-user-project", googleProjectNumber)

      IOUtils.copy(request.getInputStream, conn.getOutputStream)
      val status = conn.getResponseCode
      response.setStatus(status)

      if (status != HttpURLConnection.HTTP_OK) IOUtils.copy(conn.getErrorStream, response.getOutputStream)
      else IOUtils.copy(conn.getInputStream, response.getOutputStream)
    } catch {
      case NonFatal(ex) =>
        response.setStatus(500)
        response.getWriter.println(ex.getClass.getName + ":" + ex.getMessage)
    } finally {
      if (conn != null) conn.disconnect()
    }
  }

  private def processDev(): Unit = uri match {
    case x if x.startsWith("/open/") => openPageInEditor(x.substring(5))
    case x if x == "/fazo_diff" =>
      val txt = Source.fromInputStream(request.getInputStream)(Codec.UTF8).mkString
      FazoSync.run(txt, response)
    case _ =>
      parsedProjectUri(uri) match {
        case Right((projectCode, action, path)) => processProject(projectCode, action, path)
        case Left(error) => sendError(
          s"""
             |$error, possible values:
             |projectCode/open/path
             |projectCode/load/path
             |projectCode/save/path
             |projectCode/delete/path
             |projectCode/list
             |projectCode/exists/path
             |
             |possible project codes: ${devSetting.projectCodes.mkString(",")}
          """.
            stripMargin)
      }
  }


  private def parsedProjectUri(uri: String): Either[String, (String, String, String)] = {
    val REG = "^/([a-z]+)/([a-z]+)(/.*)$".r
    val possibleActions = Set("open", "load", "save", "delete", "list", "exists")
    uri match {
      case REG(projectCode, action, path) =>
        if (!possibleActions(action)) Left(s"$action is not a possible action key")
        else if (!devSetting.projectCodes(projectCode)) Left(s"$projectCode is not a possible project code")
        else if (action == "list" && path != "/") Left("path must be empty for 'list' action")
        else if (action != "list" && path.isEmpty) Left(s"path must not be empty for '$action' action")
        else Right((projectCode, action, path))
      case _ => Left("Invalid uri could not parse it")
    }
  }

  private def openPageInEditor(path: String): Unit = {
    val prefixMap = devSetting.projectFolders.toList.flatMap { f =>
      val p = Paths.get(f._2, "page", "form")
      p.toFile.listFiles().map(f => f.getName).map(_ -> f._2)
    }.toMap

    prefixMap.get(Paths.get(path).getName(1).toString) match {
      case Some(projectFolder) =>
        val p = Paths.get(projectFolder, "page", path)
        implicit val ec: ExecutionContextExecutor = scala.concurrent.ExecutionContext.global
        val f = Future {
          sys.process.Process(devSetting.editorPath, Seq(p.toString)).!
        }
        f.failed.foreach(ex => ex.printStackTrace())
        sendOk(s"send command to open: ${devSetting.editorPath} ${p.toString}")
      case None => sendError(s"open failed, path not found $path")
    }
  }

  private def processProject(projectCode: String, action: String, pathRelative: String): Unit = {
    val path = devSetting.getPath(projectCode, pathRelative).get

    action match {
      case "open" =>
        implicit val ec: ExecutionContextExecutor = scala.concurrent.ExecutionContext.global
        val f = Future {
          if (request.getRemoteAddr == request.getLocalAddr) {
            sys.process.Process(devSetting.editorPath, Seq(path.toString)).!
          }
        }
        f.failed.foreach(ex => ex.printStackTrace())
        sendOk(s"send command to open: ${devSetting.editorPath} ${path.toString}")

      case "load" if Files.exists(path) => sendFile(path, "text/plain")
      case "load" => sendError(s"file not found: $path", SC_NOT_FOUND)

      case "save" =>
        if (!Files.exists(path)) Files.createDirectories(path)
        Files.copy(request.getInputStream, path, StandardCopyOption.REPLACE_EXISTING)
        sendOk(s"saved to $path")

      case "delete" =>
        Files.delete(path)
        sendOk(s"deleted file $path")

      case "list" =>
        val root = path.toFile
        val s = root.getPath.length + 1
        val files = recursiveListFiles(root).filter(_.isFile)

        response.setContentType("application/json")
        response.getWriter.println(JSON.stringify(files.map(_.getPath.substring(s).replace('\\', '/'))))

      case "exists" =>
        if (!Files.exists(path)) sendError(s"file not found: $path", SC_NOT_FOUND)
        else sendOk(s"file exists: $path")

    }
  }

  private def recursiveListFiles(f: File): Array[File] = {
    val these = f.listFiles.filterNot(_.getPath.contains(".git"))
    these ++ these.filter(_.isDirectory).flatMap(recursiveListFiles)
  }

  private def loadPage(): Unit = {
    val found = devSetting.projectFolders
      .map(f => Paths.get(f._2, "page", uri))
      .filter(Files.exists(_))

    if (found.nonEmpty) sendFile(found.head, "text/html")
    else {
      val s = Paths.get(request.getServletContext.getRealPath("/page" + uri))
      if (Files.exists(s)) {
        response.setHeader("BiruniStaticPage", "Yes")
        sendFile(s, "text/html")
      } else {
        response.setStatus(HttpServletResponse.SC_NOT_FOUND)
      }
    }
  }
}
