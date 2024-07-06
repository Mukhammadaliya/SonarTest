package uz.greenwhite.biruni.service.runtimeservice

import org.json.JSONObject
import uz.greenwhite.biruni.http.TrustAllCerts
import uz.greenwhite.biruni.json.JSON

import java.io.OutputStream
import java.net.{HttpURLConnection, URI, URL}
import java.nio.charset.StandardCharsets
import javax.net.ssl.HttpsURLConnection
import scala.io.{Codec, Source}

class BillingIntegrationService extends RuntimeService {

  private val ACCESS_TOKEN_URI = "/api/auth/token"

  def getConnection(url: URL, method: String, headers: Map[String, String]): HttpURLConnection = {
    var conn: HttpURLConnection = null
    val protocol = url.getProtocol

    if ("https".equals(protocol)) {
      val trustAllCerts = new TrustAllCerts
      trustAllCerts.trust()
      conn = url.openConnection().asInstanceOf[HttpsURLConnection]
    } else if ("http".equals(protocol)) conn = url.openConnection().asInstanceOf[HttpURLConnection]

    conn.setRequestMethod(method)
    conn.setRequestProperty("Content-Type", "application/json; utf-8")
    conn.setConnectTimeout(5000)

    for ((key, value) <- headers) {
      conn.setRequestProperty(key, value)
    }

    conn
  }

  def getAccessToken(hostUrl: String, clientId: String, clientSecret: String, code: String): JSONObject = {
    val url = URI.create(hostUrl + ACCESS_TOKEN_URI).toURL
    val conn: HttpURLConnection = getConnection(url, "POST", Map.empty)
    conn.setDoOutput(true)

    val json: JSONObject = new JSONObject()
    json.put("grant_type", "code")
    json.put("client_id", clientId)
    json.put("client_secret", clientSecret)
    json.put("code", code)

    val out: OutputStream = conn.getOutputStream
    out.write(json.toString().getBytes(StandardCharsets.UTF_8))
    out.flush()
    out.close()

    if (conn.getResponseCode != 200)
      throw new RuntimeException(Source.fromInputStream(conn.getErrorStream)(Codec.UTF8).mkString)

    val result = new JSONObject(Source.fromInputStream(conn.getInputStream)(Codec.UTF8).mkString)

    conn.disconnect()

    result
  }

  def refreshAccessToken(hostUrl: String, clientId: String, clientSecret: String, refreshToken: String): JSONObject = {
    val url = URI.create(hostUrl + ACCESS_TOKEN_URI).toURL
    val conn: HttpURLConnection = getConnection(url, "POST", Map.empty)
    conn.setDoOutput(true)

    val json: JSONObject = new JSONObject()
    json.put("grant_type", "refresh_token")
    json.put("client_id", clientId)
    json.put("client_secret", clientSecret)
    json.put("refresh_token", refreshToken)

    val out: OutputStream = conn.getOutputStream
    out.write(json.toString().getBytes(StandardCharsets.UTF_8))
    out.flush()
    out.close()

    if (conn.getResponseCode != 200)
      throw new RuntimeException(Source.fromInputStream(conn.getErrorStream)(Codec.UTF8).mkString)

    val result = new JSONObject(Source.fromInputStream(conn.getInputStream)(Codec.UTF8).mkString)

    conn.disconnect()

    result
  }

  def getBillingConnection(url: URL, method: String, access_token: String, headers: Map[String, String], data: String): HttpURLConnection = {
    val conn = getConnection(url, method, headers)
    conn.setRequestProperty("Authorization", "Bearer " + access_token)
    conn.setDoOutput(true)

    val out: OutputStream = conn.getOutputStream
    out.write(data.getBytes(StandardCharsets.UTF_8))
    out.flush()
    out.close()

    conn
  }


  override def run(detail: Map[String, Any], data: String): RuntimeResult = {
    val hostUrl: String = detail.getOrElse("host_url", "").asInstanceOf[String]

    if (hostUrl.isEmpty)
      return ErrorRuntimeResult("Billing host url is not defined")

    val uri: String = detail.getOrElse("uri", "").asInstanceOf[String]

    if (uri.isEmpty)
      return ErrorRuntimeResult("Billing request uri is not defined")

    val credentials = detail.getOrElse("credentials", Map.empty).asInstanceOf[Map[String, String]]
    val clientId: String = credentials.getOrElse("client_id", "")
    val clientSecret: String = credentials.getOrElse("client_secret", "")
    val code: String = credentials.getOrElse("code", "")
    var accessToken: String = credentials.getOrElse("access_token", "")
    var refreshToken: String = credentials.getOrElse("refresh_token", "")

    if (clientId.isEmpty || clientSecret.isEmpty || code.isEmpty)
      return ErrorRuntimeResult("Billing credentials is not defined")

    var tokenUpdated: Boolean = false

    if (accessToken.isEmpty) {
      try {
        val tokens = getAccessToken(hostUrl, clientId, clientSecret, code)
        accessToken = tokens.getString("access_token")
        refreshToken = tokens.getString("refresh_token")
        tokenUpdated = true
      } catch {
        case ex: Exception => return ErrorRuntimeResult(ex.getMessage)
      }
    }

    val method = detail.getOrElse("method", "POST").asInstanceOf[String]
    val headers = detail.getOrElse("headers", Map.empty).asInstanceOf[Map[String, String]]

    var conn: HttpURLConnection = null

    try {
      val url = URI.create(hostUrl + uri).toURL
      conn = getBillingConnection(url, method, accessToken, headers, data)

      if (conn.getResponseCode == 401 && !tokenUpdated) {
        try {
          val tokens = refreshAccessToken(hostUrl, clientId, clientSecret, refreshToken)
          accessToken = tokens.getString("access_token")
          refreshToken = tokens.getString("refresh_token")
          tokenUpdated = true
        } catch {
          case ex: Exception => return ErrorRuntimeResult(ex.getMessage)
        }

        conn = getBillingConnection(url, method, accessToken, headers, data)
      }

      if (conn.getResponseCode != 200)
        throw new RuntimeException(Source.fromInputStream(conn.getErrorStream)(Codec.UTF8).mkString)

      val result = Source.fromInputStream(conn.getInputStream)(Codec.UTF8).mkString

      if (tokenUpdated) {
        val newCredentials = Map("access_token" -> accessToken, "refresh_token" -> refreshToken)
        SuccessRuntimeResult(JSON.stringify(newCredentials), result)
      } else SuccessRuntimeResult(result)
    } catch {
      case ex: Exception =>
        if (tokenUpdated) {
          val newCredentials = Map("access_token" -> accessToken, "refresh_token" -> refreshToken)
          ErrorRuntimeResult(JSON.stringify(newCredentials), ex.getMessage)
        } else ErrorRuntimeResult(ex.getMessage)
    }
    finally {
      if (conn != null) conn.disconnect()
    }
  }

}
