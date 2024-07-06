import sbt.internal.util.ManagedLogger

import java.text.SimpleDateFormat
import java.time.{ZoneId, ZonedDateTime}
import java.util.Date
import java.util.concurrent.atomic.AtomicReference
import scala.sys.process.Process

name := "biruni"
organization := "uz.greenwhite"
organizationName := "Green White Solutions LLC."
version := "7.12.1"
scalaVersion := "2.12.18"
scalacOptions ++= Seq("-feature", "-release:21", "-deprecation")
Compile / scalacOptions ++= Seq("-Xlint", "-Ywarn-unused", "-Ywarn-unused-import")
publishMavenStyle := false

libraryDependencies ++= Seq(
  // Used for running the application in Tomcat. Used only development mode. Uncomment if you want to run the application by <<sbt Tomcat / start>> command
  //  "com.heroku" % "webapp-runner-main" % "10.1.20.0" intransitive(),

  // Tomcat 10.x build in libs
  "jakarta.servlet" % "jakarta.servlet-api" % "6.0.0" % "provided",
  "jakarta.websocket" % "jakarta.websocket-client-api" % "2.1.1" % "provided",
  "jakarta.websocket" % "jakarta.websocket-api" % "2.1.1" % "provided",
  "jakarta.annotation" % "jakarta.annotation-api" % "2.1.1" % "provided",

  // Used for Oracle database connection
  "com.oracle.database.jdbc" % "ojdbc11" % "21.13.0.0",
  "com.oracle.database.jdbc" % "ucp" % "21.13.0.0",

  // Used to read files from request and upload to server
  "org.apache.commons" % "commons-fileupload2-jakarta" % "2.0.0-M1",

  // Used for generating .xlsx reports
  "org.apache.poi" % "poi-ooxml" % "5.2.5" excludeAll(ExclusionRule("commons-io", "commons-io"), ExclusionRule("org.apache.commons", "commons-compress")),
  "org.apache.logging.log4j" % "log4j-core" % "2.23.1",
  "org.apache.commons" % "commons-compress" % "1.26.1",

  // Used for image processing
  "net.coobird" % "thumbnailator" % "0.4.20",

  // Used for Web Services
  "com.sun.xml.ws" % "jaxws-rt" % "4.0.2" exclude("jakarta.servlet", "jakarta.servlet-api"),
  "org.glassfish" % "jakarta.json" % "2.0.1",
  "org.eclipse.persistence" % "org.eclipse.persistence.moxy" % "4.0.2",

  // Used for HTTP requests
  "com.squareup.okhttp3" % "okhttp" % "5.0.0-alpha.11",

  // Used for QR Code and Barcode generation
  "com.google.zxing" % "javase" % "3.5.3",

  // Used for email sending
  "org.simplejavamail" % "simple-java-mail" % "8.10.1",

  // Used for JSON parsing
  "com.google.code.gson" % "gson" % "2.10.1",
  "org.json" % "json" % "20231013",

  // Used for google OAuth 2.0, TODO: Deprecated
  "com.google.auth" % "google-auth-library-oauth2-http" % "1.23.0",

  // S3 SDK for MinIO object storage
  "io.minio" % "minio" % "8.5.10" exclude("com.squareup.okhttp3", "okhttp"),

  // Used for user agent parsing
  "com.github.ua-parser" % "uap-java" % "1.6.1",

  // Used for JWT
  "com.auth0" % "java-jwt" % "4.4.0",

  // Used for encryption
  "org.bouncycastle" % "bcprov-jdk18on" % "1.78.1"
)

assemblyJarName := name.value + "-libs.jar"

