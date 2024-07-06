package uz.greenwhite.biruni.service.finalservice

import uz.greenwhite.biruni.json.JSON
import uz.greenwhite.biruni.http.TrustAllCerts

import java.net.{HttpURLConnection, URI}
import jakarta.servlet.http.HttpServletRequest
import javax.net.ssl.HttpsURLConnection

class SendTelegramMessageService extends FinalService {

  case class TelegramMessage(botUrl: String, messages: Seq[Any])

  private object TelegramMessage {
    def apply(s: Any): TelegramMessage = {
      val x = s.asInstanceOf[Map[String, Any]]

      val botUrl = x("url").asInstanceOf[String]
      val messages = x("messages").asInstanceOf[Seq[Any]]

      TelegramMessage(botUrl, messages)
    }
  }

  def send(botUrl: String, messages: Seq[Any]): Unit = {
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

      conn.getOutputStream.write(JSON.stringify(messages).getBytes("UTF-8"))

      // connection-ning inputStream o'qilganda request yuboradi
      conn.getInputStream.close()
    } finally {
      conn.disconnect()
    }
  }

  override def run(request: HttpServletRequest, data: Seq[Any]): Unit = {
    val emailMessages = data.map(TelegramMessage(_))

    for {
      m <- emailMessages
    } send(m.botUrl, m.messages)
  }

}