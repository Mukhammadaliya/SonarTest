package uz.greenwhite.biruni.jobs

import oracle.jdbc.{OracleCallableStatement, OracleConnection, OracleTypes}
import uz.greenwhite.biruni.connection.DBConnection
import uz.greenwhite.biruni.json.JSON

import java.time.LocalDateTime
import java.util.concurrent.{Executors, ScheduledExecutorService, TimeUnit}
import jakarta.servlet.ServletContext
import uz.greenwhite.biruni.util.StringUtil

case class JobResult(status: Int,
                     output: String) {
  val isSuccess: Boolean = status < 300
}

trait JobProvider {
  def run(requestData: String): JobResult
}

class DefaultJobProvider(className: String) extends JobProvider {
  override def run(requestData: String): JobResult = {
    JobResult(status = 400,
      output = s"class is not defined $className")
  }
}

class JobRunner(context: ServletContext) {
  private var mainJob: ScheduledExecutorService = _
  private val otherJobs = collection.mutable.Map[String, ScheduledExecutorService]()

  private case class JobInfo(hash: String,
                             code: String,
                             className: String,
                             delay: Int,
                             period: Int)

  private class JobExecutor(info: JobInfo) extends Runnable {
    private def getProvider: JobProvider = {
      try {
        val clazz = Class.forName(info.className).asInstanceOf[Class[JobProvider]]

        clazz.getDeclaredConstructor().newInstance()
      } catch {
        case _: Exception =>
          new DefaultJobProvider(info.className)
      }
    }

    private def getRequestStatement(conn: OracleConnection): OracleCallableStatement = {
      val query = "BEGIN Biruni_App_Job.Execute_Request_Job(?,?,?); commit; END;"
      conn.prepareCall(query).asInstanceOf[OracleCallableStatement]
    }

    private def getResponseStatement(conn: OracleConnection): OracleCallableStatement = {
      val query = "BEGIN Biruni_App_Job.Execute_Response_Job(?,?,?); commit; END;"
      conn.prepareCall(query).asInstanceOf[OracleCallableStatement]
    }

    private def getLogStatement(conn: OracleConnection): OracleCallableStatement = {
      val query = "BEGIN Biruni_App_Job.Save_Application_Job_Log(?,?,?,?); commit; END;"
      conn.prepareCall(query).asInstanceOf[OracleCallableStatement]
    }

    private def runRequest(): Map[String, String] = {
      val k = Map("code" -> info.code, "hash" -> info.hash)
      var conn: OracleConnection = null
      var cs: OracleCallableStatement = null

      var response: String = null
      var output: Array[String] = null

      try {
        conn = DBConnection.getPoolConnectionAndFreeResources
        cs = getRequestStatement(conn)

        cs.setString(1, JSON.stringify(k))
        cs.registerOutParameter(2, OracleTypes.VARCHAR)
        cs.registerOutParameter(3, OracleTypes.ARRAY, "PUBLIC.ARRAY_VARCHAR2")

        cs.execute

        response = cs.getString(2)
        output = cs.getArray(3).getArray.asInstanceOf[Array[String]]
      } catch {
        case ex: Exception =>
          return Map("status" -> "E", "error" -> s"runRequest Exception: ${ex.getMessage}", "output" -> "")
      } finally {
        if (cs != null) cs.close()
        if (conn != null) {
          conn.close()
        }
      }

      val outputText = StringUtil.gatherChunks(output)
      val res = JSON.parseForce(response)

      Map("status" -> res("status").asInstanceOf[String],
        "error" -> res.getOrElse("error", "").asInstanceOf[String],
        "output" -> outputText)
    }

    private def runResponse(output: String): Map[String, String] = {
      val k = Map("code" -> info.code, "hash" -> info.hash)
      var conn: OracleConnection = null
      var cs: OracleCallableStatement = null

      var response: String = null

      try {
        conn = DBConnection.getPoolConnectionAndFreeResources
        cs = getResponseStatement(conn)

        val chunks: Array[String] =
          if (output.length > 10000) output.grouped(10000).toArray
          else Array(output)

        cs.setString(1, JSON.stringify(k))
        cs.setArray(2, conn.createOracleArray("PUBLIC.ARRAY_VARCHAR2", chunks))
        cs.registerOutParameter(3, OracleTypes.VARCHAR)

        cs.execute

        response = cs.getString(3)
      } catch {
        case ex: Exception =>
          return Map("status" -> "E", "error" -> s"runRequest Exception: ${ex.getMessage}")
      } finally {
        if (cs != null) cs.close()
        if (conn != null) {
          conn.close()
        }
      }

      val res = JSON.parseForce(response)

      Map("status" -> res("status").asInstanceOf[String],
        "error" -> res.getOrElse("error", "").asInstanceOf[String])
    }