assemblyMergeStrategy := {
  case x if Assembly.isConfigFile(x) => MergeStrategy.concat
  case PathList(ps@_*) if Assembly.isReadme(ps.last) || Assembly.isLicenseFile(ps.last) => MergeStrategy.rename
  case PathList("META-INF", xs@_*) =>
    xs map {
      _.toLowerCase
    } match {
      case "manifest.mf" :: Nil | "index.list" :: Nil | "dependencies" :: Nil => MergeStrategy.discard
      case ps@_ :: _ if ps.last.endsWith(".sf") || ps.last.endsWith(".dsa") => MergeStrategy.discard
      case "services" :: _ => MergeStrategy.filterDistinctLines
      case _ => MergeStrategy.first
    }
  case _ => MergeStrategy.first
}

lazy val buildDirectory = settingKey[File]("Directory where all build files show be located")

buildDirectory := target.value / "package"

Compile / packageBin / artifactPath := buildDirectory.value / "lib" / (artifact.value.name + "." + artifact.value.extension)

assemblyPackageDependency / assemblyOutputPath := buildDirectory.value / "lib" / assemblyJarName.value

lazy val build = taskKey[Unit]("build biruni")
lazy val start = taskKey[Unit]("tomcat start")
lazy val stop = taskKey[Unit]("tomcat stop")
lazy val Tomcat = config("tomcat").hide

lazy val tomcatInstance = settingKey[AtomicReference[Option[Process]]]("current container process")

tomcatInstance := new AtomicReference(None)

def stopProcess(l: ManagedLogger)(p: Process): Unit = {
  l.info("waiting for server to shut down...")
  p.destroy()
  val err = System.err
  val devNull: java.io.PrintStream =
    new java.io.PrintStream(
      (b: Int) => {}
    )
  System.setErr(devNull)
  p.exitValue()
  System.setErr(err)
}

def tomcatStop(log: ManagedLogger, atomicRef: AtomicReference[Option[Process]]): Unit = {
  val oldProcess = atomicRef.getAndSet(None)
  oldProcess.foreach(stopProcess(log))
}

Global / onLoad := (Global / onLoad).value andThen { state =>
  state.addExitHook(tomcatStop(state.log, tomcatInstance.value))
}

def launch = Def.task {
  val log = streams.value.log
  val instance = tomcatInstance.value
  log.info("starting server 127.0.0.1:9090")

  tomcatStop(log, instance)

  val libs: Seq[File] = Seq((Compile / packageBin / artifactPath).value) ++
    (Runtime / fullClasspath).value.map(_.data).filter(_.getName contains ".jar")

  val paths = Path.makeString(libs)

  val args = javaOptions.value ++
    Seq("-cp", paths) ++
    Seq("webapp.runner.launch.Main") ++
    Seq("--port", "9090") ++
    Seq((baseDirectory.value / "web").absolutePath)

  val process = new Fork("java", None).fork(ForkOptions(), args)
  instance.set(Some(process))
}

Tomcat / start := (launch dependsOn (Compile / packageBin)).value
Tomcat / stop := tomcatStop(streams.value.log, tomcatInstance.value)

def genBiruniJs(root: File): Unit = {
  val p = ".*'(.*js)'.*".r
  val targetDir = root / "biruni"
  var allLines = IO.readLines(targetDir / "main.js")
  var filteredLines = allLines.filterNot(_.contains("/*DEV*/"))

  allLines = allLines
    .collect { case p(jsFile) => jsFile }
    .map("app/" ++ _)

  filteredLines = filteredLines
    .collect { case p(jsFile) => jsFile }
    .map("app/" ++ _)

  val allJsFiles = (Seq("script-begin.js") ++ allLines ++ Seq("script-end.js")).map(targetDir / _)
  val filteredJsFiles = (Seq("script-begin.js") ++ filteredLines ++ Seq("script-end.js")).map(targetDir / _)

  def mergeFiles(files: Seq[File], to: File, excludeDev: Boolean = true): Unit = {
    for (f <- files) {
      if (f.toString.endsWith("biruni-template-loader.js")) {
        val allLines = IO.readLines(f)
        val filteredLines = if (excludeDev) allLines.filterNot(_.contains("/*DEV*/")) else allLines
        val q = ".*'(b-.*)'.*".r
        val lines = filteredLines.collect { case q(tmp) => tmp }
        IO.append(to, "biruni.run(function($templateCache) {[")
        for (line <- lines) {
          IO.append(to, "['" ++ line ++ ".html',`")
          IO.append(to, IO.read(targetDir / ("app/biruni/directives/" ++ line ++ "/" ++ line ++ ".html")).replace("`", "\\`"))
          IO.append(to, "`],")
        }
        IO.append(to, "].forEach(x=> $templateCache.put(x[0], x[1]));});")
      } else {
        IO.append(to, IO.readBytes(f))
      }
    }
  }

  mergeFiles(allJsFiles, targetDir / "main_dev.js", excludeDev = false)
  mergeFiles(filteredJsFiles, targetDir / "main_real.js")
  IO.delete(root / "biruni" / "app")
  IO.delete(targetDir / "main.js")
  IO.delete(targetDir / "script-begin.js")
  IO.delete(targetDir / "script-end.js")
}

