package uz.greenwhite.biruni.lazyreport;

import oracle.jdbc.*;
import org.jetbrains.annotations.NotNull;
import uz.greenwhite.biruni.filemanager.FileManager;
import uz.greenwhite.biruni.connection.DBConnection;
import uz.greenwhite.biruni.report.ReportBuilder;
import uz.greenwhite.biruni.service.WsNotifier;
import uz.greenwhite.biruni.util.FileUtil;

import java.io.*;
import java.sql.Clob;
import java.sql.SQLException;

public class LazyReportGenerator {
    private final ReportInfo reportInfo;
    private final Long userId;
    private final String contextPath;

    public LazyReportGenerator(long registerId, String contextPath, @NotNull String sessionInfo) {
        this.reportInfo = new ReportInfo(registerId);
        this.userId = Long.parseLong(sessionInfo.split("#")[2]);
        this.contextPath = contextPath;
    }

    public ReportInfo run() {
        try {
            executeReportQuery();

            if (reportInfo.status == Status.FAILED)
                return reportInfo;

            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            String filename = ReportBuilder.makeLazyReport(reportInfo.metadata, reportInfo.reportType.getValue(), outputStream, contextPath);

            if (reportInfo.reportType == ReportType.HTML && filename.endsWith(".xlsx"))
                filename = filename.substring(0, filename.length() - 5) + ".html";

            saveReportFile(filename, outputStream.toByteArray());
        } catch (Exception e) {
            saveReportError(e.getMessage(), e.getStackTrace());
        }

        notifyWs();
        return reportInfo;
    }

    private void executeReportQuery() throws SQLException {
        try (OracleConnection conn = DBConnection.getPoolConnectionAndFreeResources();
             OracleCallableStatement cs = (OracleCallableStatement) conn.prepareCall("BEGIN Biruni_Route.Execute_Lazy_Report(?,?,?,?); END;")) {
            cs.setLong(1, reportInfo.registerId);
            cs.registerOutParameter(2, OracleTypes.VARCHAR);
            cs.registerOutParameter(3, OracleTypes.VARCHAR);
            cs.registerOutParameter(4, OracleTypes.CLOB);
            cs.execute();

            reportInfo.status = Status.fromString(cs.getString(2));

            if (reportInfo.status == Status.FAILED) {
                reportInfo.errorMessage = cs.getString(3);
            } else {
                reportInfo.reportType = ReportType.fromValue(cs.getString(3));
                Clob clob = cs.getClob(4);
                reportInfo.metadata = clob.getSubString(1, (int) clob.length());
            }
        }
    }

    private void saveReportFile(String filename, byte[] bytes) throws SQLException {
        String sha = FileUtil.calcSHA(bytes);

        try (OracleConnection conn = DBConnection.getPoolConnectionAndFreeResources();
             OracleCallableStatement cs = (OracleCallableStatement) conn.prepareCall("BEGIN Biruni_Route.Save_Lazy_Report_File(?,?,?,?,?,?,?); END;")) {
            conn.setAutoCommit(false);

            String contentType = (reportInfo.reportType == ReportType.HTML ? "text/html" : "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet") + ";charset=UTF-8";

            cs.setLong(1, reportInfo.registerId);
            cs.setString(2, sha);
            cs.setLong(3, bytes.length);
            cs.setString(4, FileUtil.getFileStoreKind());
            cs.setString(5, filename);
            cs.setString(6, contentType);
            cs.registerOutParameter(7, OracleTypes.VARCHAR);
            cs.execute();

            String error = cs.getString(7);

            if (error == null) {
                // Commit is done because of foreign key constraint
                conn.commit();
                FileManager.uploadFileEntity(bytes, contentType, sha);
            } else {
                reportInfo.status = Status.FAILED;
                reportInfo.errorMessage = error;
                return;
            }

            // Auto commit is false, so we need to commit manually
            // It is done to avoid deadlock in table lever foreign key
            // The first report file should be saved, then report info should be updated
            conn.commit();
            updateReportInfo(conn, Status.COMPLETED, sha, null, null);
            conn.commit();

            reportInfo.filename = filename;
        }
    }

    private void updateReportInfo(OracleConnection conn, @NotNull Status status, String sha, String errorMessage, String errorBacktrace) throws SQLException {
        try (OraclePreparedStatement st = (OraclePreparedStatement) conn.prepareStatement("BEGIN Biruni_Route.Update_Lazy_Report_Info(?,?,?,?,?,?); END;")) {
            st.setLong(1, reportInfo.registerId);
            st.setString(2, status.toString());
            st.setString(3, reportInfo.reportType == ReportType.EXCEL ? sha : null);
            st.setString(4, reportInfo.reportType == ReportType.HTML ? sha : null);
            st.setString(5, errorMessage);
            st.setString(6, errorBacktrace);
            st.execute();
        }

        reportInfo.status = status;
        if (sha != null) reportInfo.sha = sha;
        if (errorMessage != null) reportInfo.errorMessage = errorMessage;
    }

    protected void saveReportError(String errorMessage, StackTraceElement[] errorBacktrace) {
        // retry 4 times with 20s, 1m, 3m, 5m intervals
        int[] retryTimeInMillisList = {0, 20_000, 60_000, 180_000, 300_000};
        String exceptionMessage = null;

        for (int retryTimeInMillis : retryTimeInMillisList) {
            if (retryTimeInMillis != 0) {
                try {
                    Thread.sleep(retryTimeInMillis);
                } catch (InterruptedException ignored) {
                }
            }

            try (OracleConnection conn = DBConnection.getPoolConnectionAndFreeResources()) {
                updateReportInfo(conn, Status.FAILED, null, errorMessage != null ? "APP: " + errorMessage : null, stacktraceToString(errorBacktrace));
                return;
            } catch (SQLException e) {
                exceptionMessage = e.getMessage();
            }
        }

        System.out.println("Exception while saving lazy report error: " + exceptionMessage);
    }

    private String stacktraceToString(StackTraceElement[] stackTrace) {
        if (stackTrace == null) return null;

        StringBuilder sb = new StringBuilder();
        for (StackTraceElement element : stackTrace) {
            sb.append(element.toString()).append("\n");
        }
        return sb.substring(0, Math.min(sb.length() - 1, 4000));
    }


    private void notifyWs() {
        try {
            WsNotifier.broadcast(userId, "{\"type\": \"load_alert\"}");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}