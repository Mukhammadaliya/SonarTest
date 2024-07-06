package uz.greenwhite.biruni.route

import jakarta.servlet.http.{Cookie, HttpServletRequest, HttpServletResponse}
import uz.greenwhite.biruni._
import uz.greenwhite.biruni.conf.Setting
import uz.greenwhite.biruni.filemanager.{FazoFile, FileManager, ServletFileUploadEntity}
import uz.greenwhite.biruni.service.QlikService
import uz.greenwhite.biruni.service.finalservice.FinalService
import uz.greenwhite.biruni.util.{FileUtil, ServletUtil}

import java.net.URLDecoder
import java.nio.charset.StandardCharsets
import scala.io.Codec

case class Route(setting: Setting,
                 request: HttpServletRequest,
                 response: HttpServletResponse) {
  private val header = OracleHeader.extractHeaderFromRequest(request, setting.requestHeaderKeys, setting.requestCookieKeys)
  private val db = new OracleRoute()

  //  private val escaper: Escaper = Escapers.builder
  //    .addEscape('<', "&lt;")
  //    .addEscape('>', "&gt;")
  //    .build

  private def evalResult(result: OracleResult): Unit = {
    if (result.session.isDefined) {
      val session = request.getSession(true)
      session.setAttribute(OracleHeader.SESSION_NAME, result.session.get)

      val qlikSession = Option(session.getAttribute(QlikService.QLIK_SESSION_NAME).asInstanceOf[String])
      if (qlikSession.isDefined) {
        val sessionLoggedOut = QlikService.logoutCheckSession(qlikSession.get, result.session.get)
        if (sessionLoggedOut) session.removeAttribute(QlikService.QLIK_SESSION_NAME)
      }
    }

    response.setStatus(result.status)
    response.setCharacterEncoding(Codec.UTF8.toString)
    result.headers foreach {
      case (k, v) => response.setHeader(k, v)
    }

    result.cookies foreach {
      case (k, v) =>
        val cookie = new Cookie(k, v("value"))
        cookie.setSecure(true)
        cookie.setHttpOnly(true)
        cookie.setMaxAge(v("max_age").toInt)
        cookie.setPath(v("path"))
        response.addCookie(cookie)
    }

    val output = result.output // escaper.escape(result.output)

    // no need to escape
    if (result.isActionFile) Provider.sendFile(setting.filesPath, FazoFile.parse(result.output), response)
    // need to escape
    else if (result.isActionReport) Provider.buildReport(output, response, request.getContextPath)
    // need to escape
    else if (result.isActionRedirect) response.getWriter.write(output)
    // no need to escape
    else if (result.isActionEasyReport) Provider.buildEasyReport(result.output, request, response)
    // need to escape
    else if (result.isActionLazyReport) Provider.makeLazyReport(response, output, request.getContextPath, request.getSession().getAttribute(OracleHeader.SESSION_NAME).asInstanceOf[String])
    // not need to escape
    else if (result.isActionExternalService) Provider.requestExternalService(result.output, response)
    // not need to escape
    else if (result.isActionOnlyoffice) Provider.runOnlyoffice(result.output, request, response)
    // need to escape
    else response.getWriter.write(output)

    for {
      m <- result.finalServices
    } FinalService.run(request, m)
  }

  def dispatchPost(): Unit = {
    val biruniUpload = request.getHeader("BiruniUpload")

    if (biruniUpload == null) run()
    else runFileUpload(biruniUpload)
  }

  def dispatchGet(): Unit = run()

  private def run(): Unit = {
    val input = ServletUtil.getRequestInput(request)
    val result = db.execute(header, input)
    evalResult(result)
  }

  private def runFileUpload(bu: String): Unit = bu match {
    case "param" => runFileUploadParam(new ServletFileUploadEntity(request, setting))
    case "easy_report" => runFileUploadEasyReport(new ServletFileUploadEntity(request, setting))
    case "excel" => runFileUploadExcel(new ServletFileUploadEntity(request, setting))
    case "alone" => runFileUploadAlone()
    case _ => throw new RuntimeException(s"$bu upload type is not found")
  }

  private def runFileUploadParam(fileUploadEntity: ServletFileUploadEntity): Unit = {
    val result = db.execute(header.copy(files = fileUploadEntity.getFiles.map(_.properties)), fileUploadEntity.getParam)
    if (result.isSuccess) fileUploadEntity.uploadFiles()
    evalResult(result)
  }

  private def runFileUploadEasyReport(fileUploadEntity: ServletFileUploadEntity): Unit = {
    val result = db.execute(header.copy(files = fileUploadEntity.getFiles.map(_.properties)), fileUploadEntity.getParam)

    if (result.isSuccess) {
      for (fileParam <- fileUploadEntity.getFiles) {
        try {
          val templateData = Provider.readEasyReportMetadata(fileParam.fileItem.getInputStream)
          db.uploadEasyReportMetadata(fileParam.sha, templateData)
          fileUploadEntity.uploadFile(fileParam)
        } catch {
          case e: Exception =>
            db.clearEasyReportTemplate(fileParam.sha)
            throw new RuntimeException(e.getMessage)
        }
      }
    }

    evalResult(result)
  }

  private def runFileUploadExcel(fileUploadEntity: ServletFileUploadEntity): Unit = {
    try {
      var customParam = fileUploadEntity.getParam

      fileUploadEntity.getFiles.foreach(fileParam => {
        val excelBook = Provider.readExcelBook(fileParam.fileItem.getInputStream)
        customParam = customParam.replace("\"" + fileParam.sha + "\"", excelBook.toString)
      })


      val result = db.execute(header, customParam)
      evalResult(result)
    } finally {
      fileUploadEntity.deleteFiles()
    }
  }

  private def runFileUploadAlone(): Unit = {
    val data = FileUtil.readInputStream(request.getInputStream)

    if (setting.maxUploadSize.isDefined && setting.maxUploadSize.get < data.length)
      throw new RuntimeException(s"the request was rejected because its size (${data.length}) exceeds the configured maximum (${setting.maxUploadSize.get})")

    val sha = FileUtil.calcSHA(data)
    val m: Map[String, String] =
      Map("file_name" -> Option[String](URLDecoder.decode(request.getHeader("filename"), StandardCharsets.UTF_8)).getOrElse(""),
        "content_type" -> Option[String](request.getContentType).getOrElse(""),
        "file_size" -> data.length.toString,
        "sha" -> sha,
        "store_kind" -> FileUtil.getFileStoreKind)

    val result = db.execute(header.copy(files = Seq(m)), sha)

    if (result.isSuccess) FileManager.uploadFileEntity(data, m("content_type"), sha)

    evalResult(result)
  }
}
