package uz.greenwhite.biruni.conf

import java.nio.file.{Path, Paths}

case class SettingDev(editorPath: String, projectFolders: Seq[(String, String)], googleProjectNumber: String, googleServiceAccountKeyFilePath: String) {
  val projectCodes: Set[String] = projectFolders.map(_._1).toSet

  def getPath(projectCode: String, path: String): Option[Path] = projectFolders.find(_._1 == projectCode) match {
    case Some((_, folderPath)) => Option(Paths.get(folderPath, path))
    case _ => None
  }
}

case class Setting(contextPath: String,
                   settingPath: String,
                   requestHeaderKeys: List[String],
                   requestCookieKeys: List[String],
                   maxUploadSize: Option[Long],
                   filesPath: String,
                   dev: Option[SettingDev])

