package uz.greenwhite.biruni.service.finalservice

import uz.greenwhite.biruni.service.WsNotifier

import jakarta.servlet.http.HttpServletRequest

class BroadcastService extends FinalService {
  case class BroadcastMessage(message: String, userIds: Set[Int])

  private object BroadcastMessage {
    def apply(s: Any): BroadcastMessage = {
      val x = s.asInstanceOf[Seq[Any]]
      val message = x.head.asInstanceOf[String]
      val userIds = x(1).asInstanceOf[Seq[Any]].map(_.asInstanceOf[String].toInt)

      BroadcastMessage(message, userIds.toSet)
    }
  }

  override def run(request: HttpServletRequest, data: Seq[Any]): Unit = {
    val broadcastMessages = data.map(BroadcastMessage(_))

    for {
      m <- broadcastMessages
      id <- m.userIds
    } WsNotifier.broadcast(id, m.message)
  }
}
