package uz.greenwhite.biruni.servlet

import oracle.jdbc.{OracleCallableStatement, OracleConnection, OracleTypes}
import org.json.{JSONObject, JSONTokener}
import uz.greenwhite.biruni.connection.DBConnection
import uz.greenwhite.biruni.crypto.RandomStringGenerator
import uz.greenwhite.biruni.json.JSON

import java.io.{IOException, InputStream, OutputStream}
import java.net.{HttpURLConnection, MalformedURLException, URI, URL, URLEncoder}
import java.nio.charset.StandardCharsets
import java.util.Base64
import javax.net.ssl.HttpsURLConnection
import jakarta.servlet.http.{HttpServlet, HttpServletRequest, HttpServletResponse}
import jakarta.servlet.{ServletConfig, ServletContext}
import uz.greenwhite.biruni.route.OracleHeader
import uz.yt.eimzo.dsv.server.plugin.pkcs7.v1.{Pkcs7, Pkcs7Service}

class Oauth2Token extends HttpServlet {
  private var context: ServletContext = _
  private var headers: List[String] = _
  private val C_ONEID: String = "oneid"
  private val C_EIMZO: String = "eimzo"

  override def init(config: ServletConfig): Unit = {
    context = config.getServletContext
    headers = config.getInitParameter("oauth2_headers").split(";").toList.filter(_.nonEmpty)
  }

  private def base64Decoder(auth: String): String = {
    try {
      new String(Base64.getDecoder.decode(auth), "UTF-8")
    } catch {
      case ex: Exception => ex.printStackTrace()
        ""
    }
  }

  private def wsdlURL(): URL = {
    try {
       URI.create(context.getInitParameter("wsdl_pkcs7")).toURL
    } catch {
      case ex: MalformedURLException => throw new RuntimeException(ex)
    }
  }

  private def verifySign(signVal: String): String = {
    try {
      val pkcs7: Pkcs7 = new Pkcs7Service(wsdlURL()).getPkcs7Port()
      pkcs7.verifyPkcs7(signVal)
    } catch {
      case _: Exception => throw new Exception("signature verification error")
    }
  }

  private def getStatement(conn: OracleConnection, query: String): OracleCallableStatement = {
    conn.prepareCall(query).asInstanceOf[OracleCallableStatement]
  }

  private def serverInfo(code: String): Map[String, Any] = {
    var conn: OracleConnection = null
    var cs: OracleCallableStatement = null

    try {
      conn = DBConnection.getPoolConnectionAndFreeResources
      cs = getStatement(conn, "BEGIN Biruni_Auth.Oauth2_Server_Info(?,?); commit; END;")

      cs.setString(1, code)
      cs.registerOutParameter(2, OracleTypes.VARCHAR)
      cs.execute

      JSON.parseForce(cs.getString(2)).asInstanceOf[Map[String, String]]
    } catch {
      case _: Exception => Map[String, Any]()
    } finally {
      if (cs != null) cs.close()
      if (conn != null) conn.close()
    }
  }

  private def applyInfo(code: String, request_param: String, data: String): Map[String, Any] = {
    var conn: OracleConnection = null
    var cs: OracleCallableStatement = null

    try {
      conn = DBConnection.getPoolConnectionAndFreeResources
      cs = getStatement(conn, "BEGIN Biruni_Auth.Oauth2_Apply_Info(?,?,?,?); commit; END;")

      cs.setString(1, code)
      cs.setString(2, request_param)
      cs.setString(3, data)

      cs.registerOutParameter(4, OracleTypes.VARCHAR)

      cs.execute
      val ss = cs.getString(4)

      JSON.parseForce(ss).asInstanceOf[Map[String, String]]
    } catch {
      case ex: Exception => throw new RuntimeException(ex.getMessage)
    } finally {
      if (cs != null) cs.close()
      if (conn != null) conn.close()
    }
  }

  private def encode(value: String): String = {
    if (value == null || "".equals(value.trim())) return ""
    try {
      URLEncoder.encode(value, "UTF-8")
    } catch {
      case _: Exception => ""
    }
  }

