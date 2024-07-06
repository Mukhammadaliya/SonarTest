package uz.greenwhite.biruni.filemanager

import uz.greenwhite.biruni.json.JSON

case class FazoFileData(sha: String,
                        var storeKind: String = "",
                        redirect: Boolean,
                        redirectKind: String,
                        name: String,
                        width: Option[Int],
                        height: Option[Int],
                        cache: Boolean,
                        format: Option[String],
                        quality: Option[Double],
                        var downloadLink: String = "")

case class FazoFile(attachmentName: Option[String], files: List[FazoFileData])

object FazoFile {
  def parse(src: String): FazoFile = {
    if (src.isEmpty) FazoFile(None, Nil)
    else {
      val r = JSON.parseForce(src)

      val attachmentName = r.get("attachment_name").map(_.toString).filter(_.nonEmpty)
      val files = {
        val q = r("files").asInstanceOf[Seq[Map[String, String]]]
        q.map { x =>
          val sha = x("sha")
          FazoFileData(sha = sha,
            name = x.get("name").map(_.trim).filter(_.nonEmpty).getOrElse(sha),
            redirect = x.getOrElse("redirect", "N") == "Y",
            redirectKind = x.getOrElse("redirect_kind", "L"), // L: Load, D: Download
            width = x.get("width").map(_.toInt),
            height = x.get("height").map(_.toInt),
            cache = x.contains("cache"),
            format = x.get("format"),
            quality = x.get("quality").map(_.toDouble)
          )
        }
      }
      FazoFile(attachmentName, files.toList)
    }
  }
}