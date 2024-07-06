package uz.greenwhite.biruni.listener

import oracle.jdbc.{OracleCallableStatement, OracleConnection}
import uz.greenwhite.biruni.connection.DBConnection
import uz.greenwhite.biruni.service.QlikService
import jakarta.servlet.http.{HttpSessionEvent, HttpSessionListener}
import uz.greenwhite.biruni.route.OracleHeader

class SessionControlListener extends HttpSessionListener {
  private def logout(sessionVal: String): Unit = {
    val query = "BEGIN Biruni_Auth.Close_Session(?); END;"
    var conn: OracleConnection = null
    var cs: OracleCallableStatement = null

    try {
      conn = DBConnection.getSingletonConnection
      cs = conn.prepareCall(query).asInstanceOf[OracleCallableStatement]
      cs.setString(1, sessionVal)
      cs.execute()
    } finally {
      if (cs != null) cs.close()
      if (conn != null) conn.close()
    }
  }

  override def sessionDestroyed(se: HttpSessionEvent): Unit = {
    try {
      val session = se.getSession
      val sessionVal = Option(session.getAttribute(OracleHeader.SESSION_NAME).asInstanceOf[String])
      val qlikSession = Option(session.getAttribute(QlikService.QLIK_SESSION_NAME).asInstanceOf[String])

      if (sessionVal.isDefined) logout(sessionVal.get)
      if (qlikSession.isDefined) QlikService.logoutSession(qlikSession.get)
    } catch {
      case ex: Exception => throw new RuntimeException("An error occurred while closing an inactive session. Error message: " + ex.getMessage)
    }
  }
}