package uz.greenwhite.biruni.jobs

import java.io.File
import java.util.Calendar
import java.util.concurrent.{Executors, ScheduledExecutorService, TimeUnit}
import jakarta.servlet.ServletContext
import uz.greenwhite.biruni.conf.Setting
import uz.greenwhite.biruni.util.FileUtil

class ImageCleanerJob(context: ServletContext) {
  private var imageCleanerJob: ScheduledExecutorService = _

  class ImageCleanerJob(filesPath: String) extends Runnable {
    override def run(): Unit = {
      val sourceDir = new File(s"$filesPath/images")
      if (sourceDir.exists()) {
        sourceDir.renameTo(new File(s"$filesPath/removed_images"))
        FileUtil.deleteDirectory(s"$filesPath/removed_images")
      }
    }
  }

  def start(): Unit = {
    val filesPath = context.getAttribute("setting").asInstanceOf[Setting].filesPath
    val param = context.getInitParameter("image_cleaner")

    if (param != null) {
      val calendar = Calendar.getInstance()
      val params = param.split("/")
      val jobTime = params(0).split(":").map(Integer.parseInt).reduceRight((hh, mm) => hh * 60 + mm)
      val currentTime = calendar.get(Calendar.HOUR_OF_DAY) * 60 + calendar.get(Calendar.MINUTE)
      val delayTime = (if (jobTime >= currentTime) jobTime else jobTime + 24 * 60) - currentTime
      val interval = Integer.parseInt(params(1)) * 24 * 60

      if (interval >= 24 * 60) {
        println(s"ImageCleaner will be started at ${params(0)} every ${params(1)} days")
        imageCleanerJob = Executors.newSingleThreadScheduledExecutor()
        imageCleanerJob.scheduleAtFixedRate(new ImageCleanerJob(filesPath), delayTime, interval, TimeUnit.MINUTES)
      }
    }
  }

  def stop(): Unit = {
    if (imageCleanerJob != null) imageCleanerJob.shutdown()
  }
}
