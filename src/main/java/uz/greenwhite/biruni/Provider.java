package uz.greenwhite.biruni;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import uz.greenwhite.biruni.easyreport.ERBuilder;
import uz.greenwhite.biruni.easyreport.ERMetadataReader;
import uz.greenwhite.biruni.filemanager.FazoFile;
import uz.greenwhite.biruni.filemanager.FileManager;
import uz.greenwhite.biruni.lazyreport.LazyReportProvider;
import uz.greenwhite.biruni.onlyoffice.OnlyofficeException;
import uz.greenwhite.biruni.onlyoffice.OnlyofficeProvider;
import uz.greenwhite.biruni.report.ReportBuilder;

import java.io.IOException;
import java.io.InputStream;
import java.util.Map;

public class Provider {
    private static void printError(String message, Throwable e) {
        System.out.print("-".repeat(100) + "\n");
        System.out.printf("Message: %s, Throwable: %s%n", message, e.getClass().getName());
        e.printStackTrace();
        System.out.print("-".repeat(100) + "\n");
    }

    public static void buildReport(String source, HttpServletResponse response, String contextPath) {
        try {
            ReportBuilder.make(source, response, contextPath);
        } catch (Throwable e) {
            printError("Build Report", e);
            throw new RuntimeException(e);
        }
    }

    public static StringBuilder readExcelBook(InputStream inputStream) {
        try {
            return ImportExcel.read(inputStream);
        } catch (Throwable e) {
            printError("Read Excel Book", e);
            throw new RuntimeException(e);
        }
    }

    public static void sendFile(String filesPath, FazoFile fazoFile, HttpServletResponse response) {
        FileManager.apply(filesPath, response).sendFile(fazoFile);
    }

    public static Map<String, String> readEasyReportMetadata(InputStream inputStream) {
        return ERMetadataReader.read(inputStream);
    }

    public static void buildEasyReport(String source, HttpServletRequest request, HttpServletResponse response) {
        ERBuilder builder = new ERBuilder();
        builder.build(source, request, response);
    }

    public static void makeLazyReport(HttpServletResponse response, String source, String url, String sessionInfo) {
        try {
            LazyReportProvider.makeLazyReport(response, source, url, sessionInfo);
        } catch (Throwable e) {
            printError("Make Lazy Report", e);
            throw new RuntimeException(e);
        }
    }

    public static void requestExternalService(String requestData, HttpServletResponse response) {
        try {
            ExternalServiceProvider.request(requestData, response);
        } catch (Throwable e) {
            printError("Request External Service", e);
            throw new RuntimeException(e.getMessage());
        }
    }

    public static void runOnlyoffice(String source, HttpServletRequest request, HttpServletResponse response) {
        try {
            if (!OnlyofficeProvider.isLive()) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.setContentType("plain/text;charset=UTF-8");
                response.getWriter().write("Onlyoffice service is not available.");
                return;
            }
            String html = OnlyofficeProvider.prepareOnlyofficeHtml(source, request.getServletContext());
            response.setContentType("text/html;charset=UTF-8");
            response.getWriter().write(html);
        } catch (OnlyofficeException | IOException e) {
            printError("Onlyoffice HTML preparation error", e);
            throw new RuntimeException(e.getMessage());
        }
    }
}
