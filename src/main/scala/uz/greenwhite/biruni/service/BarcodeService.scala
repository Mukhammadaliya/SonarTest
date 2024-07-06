package uz.greenwhite.biruni.service

import com.google.zxing.client.j2se.MatrixToImageWriter
import com.google.zxing.oned.Code128Writer
import com.google.zxing.{BarcodeFormat, EncodeHintType, MultiFormatWriter}

import java.awt.image.BufferedImage
import java.awt.{Color, Font, Graphics2D}
import java.io.ByteArrayOutputStream
import java.util
import javax.imageio.ImageIO

object BarcodeService {

  private def generateHists = {
    val hints: util.Map[EncodeHintType, Any] = new util.EnumMap[EncodeHintType, Any](classOf[EncodeHintType])
    hints.put(EncodeHintType.CHARACTER_SET, "UTF-8")
    hints.put(EncodeHintType.MARGIN, 0)
    hints
  }

  def generateBufferedImageBarcode(text: String, width: Int, height: Int, extraHeight: Int, fontSize: Int): BufferedImage = {
    val matrix = new Code128Writer().encode(text, BarcodeFormat.CODE_128, width, height, generateHists)
    val matrixWidth = matrix.getWidth
    val matrixHeight = matrix.getHeight
    val image = new BufferedImage(matrixWidth, matrixHeight + extraHeight, BufferedImage.TYPE_INT_RGB)

    image.createGraphics()

    val graphics: Graphics2D = image.getGraphics.asInstanceOf[Graphics2D]

    graphics.setColor(Color.WHITE)
    graphics.fillRect(0, 0, matrixWidth, matrixHeight + extraHeight)
    graphics.setFont(new Font("Arial", Font.PLAIN, fontSize))
    graphics.setColor(Color.black)
    graphics.drawString(text, 15, matrixHeight + 15)
    // Paint and save the image using the ByteMatrix
    graphics.setColor(Color.BLACK)

    for {
      i <- 0 until matrixWidth
      j <- 0 until matrixHeight
      if matrix.get(i, j)
    } graphics.fillRect(i, j, 1, 1)

    image
  }

  def generateByteArrayBarcode(text: String, height: Int, width: Int): Array[Byte] = {
    val matrix = new Code128Writer().encode(text, BarcodeFormat.CODE_128, width, height, generateHists)
    val bufferedImage = MatrixToImageWriter.toBufferedImage(matrix)

    val outputStream = new ByteArrayOutputStream
    ImageIO.write(bufferedImage, "png", outputStream)
    outputStream.toByteArray
  }

  def generateBufferedImageQRcode(text: String, height: Int, width: Int): BufferedImage = {
    val matrix = new MultiFormatWriter().encode(text, BarcodeFormat.QR_CODE, width, height, generateHists)
    MatrixToImageWriter.toBufferedImage(matrix)
  }

  def generateByteArrayQRcode(text: String, height: Int, width: Int): Array[Byte] = {
    val bufferedImage = generateBufferedImageQRcode(text, height, width)
    val outputStream = new ByteArrayOutputStream
    ImageIO.write(bufferedImage, "png", outputStream)
    outputStream.toByteArray
  }

  private def generateGS1Hists = {
    val hints = generateHists
    hints.put(EncodeHintType.GS1_FORMAT, true)
    hints
  }

  private def generateBufferedImageGS1DataMatrix(text: String, height: Int, width: Int): BufferedImage = {
    val matrix = new MultiFormatWriter().encode(text, BarcodeFormat.DATA_MATRIX, width, height, generateGS1Hists)
    MatrixToImageWriter.toBufferedImage(matrix)
  }

  def generateByteArrayGS1DataMatrix(text: String, height: Int, width: Int): Array[Byte] = {
    val bufferedImage = generateBufferedImageGS1DataMatrix(text, height, width)
    val outputStream = new ByteArrayOutputStream
    ImageIO.write(bufferedImage, "png", outputStream)
    outputStream.toByteArray
  }
}