package uz.greenwhite.biruni.lazyreport;

import org.json.JSONObject;
import uz.greenwhite.biruni.filemanager.FileManager;

import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.concurrent.*;

public class LazyReportProvider {
    public static void makeLazyReport(HttpServletResponse response, String input, String contextPath, String sessionInfo) throws IOException {
        JSONObject obj = new JSONObject(input);
        long registerId = obj.getLong("register_id");
        // wait 60 seconds for lazy report to complete, if not completed then return generating message
        int waitTimeInMillis = obj.getInt("wait_time") * 1000;
        // generating message, shown to user after wait time report is in EXECUTING status
        String generatingMessage = obj.getString("generating_message");

        try {
            // create executor service with single thread for lazy report
            ExecutorService executor = Executors.newSingleThreadExecutor();
            // create future task for lazy report
            Future<ReportInfo> futureTask = executor.submit(() -> new LazyReportGenerator(registerId, contextPath, sessionInfo).run());

            while (waitTimeInMillis > 0) {
                if (futureTask.isDone()) {
                    ReportInfo reportInfo = futureTask.get();

                    switch (reportInfo.status) {
                        case COMPLETED:
                            FileManager.sendReport(reportInfo.reportType, reportInfo.sha, reportInfo.filename, response);
                            break;
                        case EXECUTING:
                            response.getWriter().write(generatingMessage);
                            break;
                        case FAILED:
                            sendInternalError(response, "Lazy report error: " + reportInfo.errorMessage);
                            break;
                        case NEW:
                            sendInternalError(response, "Lazy report error: status has not been changed from NEW");
                            break;
                    }

                    return;
                } else {
                    waitTimeInMillis -= 200;
                    if (waitTimeInMillis > 0) Thread.sleep(200);
                }
            }

            response.getWriter().write(generatingMessage);
        } catch (ExecutionException | InterruptedException e) {
            new LazyReportGenerator(registerId, contextPath, sessionInfo).saveReportError(e.getMessage(), e.getStackTrace());
            sendInternalError(response, "Lazy report error: " + e.getMessage());
        }
    }

    private static void sendInternalError(HttpServletResponse response, String message) throws IOException {
        response.setStatus(500);
        response.getWriter().write(message);
    }
}
