package uz.greenwhite.biruni.util

import org.apache.commons.io.FileUtils
import uz.greenwhite.biruni.s3.S3Client

import java.io.{ByteArrayOutputStream, File, IOException, InputStream}
import java.nio.charset.StandardCharsets
import java.nio.file.{Files, Paths}
import scala.io.{BufferedSource, Codec}

object FileUtil {
  def getFileStoreKind: String = {
    if (S3Client.hasClient) "S"
    else "D"
  }

  def write(path: String, txt: String): Unit = {
    Files.write(Paths.get(path), txt.getBytes(StandardCharsets.UTF_8))
  }

  def deleteFile(path: String): Unit = {
    try {
      Files.deleteIfExists(Paths.get(path))
    } catch {
      case e: IOException => e.printStackTrace()
    }
  }

  def deleteDirectory(path: String): Unit = {
    try {
      FileUtils.deleteDirectory(new File(path))
    } catch {
      case e: IOException => e.printStackTrace()
    }
  }

  def read(path: String): String = {
    var buff: BufferedSource = null
    try {
      buff = scala.io.Source.fromFile(path)(Codec.UTF8)
      buff.getLines.mkString
    } catch {
      case ex: Exception => throw new RuntimeException(ex.getMessage)
    } finally {
      buff.close()
    }
  }

  def pipe(in: java.io.InputStream, out: java.io.OutputStream): Unit = {
    val buffer = new Array[Byte](8192)

    @annotation.tailrec def loop(): Unit = {
      val byteCount = in.read(buffer)
      if (byteCount > 0) {
        out.write(buffer, 0, byteCount)
        loop()
      }
    }

    loop()
    in.close()
    out.close()
  }

  def readInputStream(inputStream: InputStream): Array[Byte] = {
    val buf = new ByteArrayOutputStream()

    var len = 0
    val data = new Array[Byte](16384)

    while ( {
      len = inputStream.read(data, 0, data.length)
      len
    } != -1) {
      buf.write(data, 0, len)
    }

    buf.toByteArray
  }

  def shaFolder(sha: String): String = sha.substring(0, 2) + "/" + sha.substring(2, 4) + "/"

  def shaFile(sha: String): String = shaFolder(sha) + sha

  def shaHex(bytes: Array[Byte]): String = {
    // convert the byte to hex format method 1
    val r = bytes.foldLeft(new StringBuilder) { (sb, b) =>
      sb.append(Integer.toString((b & 0xff) + 0x100, 16).substring(1))
    }

    r.toString()
  }

  def calcSHA(data: Array[Byte]): String = {
    val md = java.security.MessageDigest.getInstance("SHA-256")
    md.update(data)
    shaHex(md.digest())
  }

  def calcSha(is: InputStream): String = {
    val md = java.security.MessageDigest.getInstance("SHA-256")
    val buf = new Array[Byte](100 * 1024)

    Stream.continually(is.read(buf)).takeWhile(_ != -1).foreach(md.update(buf, 0, _))

    shaHex(md.digest())
  }
}