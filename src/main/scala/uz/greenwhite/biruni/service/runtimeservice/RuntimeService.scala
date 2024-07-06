package uz.greenwhite.biruni.service.runtimeservice

import scala.collection.mutable

trait RuntimeService {
  def run(detail: Map[String, Any], data: String): RuntimeResult
}

object RuntimeService {
  private val classes: mutable.Map[String, Class[RuntimeService]] = collection.mutable.Map[String, Class[RuntimeService]]()

  private def getService(className: String): RuntimeService = {
    if (!classes.contains(className)) {
      try {
        val clazz = Class.forName(className).asInstanceOf[Class[RuntimeService]]

        classes += (className -> clazz)

        clazz.getDeclaredConstructor().newInstance()
      } catch {
        case _: Exception => new DefaultRuntimeService(className)
      }
    } else classes(className).getDeclaredConstructor().newInstance()
  }

  def run(className: String, detail: Map[String, Any], data: String): RuntimeResult = {
    try {
      if (className.isEmpty) throw new Exception("class name is required")

      val service = getService(className)

      service.run(detail, data)
    } catch {
      case ex: Exception => ErrorRuntimeResult(output = ex.getMessage)
    }
  }
}
