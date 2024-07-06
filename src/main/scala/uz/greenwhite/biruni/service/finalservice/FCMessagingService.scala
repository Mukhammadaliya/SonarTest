package uz.greenwhite.biruni.service.finalservice

import uz.greenwhite.biruni.http.TrustAllCerts
import uz.greenwhite.biruni.json.JSON

import java.io.OutputStreamWriter
import java.net.{HttpURLConnection, URI}
import javax.net.ssl.HttpsURLConnection
import jakarta.servlet.http.HttpServletRequest

class FCMessagingService extends FinalService {

  case class FirebaseMessage(fcmUrl: String, authKey: String, registrationIds: Seq[String], priority: String, data: Map[String, Any], notification: Map[String, Any])

  object FirebaseMessage {

    def apply(s: Any): FirebaseMessage = {
      val x = s.asInstanceOf[Seq[Any]]

      val fcmUrl = x.head.asInstanceOf[String]
      val authKey = x(1).asInstanceOf[String]
      val registrationIds = x(2).asInstanceOf[Seq[Any]].map(_.asInstanceOf[String])
      val priority = x(3).asInstanceOf[String]
      val data = x(4).asInstanceOf[Map[String, Any]]
      val notification = x(5).asInstanceOf[Map[String, Any]]

      FirebaseMessage(fcmUrl, authKey, registrationIds, priority, data, notification)
    }
  }

  def getConnection(fcmUrl: String,
                    authKey: String): HttpURLConnection = {
    val url = URI.create(fcmUrl).toURL

    val trustAllCerts = new TrustAllCerts()
    trustAllCerts.trust()

    val protocol = url.getProtocol.toUpperCase
    var conn: HttpURLConnection = null

    if ("HTTP".equals(protocol)) conn = url.openConnection().asInstanceOf[HttpURLConnection]
    else if ("HTTPS".equals(protocol)) conn = url.openConnection().asInstanceOf[HttpsURLConnection]

    if (conn != null) {
      conn.setUseCaches(false)
      conn.setDoInput(true)
      conn.setDoOutput(true)
      conn.setRequestMethod("POST")
      conn.setRequestProperty("Authorization", "key=" + authKey)
      conn.setRequestProperty("Content-Type", "application/json")
      conn.setConnectTimeout(3000)
    }

    conn
  }

  def send(fcmUrl: String,
           authKey: String,
           registrationIds: Seq[String],
           priority: String,
           data: Map[String, Any],
           notification: Map[String, Any]): Unit = {

    val conn = getConnection(fcmUrl, authKey)

    try {
      var json = Map("registration_ids" -> registrationIds,
        "priority" -> priority,
        "data" -> data)

      if (notification.nonEmpty) {
        json += ("notification" -> notification)
      }

      val wr = new OutputStreamWriter(conn.getOutputStream, "UTF-8")
      wr.write(JSON.stringify(json))
      wr.flush()
      wr.close()

      //connection-ning inputStream o'qilganda request yuboradi
      conn.getInputStream.close()

    } finally if (conn != null) conn.disconnect()
  }

  override def run(request: HttpServletRequest, data: Seq[Any]): Unit = {
    val firebaseMessages = data.map(FirebaseMessage(_))

    for {
      m <- firebaseMessages
    } send(m.fcmUrl, m.authKey, m.registrationIds, m.priority, m.data, m.notification)
  }
}