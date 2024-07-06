package uz.greenwhite.biruni.service.finalservice

case class FinalServiceData(className: String, data: Seq[Any])

object FinalServiceData {
  def apply(s: Any): FinalServiceData = {
    val x = s.asInstanceOf[Seq[Any]]

    val className = x.head.asInstanceOf[String]
    val data = x(1).asInstanceOf[Seq[Any]]

    FinalServiceData(className, data)
  }
}
