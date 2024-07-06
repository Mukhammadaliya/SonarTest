package uz.greenwhite.biruni.service

import org.eclipse.persistence.jaxb.{JAXBContextFactory, MarshallerProperties, UnmarshallerProperties}
import org.eclipse.persistence.oxm.MediaType
import uz.greenwhite.biruni.route.{OracleHeader, OracleRoute}

import java.io.{StringReader, StringWriter}
import java.net.HttpURLConnection
import jakarta.servlet.http.HttpServletRequest
import javax.xml.namespace.QName
import jakarta.xml.soap.{SOAPConstants, SOAPFactory}
import javax.xml.transform.stream.StreamSource
import jakarta.xml.ws.soap.SOAPFaultException
import uz.greenwhite.biruni.conf.Setting

class SOAPExchangeService(servletRequest: HttpServletRequest,
                          request: Object,
                          requestObject: Object,
                          responseObject: Object,
                          uri: String) {
  private def runStatement(input: String): String = {
    val setting = servletRequest.getServletContext.getAttribute("setting").asInstanceOf[Setting]
    val oracleRoute = new OracleRoute()
    val header = OracleHeader.extractHeaderFromRequest(servletRequest, setting.requestHeaderKeys, setting.requestCookieKeys, uri)
    val result = oracleRoute.execute(header, input)

    // TODO: should use HTTP_OK constant in oracleRoute
    if (result.status != HttpURLConnection.HTTP_OK) {
      val faultCode = new QName("", "BE-1000")
      val soapFault = SOAPFactory.newInstance(SOAPConstants.SOAP_1_1_PROTOCOL).createFault(result.output, faultCode)

      throw new SOAPFaultException(soapFault)
    }

    result.output
  }

  def run: Any = {
    val context = JAXBContextFactory.createContext(Array[Class[_]](requestObject.asInstanceOf[Class[Any]], responseObject.asInstanceOf[Class[Any]]), null)
    val marshaller = context.createMarshaller

    marshaller.setProperty(MarshallerProperties.MEDIA_TYPE, MediaType.APPLICATION_JSON)
    marshaller.setProperty(MarshallerProperties.JSON_INCLUDE_ROOT, false)
    marshaller.setProperty(MarshallerProperties.JSON_WRAPPER_AS_ARRAY_NAME, true)

    val sw = new StringWriter

    marshaller.marshal(request, sw)

    val result = runStatement(sw.toString)

    val unMarshaller = context.createUnmarshaller

    unMarshaller.setProperty(UnmarshallerProperties.MEDIA_TYPE, MediaType.APPLICATION_JSON)
    unMarshaller.setProperty(UnmarshallerProperties.JSON_INCLUDE_ROOT, false)
    unMarshaller.setProperty(UnmarshallerProperties.JSON_WRAPPER_AS_ARRAY_NAME, true)

    val json = new StreamSource(new StringReader(result))
    unMarshaller.unmarshal(json, responseObject.asInstanceOf[Class[Any]]).getValue
  }
}