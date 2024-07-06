package uz.greenwhite.biruni.fazo_sync

import scala.annotation.tailrec

object TableDiff {

  import Model._

  def diffStored(from: String, to: String): List[String] = diffStored(makeStored(from), makeStored(to))

  def diffStored(from: Stored, to: Stored): List[String] = {
    val r = List(
      diffTables(from.tables, to.tables),
      diffObjects("sequence", from.sequences, to.sequences),
      diffObjects("package", from.packages, to.packages),
      diffObjects("package body", from.packageBodies, to.packageBodies),
      diffObjects("procedure", from.procedures, to.procedures),
      diffObjects("function", from.functions, to.functions),
      diffObjects("view", from.functions, to.functions)
    )

    r.flatten
  }

  def diffObjects(typeName: String, from: List[String], to: List[String]): List[String] = {
    val r = List(
      (to diff from).map(x => s"drop $typeName $x;"),
      (from diff to).map(x => s"create $typeName $x;")
    )

    r.flatten
  }

  def diffTables(from: List[Table], to: List[Table]): List[String] = {
    val fromNames = getAndSortTableNames(from)
    val toNames = getAndSortTableNames(to)

    require(from.size == fromNames.toSet.size)
    require(to.size == toNames.toSet.size)

    val dropNames = toNames diff fromNames
    val dropQuery = dropNames.reverse.map(x => s"drop table $x;")

    val fromMap = from.map(x => x.name -> x).toMap
    val toMap = to.map(x => x.name -> x).toMap

    val alterQuery = fromNames map { n =>
      val f = fromMap(n)
      toMap.get(n) match {
        case Some(t) => diffTable(f, t) match {
          case Nil => Nil
          case _ if f.tablespace.isEmpty => s"drop table ${f.name};" :: createQuery(f)
          case x => x
        }
        case None => createQuery(f)
      }
    }

    val r = dropQuery :: alterQuery

    r.flatten
  }

  def createQuery(t: Table): List[String] = {
    val clauseTablespace =
      if (t.tablespace.isEmpty) ""
      else s"tablespace ${t.tablespace}"
    val clauseTemporary =
      if (t.tablespace.nonEmpty) ""
      else "global temporary"

    val createQuery = s"create $clauseTemporary table ${t.name} (\n\t${t.columnList.map(_.sql).mkString(",\n\t")}\n) $clauseTablespace;"

    val alterQueries = (t.primaryKeys ::: t.uniqueKeys ::: t.foreignKeys ::: t.checks ::: t.indexList).map(_.clauseAdd)

    createQuery :: alterQueries
  }

  def getAndSortTableNames(tables: List[Table]): List[String] = {
    val r = for {
      t <- tables
      c <- t.foreignKeys
    } yield c.refTableName -> t.name

    val all = tables.map(x => x.name -> x.name)

    tSort(all ::: r)
  }

  def diffTable(from: String, to: String): List[String] = {
    val f = Model.makeTable(StoredMeta.makeTable(from))
    val t = Model.makeTable(StoredMeta.makeTable(to))

    diffTable(f, t)
  }

  def diffTable(from: Table, to: Table): List[String] = {
    require(from.name == to.name)

    val r = List(
      diffProperties(from, to),
      diffColumns(from, to),
      diffDropAndAdd(from.indexList, to.indexList),
      diffDropAndAdd(from.primaryKeys, to.primaryKeys),
      diffDropAndAdd(from.uniqueKeys, to.uniqueKeys),
      diffDropAndAdd(from.foreignKeys, to.foreignKeys),
      diffDropAndAdd(from.checks, to.checks))

    r.flatten
  }

  def diffDropAndAdd[A](from: List[DropAndAdd], to: List[DropAndAdd]): List[String] = {
    val fromSet = from.toSet
    val toSet = to.toSet

    val same = fromSet.intersect(toSet)
    val dropQuery = (toSet -- same).map(_.clauseDrop)
    val addQuery = (fromSet -- same).map(_.clauseAdd)

    val r = dropQuery.toList ::: addQuery.toList

    r.filterNot(_.isEmpty)
  }

  def diffProperties(from: Table, to: Table): List[String] = {
    val buf = List.newBuilder[String]

    if (from.tablespace != to.tablespace) {
      buf += s"tablespace of ${from.name}: from=${from.tablespace} to=${to.tablespace}"
    }

    buf.result
  }

  def diffColumns(from: Table, to: Table): List[String] = {
    val fromCols = from.columnList
    val toCols = to.columnList

    val dropCols =
      toCols.filterNot(x => fromCols.exists(_.name == x.name)).map(c => s"drop column ${c.name}")

    val modifySql = fromCols.map { f =>
      toCols.find(_.name == f.name) match {
        case Some(t) if t != f =>
          if (f.virtual == t.virtual) {
            if (f.nullable != t.nullable) {
              List(s"modify ${f.sql}")
            } else if (f.dataDefault == "" && t.dataDefault != "") {
              List(s"modify ${f.name} ${f.dataTypeSql} default null")
            } else {
              List(s"modify ${f.name} ${f.dataTypeSql} ${f.defaultSql}")
            }
          } else {
            List(s"drop column ${t.name}",
              s"add ${f.sql}")
          }
        case None => List(s"add ${f.sql}")
        case _ => Nil
      }
    }

    val r = dropCols ::: modifySql.flatten

    val s = r.filterNot(_.isEmpty)

    s map (x => s"alter table ${from.name} $x;")
  }

  def tSort[A](edges: List[(A, A)]): List[A] = {
    @tailrec
    def tSort(toPreds: Map[A, Set[A]], done: List[A]): List[A] = {
      val (noPreds, hasPreds) = toPreds.partition {
        _._2.isEmpty
      }
      if (noPreds.isEmpty) {
        if (hasPreds.isEmpty) done else done ++ hasPreds.keys
      } else {
        val found = noPreds.keys
        tSort(hasPreds.mapValues {
          _ -- found
        }, done ++ found)
      }
    }

    val toPred = edges.foldLeft(Map[A, Set[A]]()) { (acc, e) =>
      acc + (e._1 -> acc.getOrElse(e._1, Set())) + (e._2 -> (acc.getOrElse(e._2, Set()) + e._1))
    }
    tSort(toPred, List())
  }

}