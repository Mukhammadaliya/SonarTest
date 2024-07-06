package uz.greenwhite.biruni.listener

import uz.greenwhite.biruni.connection.{ConnectionProperties, DBConnection}
import uz.greenwhite.biruni.s3.S3Client

import java.io.File
import java.nio.file.Paths
import java.util.Locale
import jakarta.servlet.{ServletContext, ServletContextEvent, ServletContextListener}

import scala.collection.JavaConverters._
import uz.greenwhite.biruni.conf.{Setting, SettingDev}
import uz.greenwhite.biruni.dev.DevUtil
import uz.greenwhite.biruni.property.ApplicationProperty
import uz.greenwhite.biruni.util.FileUtil

import scala.util.control.ControlThrowable

class MyContextListener extends ServletContextListener {
  override def contextInitialized(sce: ServletContextEvent): Unit = {
    Locale.setDefault(Locale.US)

    val context = sce.getServletContext

    try {
      val contextPath = context.getContextPath
      val settingPath = getSettingPath(context, contextPath)
      val property = loadProperty(settingPath, contextPath)

      var setting: Setting = Setting(
        contextPath = "",
        settingPath = property("settingPath").asInstanceOf[String],
        requestHeaderKeys = property("headerKeys").asInstanceOf[List[String]],
        requestCookieKeys = property("cookieKeys").asInstanceOf[List[String]],
        maxUploadSize = property("maxUploadSize").asInstanceOf[Option[Long]],
        filesPath = property("filesPath").asInstanceOf[String],
        dev = None)

      DBConnection.Init(new ConnectionProperties(
        property("url").asInstanceOf[String],
        property("username").asInstanceOf[String],
        property("password").asInstanceOf[String],
        property("inactiveConnectionTimeout").asInstanceOf[String],
        property("maxConnectionReuse").asInstanceOf[String],
        property("maxConnectionReuseTime").asInstanceOf[String],
        property("initialPoolSize").asInstanceOf[String],
        property("minPoolSize").asInstanceOf[String],
        property("maxPoolSize").asInstanceOf[String]))

      S3Client.Init(property("s3Endpoint").asInstanceOf[String],
        property("s3AccessKey").asInstanceOf[String],
        property("s3SecretKey").asInstanceOf[String],
        property("s3BucketName").asInstanceOf[String],
        property("s3LinkExpireTime").asInstanceOf[Int])

      ApplicationProperty.Init(property("applicationUrl").asInstanceOf[String],
        contextPath,
        property("onlyofficeUrl").asInstanceOf[String],
        property("onlyofficeKey").asInstanceOf[String])

      if (setting.filesPath.isEmpty)
        setting = setting.copy(filesPath = settingPath + File.separator + contextPath + File.separator + "files" + File.separator)

      ensureFolderExists(setting.filesPath)

      val projectFolders = {
        val projectCodes: Set[String] = DevUtil.loadProjectCodes()
        val projectsFolder = context.getInitParameter("projects_folder")

        if (projectsFolder != null) {
          DevUtil.readProjectFolders(projectsFolder)
            .filter(p => projectCodes.contains(p._1))
            .toSeq
        } else {
          // DEPRECATED
          val prefix = "project_folder:"
          context.getInitParameterNames.asScala
            .filter(_.startsWith(prefix))
            .filter(p => projectCodes.contains(p.substring(prefix.length)))
            .map(p => p.substring(prefix.length) -> context.getInitParameter(p))
            .toSeq
        }
      }

      val editorPath = Option(context.getInitParameter("editor_path")).filter(_.nonEmpty).getOrElse("notepad")
      val googleProjectNumber = Option(context.getInitParameter("google_project_number")).filter(_.nonEmpty).getOrElse("")
      val googleServiceAccountKeyFilePath = Option(context.getInitParameter("google_service_account_key_file_path")).filter(_.nonEmpty).getOrElse("")

      val dev = SettingDev(editorPath, projectFolders, googleProjectNumber, googleServiceAccountKeyFilePath)
      setting = setting.copy(contextPath = contextPath, dev = Option(dev))

      printSetting(setting)
      context.setAttribute("setting", setting)
    } catch {
      case ex: ControlThrowable => throw ex
      case ex: Throwable =>
        context.setAttribute("setting_error", ex)
        throw ex
    }
  }

