package uz.greenwhite.biruni.util

import jakarta.servlet.http.HttpServletRequest
import uz.greenwhite.biruni.json.JSON

import scala.collection.JavaConverters._
import scala.io.{Codec, Source}

object ServletUtil {
  def isFormUrlEncoded(request: HttpServletRequest): Boolean = {
    val contentType = Option(request.getHeader("Content-Type")).getOrElse("")
    contentType.contains("x-www-form-urlencoded")
  }

  def getRequestParameters(request: HttpServletRequest): Map[String, Any] = {
    request.getParameterMap.asScala.toMap
  }

  def inputStreamToString(inputStream: java.io.InputStream): String = {
    Source.fromInputStream(inputStream)(Codec.UTF8).mkString
  }

  def readRequestInputStream(request: HttpServletRequest): String = {
    inputStreamToString(request.getInputStream)
  }

  def getRequestInput(request: HttpServletRequest): String = {
    if (isFormUrlEncoded(request) || request.getMethod.equals("GET")) JSON.stringify(getRequestParameters(request))
    else readRequestInputStream(request)
  }
}