def prepareHtml(root: File, file_name: String): Unit = {
  val version = "?_=" + new SimpleDateFormat("yyMMddHHmm").format(new Date())
  val lines = IO.readLines(root / (file_name + ".html")).map(_.replace("?_=now", version))

  IO.writeLines(root / (file_name + "_dev.html"), lines)
  IO.writeLines(root / (file_name + "_real.html"), lines.filterNot(line => line.contains("<!--DEV-->") || line.contains("/*DEV*/")))
  IO.delete(root / (file_name + ".html"))
}

def buildCommand = Def.task {
  val biruniJar = (Compile / packageBin).value
  val root = target.value / "build"

  IO.copyDirectory(baseDirectory.value / "web", root)

  IO.copyFile(biruniJar, root / "WEB-INF" / "lib" / (name.value + ".jar"))

  IO.delete(root / ".gitignore")
  IO.delete(root / "WEB-INF" / "web.xml")
  IO.delete(root / "WEB-INF" / "sun-jaxws.xml")

  genBiruniJs(root)
  prepareHtml(root, "index")
  prepareHtml(root, "login")

  val excludes = Set(root,
    root / "index_dev.html",
    root / "index_real.html",
    root / "login_dev.html",
    root / "login_real.html",
    root / "fazo_sync.html",
    root / "biruni" / "main_dev.js",
    root / "biruni" / "main_real.js",
    root / "biruni" / "sass-watcher.cmd",
    root / "biruni" / "main.scss",
    root / "WEB-INF" / "web-template-dev.xml",
    root / "WEB-INF" / "web-template-real.xml"
  )

  val fs = (root ** "*").get.filterNot(excludes)
    .map(x => (x, x.relativeTo(root).get.getPath))

  val fsDev = Seq(
    root / "index_dev.html" -> "index.html",
    root / "login_dev.html" -> "login.html",
    root / "fazo_sync.html" -> "fazo_sync.html",
    root / "biruni" / "main_dev.js" -> "biruni/main.js",
    root / "WEB-INF" / "web-template-dev.xml" -> "WEB-INF/web-template.xml"
  )

  val zonedDateTime = ZonedDateTime.now(ZoneId.systemDefault())
  val currentMilliSeconds = System.currentTimeMillis() + zonedDateTime.getOffset.getTotalSeconds * 1000

  IO.zip(fs ++ fsDev, buildDirectory.value / (name.value + "_dev.zip"), Option(currentMilliSeconds))
  IO.delete(root / "doc")

  val fsReal = Seq(
    root / "index_real.html" -> "index.html",
    root / "login_real.html" -> "login.html",
    root / "biruni" / "main_real.js" -> "biruni/main.js",
    root / "WEB-INF" / "web-template-real.xml" -> "WEB-INF/web-template.xml"
  )

  IO.zip(fs ++ fsReal, buildDirectory.value / (name.value + ".zip"), Option(currentMilliSeconds))
}

build := (buildCommand dependsOn clean).value
