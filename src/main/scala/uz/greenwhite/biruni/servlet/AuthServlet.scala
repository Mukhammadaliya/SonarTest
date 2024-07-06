package uz.greenwhite.biruni.servlet

import jakarta.servlet.ServletConfig
import jakarta.servlet.http.{HttpServletRequest, HttpServletResponse}
import okhttp3.FormBody
import org.json.JSONObject
import uz.greenwhite.biruni.http
import uz.greenwhite.biruni.logger.ExceptionLogger

class AuthServlet extends OracleServlet {
  private var recaptchaVerifyUrl: Option[String] = None
  private var recaptchaKey: Option[String] = None
  private var recaptchaSecret: Option[String] = None
  private var checkRecaptcha: Boolean = false

  override def init(config: ServletConfig): Unit = {
    super.init(config)
    recaptchaVerifyUrl = Option(config.getInitParameter("recaptcha_verify_url"))
    recaptchaKey = Option(config.getInitParameter("recaptcha_key"))
    recaptchaSecret = Option(config.getInitParameter("recaptcha_secret"))
    checkRecaptcha = recaptchaVerifyUrl.isDefined && recaptchaVerifyUrl.get.nonEmpty &&
      recaptchaKey.isDefined && recaptchaKey.get.nonEmpty &&
      recaptchaSecret.isDefined && recaptchaSecret.get.nonEmpty
  }

  private def unauthorized(response: HttpServletResponse, message: String): Boolean = {
    response.setStatus(401)
    response.getWriter.write(message)
    false
  }

  private def verifyCaptcha(request: HttpServletRequest, response: HttpServletResponse): Boolean = {
    if (!checkRecaptcha) return return true // Recaptcha is not configured

    val token = request.getHeader("G-Recaptcha-Response")

    if (token == null) return unauthorized(response, "reCaptcha token is not found") // Recaptcha token is not found

    try {
      val ipAddress = {
        val xForwardedFor = request.getHeader("X-Forwarded-For")

        if (xForwardedFor != null && xForwardedFor.nonEmpty) xForwardedFor.split(",").head.trim
        else request.getRemoteAddr
      }

      val client = http.OkHttp3.getUnsafeOkHttpClient
      val body = new FormBody.Builder().add("secret", recaptchaSecret.get).add("response", token).add("remoteip", ipAddress).build()
      val recaptchaRequest = new okhttp3.Request.Builder().url(recaptchaVerifyUrl.get).method("POST", body).build()
      val recaptchaResponse = client.newCall(recaptchaRequest).execute()
      val json = new JSONObject(recaptchaResponse.body().string())

      if (json.getBoolean("success") || json.getFloat("score") > 0.5) return true
    } catch {
      case e: Exception =>
        ExceptionLogger.saveException(this.getClass.getName, e)
    }

    unauthorized(response, "reCaptcha verification failed")
  }

  override def doPost(request: HttpServletRequest, response: HttpServletResponse): Unit = {
    if (verifyCaptcha(request, response))
      super.doPost(request, response)
  }

  override def doGet(request: HttpServletRequest, response: HttpServletResponse): Unit = {
    if (request.getRequestURI.equals("/recaptcha_key")) {
      response.getWriter.write(recaptchaKey.getOrElse(""))
    } else {
      if (verifyCaptcha(request, response))
        super.doGet(request, response)
    }
  }
}