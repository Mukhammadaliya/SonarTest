package uz.greenwhite.biruni.route

import oracle.jdbc.{OracleCallableStatement, OracleConnection, OracleTypes}
import uz.greenwhite.biruni.connection.DBConnection
import uz.greenwhite.biruni.json.JSON
import uz.greenwhite.biruni.logger.ExceptionLogger
import uz.greenwhite.biruni.service.finalservice.FinalServiceData
import uz.greenwhite.biruni.service.runtimeservice.RuntimeService
import uz.greenwhite.biruni.util.StringUtil

import java.sql.{PreparedStatement, SQLException}
import java.util

class OracleRoute {
  private def getCommonStatement(conn: OracleConnection): OracleCallableStatement =
    conn.prepareCall("BEGIN Biruni_Route.Execute_Route(?,?,?,?); END;").asInstanceOf[OracleCallableStatement]

  private def getRuntimeStatement(conn: OracleConnection): OracleCallableStatement =
    conn.prepareCall("BEGIN Biruni_Route.Execute_Runtime_Route(?,?,?,?); END;").asInstanceOf[OracleCallableStatement]

  private def getRuntimeFailStatement(conn: OracleConnection): OracleCallableStatement =
    conn.prepareCall("BEGIN Biruni_Route.Execute_Runtime_Route_Fail(?,?); END;").asInstanceOf[OracleCallableStatement]

  private def parseResponse(res: Map[String, Any], output: String): OracleResult = {
    val status = OracleResult.mapResponseStatus(res("status").asInstanceOf[String].charAt(0))
    val cookies = {
      val x = res.get("cookie")
      if (x.isDefined) x.get.asInstanceOf[Map[String, Map[String, String]]]
      else Map.empty[String, Map[String, String]]
    }

    if (status == 200) {
      OracleResult(
        status = status,
        output = output,
        headers = res("header").asInstanceOf[Map[String, String]],
        cookies = cookies,
        session = res.get("session").map(_.asInstanceOf[String]),
        action = res.get("action").map(_.asInstanceOf[String]).getOrElse("none"),
        finalServices = res.get("final_services").map(_.asInstanceOf[Seq[Any]].map(FinalServiceData(_))).getOrElse(Seq.empty))
    } else {
      OracleResult(
        status = status,
        output = output,
        headers = res.get("header").map(_.asInstanceOf[Map[String, String]]).getOrElse(Map.empty),
        cookies = cookies,
        session = res.get("session").map(_.asInstanceOf[String]),
        action = "none",
        finalServices = Seq.empty)
    }
  }

