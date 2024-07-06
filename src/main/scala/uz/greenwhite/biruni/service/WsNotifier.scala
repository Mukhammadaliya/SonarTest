package uz.greenwhite.biruni.service

import java.util.Collections
import jakarta.servlet.http.HttpSession
import jakarta.websocket._
import jakarta.websocket.server.{HandshakeRequest, ServerEndpoint, ServerEndpointConfig}
import uz.greenwhite.biruni.route.OracleHeader

import scala.collection.JavaConverters.asScalaSetConverter
import scala.collection.mutable

class ServletAwareConfig extends ServerEndpointConfig.Configurator {
  override def modifyHandshake(config: ServerEndpointConfig,
                               request: HandshakeRequest,
                               response: HandshakeResponse): Unit = {
    config.getUserProperties.put(OracleHeader.SESSION_NAME, Option(request.getHttpSession))
  }
}

@ServerEndpoint(value = "/broadcast", configurator = classOf[ServletAwareConfig])
class WsNotifier {
  private var mSession: Option[Session] = None
  private var mUserId: Option[Long] = None

  @OnOpen
  def onOpen(session: Session, config: EndpointConfig): Unit = {
    config.getUserProperties.get(OracleHeader.SESSION_NAME) match {
      case Some(s: HttpSession) =>
        val r = s.getAttribute(OracleHeader.SESSION_NAME).asInstanceOf[String]
        if (r != null) {
          mSession = Some(session)
          mUserId = Option(r.split("#")(2).toInt)
          WsNotifier.clients.add(this)
        } else {
          session.close()
        }
      case _ => session.close()
    }
  }

  @OnClose
  def onClose(): Unit = {
    WsNotifier.clients.remove(this)
  }

  @OnError
  def onError(throwable: Throwable): Unit = {
    println("chat: error")
    println(throwable)
  }
}

object WsNotifier {
  private val clients: mutable.Set[WsNotifier] = Collections.newSetFromMap(new java.util.concurrent.ConcurrentHashMap[WsNotifier, java.lang.Boolean]).asScala

  def broadcast(userId: Long, message: String): Unit = {
    for {
      c <- clients
      session <- c.mSession
      if userId == c.mUserId.getOrElse(0)
    } session.getBasicRemote.sendText(message)
  }
}