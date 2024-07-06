package uz.greenwhite.biruni.route

import uz.greenwhite.biruni.service.finalservice.FinalServiceData

import java.net.HttpURLConnection

case class OracleResult(status: Int,
                        output: String,
                        headers: Map[String, String],
                        cookies: Map[String, Map[String, String]],
                        session: Option[String],
                        action: String,
                        finalServices: Seq[FinalServiceData]) {
  require(output != null)

  val isSuccess: Boolean = status < 300

  val isActionFile: Boolean = action.equals("file")
  val isActionReport: Boolean = action.equals("report")
  val isActionRedirect: Boolean = action.equals("redirect")
  val isActionEasyReport: Boolean = action.equals("easy_report")
  val isActionLazyReport: Boolean = action.equals("lazy_report")
  val isActionExternalService: Boolean = action.equals("external_service")
  val isActionOnlyoffice: Boolean = action.equals("onlyoffice")
}

object OracleResult {
  def mapResponseStatus(status: Char): Int =
    status match {
      case 'S' => 200
      case 'E' => 400
      case 'U' => 401
      case 'P' => 402
      case 'R' => 403
      case 'N' => 404
      case 'C' => 409
      case 'T' => 429
      case 'F' => 500
    }

  def buildErrorResult(status: Int, output: String): OracleResult = {
    OracleResult(
      status = status,
      output = output,
      headers = Map.empty,
      cookies = Map.empty,
      session = None,
      action = "none",
      finalServices = Seq.empty)
  }

  def buildInternalErrorResult(output: String): OracleResult = {
    buildErrorResult(HttpURLConnection.HTTP_INTERNAL_ERROR, output)
  }
}
