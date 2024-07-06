package uz.greenwhite.biruni.servlet

import oracle.jdbc.{OracleCallableStatement, OracleConnection, OracleType}
import org.json.JSONObject
import uz.greenwhite.biruni.connection.DBConnection

import java.nio.charset.StandardCharsets
import java.util.Base64
import java.util.regex.Pattern
import jakarta.servlet.http.{HttpServletRequest, HttpServletResponse}
import uz.greenwhite.biruni.route.OracleResult

import scala.io.{Codec, Source}

class Oauth2ClientServer extends ClientAuthorization {

  private def checkRequest(req: HttpServletRequest, resp: HttpServletResponse): Boolean = {
    val query = "BEGIN Biruni_Auth.Oauth2_Check_Request(?, ?, ?, ?, ?); END;"
    var conn: OracleConnection = null
    var cs: OracleCallableStatement = null

    try {
      conn = DBConnection.getPoolConnectionAndFreeResources
      cs = prepareCallableStatement(conn, query)

      cs.setString(1, req.getParameter("response_type"))
      cs.setString(2, req.getParameter("client_id"))
      cs.setString(3, req.getParameter("scope"))

      cs.registerOutParameter(4, OracleType.VARCHAR2)
      cs.registerOutParameter(5, OracleType.VARCHAR2)
      cs.execute()

      val status = OracleResult.mapResponseStatus(cs.getString(4).charAt(0))

      if (status != 200) {
        setResponse(resp, status, cs.getString(5))
        false
      } else true
    } catch {
      case ex: Exception =>
        ex.printStackTrace()
        setBadRequest(resp)
        false
    } finally {
      if (cs != null) cs.close()
      if (conn != null) conn.close()
    }
  }

  private def getAuthCode(req: HttpServletRequest, resp: HttpServletResponse): Unit = {
    val query = "BEGIN Biruni_Auth.Generate_Oauth2_Code(?,?,?,?,?,?,?,?); END;"
    var conn: OracleConnection = null
    var cs: OracleCallableStatement = null

    try {
      conn = DBConnection.getPoolConnectionAndFreeResources
      cs = prepareCallableStatement(conn, query)

      val m = Pattern.compile("^Basic (.+$)").matcher(req.getHeader("Authorization"))
      m.lookingAt()
      val credentials = new String(Base64.getDecoder.decode(m.group(1)), StandardCharsets.UTF_8)

      cs.setString(1, req.getParameter("response_type"))
      cs.setString(2, req.getParameter("client_id"))
      cs.setString(3, credentials)
      cs.setString(4, req.getParameter("redirect_url"))
      cs.setString(5, req.getParameter("scope"))
      cs.setString(6, req.getParameter("state"))

      cs.registerOutParameter(7, OracleType.VARCHAR2)
      cs.registerOutParameter(8, OracleType.VARCHAR2)
      cs.execute()

      val status = OracleResult.mapResponseStatus(cs.getString(7).charAt(0))
      setResponse(resp, status, cs.getString(8))
    } catch {
      case ex: Exception =>
        ex.printStackTrace()
        setBadRequest(resp)
    } finally {
      if (cs != null) cs.close()
      if (conn != null) conn.close()
    }
  }

  override def getAccessToken(resp: HttpServletResponse, data: JSONObject): Unit = {
    val query = "BEGIN Biruni_Auth.Generate_Oauth2_Access_Token(?,?,?,?,?,?,?); END;"
    var conn: OracleConnection = null
    var cs: OracleCallableStatement = null

    try {
      conn = DBConnection.getPoolConnectionAndFreeResources
      cs = prepareCallableStatement(conn, query)

      cs.setString(1, data.getString("grant_type"))
      cs.setString(2, data.getString("auth_code"))
      cs.setString(3, data.getString("client_id"))
      cs.setString(4, data.getString("client_secret"))
      cs.setString(5, data.getString("redirect_url"))

      cs.registerOutParameter(6, OracleType.VARCHAR2)
      cs.registerOutParameter(7, OracleType.VARCHAR2)
      cs.execute()

      val status = OracleResult.mapResponseStatus(cs.getString(6).charAt(0))
      setResponse(resp, status, cs.getString(7))
    } catch {
      case ex: Exception =>
        ex.printStackTrace()
        setBadRequest(resp)
    } finally {
      if (cs != null) cs.close()
      if (conn != null) conn.close()
    }
  }

  override def doPost(req: HttpServletRequest, resp: HttpServletResponse): Unit = {
    val uri: String = req.getRequestURI

    if (uri.endsWith("authorize")) {
      getAuthCode(req, resp)
    } else if (uri.endsWith("token")) {
      try {
        val data = new JSONObject(Source.fromInputStream(req.getInputStream)(Codec.UTF8).mkString)

        data.getString("grant_type") match {
          case "authorization_code" => getAccessToken(resp, data)
          case "refresh_token" => refreshAccessToken(resp, data)
          case _ => setResponse(resp, 400, "unsupported_grant_type")
        }
      } catch {
        case ex: Exception =>
          ex.printStackTrace()
          setBadRequest(resp)
      }
    }
  }

  override def doGet(req: HttpServletRequest, resp: HttpServletResponse): Unit = {
    if (req.getRequestURI.endsWith("authorize")) {
      if (checkRequest(req, resp))
        resp.sendRedirect(req.getContextPath + "/login_oauth2.html?" + req.getQueryString)
    }
  }
}