  override def contextDestroyed(sce: ServletContextEvent): Unit = {}

  private def printSetting(s: Setting): Unit = {
    println("*" * 70)
    println(s"Context path:${s.contextPath}")
    println(s"Setting path:${s.settingPath}")
    println(s"Files path  :${s.filesPath}")

    if (s.dev.isDefined) {
      println(s"Editor path :${s.dev.get.editorPath}")
      println
      println("Project folders")
      s.dev.get.projectFolders.foreach(f => println(f"${f._1}%-12s:${f._2}"))
    }

    println("*" * 70)
  }

  private def ensureFolderExists(path: String): Unit = {
    val pathF = new File(path)
    if (!pathF.exists) pathF.mkdirs()
  }

  private def getSettingPath(context: ServletContext, contextPath: String): String = {
    if ((contextPath eq null) || contextPath.isEmpty) {
      Paths.get(context.getRealPath("/")).getParent.toString
    } else {
      var s = Option(context.getInitParameter("setting_path")).filter(_.nonEmpty).getOrElse("~/biruni")
      s = if (s.startsWith("~")) System.getProperty("user.home") + s.substring(1) else s
      ensureFolderExists(s)
      s
    }
  }

  private def loadProperty(settingPath: String, contextPath: String): Map[String, Any] = {
    val f = new File(settingPath, contextPath + ".properties")
    if (f.exists) loadProperty(f) else loadProperty(createSettingFile(f))
  }

  private def loadProperty(file: File): Map[String, Any] = {
    val prop = new java.util.Properties()
    prop.load(new java.io.FileInputStream(file))

    def k(key: String): String = Option(prop.getProperty(key)).getOrElse("")

    Map(
      "settingPath" -> file.getAbsolutePath,
      "headerKeys" -> k("request_header_keys").split(";").toList.filter(_.nonEmpty),
      "cookieKeys" -> k("request_cookie_keys").split(";").toList.filter(_.nonEmpty),
      "maxUploadSize" -> Option(k("max_upload_size")).filter(_.trim.nonEmpty).map(_.toLong),
      "filesPath" -> formatFolderPath(k("files_path")),
      "url" -> k("db.url"),
      "username" -> k("db.username"),
      "password" -> k("db.password"),
      "inactiveConnectionTimeout" -> k("db.inactiveConnectionTimeout"),
      "maxConnectionReuse" -> k("db.maxConnectionReuse"),
      "maxConnectionReuseTime" -> k("db.maxConnectionReuseTime"),
      "initialPoolSize" -> k("db.initialPoolSize"),
      "minPoolSize" -> k("db.minPoolSize"),
      "maxPoolSize" -> k("db.maxPoolSize"),
      "s3Endpoint" -> k("s3.endpoint"),
      "s3AccessKey" -> k("s3.access_key"),
      "s3SecretKey" -> k("s3.secret_key"),
      "s3BucketName" -> k("s3.bucket_name"),
      "s3LinkExpireTime" -> Option(k("s3.link_expire_time")).filter(_.trim.nonEmpty).map(_.toInt).getOrElse(24),
      "applicationUrl" -> k("application.url"),
      "onlyofficeUrl" -> k("onlyoffice.url"),
      "onlyofficeKey" -> k("onlyoffice.secret")
    )
  }

  private def formatFolderPath(path: String): String =
    if (path.isEmpty || path.endsWith("/")) path
    else path + "/"

  private def createSettingFile(file: File): File = {
    val in = getClass.getResourceAsStream("/setting.properties")
    val out = new java.io.FileOutputStream(file)
    FileUtil.pipe(in, out)
    file
  }
}