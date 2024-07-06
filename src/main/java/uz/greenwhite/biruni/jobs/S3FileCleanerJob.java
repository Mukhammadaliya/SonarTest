package uz.greenwhite.biruni.jobs;

import jakarta.servlet.ServletContext;
import oracle.jdbc.OracleConnection;
import uz.greenwhite.biruni.connection.DBConnection;
import uz.greenwhite.biruni.s3.S3Client;
import uz.greenwhite.biruni.s3.S3Util;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Calendar;
import java.util.LinkedList;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class S3FileCleanerJob {
    private ScheduledExecutorService fileCleanerExecutor;
    private final String contextParam;

    public S3FileCleanerJob(ServletContext context) {
        this.contextParam = context.getInitParameter("s3_file_cleaner");
    }

    public void start() {
        if (contextParam == null || !S3Client.hasClient()) return;

        Calendar calendar = Calendar.getInstance();
        String[] params = contextParam.split("/");
        int jobTime = Integer.parseInt(params[0].split(":")[0]) * 60 + Integer.parseInt(params[0].split(":")[1]);
        int currentTime = calendar.get(Calendar.HOUR_OF_DAY) * 60 + calendar.get(Calendar.MINUTE);
        int delayTime = (jobTime >= currentTime ? jobTime : jobTime + 24 * 60) - currentTime;
        int interval = Integer.parseInt(params[1]) * 24 * 60;


        if (interval >= 24 * 60) {
            System.out.printf("ImageCleaner will be started at %s every %s days%n", params[0], params[1]);
            fileCleanerExecutor = Executors.newSingleThreadScheduledExecutor();
            fileCleanerExecutor.scheduleAtFixedRate(new FileCleanerJob(), delayTime, interval, TimeUnit.MINUTES);
        }
    }

    public void stop() {
        if (fileCleanerExecutor != null) fileCleanerExecutor.shutdown();
    }

}

class FileCleanerJob implements Runnable {
    private void updateFileSHAStatus(OracleConnection conn, String sha, String status) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement("UPDATE biruni_files_to_delete SET status = ? WHERE sha = ?")) {
            ps.setString(1, status);
            ps.setString(2, sha);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("File Cleaner Job: error while updating file status in database", e);
        }
    }

    private void deleteFileSHAFromDatabase(OracleConnection conn, String sha) {
        try (PreparedStatement ps = conn.prepareStatement("DELETE FROM biruni_files_to_delete WHERE sha = ?")) {
            ps.setString(1, sha);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("File Cleaner Job: error while deleting SHA from database", e);
        }
    }

    private LinkedList<String> getFileSHAs() {
        try (OracleConnection conn = DBConnection.getPoolConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT sha FROM biruni_files_to_delete WHERE status = 'N' AND ROWNUM <= 100 FOR UPDATE");
             ResultSet rs = ps.executeQuery()) {
            LinkedList<String> shaList = new LinkedList<>();

            while (rs.next()) {
                String sha = rs.getString("sha");
                updateFileSHAStatus(conn, sha, "D");
                shaList.add(rs.getString("sha"));
            }

            return shaList;
        } catch (SQLException e) {
            throw new RuntimeException("File Cleaner Job: error while getting file list from database", e);
        }
    }

    @Override
    public void run() {
        LinkedList<String> shaList = getFileSHAs();

        while (!shaList.isEmpty()) {
            try (OracleConnection conn = DBConnection.getPoolConnection()) {
                while (!shaList.isEmpty()) {
                    String sha = shaList.poll();

                    if (S3Util.removeObject(sha)) deleteFileSHAFromDatabase(conn, sha);
                    else updateFileSHAStatus(conn, sha, "F");
                }
            } catch (SQLException e) {
                throw new RuntimeException("File Cleaner Job: error while establishing connection with database", e);
            }

            shaList = getFileSHAs();
        }
    }
}