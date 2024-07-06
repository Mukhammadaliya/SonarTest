package uz.greenwhite.biruni.report;

public class BrBookSetting {

    public String filename = "report";
    public String reportType;
    public String url;
    public String contextPath;

    public static final String HTML = "html";
    public static final String HTMLM = "htmlm";
    public static final String XLSX = "xlsx";
    public static final String IMP_XLSX = "imp_xlsx";
    public static final String HTMLD = "htmld";
    public static final String HTMLS = "htmls";
    public static final String XML = "xml";
    public static final String CSV = "csv";

    public void init() {
        if (!(HTML.equals(reportType) ||
                HTMLM.equals(reportType) ||
                XLSX.equals(reportType) ||
                IMP_XLSX.equals(reportType) ||
                HTMLD.equals(reportType) ||
                HTMLS.equals(reportType) ||
                XML.equals(reportType) ||
                CSV.equals(reportType)
        )) {
            reportType = HTML;
        }
    }
}
