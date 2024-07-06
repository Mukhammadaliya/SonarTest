package uz.greenwhite.biruni.service.runtimeservice

import uz.greenwhite.biruni.crypto.DigitalSignatureRSA
import uz.greenwhite.biruni.json.JSON

class BiruniCryptoService extends RuntimeService {

  override def run(detail: Map[String, Any], data: String): RuntimeResult = {
    try {
      var m: Map[String, Any] = JSON.parseForce(data)
      m += "secret_key" -> DigitalSignatureRSA.encrypt(m("secret_key").asInstanceOf[String], m("rsa_public_key").asInstanceOf[String])
      SuccessRuntimeResult(JSON.stringify(m))
    } catch {
      case ex: Exception => ErrorRuntimeResult(ex.getMessage)
    }
  }

}
