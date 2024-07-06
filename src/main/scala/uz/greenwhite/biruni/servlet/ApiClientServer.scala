package uz.greenwhite.biruni.servlet

import oracle.jdbc.{OracleCallableStatement, OracleConnection}
import org.json.JSONObject
import uz.greenwhite.biruni.connection.DBConnection
import jakarta.servlet.http.{HttpServletRequest, HttpServletResponse}
import uz.greenwhite.biruni.route.OracleResult

import scala.io.{Codec, Source}

class ApiClientServer extends ClientAuthorization {

  override def getAccessToken(resp: HttpServletResponse, data: JSONObject): Unit = {
    val query = "BEGIN Biruni_Auth.Generate_Api_Access_Token(?,?,?,?,?,?); END;"
    var conn: OracleConnection = null
    var cs: OracleCallableStatement = null

    try {
      conn = DBConnection.getPoolConnectionAndFreeResources
      cs = prepareCallableStatement(conn, query)

      val grantType = data.getString("grant_type")
      val credentials = {
        if (grantType.equals("password")) data.getString("username") + ":" + data.getString("password")
        else data.getString("code")
      }

      cs.setString(1, grantType)
      cs.setString(2, credentials)
      cs.setString(3, data.getString("client_id"))
      cs.setString(4, data.getString("client_secret"))

      cs.registerOutParameter(5, oracle.jdbc.OracleType.VARCHAR2)
      cs.registerOutParameter(6, oracle.jdbc.OracleType.VARCHAR2)
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

  override def doPost(req: HttpServletRequest, resp: HttpServletResponse): Unit = {
    try {
      val data = new JSONObject(Source.fromInputStream(req.getInputStream)(Codec.UTF8).mkString)

      data.getString("grant_type") match {
        case "code" | "password" => getAccessToken(resp, data)
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
