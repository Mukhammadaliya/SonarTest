package uz.greenwhite.biruni.servlet

import com.google.common.escape.Escapers
import uz.greenwhite.biruni.http.GZipServletResponseWrapper

import java.io.PrintWriter
import jakarta.servlet.http.{HttpServlet, HttpServletRequest, HttpServletResponse}

class ErrorHandler extends HttpServlet {
  private val escaper = Escapers.builder
    .addEscape('&', "&amp;")
    .addEscape('<', "&lt;")
    .addEscape('>', "&gt;")
    .addEscape('"', "&quot;")
    .addEscape('`', "&#96;")
    .build

  private def acceptsGZipEncoding(httpRequest: HttpServletRequest) = {
    val acceptEncoding = httpRequest.getHeader("Accept-Encoding")
    acceptEncoding != null && acceptEncoding.contains("gzip")
  }

  private def printContent(out: PrintWriter, uri: String, status: Int, error: String): Unit = {
    if (status != 500) {
      out.write("<h3>Error Details</h3>")
      out.write("<strong>Requested URI</strong>:" + escaper.escape(uri) + "<br>")
      out.write("<strong>Status Code</strong>:" + status)
    } else {
      out.write("<h3>Exception Details</h3>")
      out.write("<strong>Requested URI</strong>:" + escaper.escape(uri) + "<br>")
      out.write("<pre>Error:" + escaper.escape(error) + "</pre>")
      out.write("</ul>")
    }
  }

  override def doGet(request: HttpServletRequest, response: HttpServletResponse): Unit = {

    val uri = {
      val r = Option(request.getAttribute("jakarta.servlet.error.request_uri").asInstanceOf[String])
      r.getOrElse("Unknown")
    }
    val ex = Option(request.getAttribute("jakarta.servlet.error.exception").asInstanceOf[Throwable])
    val status = request.getAttribute("jakarta.servlet.error.status_code").asInstanceOf[Int]
    val error = ex.map(_.getMessage).getOrElse("Unknown")

    response.setContentType("text/html")

    if (acceptsGZipEncoding(request)) {
      val gzipResponse = new GZipServletResponseWrapper(response)
      printContent(gzipResponse.getWriter, uri, status, error)
      gzipResponse.close()
    } else {
      printContent(response.getWriter, uri, status, error)
    }
  }

  override def doPost(request: HttpServletRequest, response: HttpServletResponse): Unit = {
    doGet(request, response)
  }
}