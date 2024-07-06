package uz.greenwhite.biruni.servlet

import org.json.JSONObject
import uz.greenwhite.biruni.json.JSON
import uz.greenwhite.biruni.service.EimzoService

import java.net.{HttpURLConnection, MalformedURLException, URI, URL}
import java.util.Base64
import java.util.regex.{Matcher, Pattern}
import jakarta.servlet.http.{HttpServlet, HttpServletRequest, HttpServletResponse}
import jakarta.servlet.{ServletConfig, ServletContext}
import uz.greenwhite.biruni.route.OracleHeader
import uz.yt.eimzo.dsv.server.plugin.pkcs7.v1.{Pkcs7, Pkcs7Service}

import scala.io.Source

class EimzoServlet extends HttpServlet {
  private var context: ServletContext = _

  override def init(config: ServletConfig): Unit = {
    context = config.getServletContext
  }

  private def wsdlURL(): URL = {
    try {
      URI.create(context.getInitParameter("wsdl_pkcs7")).toURL
    } catch {
      case ex: MalformedURLException => throw new RuntimeException(ex)
    }
  }

  private def verifySign(signVal: String): String = {
    try {
      val pkcs7: Pkcs7 = new Pkcs7Service(wsdlURL()).getPkcs7Port()
      pkcs7.verifyPkcs7(signVal)
    } catch {
      case _: Exception => throw new Exception("signature verification error")
    }
  }

  private def getUriLastPart(uri: String): String = {
    uri.split("/").last
  }

  private def getRequestInput(req: HttpServletRequest): JSONObject = {
    new JSONObject(Source.fromInputStream(req.getInputStream).mkString)
  }

  override def doPost(req: HttpServletRequest, resp: HttpServletResponse): Unit = {
    try {
      getUriLastPart(req.getRequestURI) match {
        case "sign" =>
          val sessionVal = req.getSession().getAttribute(OracleHeader.SESSION_NAME).asInstanceOf[String]
          val filialId = req.getHeader("filial_id").toInt

          if ("".equals(sessionVal)) throw new Exception("session not defined")

          val obj: JSONObject = getRequestInput(req)
          val applicationId = obj.getString("application_id").toInt
          val applicantSign = obj.getString("applicant_sign")
          val applicantSignObj = new JSONObject(verifySign(applicantSign))

          val pkcs7Info = applicantSignObj.getJSONObject("pkcs7Info")
          val documentBase64 = pkcs7Info.getString("documentBase64")
          val signer = pkcs7Info.getJSONArray("signers").getJSONObject(0)
          val certificate = signer.getJSONArray("certificate").getJSONObject(0)
          val subjectName = certificate.getString("subjectName")

          val pattern: Pattern = Pattern.compile(".*UID=([0-9]+),.*")
          val matcher: Matcher = pattern.matcher(subjectName)
          matcher.find()
          val tin: String = matcher.group(1)

          val applicantSignInfo = Map.newBuilder[String, Any]
          applicantSignInfo += "document" -> new String(Base64.getDecoder.decode(documentBase64))
          applicantSignInfo += "tin" -> tin

          val es = new EimzoService(sessionVal, filialId, applicationId, applicantSign, JSON.stringify(applicantSignInfo.result))
          es.sign()
        case "verify" =>
          val obj: JSONObject = getRequestInput(req)
          val applicantSign = obj.get("applicant_sign").asInstanceOf[String]
          verifySign(applicantSign)
        case _ => throw new Exception("action not found")
      }
    } catch {
      case ex: Exception =>
        resp.setStatus(HttpURLConnection.HTTP_BAD_REQUEST)
        resp.setCharacterEncoding("UTF-8")
        resp.setContentType("text/plain;charset=UTF-8")
        resp.getWriter.append(ex.getMessage)
    }
  }
}
