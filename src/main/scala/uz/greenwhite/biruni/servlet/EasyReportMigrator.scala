package uz.greenwhite.biruni.servlet

import oracle.jdbc.OracleConnection
import uz.greenwhite.biruni.connection.DBConnection
import uz.greenwhite.biruni.easyreport.{ERMetadataReader, ERUtil}

import java.sql.{PreparedStatement, ResultSet, SQLException}
import java.util
import jakarta.servlet.http.{HttpServlet, HttpServletRequest, HttpServletResponse}
import uz.greenwhite.biruni.filemanager.FileManager

class EasyReportMigrator extends HttpServlet {
  private final val THREAD_NAME: String = "EasyReportMigrator"
  private var migrationThread: Thread = _

  private def getOutdatedEasyReports: Array[String] = {
    var conn: OracleConnection = DBConnection.getPoolConnection
    var st: PreparedStatement = null
    var rs: ResultSet = null
    var result = Array[String]()

    try {
      val query = "SELECT t.template_sha FROM ker_templates t WHERE EXISTS (SELECT 1 FROM biruni_easy_report_templates k WHERE k.sha = t.template_sha AND k.version <> ?)"
      st = conn.prepareStatement(query)
      st.setString(1, ERUtil.VERSION)
      st.execute()

      rs = st.getResultSet
      while (rs.next()) result :+= rs.getString(1)
      result
    } finally {
      if (rs != null) rs.close()
      if (st != null) st.close()
      conn.close()
      conn = null
    }
  }

  private def splitChunks(value: String): Array[String] = {
    if (value.length > 10000) value.grouped(10000).toArray
    else Array(value)
  }

  private def uploadEasyReportMetadata(sha: String, templateData: util.Map[String, String]): Unit = {
    var conn = DBConnection.getSingletonConnection
    var st: PreparedStatement = null

    try {
      st = conn.prepareStatement("BEGIN Biruni_Route.Upload_Easy_Report_Metadata(?,?,?,?,?); END;")
      st.setString(1, sha)
      st.setArray(2, conn.createOracleArray("PUBLIC.ARRAY_VARCHAR2", splitChunks(templateData.get("metadata"))))
      st.setArray(3, conn.createOracleArray("PUBLIC.ARRAY_VARCHAR2", splitChunks(templateData.get("definitions"))))
      st.setString(4, templateData.get("version"))
      st.setArray(5, conn.createOracleArray("PUBLIC.ARRAY_VARCHAR2", splitChunks(templateData.get("photoInfos"))))
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

  private def interrupt(): Unit = {
    if (migrationThread != null && migrationThread.isAlive) {
      migrationThread.interrupt()
      migrationThread = null
    }
  }

  private class Migrate extends Runnable {
    override def run(): Unit = {
      val outdatedEasyReports = getOutdatedEasyReports

      for (sha <- outdatedEasyReports) {
        try {
          val easyReportFile = FileManager.loadFileAsInputStream(sha)
          val easyReportMetadata = ERMetadataReader.read(easyReportFile)
          uploadEasyReportMetadata(sha, easyReportMetadata)
        } catch {
          case ex: Exception =>
            println(ex.getMessage)
        }

        if (migrationThread == null || migrationThread.isInterrupted) return
      }

      interrupt()
    }
  }

  override def doPost(request: HttpServletRequest, response: HttpServletResponse): Unit = {
    val easyReportMigratorAction = Option(request.getHeader("easy_report_migrator_action")).getOrElse("")

    if (easyReportMigratorAction.equals("start")) {
      if (migrationThread == null) {
        migrationThread = new Thread(new Migrate(), THREAD_NAME)
        migrationThread.start()
      }
    } else if (easyReportMigratorAction.equals("stop")) {
      interrupt()
    }
  }
}
