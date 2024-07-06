package uz.greenwhite.biruni.fazo_sync

object Model {

  object DataType extends Enumeration {
    val Varchar2, Number, Date, Clob, Other = Value
  }

  case class Column(name: String,
                    virtual: Boolean,
                    dataType: DataType.Value,
                    dataSize: Int,
                    dataScale: Int,
                    nullable: Boolean,
                    charUsed: String,
                    otherSql: String,
                    dataDefault: String) {

    def dataTypeSql: String = dataType match {
      case DataType.Varchar2 if charUsed == "B" => "varchar2(" + dataSize + " byte)"
      case DataType.Varchar2 => "varchar2(" + dataSize + " char)"
      case DataType.Number => "number(" + dataSize + (if (dataScale > 0) "," + dataScale else "") + ")"
      case DataType.Date => "date"
      case DataType.Clob => "clob"
      case DataType.Other => otherSql
    }

    def nullSql: String = if (nullable) "null" else "not null"

    def defaultSql: String = if (dataDefault.nonEmpty) "default " + dataDefault else ""

    def nvl(s: String): String = if (s.isEmpty) s else " " + s

    def sql: String =
      if (virtual) {
        name + " as (" + dataDefault + ")"
      } else {
        name + " " + dataTypeSql + nvl(defaultSql) + nvl(nullSql)
      }
  }

  def makeColumn(c: StoredMeta.Column): Column = Column(
    name = c.name,
    virtual = c.virtual match {
      case "YES" => true
      case "NO" => false
    },
    dataType = c.dataType match {
      case "VARCHAR2" => DataType.Varchar2
      case "NUMBER" => DataType.Number
      case "DATE" => DataType.Date
      case "CLOB" => DataType.Clob
      case _ => DataType.Other
    },
    dataSize = c.dataSize,
    dataScale = c.dataScale,
    nullable = c.nullable match {
      case "Y" => true
      case "N" => false
    },
    charUsed = c.charUsed,
    otherSql = c.dataType.toLowerCase,
    dataDefault = {
      val d = c.dataDefault.trim
      if ("null" == d) "" else d
    })

  case class ConstraintInfo(tableName: String,
                            name: String,
                            enabled: Boolean,
                            deferrable: Boolean,
                            deferred: Boolean,
                            validated: Boolean,
                            generated: Boolean,
                            columnNames: List[String])

  trait DropAndAdd {
    def clauseDrop: String

    def clauseAdd: String
  }

