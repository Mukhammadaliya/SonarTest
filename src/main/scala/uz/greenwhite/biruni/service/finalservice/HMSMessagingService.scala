package uz.greenwhite.biruni.service.finalservice

import jakarta.servlet.http.HttpServletRequest
import okhttp3.{FormBody, MediaType, Request, RequestBody, Response}
import oracle.jdbc.OracleConnection
import org.json.JSONObject
import uz.greenwhite.biruni.connection.DBConnection
import uz.greenwhite.biruni.http.OkHttp3
import uz.greenwhite.biruni.json.JSON

import java.sql.CallableStatement

class HMSMessagingService extends FinalService {
  private case class HMSMessage(authServerUrl: String,
                                sendMessageUrl: String,
                                clientId: String,
                                clientSecret: String,
                                accessToken: String,
                                registrationIds: Seq[String],
                                data: Map[String, Any])

  private object HMSMessage {
    def apply(s: Any): HMSMessage = {
      val x = s.asInstanceOf[Seq[Any]]

      val authServerUrl = x.head.asInstanceOf[String]
      val sendMessageUrl = x(1).asInstanceOf[String]
      val clientId = x(2).asInstanceOf[String]
      val clientSecret = x(3).asInstanceOf[String]
      val accessToken = x(4).asInstanceOf[String]
      val registrationIds = x(5).asInstanceOf[Seq[Any]].map(_.asInstanceOf[String])
      val data = x(6).asInstanceOf[Map[String, Any]]

      HMSMessage(authServerUrl, sendMessageUrl, clientId, clientSecret, accessToken, registrationIds, data)
    }
  }

  private case class AccessTokenResponse(accessToken: String, expiresIn: Int)

  private def getAccessToken(authServerUrl: String, clientId: String, clientSecret: String): AccessTokenResponse = {
    val okHttp3Client = OkHttp3.getUnsafeOkHttpClient

    val body: RequestBody = new FormBody.Builder()
      .add("grant_type", "client_credentials")
      .add("client_id", clientId)
      .add("client_secret", clientSecret)
      .build()

    val request: Request = new Request.Builder()
      .url(authServerUrl)
      .addHeader("Content-Type", "application/x-www-form-urlencoded")
      .post(body)
      .build()

    var response: Response = null
    try {
      response = okHttp3Client.newCall(request).execute()
      val json = new JSONObject(response.body().string())
      AccessTokenResponse(json.getString("access_token"), json.getInt("expires_in"))
    } finally {
      if (response != null) response.close()
    }
  }

  private def saveAccessToken(clientId: String, accessToken: String, expiresIn: Int): Unit = {
    var conn: OracleConnection = null
    var st: CallableStatement = null

    try {
      conn = DBConnection.getPoolConnectionAndFreeResources

      st = conn.prepareCall("BEGIN Biruni_Service.Save_Hms_Token(?,?, ?); END;")
      st.setString(1, clientId)
      st.setString(2, accessToken)
      st.setInt(3, expiresIn)
      st.execute()
    } finally {
      if (st != null) st.close()
      if (conn != null) conn.close()
      conn = null
    }
  }

  private def sendMessage(sendMessageUrl: String, accessToken: String, registrationIds: Seq[Any], data: Map[String, Any]): Unit = {
    val json: MediaType = MediaType.get("application/json; charset=utf-8")
    val okHttp3Client = OkHttp3.getUnsafeOkHttpClient

    val hmsMessage = Map(
      "message" -> Map(
        "data" -> JSON.stringify(data),
        "token" -> registrationIds
      )
    )

    val request = new Request.Builder()
      .url(sendMessageUrl)
      .addHeader("Authorization", "Bearer " + accessToken)
      .post(RequestBody.create(JSON.stringify(hmsMessage), json))
      .build()

    var response: Response = null
    try {
      response = okHttp3Client.newCall(request).execute()
    } finally {
      if (response != null) response.close()
    }
  }

  private def send(hmsMessage: HMSMessage): Unit = {
    if (hmsMessage.accessToken.isEmpty) {
      val accessTokenResponse = getAccessToken(hmsMessage.authServerUrl, hmsMessage.clientId, hmsMessage.clientSecret)
      saveAccessToken(hmsMessage.clientId, accessTokenResponse.accessToken, accessTokenResponse.expiresIn)
      sendMessage(hmsMessage.sendMessageUrl, accessTokenResponse.accessToken, hmsMessage.registrationIds, hmsMessage.data)
    } else {
      sendMessage(hmsMessage.sendMessageUrl, hmsMessage.accessToken, hmsMessage.registrationIds, hmsMessage.data)
    }
  }

  override def run(request: HttpServletRequest, data: Seq[Any]): Unit = {
    val hmsMessages = data.map(HMSMessage(_))

    for {
      m <- hmsMessages
    } send(m)

  }
}
