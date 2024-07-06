package uz.greenwhite.biruni.lazyreport;

public class ReportInfo {
    public final long registerId;
    public Status status;
    public ReportType reportType;
    public String metadata;
    public String sha;
    public String filename;
    public String errorMessage;

    public ReportInfo(long registerId) {
        this.registerId = registerId;
    }
}