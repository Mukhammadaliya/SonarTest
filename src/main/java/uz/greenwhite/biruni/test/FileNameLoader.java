package uz.greenwhite.biruni.test;

import io.minio.ListObjectsArgs;
import io.minio.MinioAsyncClient;
import io.minio.Result;
import io.minio.http.HttpUtils;
import io.minio.messages.Item;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import uz.greenwhite.biruni.connection.DBConnection;

import java.io.IOException;
import java.security.KeyManagementException;
import java.security.NoSuchAlgorithmException;
import java.sql.SQLException;
import java.util.LinkedList;
import java.util.concurrent.TimeUnit;

class FileNameLoader extends HttpServlet {
    private static final MinioAsyncClient client;

    static {
        long DEFAULT_CONNECTION_TIMEOUT = TimeUnit.HOURS.toMillis(2);

        try {
            client = MinioAsyncClient.builder()
                    .endpoint("https://s3.smartup.online")
                    .credentials("pharm-access-key", "V7S2U7zRv5mIw6SxieYFqQkaIi7vDAinpS28CeBc")
                    .httpClient(HttpUtils.disableCertCheck(HttpUtils.newDefaultHttpClient(DEFAULT_CONNECTION_TIMEOUT, DEFAULT_CONNECTION_TIMEOUT, DEFAULT_CONNECTION_TIMEOUT)))
                    .build();
        } catch (KeyManagementException | NoSuchAlgorithmException e) {
            throw new RuntimeException(e);
        }
    }

    private void loadFiles(String prefix, String startWith) {
        Iterable<Result<Item>> results;

        ListObjectsArgs.Builder builder = ListObjectsArgs.builder()
                .bucket("smartup")
                .maxKeys(1000)
                .prefix(prefix.substring(0, 1));

        if (startWith != null) {
            builder.startAfter(startWith);
        }

        results = client.listObjects(builder.build());

        LinkedList<String> list = new LinkedList<>();
        int count = 0;

        for (Result<Item> result : results) {
            try {
                Item item = result.get();
                list.add(item.objectName());

                if (list.size() == 1000) {
                    saveFileNameToDb(list);
                    list.clear();
                    System.out.printf("%d files saved with a prefix %C. Last file name is %s\n", count += 1000, prefix.charAt(0), item.objectName());
                    System.out.println("-".repeat(100));
                }
            } catch (Exception e) {
                throw new RuntimeException("Error while listing files", e);
            }
        }

        if (!list.isEmpty()) {
            saveFileNameToDb(list);
        }
    }

    private void saveFileNameToDb(LinkedList<String> list) {
        try (var connection = DBConnection.getPoolConnection();
             var statement = connection.prepareStatement("insert into biruni_s3_files (sha) values (?)")) {

            for (String sha : list) {
                statement.setString(1, sha);
                statement.executeUpdate();
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String prefix = req.getParameter("prefix");
        String startWith = req.getParameter("startWith");

        System.out.println("Prefix: " + prefix);

        if (prefix == null) {
            resp.getWriter().write("Prefix is not specified");
            return;
        }

        if (prefix.length() != 1) {
            resp.getWriter().write("Prefix must be a single character");
            return;
        }

        if (!Character.isDigit(prefix.charAt(0)) && !Character.isLetter(prefix.charAt(0))) {
            resp.getWriter().write("Prefix must be a digit or a letter");
            return;
        }

        if (!prefix.toLowerCase().equals(prefix)) {
            resp.getWriter().write("Prefix must be a lowercase");
            return;
        }

        if (startWith != null) {
            if (startWith.length() != 64) {
                resp.getWriter().write("Start with must be a 64 character string");
                return;
            }

            if (!startWith.toLowerCase().equals(startWith)) {
                resp.getWriter().write("Start with must be a lowercase");
                return;
            }
        }

        loadFiles(prefix, startWith);
        resp.getWriter().write("OK");
    }
}