    private def saveLog(errorMessage: String): Unit = {
      var conn: OracleConnection = null
      var cs: OracleCallableStatement = null

      try {
        conn = DBConnection.getPoolConnectionAndFreeResources
        cs = getLogStatement(conn)

        cs.setString(1, info.code)
        cs.setString(2, "F")
        cs.setString(3, "JB")
        cs.setString(4, errorMessage.slice(0, 500))

        cs.execute
      } catch {
        case ex: Exception =>
          println(s"Error in saveLog: ${ex.getMessage}")
      } finally {
        if (cs != null) cs.close()
        if (conn != null) {
          conn.close()
        }
      }
    }

    override def run(): Unit = {
      try {
        println(s"start request ${LocalDateTime.now}")

        val req = runRequest()
        if (!req("status").equals("S")) {
          println(s"error after runRequest jobCode => ${info.code}, jobClass => ${info.className} error text: ${req("error")}")
          return
        }

        println(s"start provider ${LocalDateTime.now}")

        val provider = getProvider
        val jobRes = provider.run(req("output"))

        if (!jobRes.isSuccess) {
          println(s"error after jobProvider jobCode(${info.code}) jobClass => ${info.className} error text: ${jobRes.output}")
          saveLog(jobRes.output)
          return
        }

        println(s"start response ${LocalDateTime.now}")

        val resp = runResponse(jobRes.output)
        if (!resp("status").equals("S")) {
          println(s"error after runResponse jobCode => ${info.code}, jobClass => ${info.className} error text: ${resp("error")}")
        }

        println("*********************************************")
      } catch {
        case ex: Exception =>
          println("Exception handler JOB")
          ex.printStackTrace()
      }
    }
  }

  private def jobExecutor(info: JobInfo): ScheduledExecutorService = {
    println(s"the job ${info.code} starts working delay ${info.delay} minutes period ${info.period} minutes")

    val scheduler = Executors.newSingleThreadScheduledExecutor()

    scheduler.scheduleAtFixedRate(new JobExecutor(info), info.delay, info.period, TimeUnit.MINUTES)

    scheduler
  }

  private class MainJobExecutor extends Runnable {
    private def getStatement(conn: OracleConnection): OracleCallableStatement = {
      val query = "BEGIN Biruni_App_Job.Application_Jobs_Info(?); END;"
      conn.prepareCall(query).asInstanceOf[OracleCallableStatement]
    }

    private def evalJobs(jobList: Seq[Any]): Unit = {
      val jobHashes = otherJobs.keySet.toList
      val availableJobHashes = jobList.map(x => x.asInstanceOf[Map[String, Any]]("hash").asInstanceOf[String])

      jobList.foreach(x => {
        val v = x.asInstanceOf[Map[String, Any]]
        val hash = v("hash").asInstanceOf[String]


        if (!jobHashes.contains(hash)) {
          val info = JobInfo(hash = hash,
            code = v("code").asInstanceOf[String],
            className = v("class_name").asInstanceOf[String],
            delay = v("delay").asInstanceOf[String].toInt,
            period = v("period").asInstanceOf[String].toInt)

          otherJobs += (info.hash -> jobExecutor(info))
        }
      })

      jobHashes.filterNot(availableJobHashes.contains(_)).foreach(x => {
        otherJobs(x).shutdownNow()
        otherJobs.remove(x)
      })
    }

    override def run(): Unit = {
      println(s"start main job ${LocalDateTime.now}")
      var conn: OracleConnection = null
      var cs: OracleCallableStatement = null

      try {
        conn = DBConnection.getPoolConnectionAndFreeResources
        cs = getStatement(conn)

        cs.registerOutParameter(1, OracleTypes.ARRAY, "PUBLIC.ARRAY_VARCHAR2")
        cs.execute

        val output = cs.getArray(1).getArray.asInstanceOf[Array[String]]
        val outputText = StringUtil.gatherChunks(output)
        evalJobs(JSON.parseSeqForce(outputText))
      } catch {
        case ex: Exception =>
          println("Exception handler main job")
          ex.printStackTrace()
      } finally {
        if (cs != null) cs.close()
        if (conn != null) conn.close()
      }
    }
  }

  def start(): Unit = {
    val interval = context.getInitParameter("job_runner_interval")

    if (interval == null) return

    println("Biruni application server jobs are running")

    mainJob = Executors.newSingleThreadScheduledExecutor()
    mainJob.scheduleAtFixedRate(new MainJobExecutor, 0, interval.toInt, TimeUnit.MINUTES)
  }

  def stop(): Unit = {
    if (mainJob != null) mainJob.shutdownNow()
    otherJobs.foreach(job => {
      job._2.shutdownNow()
    })
  }
}
