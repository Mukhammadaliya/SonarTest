package uz.greenwhite.biruni.servlet

import oracle.jdbc.{OracleCallableStatement, OracleTypes}
import org.json.JSONObject
import uz.greenwhite.biruni.connection.DBConnection
import uz.greenwhite.biruni.json.JSON
import uz.greenwhite.biruni.service.QlikService

import java.net.HttpURLConnection
import java.nio.charset.StandardCharsets
import java.util.UUID
import javax.net.ssl.HttpsURLConnection
import jakarta.servlet.http.{Cookie, HttpServlet, HttpServletRequest, HttpServletResponse, HttpSession}
import uz.greenwhite.biruni.route.OracleHeader

import scala.io.Source

class QlikSessionServlet extends HttpServlet {
  private val QLIK_NO_LICENSE = "QLIK_ERROR_NO_LICENSE"
  private val QLIK_COOKIE_SECURE = "N"

  private def isEmpty(x: String): Boolean = x == null || x.isEmpty

  private def setBadRequest(errortext: String, resp: HttpServletResponse): Unit = {
    resp.setStatus(HttpURLConnection.HTTP_BAD_REQUEST)
    resp.setCharacterEncoding(StandardCharsets.UTF_8.name)
    resp.setContentType("text/plain; charset=UTF-8")
    resp.getWriter.append(errortext)
  }

  private def loadQlikData(sessionVal: String, projectCode: String, filialId: Int): Map[String, String] = {
    var conn = DBConnection.getPoolConnection
    var cs: OracleCallableStatement = null

    try {
      cs = conn.prepareCall("BEGIN Biruni_Qlik.Load_Qlik_Data(?,?,?,?,?); END;").asInstanceOf[OracleCallableStatement]
      cs.setString(1, sessionVal)
      cs.setString(2, projectCode)
      cs.setInt(3, filialId)
      cs.registerOutParameter(4, OracleTypes.VARCHAR)
      cs.registerOutParameter(5, OracleTypes.VARCHAR)
      cs.execute()

      val status = QlikService.mapResponseStatus(cs.getString(4))
      val output = cs.getString(5)

      if (status != HttpURLConnection.HTTP_OK) throw new Exception(output)

      JSON.parseForce(output).asInstanceOf[Map[String, String]]
    } finally {
      if (cs != null) cs.close()
      conn.close()
      conn = null
    }
  }

  private def validateSession(sessionUUID: String): Unit = {
    var conn = DBConnection.getPoolConnection
    var cs: OracleCallableStatement = null

    try {
      cs = conn.prepareCall("BEGIN Biruni_Qlik.Validate_Qlik_Session(?,?,?); END;").asInstanceOf[OracleCallableStatement]
      cs.setString(1, sessionUUID)
      cs.registerOutParameter(2, OracleTypes.VARCHAR)
      cs.registerOutParameter(3, OracleTypes.VARCHAR)
      cs.execute()

      val status = QlikService.mapResponseStatus(cs.getString(2))
      val output = cs.getString(3)

      if (status != HttpURLConnection.HTTP_OK) throw new Exception(output)
    } catch {
      case ex: Exception =>
        ex.printStackTrace()
    } finally {
      if (cs != null) cs.close()
      conn.close()
      conn = null
    }
  }

  private def saveQlikSession(sessionVal: String, sessionUUID: String): Unit = {
    var conn = DBConnection.getPoolConnection
    var cs: OracleCallableStatement = null

    try {
      cs = conn.prepareCall("BEGIN Biruni_Qlik.Open_Qlik_Session(?,?,?,?); END;").asInstanceOf[OracleCallableStatement]
      cs.setString(1, sessionUUID)
      cs.setString(2, sessionVal)
      cs.registerOutParameter(3, OracleTypes.VARCHAR)
      cs.registerOutParameter(4, OracleTypes.VARCHAR)
      cs.execute()

      val status = QlikService.mapResponseStatus(cs.getString(3))
      val output = cs.getString(4)

      if (status != HttpURLConnection.HTTP_OK) throw new Exception(output)
    } catch {
      case ex: Exception =>
        ex.printStackTrace()
        throw new Exception("couldn't save qlik session error")
    } finally {
      if (cs != null) cs.close()
      conn.close()
      conn = null
    }
  }

  private def setQlikSession(session: HttpSession, sessionUUID: String): Unit = {
    session.setAttribute(QlikService.QLIK_SESSION_NAME, sessionUUID)
  }

  private def setResponseCookie(sessionUUID: String,
                                cookieName: String,
                                cookieDomain: String,
                                cookieSecure: Boolean,
                                resp: HttpServletResponse): Unit = {
    val cookie = new Cookie(cookieName, sessionUUID)
    cookie.setPath("/")
    cookie.setHttpOnly(true)
    cookie.setSecure(cookieSecure)
    if (!isEmpty(cookieDomain)) cookie.setDomain(cookieDomain)
    resp.addCookie(cookie)
  }

