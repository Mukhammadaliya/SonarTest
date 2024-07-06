package uz.greenwhite.biruni.report;

import jakarta.servlet.http.HttpServletResponse;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Date;

public class ReportBuilder {

    public static void make(String source, HttpServletResponse response, String contextPath) throws IOException {
        Parser parser = new Parser(new Token(source));
        BrBook book = parser.result();

        switch (book.setting.reportType) {
            case BrBookSetting.XLSX:
                makeExcel(book, response);
                break;
            case BrBookSetting.IMP_XLSX:
                makeImpExcel(book, response);
                break;
            case BrBookSetting.HTML:
                makeHtml(book, response, contextPath);
                break;
            case BrBookSetting.HTMLM:
                makeHtmlm(book, response, contextPath);
                break;
            case BrBookSetting.HTMLD:
                makeHtmlDebug(book, response);
                break;
            case BrBookSetting.HTMLS:
                makeHtmls(book, response, contextPath);
                break;
            case BrBookSetting.XML:
                makeXml(book, response);
                break;
            case BrBookSetting.CSV:
                makeCsv(book, response);
                break;
            default:
                throw new RuntimeException("Unsupported report type");
        }
    }

    public static String makeLazyReport(String source, String reportType, ByteArrayOutputStream outputStream, String contextPath) throws IOException {
        Parser parser = new Parser(new Token(source));
        BrBook book = parser.result();

        if (reportType.equals(BrBookSetting.XLSX)) {
            Excel excel = new Excel(book);
            excel.write(outputStream);
        } else if (reportType.equals(BrBookSetting.HTML)) {
            Html html = new Html(book, outputStream, false);
            html.build(contextPath);
        } else {
            throw new RuntimeException("Unsupported lazy report type");
        }

        return getFileName(book);
    }

    private static void makeHtml(BrBook book, HttpServletResponse response, String contextPath) throws IOException {
        response.setContentType("text/html;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        Html html = new Html(book, response.getOutputStream(), false);
        html.build(contextPath);
    }

    private static void makeHtmlm(BrBook book, HttpServletResponse response, String contextPath) throws IOException {
        response.setContentType("text/html;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        Html html = new Html(book, response.getOutputStream(), true);
        html.build(contextPath);
    }

    private static void makeHtmlDebug(BrBook book, HttpServletResponse response) throws IOException {
        response.setContentType("text/html;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        HtmlDebug html = new HtmlDebug(book, response.getOutputStream());
        html.build();
    }

    private static void makeHtmls(BrBook book, HttpServletResponse response, String contextPath) throws IOException {
        response.setContentType("text/html;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        HtmlStyle html = new HtmlStyle(book, response.getOutputStream(), false);
        html.build(contextPath);
    }

    private static void makeExcel(BrBook book, HttpServletResponse response) throws IOException {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment;filename*=UTF-8''" + getURLEncodedFileName(book) + ".xlsx");

        Excel excel = new Excel(book);
        excel.write(response.getOutputStream());
    }

    private static void makeImpExcel(BrBook book, HttpServletResponse response) throws IOException {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment;filename*=UTF-8''" + getURLEncodedFileName(book) + ".xlsx");

        ImpExcel excel = new ImpExcel(book);
        excel.write(response.getOutputStream());
    }

    private static void makeXml(BrBook book, HttpServletResponse response) throws IOException {
        String fileName = getURLEncodedFileName(book);
        if (book.sheets.size() > 1) {
            response.setContentType("application/zip");
            fileName += ".zip";
        } else {
            response.setContentType("application/xml");
            fileName += ".xml";
        }
        response.setHeader("Content-Disposition", "attachment;filename*=UTF-8''" + fileName);

        Xml xml = new Xml(book);
        xml.write(response.getOutputStream());
    }

    private static void makeCsv(BrBook book, HttpServletResponse response) throws IOException {
        String fileName = getURLEncodedFileName(book);
        if (book.sheets.size() > 1) {
            response.setContentType("application/zip");
            fileName += ".zip";
        } else {
            response.setContentType("application/vnd.ms-excel;charset=UTF-8");
            fileName += ".csv";
        }
        response.setHeader("Content-Disposition", "attachment;filename*=UTF-8''" + fileName);

        Csv csv = new Csv(book);
        csv.write(response.getOutputStream());
    }

    private static String getFileName(BrBook book) throws IOException {
        String fileName;
        if (!book.setting.filename.isEmpty()) {
            fileName = book.setting.filename;
        } else {
            if (book.sheets.size() > 1) {
                SimpleDateFormat dt = new SimpleDateFormat("dd.MM.yyyy HH:mm:ss");
                fileName = "smartup-report(" + dt.format(new Date()) + ")";
            } else {
                fileName = book.sheets.get(0).name;
            }
        }
        return fileName;
    }

    private static String getURLEncodedFileName(BrBook book) throws IOException {
        return URLEncoder.encode(getFileName(book), StandardCharsets.UTF_8);
    }
}
