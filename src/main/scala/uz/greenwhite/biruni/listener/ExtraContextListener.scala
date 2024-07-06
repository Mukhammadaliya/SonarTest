package uz.greenwhite.biruni.listener

import uz.greenwhite.biruni.jobs.{ImageCleanerJob, JobRunner, S3FileCleanerJob}
import jakarta.servlet.{ServletContextEvent, ServletContextListener}

class ExtraContextListener extends ServletContextListener {
  private var jobRunner: JobRunner = _
  private var imageCleanerJob: ImageCleanerJob = _
  private var s3FileCleanerJob: S3FileCleanerJob = _

  override def contextInitialized(servletContextEvent: ServletContextEvent): Unit = {
    val context = servletContextEvent.getServletContext

    jobRunner = new JobRunner(context)
    imageCleanerJob = new ImageCleanerJob(context)
    s3FileCleanerJob = new S3FileCleanerJob(context)

    jobRunner.start()
    imageCleanerJob.start()
    s3FileCleanerJob.start()
  }

  override def contextDestroyed(servletContextEvent: ServletContextEvent): Unit = {
    jobRunner.stop()
    imageCleanerJob.stop()
    s3FileCleanerJob.stop()
  }
}
