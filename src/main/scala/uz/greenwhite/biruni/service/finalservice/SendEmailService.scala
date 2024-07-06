package uz.greenwhite.biruni.service.finalservice

import org.apache.commons.io.FileUtils
import org.simplejavamail.api.email.Email
import org.simplejavamail.api.mailer.config.TransportStrategy
import org.simplejavamail.email.EmailBuilder
import org.simplejavamail.mailer.MailerBuilder

import java.io.File
import java.nio.charset.StandardCharsets
import jakarta.servlet.ServletContext
import jakarta.servlet.http.HttpServletRequest

class SendEmailService extends FinalService {
  case class EmailMessage(host: String, port: Int, fromName: String, fromAddress: String, password: String, transportStrategy: String, messages: Seq[Any])

  private object EmailMessage {
    def apply(s: Any): EmailMessage = {
      val x = s.asInstanceOf[Seq[Any]]

      val host = x.head.asInstanceOf[String]
      val port = x(1).asInstanceOf[String].toInt
      val fromName = x(2).asInstanceOf[String]
      val fromAddress = x(3).asInstanceOf[String]
      val password = x(4).asInstanceOf[String]
      val transportStrategy = x(5).asInstanceOf[String]
      val messages = x(6).asInstanceOf[Seq[Any]]

      EmailMessage(host, port, fromName, fromAddress, password, transportStrategy, messages)
    }
  }

  private def send(context: ServletContext, emailMessage: EmailMessage): Unit = {
    val mailer = MailerBuilder
      .withSMTPServer(emailMessage.host, emailMessage.port, emailMessage.fromAddress, emailMessage.password)
      .withTransportStrategy(emailMessage.transportStrategy match {
        case "T" => TransportStrategy.SMTP_TLS
        case "S" => TransportStrategy.SMTPS
        case "H" => TransportStrategy.SMTP
      })
      .buildMailer()

    for {
      m <- emailMessage.messages
    } {
      val x = m.asInstanceOf[Seq[Any]]

      val to = x.head.asInstanceOf[String]
      val toAddress = x(1).asInstanceOf[String]
      val subject = x(2).asInstanceOf[String]
      val message = x(3).asInstanceOf[String]
      val htmlURL = x(4).asInstanceOf[String]
      val htmlReplacementKeys = x(5).asInstanceOf[Map[String, String]]

      var email: Email = null

      if (message.nonEmpty) {
        email = EmailBuilder.startingBlank()
          .from(emailMessage.fromName, emailMessage.fromAddress)
          .to(to, toAddress)
          .withSubject(subject)
          .withPlainText(message)
          .buildEmail()
      } else {
        val file = new File(context.getResource(htmlURL).toURI)
        var fileContext: String = FileUtils.readFileToString(file, StandardCharsets.UTF_8.name())

        for {
          k <- htmlReplacementKeys.keys
        } fileContext = fileContext.replaceAll("\\{\\{\\s*" + k + "\\s*\\}\\}", htmlReplacementKeys.getOrElse(k, ""))

        email = EmailBuilder.startingBlank()
          .from(emailMessage.fromName, emailMessage.fromAddress)
          .to(to, toAddress)
          .withSubject(subject)
          .withHTMLText(fileContext)
          .buildEmail()
      }

      mailer.sendMail(email)
    }
  }

  override def run(request: HttpServletRequest, data: Seq[Any]): Unit = {
    val emailMessages = data.map(EmailMessage(_))

    for {
      m <- emailMessages
    } send(request.getServletContext, m)
  }
}