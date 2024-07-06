package uz.greenwhite.biruni.servlet

import jakarta.servlet.http.{HttpServlet, HttpServletRequest, HttpServletResponse}
import uz.greenwhite.biruni.route.OracleHeader

class SessionInfo extends HttpServlet {
  override def doGet(request: HttpServletRequest, response: HttpServletResponse): Unit = {
    val session = request.getSession(false)

    if (session != null && Option(session.getAttribute(OracleHeader.SESSION_NAME).asInstanceOf[String]).getOrElse("") != "") {
      response.getWriter.println(Integer.toString(session.getMaxInactiveInterval))
    }
  }
}
