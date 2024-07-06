package uz.greenwhite.biruni.servlet

import uz.greenwhite.biruni.route.Route

import jakarta.servlet.ServletConfig
import jakarta.servlet.http.{HttpServlet, HttpServletRequest, HttpServletResponse}
import uz.greenwhite.biruni.conf.Setting

class OracleServlet extends HttpServlet {
  private var setting: Option[Setting] = None

  override def init(config: ServletConfig): Unit = {
    setting = Option(config.getServletContext.getAttribute("setting").asInstanceOf[Setting])
  }

  private def getSetting: Setting = {
    setting match {
      case Some(s) => s
      case None => throw new RuntimeException("Biruni setting is not found")
    }
  }

  override def doPost(request: HttpServletRequest, response: HttpServletResponse): Unit = {
    val route = Route(getSetting, request, response)
    route.dispatchPost()
  }

  override def doGet(request: HttpServletRequest, response: HttpServletResponse): Unit = {
    val route = Route(getSetting, request, response)
    route.dispatchGet()
  }
}