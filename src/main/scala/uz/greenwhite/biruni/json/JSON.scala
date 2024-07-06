package uz.greenwhite.biruni.json

import scala.annotation.switch
import scala.collection.mutable.ListBuffer

class JSON(val json: String) {
  override def toString: String = json
}

object JSON {

  def apply(json: String) = new JSON(json)

  private class Parser(src: String) {
    val token = new JsonToken(src)

    def parseSeq: Seq[Any] = {
      val r = ListBuffer[Any]()
      var required = false
      var result = true
      while (result) {

        token.next match {
          case ']' => if (required) throw token.error else result = false
          case _ => r += parseToken
        }

        if (result) {
          (token.next: @switch) match {
            case ']' => result = false
            case ',' => required = true
            case _ => throw token.error
          }
        }
      }
      r.result
    }

    def parseMap: Map[String, Any] = {
      val r = Map.newBuilder[String, Any]
      var required = false
      var result = true

      while (result) {
        (token.next: @switch) match {
          case '}' => if (required) throw token.error else result = false
          case '"' =>
            r += token.st -> {
              if (token.next == ':') {
                token.next
                parseToken
              } else throw token.error
            }
          case _ => throw token.error
        }

        if (result) {
          (token.next: @switch) match {
            case '}' => result = false
            case ',' => required = true
            case _ => throw token.error()
          }
        }

      }

      r.result
    }

    def parseToken: Any = (token.kind: @switch) match {
      case '"' => token.st
      case '[' => parseSeq
      case '{' => parseMap
      case _ => throw token.error
    }

    def resultForce: Map[String, Any] = {
      token.next
      if (token.kind == '{') {
        val r = parseMap
        if (token.tryNext) throw token.error
        r
      } else throw token.error
    }

    def result: Option[Map[String, Any]] = {
      try {
        Some(resultForce)
      } catch {
        case _: JsonError => None
      }
    }

    def resultSeqForce: Seq[Any] = {
      token.next
      if (token.kind == '[') {
        val r = parseSeq
        if (token.tryNext) throw token.error
        r
      } else throw token.error
    }

    def resultSeq: Option[Seq[Any]] = {
      try {
        Some(resultSeqForce)
      } catch {
        case _: JsonError => None
      }
    }
  }

  def parseForce(src: String): Map[String, Any] = {
    val parser = new Parser(src)
    parser.resultForce
  }

  def parse(src: String): Option[Map[String, Any]] = {
    val parser = new Parser(src)
    parser.result
  }

  def parseSeqForce(src: String): Seq[Any] = {
    val parser = new Parser(src)
    parser.resultSeqForce
  }

  def parseSeq(src: String): Option[Seq[Any]] = {
    val parser = new Parser(src)
    parser.resultSeq
  }

  def stringify(obj: Any): String = {

    obj match {
      case x: collection.Map[_, _] => makeMap(x.asInstanceOf[Map[String, Any]])
      case x: collection.Seq[_] => makeSeq(x)
      case x: Array[Any] => makeSeq(x)
      case x: String => quote(x)
      case x: java.lang.Character => quote(x.toString)
      case x: Int => "\"" + x + "\""
      case x: JSON => x.json
      case x: Long => "\"" + x + "\""
      case x => throw new JsonError("Error json stringify className=" + x.getClass.getName)
    }

  }

  private def makeMap(s: collection.Map[String, Any]): String = {
    val r = for ((key, value) <- s) yield {
      "\"" + key + "\":" + stringify(value)
    }

    r mkString("{", ",", "}")
  }

  private def makeSeq(s: Seq[Any]): String = {
    val r = for (value <- s) yield stringify(value)

    r mkString("[", ",", "]")
  }

  private def quote(s: String): String = s match {
    case null => "null"
    case _ =>
      new StringBuilder(s.length + 2)
        .append('"')
        .append(s.foldLeft(new StringBuilder(""))((a, b) => a.append(escape(b, '"'))).toString)
        .append('"')
        .toString
  }

  private def escape(c: Char, quoteChar: Char): String = c match {
    case '"' if c == quoteChar => "\\" + c
    case '"' => "" + c
    case '\'' if c == quoteChar => "\\" + c
    case '\'' => "" + c
    case '/' => "\\/"
    case '\\' => "\\\\"
    case '\b' => "\\b"
    case '\f' => "\\f"
    case '\n' => "\\n"
    case '\r' => "\\r"
    case '\t' => "\\t"
    case _ => "" + c
  }

}