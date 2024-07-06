package uz.greenwhite.biruni.dev

import jakarta.servlet.ServletConfig
import jakarta.servlet.http.{HttpServlet, HttpServletRequest, HttpServletResponse}
import uz.greenwhite.biruni.conf.Setting

class ProjectManager extends HttpServlet {
  private var setting: Option[Setting] = None

  override def init(config: ServletConfig): Unit = setting = Option(config.getServletContext.getAttribute("setting").asInstanceOf[Setting])

  override def doGet(request: HttpServletRequest, response: HttpServletResponse): Unit = doPost(request, response)

  override def doPost(request: HttpServletRequest, response: HttpServletResponse): Unit = {
    setting match {
      case Some(s) if s.dev.isDefined => ProjectHandler(request, response, s.dev.get).processFile()
      case _ =>
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR)
        response.getWriter.println("Dev setting is not defined in web.xml")
    }
  }
}
