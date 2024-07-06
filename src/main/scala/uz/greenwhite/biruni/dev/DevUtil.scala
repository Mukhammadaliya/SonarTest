package uz.greenwhite.biruni.dev

import oracle.jdbc.{OracleCallableStatement, OracleTypes}
import oracle.jdbc.OracleConnection
import uz.greenwhite.biruni.connection.DBConnection

import java.io.File
import java.nio.file.Path

object DevUtil {
  def loadProjectCodes(): Set[String] = {
    var conn: OracleConnection = null
    var st: OracleCallableStatement = null

    try {
      conn = DBConnection.getPoolConnection
      st = conn.prepareCall("BEGIN Biruni.Get_Project_Codes(?); END;").asInstanceOf[OracleCallableStatement]
      st.registerOutParameter(1, OracleTypes.VARCHAR)

      st.execute()

      st.getString(1).split(";").toSet
    } catch {
      case ex: Throwable =>
        println("Failed to load project codes. Error:" + ex.getMessage)
        Set.empty
    } finally {
      if (st != null) st.close()
      if (conn != null) conn.close()
      conn = null
    }
  }

  def readProjectFolders(projectsFolder: String): Array[(String, String)] = {
    val f = new java.io.File(projectsFolder)

    if (f.exists() && f.isDirectory) {
      f.listFiles()
        .filter(p => p.isDirectory)
        .map(p => p.getPath -> Path.of(p.getPath, "main", "page", "form").toFile)
        .filter(p => p._2.exists() && p._2.isDirectory)
        .map(p => p._2.listFiles().head.getName -> (p._1 + File.separator + "main"))
    } else Array.empty
  }
}
