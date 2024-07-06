package uz.greenwhite.biruni.service.runtimeservice

class DefaultRuntimeService(className: String) extends RuntimeService {

  override def run(detail: Map[String, Any], data: String): RuntimeResult = {
    ErrorRuntimeResult(output = s"class is not defined $className")
  }

}
