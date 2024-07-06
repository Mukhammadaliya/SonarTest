package uz.greenwhite.biruni.service.finalservice

import oracle.jdbc.OracleCallableStatement
import uz.greenwhite.biruni.connection.DBConnection

import jakarta.servlet.http.HttpServletRequest
import scala.collection.mutable

trait FinalService {
  def run(request: HttpServletRequest, data: Seq[Any]): Unit
}

object FinalService {
  private val classes: mutable.Map[String, Class[FinalService]] = collection.mutable.Map[String, Class[FinalService]]()

  private def getService(className: String): FinalService = {
    if (!classes.contains(className)) {
      try {
        val clazz = Class.forName(className).asInstanceOf[Class[FinalService]]

        classes += (className -> clazz)

        clazz.getDeclaredConstructor().newInstance()
      } catch {
        case _: Exception => throw new Exception(s"class is not defined $className")
      }
    } else classes(className).getDeclaredConstructor().newInstance()
  }

  private def saveLog(errorMessage: String): Unit = {
    var conn = DBConnection.getPoolConnection
    var cs: OracleCallableStatement = null

    try {
      val query = "BEGIN Biruni_Service.Save_Final_Service_Log(?); COMMIT; END;"
      cs = conn.prepareCall(query).asInstanceOf[OracleCallableStatement]

      cs.setString(1, errorMessage.slice(0, 500))
      cs.execute
    } catch {
      case ex: Exception => println(ex.getMessage)
    } finally {
      if (cs != null) cs.close()
      conn.close()
      conn = null
    }
  }

  def run(request: HttpServletRequest, finalServiceData: FinalServiceData): Unit = {
    try {
      if (finalServiceData.className.isEmpty) throw new Exception("class name is required")

      val service = getService(finalServiceData.className)

      service.run(request, finalServiceData.data)
    } catch {
      case ex: Exception => saveLog(ex.getMessage)
    }
  }
}
