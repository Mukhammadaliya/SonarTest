package uz.greenwhite.biruni.dev

import java.io.File
import java.net.{URL, URLClassLoader}
import jakarta.servlet.{ServletContextEvent, ServletContextListener}
import scala.collection.JavaConverters._

class DevContextListener extends ServletContextListener {
  override def contextInitialized(sce: ServletContextEvent): Unit = {
    val context = sce.getServletContext

    try {
      val prefix = "project_folder:"
      val projectFolders = context.getInitParameterNames.asScala.filter(_.startsWith(prefix)).map(p => context.getInitParameter(p))

      projectFolders.foreach(
        f => loadLibs(f + "\\lib\\")
      )
    } catch {
      case ex: Exception =>
        throw new RuntimeException("Unexpected exception", ex)
    }
  }

  private def loadLibs(path: String): Unit = {
    if (new File(path).exists()) {
      val jarFiles = new File(path).listFiles.filter(_.getName.endsWith(".jar"))

      jarFiles.foreach(f => {
        val filePath = new File(f.toString).toURI.toURL
        val classLoader = ClassLoader.getSystemClassLoader.asInstanceOf[URLClassLoader]
        val method = classOf[URLClassLoader].getDeclaredMethod("addURL", classOf[URL])
        method.setAccessible(true)
        method.invoke(classLoader, filePath)
      })
    }
  }

  override def contextDestroyed(sce: ServletContextEvent): Unit = {
  }

}