  private def isActiveSession(sessionUUID: String,
                              sessionRoute: String,
                              clientCertSha: String,
                              rootCertSha: String,
                              certificatePassword: String): Boolean = {
    var conn: HttpsURLConnection = null

    try {
      val url = sessionRoute + "/" + sessionUUID
      val requestMethod = "GET"

      conn = QlikService.getConnection(url, requestMethod, clientCertSha, rootCertSha, certificatePassword)

      val status = conn.getResponseCode

      status == HttpURLConnection.HTTP_OK
    } finally {
      if (conn != null) conn.disconnect()
    }
  }

  private def addQlikSession(userId: String,
                             userDirectory: String,
                             cookieName: String,
                             cookieDomain: String,
                             cookieSecure: Boolean,
                             qlikRoute: String,
                             clientCertSha: String,
                             rootCertSha: String,
                             certificatePassword: String,
                             session: HttpSession,
                             resp: HttpServletResponse): Unit = {
    var conn: HttpsURLConnection = null

    try {
      val sessionVal = session.getAttribute(OracleHeader.SESSION_NAME).asInstanceOf[String]
      val sessionUUID = UUID.randomUUID().toString

      saveQlikSession(sessionVal, sessionUUID)

      val requestMethod = "POST"
      val qlikData: JSONObject = new JSONObject

      qlikData.put("UserDirectory", userDirectory)
      qlikData.put("UserId", userId)
      qlikData.put("SessionId", sessionUUID)

      conn = QlikService.getConnection(qlikRoute, requestMethod, clientCertSha, rootCertSha, certificatePassword)
      conn.setRequestProperty("Content-Length", qlikData.toString.length.toString)

      val out = conn.getOutputStream
      out.write(qlikData.toString.getBytes(StandardCharsets.UTF_8))
      out.flush()
      out.close()

      val status = conn.getResponseCode

      if (status == HttpURLConnection.HTTP_CREATED) {
        setResponseCookie(sessionUUID, cookieName, cookieDomain, cookieSecure, resp)
        setQlikSession(session, sessionUUID)
        validateSession(sessionUUID)
      } else {
        if (conn.getErrorStream != null) {
          throw new Exception(Source.fromInputStream(conn.getErrorStream)(StandardCharsets.UTF_8).mkString)
        } else {
          throw new Exception("Qlik response error code = " + status)
        }
      }
    } finally {
      if (conn != null) conn.disconnect()
    }
  }

  override def doPost(req: HttpServletRequest, resp: HttpServletResponse): Unit = {
    try {
      val session = req.getSession(false)

      if (session == null) throw new Exception("No session found")

      val sessionVal = session.getAttribute(OracleHeader.SESSION_NAME).asInstanceOf[String]

      val requestData = JSON.parseForce(Source.fromInputStream(req.getInputStream)(StandardCharsets.UTF_8).mkString)

      val projectCode = requestData.getOrElse("project_code", "").asInstanceOf[String]
      val filialId = requestData.getOrElse("filial_id", "").asInstanceOf[String].toInt

      val qlikData = loadQlikData(sessionVal, projectCode, filialId)

      val sessionUUID = session.getAttribute(QlikService.QLIK_SESSION_NAME).asInstanceOf[String]

      val userId = qlikData.getOrElse("user_id", "")
      val userDirectory = qlikData.getOrElse("user_directory", "")

      val qlikRoute = qlikData.getOrElse("qlik_route", "")

      val clientCertSha = qlikData.getOrElse("client_cert_sha", "")
      val rootCertSha = qlikData.getOrElse("root_cert_sha", "")
      val certificatePassword = qlikData.getOrElse("certificate_password", "")

      val cookieName = qlikData.getOrElse("cookie_name", "")
      val cookieDomain = qlikData.getOrElse("cookie_domain", "")
      val cookieSecure = qlikData.getOrElse("cookie_secure", QLIK_COOKIE_SECURE) == "Y"

      if (isEmpty(userId)) throw new Exception(QLIK_NO_LICENSE)
      if (isEmpty(userDirectory)) throw new Exception(QLIK_NO_LICENSE)

      if (isEmpty(qlikRoute)) throw new Exception("provide qlikRoute")
      if (isEmpty(clientCertSha)) throw new Exception("provide clientCertSha")
      if (isEmpty(rootCertSha)) throw new Exception("provide rootCertSha")
      if (isEmpty(certificatePassword)) throw new Exception("provide certificatePassword")

      if (isEmpty(cookieName)) throw new Exception("provide cookieName")

      if (!isEmpty(sessionUUID) && isActiveSession(sessionUUID, qlikRoute, clientCertSha, rootCertSha, certificatePassword)) {
        setResponseCookie(sessionUUID, cookieName, cookieDomain, cookieSecure, resp)
      } else {
        addQlikSession(userId,
          userDirectory,
          cookieName,
          cookieDomain,
          cookieSecure,
          qlikRoute,
          clientCertSha,
          rootCertSha,
          certificatePassword,
          session,
          resp)
      }

      resp.setStatus(HttpURLConnection.HTTP_OK)
    } catch {
      case ex: Exception =>
        ex.printStackTrace()
        setBadRequest(ex.getMessage, resp)
    }
  }
}