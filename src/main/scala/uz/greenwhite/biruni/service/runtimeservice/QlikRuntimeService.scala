package uz.greenwhite.biruni.service.runtimeservice

import uz.greenwhite.biruni.service.QlikService

import java.net.HttpURLConnection
import java.nio.charset.StandardCharsets
import javax.net.ssl.HttpsURLConnection
import scala.io.Source

class QlikRuntimeService extends RuntimeService {
  private def isEmpty(x: String) = x == null || x.isEmpty

  private def executeQlikRoute(qlikData: String,
                               qlikRoute: String,
                               requestMethod: String,
                               clientCertSha: String,
                               rootCertSha: String,
                               certificatePassword: String): RuntimeResult = {
    var conn: HttpsURLConnection = null

    try {
      conn = QlikService.getConnection(qlikRoute, requestMethod, clientCertSha, rootCertSha, certificatePassword)
      conn.setRequestProperty("Content-Length", qlikData.length.toString)

      if (!isEmpty(qlikData)) {
        val out = conn.getOutputStream
        out.write(qlikData.getBytes(StandardCharsets.UTF_8))
        out.flush()
        out.close()
      }

      val status = conn.getResponseCode

      if (status == HttpURLConnection.HTTP_OK || status == HttpURLConnection.HTTP_CREATED) {
        SuccessRuntimeResult(Source.fromInputStream(conn.getInputStream)(StandardCharsets.UTF_8).mkString)
      } else {
        if (conn.getErrorStream != null) {
          ErrorRuntimeResult(Source.fromInputStream(conn.getErrorStream)(StandardCharsets.UTF_8).mkString)
        } else {
          ErrorRuntimeResult("Qlik response error code = " + status)
        }
      }
    } finally {
      if (conn != null) conn.disconnect()
    }
  }

  override def run(detail: Map[String, Any], data: String): RuntimeResult = {
    try {
      val qlikRoute = detail.getOrElse("qlik_route", "").asInstanceOf[String]
      val requestMethod = detail.getOrElse("request_method", "").asInstanceOf[String]

      val clientCertSha = detail.getOrElse("client_cert_sha", "").asInstanceOf[String]
      val rootCertSha = detail.getOrElse("root_cert_sha", "").asInstanceOf[String]
      val certificatePassword = detail.getOrElse("certificate_password", "").asInstanceOf[String]

      if (isEmpty(qlikRoute)) throw new Exception("provide qlikRoute")
      if (isEmpty(clientCertSha)) throw new Exception("provide clientCertSha")
      if (isEmpty(rootCertSha)) throw new Exception("provide rootCertSha")
      if (isEmpty(certificatePassword)) throw new Exception("provide certificatePassword")

      executeQlikRoute(data, qlikRoute, requestMethod, clientCertSha, rootCertSha, certificatePassword)
    } catch {
      case ex: Exception =>
        ErrorRuntimeResult(ex.getMessage)
    }
  }
}
