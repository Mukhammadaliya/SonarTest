package uz.greenwhite.biruni.jobs

import org.json.JSONObject
import uz.greenwhite.biruni.http.TrustAllCerts

import java.net.{HttpURLConnection, URI}
import javax.net.ssl.HttpsURLConnection

class TelegramPushMessageJobProvider extends JobProvider {
  private def send(botUrl: String, messages: String): Unit = {
    val url = URI.create(botUrl + "/t").toURL
    val protocol = url.getProtocol
    var conn: HttpURLConnection = null

    try {
      if ("https".equals(protocol)) {
        val trustAllCerts = new TrustAllCerts
        trustAllCerts.trust()
        conn = url.openConnection().asInstanceOf[HttpsURLConnection]
      } else if ("http".equals(protocol)) conn = url.openConnection().asInstanceOf[HttpURLConnection]

      conn.setRequestMethod("POST")
      conn.setRequestProperty("Content-Type", "application/json")
      conn.setDoOutput(true)
      conn.setConnectTimeout(5000)

      conn.getOutputStream.write(messages.getBytes("UTF-8"))

      conn.getInputStream.close()
    } catch {
      case ex: Exception => ex.printStackTrace()
    } finally {
      conn.disconnect()
    }
  }

  override def run(requestData: String): JobResult = {
    if (requestData.nonEmpty) {
      val dt: JSONObject = new JSONObject(requestData)

      val botUrl = dt.get("url").asInstanceOf[String]
      val messages = dt.getJSONArray("messages")

      send(botUrl, messages.toString)
    }
    JobResult(200, "")
  }
}