  private def makeParam(param: Map[String, Any]): String = {
    param.toList.map {
      case (k, v) => encode(k) + "=" + encode(v.toString)
    }.mkString("&")
  }

  private def getHttpConnection(url: URL): HttpURLConnection = {
    val protocol = url.getProtocol.toLowerCase()
    var conn: HttpURLConnection = null

    try {
      if ("http".equals(protocol))
        conn = url.openConnection().asInstanceOf[HttpURLConnection]
      else if ("https".equals(protocol))
        conn = url.openConnection().asInstanceOf[HttpsURLConnection]

      if (conn != null) {
        conn.setDoInput(true)
        conn.setDoOutput(true)
        conn.setRequestMethod("POST")
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded")
      }
    } catch {
      case ex: Exception => throw new RuntimeException(ex.getMessage)
    }

    conn
  }

  private def httpRequest(requestUrl: String, paramMap: Map[String, Any]): String = {
    var conn: HttpURLConnection = null
    var reader: InputStream = null
    var writer: OutputStream = null
    try {
      val url = URI.create(requestUrl).toURL
      val param = makeParam(paramMap)

      conn = getHttpConnection(url)
      writer = conn.getOutputStream
      writer.write(param.getBytes(StandardCharsets.UTF_8))
      writer.flush()

      try {
        reader = conn.getInputStream
      } catch {
        case _: IOException => reader = conn.getErrorStream
      }
      val br = new java.io.BufferedReader(new java.io.InputStreamReader(reader, StandardCharsets.UTF_8))
      br.readLine()
    } catch {
      case _: Exception => ""
    } finally {
      if (conn != null) conn.disconnect()
      if (reader != null) reader.close()
      if (writer != null) writer.close()
    }
  }

  private def prepareRequestHeader(request: HttpServletRequest, reqHeaders: Map[String, String], sessionVal: String): String = {
    val r = Map.newBuilder[String, Any]

    r += "context_path" -> request.getContextPath

    Option(request.getRemoteAddr) foreach {
      r += "ip_address" -> _
    }

    Option(request.getRemoteHost) foreach {
      r += "host_name" -> _
    }

    Option(request.getRemoteUser) foreach {
      r += "host_user" -> _
    }

    r += "session" -> sessionVal

    r += "headers" -> reqHeaders

    JSON.stringify(r.result)
  }

  private def windowCloseScript(response: HttpServletResponse): Unit = {
    response.getWriter.println("<script> window.close(); </script>")
  }

  private def doOneId(request: HttpServletRequest, response: HttpServletResponse): Unit = {
    val info = serverInfo(C_ONEID)
    val authorize_url = info.getOrElse("authorize_url", "").asInstanceOf[String]
    val client_id = info.getOrElse("client_id", "").asInstanceOf[String]
    val client_secret = info.getOrElse("client_secret", "").asInstanceOf[String]
    val scope = info.getOrElse("scope", "").asInstanceOf[String]

    if (authorize_url.isEmpty || client_id.isEmpty || client_secret.isEmpty || scope.isEmpty) {
      windowCloseScript(response)
      return
    }

    var param = Map[String, Any]()

    param += ("grant_type" -> "one_authorization_code")
    param += ("client_id" -> client_id)
    param += ("client_secret" -> client_secret)
    param += ("code" -> request.getParameter("code"))

    val stateMap = JSON.parseForce(base64Decoder(request.getParameter("state"))).asInstanceOf[Map[String, String]]

    try {
      val resultData = new JSONObject(httpRequest(authorize_url, param))
      val access_token = resultData.getString("access_token")

      param = Map[String, Any]()

      param += ("grant_type" -> "one_access_token_identify")
      param += ("client_id" -> client_id)
      param += ("client_secret" -> client_secret)
      param += ("access_token" -> access_token)
      param += ("scope" -> scope)

      val data = httpRequest(authorize_url, param)

      val reqHeaders = (for {
        key <- headers
        value <- Option(stateMap.get(key).map(_.asInstanceOf[String]).getOrElse(""))
      } yield key -> value).toMap

      var session = request.getSession(false)
      var sessionVal = {
        if (session != null) Option(session.getAttribute(OracleHeader.SESSION_NAME).asInstanceOf[String]).getOrElse("")
        else ""
      }

      val res = applyInfo(C_ONEID, prepareRequestHeader(request, reqHeaders, sessionVal), data)

      val status = res("status").asInstanceOf[String].charAt(0)
      if (status == 'S') {
        sessionVal = res("session").asInstanceOf[String]

        if (sessionVal != null) {
          if (session == null) session = request.getSession(true)
          session.setAttribute(OracleHeader.SESSION_NAME, sessionVal)
        } else if (session != null) session.setAttribute(OracleHeader.SESSION_NAME, "")
      } else if (session != null) session.setAttribute(OracleHeader.SESSION_NAME, "")

      response.sendRedirect(res("redirect_url").asInstanceOf[String])
    } catch {
      case _: Exception =>
        windowCloseScript(response)
    }
  }

