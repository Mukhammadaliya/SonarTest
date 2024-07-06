package uz.greenwhite.biruni.service.finalservice

import okhttp3.{MediaType, Request, RequestBody, Response}
import uz.greenwhite.biruni.http.OkHttp3
import uz.greenwhite.biruni.json.JSON

import jakarta.servlet.http.HttpServletRequest

class SendSMSService extends FinalService {
  case class SMSMessage(apiUrl: String, apiKey: String, data: Seq[Seq[String]])

  private object SMSMessage {
    def apply(s: Any): SMSMessage = {
      val x = s.asInstanceOf[Seq[Any]]

      val apiUrl = x.head.asInstanceOf[String]
      val apiKey = x(1).asInstanceOf[String]
      val data = x(2).asInstanceOf[Seq[Seq[String]]]

      SMSMessage(apiUrl, apiKey, data)
    }
  }

  private def send(apiUrl: String, apiKey: String, data: Seq[Seq[String]]): Unit = {
    val client = OkHttp3.getUnsafeOkHttpClient
    val mediaType: MediaType = MediaType.get("application/json")

    for {
      d <- data
    } {
      var response: Response = null
      try {
        val message = Map("key" -> apiKey, "phone" -> d.head, "message" -> d(1))
        val body: RequestBody = RequestBody.create(mediaType, JSON.stringify(message))

        val request: Request = new Request.Builder()
          .url(apiUrl)
          .post(body)
          .build()

        response = client.newCall(request).execute()

        if (!response.isSuccessful)
          throw new RuntimeException("Failed to send SMS, response code: " + response.code())
      } finally {
        if (response != null) response.close()
      }
    }
  }

  override def run(request: HttpServletRequest, data: Seq[Any]): Unit = {
    val smsMessages = data.map(SMSMessage(_))

    for {
      m <- smsMessages
    } send(m.apiUrl, m.apiKey, m.data)
  }
}
