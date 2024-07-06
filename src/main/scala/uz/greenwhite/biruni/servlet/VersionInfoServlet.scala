package uz.greenwhite.biruni.servlet

import oracle.jdbc.{OracleCallableStatement, OracleTypes}
import uz.greenwhite.biruni.connection.DBConnection

import jakarta.servlet.http.{HttpServlet, HttpServletRequest, HttpServletResponse}

class VersionInfoServlet extends HttpServlet {
  private def getOracleVersion: String = {
    val conn = DBConnection.getSingletonConnection
    var cs: OracleCallableStatement = null

    try {
      cs = conn.prepareCall("BEGIN Biruni.Get_Version(?); END;").asInstanceOf[OracleCallableStatement]
      cs.registerOutParameter(1, OracleTypes.VARCHAR)
      cs.execute

      cs.getString(1)
    } catch {
      case _: Exception =>
        throw new RuntimeException("Biruni get oracle version failed.")
    } finally {
      if (cs != null) cs.close()
      conn.close()
    }
  }

  override def doGet(req: HttpServletRequest, resp: HttpServletResponse): Unit = {
    resp.getWriter.write(getOracleVersion)
  }
}
