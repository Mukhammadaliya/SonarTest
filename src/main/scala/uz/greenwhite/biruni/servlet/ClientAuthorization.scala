package uz.greenwhite.biruni.servlet

import oracle.jdbc.{OracleCallableStatement, OracleConnection, OracleType}
import org.json.JSONObject
import uz.greenwhite.biruni.connection.DBConnection

import java.net.HttpURLConnection
import java.nio.charset.StandardCharsets
import jakarta.servlet.http.{HttpServlet, HttpServletResponse}
import uz.greenwhite.biruni.route.OracleResult

abstract class ClientAuthorization extends HttpServlet {
  def setBadRequest(resp: HttpServletResponse): Unit = {
    resp.setStatus(HttpURLConnection.HTTP_BAD_REQUEST)
    resp.setCharacterEncoding(StandardCharsets.UTF_8.name)
    resp.setContentType("text/plain; charset=UTF-8")
    resp.getWriter.append("Bad request")
  }

  def setResponse(resp: HttpServletResponse, status: Int, errorText: String): Unit = {
    resp.setStatus(status)
    resp.setCharacterEncoding(StandardCharsets.UTF_8.name)
    resp.setContentType("application/json; charset=utf-8")
    resp.getWriter.append(errorText)
  }

  def prepareCallableStatement(conn: OracleConnection, query: String): OracleCallableStatement = {
    conn.prepareCall(query).asInstanceOf[OracleCallableStatement]
  }

  def getAccessToken(resp: HttpServletResponse, data: JSONObject): Unit

  def refreshAccessToken(resp: HttpServletResponse, data: JSONObject): Unit = {
    val query = "BEGIN Biruni_Auth.Refresh_Access_Token(?,?,?,?,?,?); END;"
    var conn: OracleConnection = null
    var cs: OracleCallableStatement = null

    try {
      conn = DBConnection.getPoolConnectionAndFreeResources
      cs = prepareCallableStatement(conn, query)

      cs.setString(1, data.getString("grant_type"))
      cs.setString(2, data.getString("refresh_token"))
      cs.setString(3, data.getString("client_id"))
      cs.setString(4, data.getString("client_secret"))

      cs.registerOutParameter(5, OracleType.VARCHAR2)
      cs.registerOutParameter(6, OracleType.VARCHAR2)
      cs.execute()

      val status = OracleResult.mapResponseStatus(cs.getString(5).charAt(0))
      setResponse(resp, status, cs.getString(6))
    } catch {
      case ex: Exception =>
        ex.printStackTrace()
        setBadRequest(resp)
    } finally {
      if (cs != null) cs.close()
      if (conn != null) conn.close()
    }
  }
}
