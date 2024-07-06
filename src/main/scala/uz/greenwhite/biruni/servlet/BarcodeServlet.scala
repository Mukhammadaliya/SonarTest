package uz.greenwhite.biruni.servlet

import net.coobird.thumbnailator.Thumbnails
import uz.greenwhite.biruni.service.BarcodeService

import java.io.ByteArrayInputStream
import javax.imageio.ImageIO
import jakarta.servlet.http.{HttpServlet, HttpServletRequest, HttpServletResponse}

class BarcodeServlet extends HttpServlet {
  override def doGet(request: HttpServletRequest, response: HttpServletResponse): Unit = {
    val uri = request.getRequestURI

    if (uri.endsWith("/gen/barcode")) genBarcode(request, response)
    else if (uri.endsWith("/gen/qrcode")) genQRCode(request, response)
    else if (uri.endsWith("/gen/gs1datamatrix")) genGS1DataMatrix(request, response)
    else response.sendError(HttpServletResponse.SC_NOT_FOUND)
  }

  private def genBarcode(request: HttpServletRequest, response: HttpServletResponse): Unit = {
    def param(key: String): Option[String] = Option(request.getParameter(key))

    val text = param("text").getOrElse("")
    val width = param("width").map(_.toInt).getOrElse(300)
    val height = param("height").map(_.toInt).getOrElse(100)
    val extraHeight = param("extra-height").map(_.toInt).getOrElse(20)
    val rotate = param("rotate").map(_.toInt).getOrElse(0)
    val fontSize = param("font-size").map(_.toInt).getOrElse(14)
    val label = param("label").forall(_.toBoolean)

    response.setContentType("image/png")

    val image = {
      if (label) BarcodeService.generateBufferedImageBarcode(text, width, height, extraHeight, fontSize)
      else {
        val byteArray = BarcodeService.generateByteArrayBarcode(text, height, width)
        ImageIO.read(new ByteArrayInputStream(byteArray))
      }
    }

    Thumbnails.of(image)
      .outputFormat("png")
      .rotate(rotate)
      .size(image.getWidth(), image.getHeight())
      .outputQuality(0.8)
      .toOutputStream(response.getOutputStream)
  }

  private def genQRCode(request: HttpServletRequest, response: HttpServletResponse): Unit = {
    def param(key: String): Option[String] = Option(request.getParameter(key))

    val text = param("text").getOrElse("")
    val width = param("width").map(_.toInt).getOrElse(300)
    val height = param("height").map(_.toInt).getOrElse(300)

    response.setContentType("image/png")
    response.getOutputStream.write(BarcodeService.generateByteArrayQRcode(text, width, height))
  }

  private def genGS1DataMatrix(request: HttpServletRequest, response: HttpServletResponse): Unit = {
    def param(key: String): Option[String] = Option(request.getParameter(key))

    val text = param("text").getOrElse("")
    val width = param("width").map(_.toInt).getOrElse(88)
    val height = param("height").map(_.toInt).getOrElse(88)

    response.setContentType("image/png")
    response.getOutputStream.write(BarcodeService.generateByteArrayGS1DataMatrix(text, width, height))
  }
}