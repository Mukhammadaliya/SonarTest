package uz.greenwhite.biruni.servlet

import oracle.jdbc.{OracleCallableStatement, OracleConnection, OracleTypes}
import uz.greenwhite.biruni.connection.DBConnection
import uz.greenwhite.biruni.json.JSON
import jakarta.servlet.http.{HttpServlet, HttpServletRequest, HttpServletResponse}
import uz.greenwhite.biruni.util.StringUtil

import scala.collection.JavaConverters._
import scala.io.{Codec, Source}
import scala.util.control.NonFatal

class ZKTime extends HttpServlet {

  override def doGet(request: HttpServletRequest, response: HttpServletResponse): Unit = doPost(request, response)

  override def doPost(request: HttpServletRequest, response: HttpServletResponse): Unit =
    try {
      run(request, response)
    } catch {
      case NonFatal(ex) =>
        response.setStatus(500)
        response.getWriter.println(ex.getClass.getName + ":" + ex.getMessage)
    }


  private def run(request: HttpServletRequest, response: HttpServletResponse): Unit = {
    val path = request.getRequestURI.substring(request.getContextPath.length)

    val query = {
      val params = request.getParameterMap.asScala.toMap
      JSON.stringify(params)
    }
    val input = Source.fromInputStream(request.getInputStream)(Codec.ISO8859).mkString
    val result = call(path, query, input)
    val content = result.getBytes("UTF-8")
    response.setContentLength(content.length)
    val os = response.getOutputStream
    os.write(content)
    os.flush()
  }

  private def getStatement(conn: OracleConnection): OracleCallableStatement = {
    val query = "BEGIN Hrt_ZKTime.Process(?,?,?,?); commit; END;"
    conn.prepareCall(query).asInstanceOf[OracleCallableStatement]
  }

  private def call(path: String, query: String, input: String): String = {
    val conn = DBConnection.getSingletonConnection
    var cs: OracleCallableStatement = null

    try {
      cs = getStatement(conn)

      val chunks: Array[String] = input.split('\n').map(_.trim).filter(_ != "")

      cs.setString(1, path)
      cs.setString(2, query)
      cs.setArray(3, conn.createOracleArray("PUBLIC.ARRAY_VARCHAR2", chunks))
      cs.registerOutParameter(4, OracleTypes.ARRAY, "PUBLIC.ARRAY_VARCHAR2")

      cs.execute

      val output = cs.getArray(4).getArray.asInstanceOf[Array[String]]
      StringUtil.gatherChunks(output)
    } finally {
      if (cs != null) cs.close()
      conn.close()
    }
  }
}