  private def runStored(header: OracleHeader, input: String): OracleResult = {
    var conn = DBConnection.getPoolConnectionAndFreeResources
    var cs: OracleCallableStatement = null
    var rcs: OracleCallableStatement = null
    var oracleResult: OracleResult = null

    try {
      conn.setAutoCommit(false)

      cs = getCommonStatement(conn)

      cs.setString(1, header.asJson)
      cs.setArray(2, conn.createOracleArray("PUBLIC.ARRAY_VARCHAR2", StringUtil.splitChunks(input)))
      cs.registerOutParameter(3, OracleTypes.ARRAY, "PUBLIC.ARRAY_VARCHAR2")
      cs.registerOutParameter(4, OracleTypes.ARRAY, "PUBLIC.ARRAY_VARCHAR2")

      cs.execute

      var respMap = JSON.parseForce(StringUtil.gatherChunks(cs.getArray(3).getArray.asInstanceOf[Array[String]]))
      var outputText = StringUtil.gatherChunks(cs.getArray(4).getArray.asInstanceOf[Array[String]])

      if (respMap.get("runtime_service").map(_.asInstanceOf[String]).getOrElse("N") == "Y") {
        val runtimeResult = RuntimeService.run(respMap("class_name").asInstanceOf[String], respMap("detail").asInstanceOf[Map[String, Any]], outputText)

        if (runtimeResult.isSuccess) {
          rcs = getRuntimeStatement(conn)

          rcs.setString(1, runtimeResult.reviewData)
          rcs.setArray(2, conn.createOracleArray("PUBLIC.ARRAY_VARCHAR2", StringUtil.splitChunks(runtimeResult.output)))
          rcs.registerOutParameter(3, OracleTypes.ARRAY, "PUBLIC.ARRAY_VARCHAR2")
          rcs.registerOutParameter(4, OracleTypes.ARRAY, "PUBLIC.ARRAY_VARCHAR2")

          rcs.execute

          respMap = JSON.parseForce(StringUtil.gatherChunks(rcs.getArray(3).getArray.asInstanceOf[Array[String]]))
          outputText = StringUtil.gatherChunks(rcs.getArray(4).getArray.asInstanceOf[Array[String]])
        } else {
          conn.rollback()

          rcs = getRuntimeFailStatement(conn)

          rcs.setString(1, runtimeResult.reviewData)
          rcs.setString(2, runtimeResult.output)
          rcs.execute

          return OracleResult.buildInternalErrorResult(runtimeResult.output)
        }
      }

      oracleResult = parseResponse(respMap, if (respMap.isDefinedAt("fetch_output")) fetchOutput(conn) else outputText)

      conn.commit()
    } catch {
      case ex: Exception =>
        ExceptionLogger.saveException(this.getClass.getName, ex)
        oracleResult = OracleResult.buildInternalErrorResult(ex.getMessage)
        if (!conn.isClosed) conn.rollback()
    } finally {
      if (cs != null) cs.close()
      if (rcs != null) rcs.close()
      conn.close()
      conn = null
    }

    oracleResult
  }

  private def fetchOutput(conn: OracleConnection): String = {
    val st = conn.createStatement()

    try {
      val rs = st.executeQuery("SELECT line FROM biruni_report_lines ORDER BY table_id, order_no")
      val sb = new StringBuilder
      while (rs.next()) sb.append(rs.getString(1))
      sb.toString()
    } finally {
      st.close()
    }
  }

  def execute(header: OracleHeader, input: String): OracleResult = {
    try {
      runStored(header, input)
    } catch {
      case ex: SQLException => OracleResult.buildInternalErrorResult(ex.getMessage)
    }
  }

  def uploadEasyReportMetadata(sha: String, templateData: util.Map[String, String]): Unit = {
    var conn = DBConnection.getPoolConnection
    var st: PreparedStatement = null

    try {
      st = conn.prepareStatement("BEGIN Biruni_Route.Upload_Easy_Report_Metadata(?,?,?,?,?); END;")
      st.setString(1, sha)
      st.setArray(2, conn.createOracleArray("PUBLIC.ARRAY_VARCHAR2", StringUtil.splitChunks(templateData.get("metadata"))))
      st.setArray(3, conn.createOracleArray("PUBLIC.ARRAY_VARCHAR2", StringUtil.splitChunks(templateData.get("definitions"))))
      st.setString(4, templateData.get("version"))
      st.setArray(5, conn.createOracleArray("PUBLIC.ARRAY_VARCHAR2", StringUtil.splitChunks(templateData.get("photoInfos"))))
      st.execute
    } catch {
      case ex: SQLException =>
        println("Biruni ER: uploading error " + ex.getMessage)
    } finally {
      if (st != null) st.close()
      conn.close()
      conn = null
    }
  }

  def clearEasyReportTemplate(sha: String): Unit = {
    var conn = DBConnection.getPoolConnection
    var st: PreparedStatement = null

    try {
      st = conn.prepareStatement("BEGIN Biruni_Route.Clear_Easy_Report_Template(?); END;")
      st.setString(1, sha)
      st.execute
    } catch {
      case ex: SQLException =>
        println("Biruni ER: template cleaning error " + ex.getMessage)
    } finally {
      if (st != null) st.close()
      conn.close()
      conn = null
    }
  }
}
