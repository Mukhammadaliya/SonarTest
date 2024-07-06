package uz.greenwhite.biruni.fazo_sync

import jakarta.servlet.http.HttpServletResponse
import oracle.jdbc.OracleTypes
import oracle.jdbc.pool.OracleDataSource

import scala.io.{Codec, Source}

object FazoSync {

  abstract class Fetch {
    def apply: String
  }

  case class FetchDB(url: String, username: String, password: String) extends Fetch {
    def apply: String = {
      val ods = new OracleDataSource()
      ods.setURL(url)
      ods.setUser(username)
      ods.setPassword(password)

      val conn = ods.getConnection

      val r = conn.prepareCall(s"DECLARE r hashmap;v stream:=stream();BEGIN r := fazo_gen.serial_all; r.print_json(v); ?:= v.val; END;")

      r.registerOutParameter(1, OracleTypes.ARRAY, "PUBLIC.ARRAY_VARCHAR2")

      r.execute()

      val output2 = r.getArray(1)
      val output = if (output2 == null) Array("") else output2.getArray().asInstanceOf[Array[String]]

      val s = output mkString ""

      conn.close()

      s
    }
  }

  case class FetchURL(url: String) extends Fetch {

    def apply: String = {
      val trustAllCerts = new uz.greenwhite.biruni.http.TrustAllCerts()
      trustAllCerts.trust()

      val u = if (url.endsWith(".json")) url
      else {
        val us = if (url.endsWith("/")) url.init else url
        us + "/b/fazo/metadata"
      }
      Source.fromURL(u)(Codec.UTF8).getLines.mkString("")
    }
  }

  def run(inputRaw: String, response: HttpServletResponse): Unit = {
    response.setContentType("text/plain")
    response.setCharacterEncoding("UTF-8")

    val trustAllCerts = new uz.greenwhite.biruni.http.TrustAllCerts()
    trustAllCerts.trust()

    val writer = response.getWriter

    try {

      uz.greenwhite.biruni.json.JSON.parse(inputRaw) match {
        case Some(r: Map[_, _]) =>
          val urlFrom = r("from").toString
          val urlTo = r("to").toString
          val s = List(FetchURL(urlFrom), FetchURL(urlTo)).par.map(x => Model.makeStored(x.apply))
          writer.println("<pre>")
          writer.println(s"FROM: $urlFrom")
          writer.println(s"TO: $urlTo")
          writer.println("-----------------------------------------------")

          writer.println(TableDiff.diffStored(s.head, s(1)).mkString("\n"))
          writer.println("</pre>")

        case _ =>
          response.setStatus(412)
          writer.println("invalid input arguments")
          writer.println(inputRaw)
      }

    } catch {
      case ex: Exception =>
        response.setStatus(500)
        writer.println(ex.getMessage)
        ex.printStackTrace()
    } finally {
      writer.close()
    }
  }

  def form(response: HttpServletResponse): Unit = {
    response.setContentType("text/html")
    response.setCharacterEncoding("UTF-8")

    val writer = response.getWriter

    try {

      val r = getClass.getResourceAsStream("/fazo/index.html")

      val inputRaw = Source.fromInputStream(r)(Codec.UTF8)

      writer.println(inputRaw.getLines.mkString("\n"))

    } catch {
      case ex: Exception =>
        response.setStatus(500)
        writer.println(ex.getMessage)
        ex.printStackTrace()
    } finally {
      writer.close()
    }
  }

}
