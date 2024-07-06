package uz.greenwhite.biruni.servlet

import oracle.jdbc.OracleConnection
import uz.greenwhite.biruni.connection.DBConnection

import java.io.FileInputStream
import java.sql.{PreparedStatement, Statement}
import jakarta.servlet.ServletConfig
import jakarta.servlet.http.{HttpServlet, HttpServletRequest, HttpServletResponse}
import uz.greenwhite.biruni.conf.Setting

class FileMigrator extends HttpServlet {
  private var setting: Option[Setting] = None
  private var th: Thread = null

  override def init(config: ServletConfig): Unit = {
    setting = Option(config.getServletContext.getAttribute("setting").asInstanceOf[Setting])
  }

  private def getFilePath(sha: String): String =
    s"${setting.get.filesPath}/files/${sha.substring(0, 2)}/${sha.substring(2, 4)}/$sha"

  private def getFilesInfo: String = {
    val conn: OracleConnection = DBConnection.getSingletonConnection
    val st: Statement = conn.createStatement()

    try {
      val rs = st.executeQuery("SELECT (SELECT COUNT(sha) FROM biruni_files), (SELECT COUNT(sha) FROM biruni_filespace) FROM DUAL")
      rs.next()
      s"${rs.getInt(1)},${rs.getInt(2)}"
    } finally {
      st.close()
      conn.close()
    }
  }

  private def getFilesShaList(conn: OracleConnection): Array[String] = {
    val st: Statement = conn.createStatement()
    var result = Array[String]()

    try {
      val rs = st.executeQuery("""SELECT q.sha
                                    FROM biruni_files q
                                   WHERE NOT EXISTS (SELECT 1
                                                       FROM biruni_filespace w
                                                      WHERE w.sha = q.sha)
                                   FETCH NEXT 10000 ROWS ONLY""")
      while (rs.next()) result :+= rs.getString(1)
      result
    } finally {
      st.close()
    }
  }

  private class Transfer extends Runnable {
    override def run(): Unit = {
      val conn = DBConnection.getSingletonConnection
      conn.setAutoCommit(false)

      while (true) {
        if (conn.isClosed) return

        if (Thread.currentThread().isInterrupted) {
          if (!conn.isClosed) conn.close()
          return
        }

        val filesShaList = getFilesShaList(conn)

        if (filesShaList.isEmpty) {
          if (!conn.isClosed) conn.close()
          return
        }

        for (sha <- filesShaList) {
          var st: PreparedStatement = null

          try {
            if (conn.isClosed) return

            val file = new FileInputStream(getFilePath(sha))

            st = conn.prepareStatement("INSERT INTO biruni_filespace VALUES(?,?)")
            st.setString(1, sha)
            st.setBinaryStream(2, file)
            st.execute
            st.close()

            file.close()
            conn.commit()
          } catch {
            case ex: Exception =>
              if (!conn.isClosed) conn.rollback()
              println(ex.getMessage)
          } finally {
            if (!conn.isClosed && st != null && !st.isClosed) st.close()
          }
        }
      }

      if (!conn.isClosed) conn.close()

    }
  }

  override def doPost(request: HttpServletRequest, response: HttpServletResponse): Unit = {
    val fileMigrator = Option(request.getHeader("FileMigrator")).getOrElse("")

    if (fileMigrator == "files_info") response.getWriter.println(getFilesInfo)
    else if (fileMigrator == "start_transfer") {
      if (th != null && th.isAlive) return
      th = new Thread(new Transfer())
      th.start()
    } else {
      if (th.isAlive && !th.isInterrupted) th.interrupt()
    }
  }
}