  case class PrimaryKey(ci: ConstraintInfo,
                        expr: List[String],
                        indexTablespace: String,
                        indexName: String) extends DropAndAdd {

    val clauseTableSpace: String =
      if (indexTablespace.isEmpty) ""
      else s" using index tablespace $indexTablespace"

    def clauseDrop: String =
      if (ci.name.isEmpty) ci.tableName + " has not primary key name to drop"
      else s"alter table ${ci.tableName} drop constraint ${ci.name};\ndrop index $indexName;"

    def clauseAdd: String =
      if (ci.name.isEmpty) ci.tableName + " has not primary key name to add"
      else s"alter table ${ci.tableName} add constraint ${ci.name} primary key ${
        expr.mkString("(", ",", ")")
      }$clauseTableSpace;"
  }

  case class UniqueKey(ci: ConstraintInfo,
                       expr: List[String],
                       indexTablespace: String,
                       indexName: String) extends DropAndAdd {

    val clauseTableSpace: String =
      if (indexTablespace.isEmpty) ""
      else s" using index tablespace $indexTablespace"

    def clauseDrop: String =
      if (ci.name.isEmpty) ci.tableName + " has not unique constraint name to drop"
      else s"alter table ${ci.tableName} drop constraint ${ci.name};\ndrop index $indexName;"

    def clauseAdd: String =
      if (ci.name.isEmpty) ci.tableName + " has not unique constraint name to add"
      else s"alter table ${ci.tableName} add constraint ${ci.name} unique " +
        s"${expr.mkString("(", ",", ")")}$clauseTableSpace;"
  }

  case class ForeignKey(ci: ConstraintInfo,
                        refConstraintName: String,
                        refTableName: String,
                        refColumnNames: List[String],
                        deleteRule: String) extends DropAndAdd {

    val deleteRule2: String =
      if (deleteRule.isEmpty) ""
      else s"on delete $deleteRule"

    def clauseDrop: String =
      if (ci.name.isEmpty) ci.tableName + " has not foreign key name to drop"
      else s"alter table ${ci.tableName} drop constraint ${ci.name};"

    def clauseAdd: String =
      if (ci.name.isEmpty) ci.tableName + " has not foreign key name to add"
      else s"alter table ${ci.tableName} add constraint ${ci.name} foreign key " +
        s"${ci.columnNames.mkString("(", ",", ")")} references " +
        s"$refTableName ${refColumnNames.mkString("(", ",", ")")} $deleteRule2;"
  }

  case class Check(ci: ConstraintInfo,
                   searchCondition: String) extends DropAndAdd {

    def clauseDrop: String =
      if (ci.name.isEmpty) ci.tableName + " has not check name to drop\n" + this
      else s"alter table ${ci.tableName} drop constraint ${ci.name};"

    def clauseAdd: String =
      if (ci.name.isEmpty) ci.tableName + " has not check name to add"
      else {
        val defer = ci.deferrable match {
          case true if ci.deferred => " deferrable initially deferred"
          case true => " deferrable"
          case _ => ""
        }
        s"alter table ${ci.tableName} add constraint ${ci.name} check ($searchCondition)$defer;"
      }
  }

  def makeConstraintInfo(tbl: StoredMeta.Table, m: StoredMeta.Constraint): ConstraintInfo =
    ConstraintInfo(
      tableName = tbl.name,
      name = m.name,
      enabled = m.enabled match {
        case "Y" => true
        case "N" => false
      },
      deferrable = m.deferrable match {
        case "Y" => true
        case "N" => false
      },
      deferred = m.deferred match {
        case "Y" => true
        case "N" => false
      },
      validated = m.validated match {
        case "Y" => true
        case "N" => false
      },
      generated = m.generated match {
        case "Y" => true
        case "N" => false
      },
      columnNames = m.columnNames)

  def getStoredMetaIndex(tbl: StoredMeta.Table, name: String): StoredMeta.Index = {
    val ix: Option[StoredMeta.Index] = tbl.indexList.find(_.name == name)

    ix match {
      case Some(x) => x
      case None => sys.error(s"Index not found, table=${tbl.name} index=$name")
    }
  }

  def makePrimaryKey(tbl: StoredMeta.Table, m: StoredMeta.Constraint): PrimaryKey = {
    val index = getStoredMetaIndex(tbl, m.indexName)
    PrimaryKey(
      ci = makeConstraintInfo(tbl, m),
      expr = index.expr,
      indexTablespace = index.tablespace,
      indexName = index.name)
  }

  def makeUniqueKey(tbl: StoredMeta.Table, m: StoredMeta.Constraint): UniqueKey = {
    val index = getStoredMetaIndex(tbl, m.indexName)
    UniqueKey(
      ci = makeConstraintInfo(tbl, m),
      expr = index.expr,
      indexTablespace = index.tablespace,
      indexName = index.name)
  }

  def makeForeignKey(tbl: StoredMeta.Table, m: StoredMeta.Constraint): ForeignKey =
    ForeignKey(
      ci = makeConstraintInfo(tbl, m),
      refConstraintName = m.refConstraintName,
      refTableName = m.refTableName,
      refColumnNames = m.refColumnNames,
      deleteRule = if ("NO ACTION" == m.deleteRule) "" else m.deleteRule)

  def makeCheck(tbl: StoredMeta.Table, m: StoredMeta.Constraint): Check =
    Check(
      ci = makeConstraintInfo(tbl, m),
      searchCondition = m.searchCondition)

  case class Index(tableName: String,
                   name: String,
                   indexType: String,
                   uniqueness: Boolean,
                   tablespace: String,
                   generated: Boolean,
                   columnNames: List[String],
                   expr: List[String]) extends DropAndAdd {

    private val uniqueQuery = if (uniqueness) " unique" else ""

    def clauseDrop: String =
      if (generated) ""
      else if (name.isEmpty) tableName + " has not index name to drop"
      else s"drop index $name;"

    def clauseAdd: String =
      if (generated) ""
      else if (name.isEmpty) tableName + " has not index name to add"
      else s"create$uniqueQuery index $name on $tableName ${expr.mkString("(", ",", ")")} tablespace $tablespace;"
  }

  def makeIndex(tableName: String, ind: StoredMeta.Index): Index =
    Index(
      tableName = tableName,
      name = ind.name,
      indexType = ind.indexType,
      uniqueness = ind.uniqueness match {
        case "UNIQUE" => true
        case "NONUNIQUE" => false
      },
      tablespace = ind.tablespace,
      generated = ind.generated match {
        case "Y" => true
        case "N" => false
      },
      columnNames = ind.columnNames,
      expr = ind.expr)

  case class Table(name: String,
                   tablespace: String,
                   columnList: List[Column],
                   primaryKeys: List[PrimaryKey],
                   uniqueKeys: List[UniqueKey],
                   foreignKeys: List[ForeignKey],
                   checks: List[Check],
                   indexList: List[Index],
                   otherConstraintTypes: Set[String])

  def makeTable(tbl: StoredMeta.Table): Table = {

    val columns: List[Column] = tbl.columnList map makeColumn

    val constraintGroups = tbl.constraintList.groupBy(_.constraintType)

    def extractConstraint[A](n: String, f: (StoredMeta.Table, StoredMeta.Constraint) => A): List[A] =
      constraintGroups.getOrElse(n, Nil).map(f(tbl, _))

    val usedIndexNames: Set[String] = tbl.constraintList.map(_.indexName).filter(_.nonEmpty).toSet

    val indexes = tbl.indexList.filterNot(x => usedIndexNames.contains(x.name)).map(makeIndex(tbl.name, _))

    def isNullCheck(c: Check): Boolean = c.ci.columnNames match {
      case x :: Nil if "\"" + x + "\" IS NOT NULL" == c.searchCondition => true
      case _ => false
    }

    Table(
      name = tbl.name,
      tablespace = tbl.tablespace,
      columnList = columns,
      primaryKeys = extractConstraint("P", makePrimaryKey),
      uniqueKeys = extractConstraint("U", makeUniqueKey),
      foreignKeys = extractConstraint("R", makeForeignKey),
      checks = extractConstraint("C", makeCheck).filterNot(isNullCheck),
      indexList = indexes,
      otherConstraintTypes = constraintGroups.keySet - ("P", "U", "R", "C"))
  }

  case class Stored(tables: List[Table],
                    sequences: List[String],
                    packages: List[String],
                    packageBodies: List[String],
                    procedures: List[String],
                    functions: List[String],
                    views: List[String])

  def makeStored(s: StoredMeta.Stored): Stored =
    Stored(
      tables = s.tables map makeTable,
      sequences = s.sequences,
      packages = s.packages,
      packageBodies = s.packageBodies,
      procedures = s.procedures,
      functions = s.functions,
      views = s.views)

  def makeStored(s: String): Stored = makeStored(StoredMeta.makeStored(s))

}