package uz.greenwhite.biruni.fazo_sync

import scala.language.implicitConversions

object StoredMeta {

  case class Column(name: String,
                    virtual: String,
                    dataType: String,
                    dataSize: Int,
                    dataScale: Int,
                    nullable: String,
                    charUsed: String,
                    dataDefault: String)

  case class Constraint(name: String,
                        constraintType: String,
                        enabled: String,
                        deferrable: String,
                        deferred: String,
                        validated: String,
                        generated: String,
                        refConstraintName: String,
                        refTableName: String,
                        refColumnNames: List[String],
                        deleteRule: String,
                        searchCondition: String,
                        indexName: String,
                        columnNames: List[String],
                        childConstraints: List[String])

  case class Index(name: String,
                   indexType: String,
                   uniqueness: String,
                   tablespace: String,
                   generated: String,
                   columnNames: List[String],
                   expr: List[String])

  case class Table(fazoVersion: String,
                   name: String,
                   tablespace: String,
                   columnList: List[Column],
                   constraintList: List[Constraint],
                   indexList: List[Index])

  def getString(m: Map[String, Any], key: String): String = m(key).asInstanceOf[String]

  def getString(m: List[Any], i: Int): String = m(i).asInstanceOf[String]

  private def toInt(x: String) = if (x.nonEmpty) x.toInt else 0

  def getInt(m: Map[String, Any], key: String): Int = toInt(getString(m, key))

  def getInt(m: List[Any], i: Int): Int = toInt(getString(m, i))

  def getList(m: Map[String, Any], key: String): List[Any] = m.getOrElse(key, Nil).asInstanceOf[List[Any]]

  def getList(m: List[Any], i: Int): List[Any] = m(i).asInstanceOf[List[Any]]

  def getMap(m: Map[String, Any], key: String): Map[String, Any] = m(key).asInstanceOf[Map[String, Any]]

  def getMap(m: List[Any], i: Int): Map[String, Any] = m(i).asInstanceOf[Map[String, Any]]

  def makeColumn(m: Map[String, Any]): Column =
    Column(
      name = getString(m, "name"),
      virtual = getString(m, "virtual"),
      dataType = getString(m, "data_type"),
      dataSize = getInt(m, "data_size"),
      dataScale = getInt(m, "data_scale"),
      nullable = getString(m, "nullable"),
      charUsed = m.getOrElse("char_used", "B").asInstanceOf[String],
      dataDefault = getString(m, "data_default"))

  def makeConstraint(m: Map[String, Any]): Constraint =
    Constraint(
      name = getString(m, "name"),
      constraintType = getString(m, "type"),
      enabled = getString(m, "enabled"),
      deferrable = getString(m, "deferrable"),
      deferred = getString(m, "deferred"),
      validated = getString(m, "validated"),
      generated = getString(m, "generated"),
      refConstraintName = getString(m, "ref_constraint"),
      refTableName = getString(m, "ref_table"),
      refColumnNames = getList(m, "ref_column_names").map(_.asInstanceOf[String]),
      deleteRule = getString(m, "delete_rule"),
      searchCondition = getString(m, "search_condition"),
      indexName = getString(m, "index_name"),
      columnNames = getList(m, "column_names").map(_.asInstanceOf[String]),
      childConstraints = getList(m, "child_constraints").map(_.asInstanceOf[String]))

  def makeIndex(m: Map[String, Any]): Index =
    Index(
      name = getString(m, "name"),
      indexType = getString(m, "index_type"),
      uniqueness = getString(m, "uniqueness"),
      tablespace = getString(m, "tablespace"),
      generated = getString(m, "generated"),
      columnNames = getList(m, "column_names").map(_.asInstanceOf[String]),
      expr = getList(m, "expr").map(_.asInstanceOf[String]))

  implicit def Any2Map(x: Any): Map[String, Any] = x.asInstanceOf[Map[String, Any]]

  def makeTable(m: Map[String, Any]): Table =
    Table(
      fazoVersion = getString(m, "fv"),
      name = getString(m, "name"),
      tablespace = getString(m, "tablespace"),
      columnList = getList(m, "columns").map(makeColumn(_)),
      constraintList = getList(m, "constraints").map(makeConstraint(_)),
      indexList = getList(m, "indexes").map(makeIndex(_)))

  case class Stored(tables: List[Table],
                    sequences: List[String],
                    packages: List[String],
                    packageBodies: List[String],
                    procedures: List[String],
                    functions: List[String],
                    views: List[String])

  def makeStored(m: Map[String, Any]): Stored = {
    def names(key: String): List[String] = getList(m, key).map(_.asInstanceOf[String])

    Stored(
      tables = getList(m, "tables").map(makeTable(_)),
      sequences = names("sequences"),
      packages = names("packages"),
      packageBodies = names("package_bodies"),
      procedures = names("procedures"),
      functions = names("functions"),
      views = names("views")
    )
  }

  def makeTable(s: String): Table =
    uz.greenwhite.biruni.json.JSON.parse(s) match {
      case Some(r: Map[_, _]) => makeTable(r)
      case _ => sys.error("Json parse error")
    }

  def makeStored(s: String): Stored =
    uz.greenwhite.biruni.json.JSON.parse(s) match {
      case Some(r: Map[_, _]) => makeStored(r)
      case _ => sys.error("Json parse error")
    }

}