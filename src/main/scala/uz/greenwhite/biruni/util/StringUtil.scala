package uz.greenwhite.biruni.util

object StringUtil {
  def splitChunks(value: String, length: Int = 10000): Array[String] = {
    if (value.length > length) value.grouped(length).toArray
    else Array(value)
  }

  def gatherChunks(value: Array[String]): String = {
    value.foldLeft(new StringBuilder()) {
      (sb, line) =>
        if (line != null) sb.append(line)
        sb
    }.toString
  }
}