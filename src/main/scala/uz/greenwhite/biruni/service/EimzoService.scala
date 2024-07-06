package uz.greenwhite.biruni.service

import oracle.jdbc.{OracleCallableStatement, OracleConnection, OracleTypes}
import uz.greenwhite.biruni.connection.DBConnection

class EimzoService(sessionVal: String,
                   filialId: Int,
                   applicationId: Int,
                   applicantSign: String,
                   applicantSignInfo: String) {
  private def splitChunks(value: String): Array[String] = {
    if (value.length > 10000) value.grouped(10000).toArray
    else Array(value)
  }

  private def getStatement(conn: OracleConnection): OracleCallableStatement = {
    val query: String = "BEGIN Dsrp_Application.Sign(?,?,?,?,?,?,?); END;"
    conn.prepareCall(query).asInstanceOf[OracleCallableStatement]
  }

  def sign(): Unit = {
    val conn = DBConnection.getSingletonConnection
    var cs: OracleCallableStatement = null

    try {
      cs = getStatement(conn)

      cs.setString(1, sessionVal)
      cs.setInt(2, filialId)
      cs.setInt(3, applicationId)
      cs.setArray(4, conn.createOracleArray("PUBLIC.ARRAY_VARCHAR2", splitChunks(applicantSign)))
      cs.setArray(5, conn.createOracleArray("PUBLIC.ARRAY_VARCHAR2", splitChunks(applicantSignInfo)))

      cs.registerOutParameter(6, OracleTypes.VARCHAR)
      cs.registerOutParameter(7, OracleTypes.VARCHAR)

      cs.execute

      if ("F".equals(cs.getString(6))) throw new Exception(cs.getString(7))
    } finally {
      if (cs != null) cs.close()
      conn.close()
    }
  }
}
