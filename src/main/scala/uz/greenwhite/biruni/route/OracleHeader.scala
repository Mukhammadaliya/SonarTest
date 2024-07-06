package uz.greenwhite.biruni.route

import jakarta.servlet.http.HttpServletRequest
import ua_parser.Parser
import uz.greenwhite.biruni.json.JSON

import java.nio.charset.StandardCharsets
import java.util.Base64

case class OracleHeader(uri: String,
                        session: String,
                        method: String,
                        url: String,
                        authorization: Map[String, String],
                        contextPath: String,
                        servletPath: String,
                        ipAddress: Option[String],
                        hostName: Option[String],
                        userAgent: Map[String, String],
                        hostUser: Option[String],
                        headers: Map[String, String],
                        cookies: Map[String, String],
                        files: Seq[Map[String, String]]) {
  def asJson: String = {
    val r = Map.newBuilder[String, Any]

    r += "uri" -> uri
    r += "session" -> session
    r += "method" -> method
    r += "url" -> url
    r += "authorization" -> authorization
    r += "context_path" -> contextPath
    r += "servlet_path" -> servletPath

    ipAddress foreach {
      r += "ip_address" -> _
    }

    hostName foreach {
      r += "host_name" -> _
    }

    hostUser foreach {
      r += "host_user" -> _
    }

    r += "user_agent" -> userAgent

    r += "headers" -> headers

    r += "cookies" -> cookies

    r += "files" -> files

    JSON.stringify(r.result)
  }
}

object OracleHeader {
  val SESSION_NAME = "SESSION"

  def extractHeaderFromRequest(request: HttpServletRequest,
                               headerKeys: List[String],
                               cookieKeys: List[String],
                               customUri: String = null): OracleHeader = {
    val uri = {
      if (customUri == null) {
        val k = request.getContextPath.length + 2 // +2 for / /b
        request.getRequestURI.substring(k)
      } else customUri
    }

    val url = {
      val port = {
        val p = request.getServerPort
        if (p == 80 || p == 443) "" else ":" + p
      }

      request.getScheme + "://" + request.getServerName + port + request.getContextPath + request.getServletPath
    }

    val session = request.getSession(false)
    val sessionVal = {
      if (session != null) Option(session.getAttribute(SESSION_NAME).asInstanceOf[String]).getOrElse("")
      else ""
    }

    def takeFromGet(key: String): Option[String] = {
      if ("GET".equals(request.getMethod)) Option(request.getParameter("-" + key))
      else None
    }

    val headers = for {
      key <- headerKeys
      value <- Option(request.getHeader(key)).orElse(takeFromGet(key))
    } yield key -> value

    val cookies = for {
      key <- cookieKeys
      value <- Option(request.getCookies).map(_.find(_.getName == key).map(_.getValue)).getOrElse(Option.empty[String])
    } yield key -> value

    val ipAddress: Option[String] = {
      val xForwardedFor = request.getHeader("X-Forwarded-For")

      if (xForwardedFor != null && xForwardedFor.nonEmpty)
        Option(xForwardedFor.split(",").head.trim)
      else
        Option(request.getRemoteAddr)
    }

    OracleHeader(
      uri = uri,
      session = sessionVal,
      method = request.getMethod,
      url = url,
      authorization = getAuthorization(request),
      contextPath = request.getContextPath,
      servletPath = request.getServletPath,
      ipAddress = ipAddress,
      hostName = Option(request.getRemoteHost),
      hostUser = Option(request.getRemoteUser),
      userAgent = getUserAgentDetails(request),
      headers = headers.toMap,
      cookies = cookies.toMap,
      files = List.empty)
  }

  private def getAuthorization(request: HttpServletRequest): Map[String, String] = {
    try {
      val arr = request.getHeader("Authorization").split(" ")
      val authorizationType = arr.head

      authorizationType match {
        case "Basic" =>
          val credentials = new String(Base64.getDecoder.decode(arr(1)), StandardCharsets.UTF_8)
          Map("type" -> authorizationType, "credentials" -> credentials)
        case "Bearer" => Map("type" -> authorizationType, "token" -> arr(1))
        case _ => Map()
      }
    } catch {
      case _: Exception => Map()
    }
  }

  private def getUserAgentDetails(request: HttpServletRequest): Map[String, String] = {
    try {
      val userAgentHeader = request.getHeader("User-Agent")

      if (userAgentHeader == null || userAgentHeader.isEmpty) return Map("user_agent" -> "Unknown", "os" -> "Unknown", "device" -> "Unknown")

      val client = new Parser().parse(userAgentHeader)

      val userAgent: String = {
        var s = client.userAgent.family
        if (s == null || s.isEmpty) s = "Unknown"
        if (client.userAgent.major != null) s += " " + client.userAgent.major
        if (client.userAgent.minor != null) s += "." + client.userAgent.minor
        if (client.userAgent.patch != null) s += "." + client.userAgent.patch
        s
      }

      val os: String = {
        var s = client.os.family
        if (s == null || s.isEmpty) s = "Unknown"
        if (client.os.major != null) s += " " + client.os.major
        if (client.os.minor != null) s += "." + client.os.minor
        if (client.os.minor != null) s += "." + client.os.patch
        s
      }

      val device: String = {
        val s = client.device.family
        if (s == null || s.isEmpty) "Unknown"
        else s
      }

      Map("user_agent" -> userAgent, "os" -> os, "device" -> device)
    } catch {
      case _: Exception => Map("user_agent" -> "Unknown", "os" -> "Unknown", "device" -> "Unknown")
    }
  }
}