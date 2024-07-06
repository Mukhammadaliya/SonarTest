package uz.greenwhite.biruni.service

import oracle.jdbc.{OracleCallableStatement, OracleTypes}
import uz.greenwhite.biruni.connection.DBConnection
import uz.greenwhite.biruni.filemanager.FileManager
import uz.greenwhite.biruni.json.JSON
import java.net.{HttpURLConnection, URI}
import java.security.{KeyStore, SecureRandom}
import javax.net.ssl._
import scala.util.Random

object QlikService {
  private val QLIK_USER_HEADER = "UserDirectory=DOMAIN; UserId=Administrator"
  private var socketFactory: SSLSocketFactory = _
  private var certificateShas: String = ""

  val QLIK_SESSION_NAME = "QLIK_SESSION"

  private def isEmpty(x: String): Boolean = x == null || x.isEmpty

  private def createSSLFactory(clientCertSha: String, rootCertSha: String, certificatePassword: String): SSLSocketFactory = {
    val ks_client: KeyStore = KeyStore.getInstance(KeyStore.getDefaultType)
    val ks_root: KeyStore = KeyStore.getInstance(KeyStore.getDefaultType)

    ks_client.load(FileManager.loadFileAsInputStream(clientCertSha), certificatePassword.toCharArray)
    ks_root.load(FileManager.loadFileAsInputStream(rootCertSha), certificatePassword.toCharArray)

    val kf: KeyManagerFactory = KeyManagerFactory.getInstance(KeyManagerFactory.getDefaultAlgorithm)
    kf.init(ks_client, certificatePassword.toCharArray)

    val tf: TrustManagerFactory = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm)
    tf.init(ks_root)

    val sc: SSLContext = SSLContext.getInstance("TLSv1.2")
    sc.init(kf.getKeyManagers, tf.getTrustManagers, new SecureRandom())

    sc.getSocketFactory
  }

  private def getSocketFactory(clientCertSha: String,
                               rootCertSha: String,
                               certificatePassword: String): SSLSocketFactory = {
    if (socketFactory != null && (clientCertSha + rootCertSha) == certificateShas) return socketFactory

    socketFactory = createSSLFactory(clientCertSha, rootCertSha, certificatePassword)
    certificateShas = clientCertSha + rootCertSha

    socketFactory
  }

  private def loadQlikSettings(): (String, String, String, String) = {
    var conn = DBConnection.getPoolConnection
    var cs: OracleCallableStatement = null

    try {
      cs = conn.prepareCall("BEGIN Biruni_Qlik.Load_Qlik_Settings(?,?); END;").asInstanceOf[OracleCallableStatement]
      cs.registerOutParameter(1, OracleTypes.VARCHAR)
      cs.registerOutParameter(2, OracleTypes.VARCHAR)
      cs.execute()

      val status = mapResponseStatus(cs.getString(1))
      val output = cs.getString(2)

      if (status != HttpURLConnection.HTTP_OK) throw new Exception(output)

      val settings = JSON.parseForce(output).asInstanceOf[Map[String, String]]

      (
        settings.getOrElse("qlik_route", ""),
        settings.getOrElse("client_cert_sha", ""),
        settings.getOrElse("root_cert_sha", ""),
        settings.getOrElse("certificate_password", "")
      )
    } catch {
      case ex: Exception =>
        ex.printStackTrace()
        throw new Exception("couldn't load qlik settings error")
    } finally {
      if (cs != null) cs.close()
      conn.close()
      conn = null
    }
  }

  private def isActiveSession(sessionUUID: String, sessionVal: String): Boolean = {
    var conn = DBConnection.getPoolConnection
    var cs: OracleCallableStatement = null

    try {
      cs = conn.prepareCall("BEGIN Biruni_Qlik.Check_Qlik_Session(?,?,?,?); END;").asInstanceOf[OracleCallableStatement]
      cs.setString(1, sessionUUID)
      cs.setString(2, sessionVal)
      cs.registerOutParameter(3, OracleTypes.VARCHAR)
      cs.registerOutParameter(4, OracleTypes.VARCHAR)
      cs.execute()

      val status = mapResponseStatus(cs.getString(3))
      val output = cs.getString(4)

      if (status != HttpURLConnection.HTTP_OK) throw new Exception(output)

      output == "Y"
    } catch {
      case ex: Exception =>
        ex.printStackTrace()
        false
    } finally {
      if (cs != null) cs.close()
      conn.close()
      conn = null
    }
  }

  private def closeSession(sessionUUID: String): Unit = {
    var conn = DBConnection.getPoolConnection
    var cs: OracleCallableStatement = null

    try {
      cs = conn.prepareCall("BEGIN Biruni_Qlik.Close_Qlik_Session(?,?,?); END;").asInstanceOf[OracleCallableStatement]
      cs.setString(1, sessionUUID)
      cs.registerOutParameter(2, OracleTypes.VARCHAR)
      cs.registerOutParameter(3, OracleTypes.VARCHAR)
      cs.execute()

      val status = mapResponseStatus(cs.getString(2))
      val output = cs.getString(3)

      if (status != HttpURLConnection.HTTP_OK) throw new Exception(output)
    } catch {
      case ex: Exception =>
        ex.printStackTrace()
    } finally {
      if (cs != null) cs.close()
      conn.close()
      conn = null
    }
  }

  def mapResponseStatus(status: String): Int =
    status match {
      case "S" => 200
      case "E" => 400
      case "F" => 500
      case "U" => 401
      case "R" => 403
      case "N" => 404
      case _ => 400
    }

  def getConnection(requestURL: String,
                    requestMethod: String,
                    clientCertSha: String,
                    rootCertSha: String,
                    certificatePassword: String): HttpsURLConnection = {
    val xrfKey = Random.alphanumeric.take(16).mkString
    val url = URI.create(requestURL + "?XRFKEY=" + xrfKey).toURL
    var conn: HttpsURLConnection = null

    val protocol = url.getProtocol.toLowerCase

    if (protocol != "https") {
      throw new Exception("Only https protocol is supported")
    }

    conn = url.openConnection().asInstanceOf[HttpsURLConnection]
    conn.setSSLSocketFactory(QlikService.getSocketFactory(clientCertSha, rootCertSha, certificatePassword))
    conn.setRequestMethod(requestMethod)
    conn.setDoOutput(true)
    conn.setRequestProperty("X-Qlik-XRFKEY", xrfKey)
    conn.setRequestProperty("X-Qlik-User", QLIK_USER_HEADER)
    conn.setRequestProperty("Content-Type", "application/json")

    conn
  }

  def logoutSession(sessionUUID: String): Unit = {
    var conn: HttpsURLConnection = null

    try {
      val (sessionRoute, clientCertSha, rootCertSha, certificatePassword) = loadQlikSettings()

      val url = sessionRoute + "/" + sessionUUID
      val requestMethod = "DELETE"

      conn = getConnection(url, requestMethod, clientCertSha, rootCertSha, certificatePassword)

      val status = conn.getResponseCode

      if (status == HttpURLConnection.HTTP_OK) closeSession(sessionUUID)
    } catch {
      case ex: Exception =>
        ex.printStackTrace()
    } finally {
      if (conn != null) conn.disconnect()
    }
  }

  def logoutCheckSession(sessionUUID: String, sessionVal: String): Boolean = {
    try {
      if (isEmpty(sessionUUID)) return true
      if (isEmpty(sessionVal) || !isActiveSession(sessionUUID, sessionVal)) {
        logoutSession(sessionUUID)
        return true
      }
      false
    } catch {
      case ex: Exception =>
        ex.printStackTrace()
        true
    }
  }
}
