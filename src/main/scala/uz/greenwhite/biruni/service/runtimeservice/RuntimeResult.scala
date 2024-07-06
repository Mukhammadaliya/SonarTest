package uz.greenwhite.biruni.service.runtimeservice

trait RuntimeResult {
  var reviewData: String
  var output: String

  def isSuccess: Boolean
}

case class SuccessRuntimeResult(var reviewData: String, var output: String) extends RuntimeResult {
  override def isSuccess: Boolean = true
}

object SuccessRuntimeResult {
  def apply(output: String): SuccessRuntimeResult = new SuccessRuntimeResult("", output)
}

case class ErrorRuntimeResult(var reviewData: String, var output: String) extends RuntimeResult {
  override def isSuccess: Boolean = false
}

object ErrorRuntimeResult {
  def apply(output: String): ErrorRuntimeResult = new ErrorRuntimeResult("", output)
}