  private def doESI(request: HttpServletRequest, response: HttpServletResponse): Unit = {
    val eimzoguid = "EIMZOGUID"
    try {
      val tokener = new JSONTokener(request.getInputStream)
      val data = new JSONObject(tokener)

      data.getString("action") match {
        case "generate_guid" =>
          val session = request.getSession(true)
          val guid = RandomStringGenerator.generate(15)

          session.setAttribute(eimzoguid, guid)

          response.getWriter.append(guid)
        case "authenticate" =>
          val guid = request.getSession.getAttribute(eimzoguid).asInstanceOf[String]

          if (guid.isEmpty) throw new Exception("guid is empty")

          val sign = data.getString("sign")
          val verify = new JSONObject(verifySign(sign))

          if (!verify.getBoolean("success")) throw new Exception("verified sign is not success")

          val pkcs7Info = verify.getJSONObject("pkcs7Info")

          if (!guid.equals(new String(Base64.getDecoder.decode(pkcs7Info.getString("documentBase64"))))) throw new Exception("guids are not equal")

          val signer = pkcs7Info.getJSONArray("signers").getJSONObject(0)

          if (!signer.getBoolean("verified")) throw new Exception(s"signer is not verified: ${signer.getString("exception")}")
          if (!signer.getBoolean("certificateVerified")) throw new Exception(s"certificate is not verified: ${signer.getString("exception")}")

          val certificate = signer.getJSONArray("certificate").getJSONObject(0)
          val subjectName = certificate.getString("subjectName")

          val reqHeaders = (for {
            key <- headers
            value <- Option(request.getParameter(key)).orElse(None)
          } yield key -> value).toMap

          var session = request.getSession(false)
          var sessionVal = {
            if (session != null) Option(session.getAttribute(OracleHeader.SESSION_NAME).asInstanceOf[String]).getOrElse("")
            else ""
          }

          val res = applyInfo(C_EIMZO, prepareRequestHeader(request, reqHeaders, sessionVal), subjectName)

          val status = res("status").asInstanceOf[String].charAt(0)
          if (status == 'S') {
            sessionVal = res("session").asInstanceOf[String]

            if (sessionVal != null) {
              if (session == null) session = request.getSession(true)
              session.setAttribute(OracleHeader.SESSION_NAME, sessionVal)
            } else if (session != null) session.setAttribute(OracleHeader.SESSION_NAME, "")
          } else if (session != null) session.setAttribute(OracleHeader.SESSION_NAME, "")

          response.getWriter.append(res("redirect_url").asInstanceOf[String])
        case _ => throw new Exception("action not found")
      }
    } catch {
      case ex: Exception =>
        response.setStatus(HttpURLConnection.HTTP_BAD_REQUEST)
        response.setCharacterEncoding("UTF-8")
        response.setContentType("text/plain;charset=UTF-8")
        response.getWriter.append(ex.toString)
    }
  }

  override def doGet(req: HttpServletRequest, resp: HttpServletResponse): Unit = {
    if (req.getRequestURI.endsWith(C_ONEID)) {
      doOneId(req, resp)
    }
  }

  override def doPost(req: HttpServletRequest, resp: HttpServletResponse): Unit = {
    if (req.getRequestURI.endsWith(C_EIMZO)) {
      doESI(req, resp)
    }
  }
}
