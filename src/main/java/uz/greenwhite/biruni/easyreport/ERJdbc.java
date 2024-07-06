package uz.greenwhite.biruni.easyreport;

import oracle.jdbc.OracleConnection;
import uz.greenwhite.biruni.connection.DBConnection;

import java.io.Reader;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class ERJdbc {
    static Reader getMetadata(String fileSha) {
        try (OracleConnection conn = DBConnection.getPoolConnection();
             PreparedStatement st = conn.prepareStatement("SELECT metadata FROM biruni_easy_report_templates WHERE sha = ?")) {
            st.setString(1, fileSha);
            st.execute();

            try (ResultSet rs = st.getResultSet()) {
                rs.next();
                return rs.getClob(1).getCharacterStream();
            }
        } catch (SQLException ex) {
            throw new RuntimeException("Biruni ER: error found when downloading ER metadata. Error message " + ex.getMessage());
        }
    }
}