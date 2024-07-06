package uz.greenwhite.biruni.logger;

import oracle.jdbc.OracleClob;
import oracle.jdbc.OracleConnection;
import org.json.JSONObject;
import uz.greenwhite.biruni.connection.DBConnection;

import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Arrays;

public class ExceptionLogger {
    private static void saveException(OracleConnection conn, String sourceClass, String detail, String message) {
        try (PreparedStatement st = conn.prepareStatement("BEGIN Biruni_Jdbc.Save_App_Server_Exception(?, ?, ?); END;")) {
            st.setString(1, sourceClass);
            st.setString(2, detail);
            OracleClob clob = (OracleClob) conn.createClob();
            clob.setString(1, message);
            st.setClob(3, clob);
            st.execute();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public static void saveException(OracleConnection conn, String sourceClass, Exception exception) {
        JSONObject detail = new JSONObject();
        detail.put("message", exception.getMessage());
        detail.put("class", exception.getClass().getName());

        if (exception instanceof SQLException sqlException) {
            detail.put("sqlState", sqlException.getSQLState());
            detail.put("errorCode", sqlException.getErrorCode());
        }

        StringBuilder sb = new StringBuilder();
        Arrays.stream(exception.getStackTrace()).forEach(stackTraceElement -> {
            sb.append(stackTraceElement.toString());
            sb.append("\n");
        });

        saveException(conn, sourceClass, detail.toString(), sb.toString());
    }

    public static void saveException(String sourceClass, Exception exception) {
        try (OracleConnection conn = DBConnection.getPoolConnectionAndFreeResources()) {
            saveException(conn, sourceClass, exception);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}