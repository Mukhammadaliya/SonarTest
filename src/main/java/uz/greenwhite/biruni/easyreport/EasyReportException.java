package uz.greenwhite.biruni.easyreport;

public class EasyReportException extends RuntimeException {
    public EasyReportException(String message) {
        super(message);
    }

    public EasyReportException(Throwable cause) {
        super(cause);
    }

    public EasyReportException(String message, Throwable cause) {
        super(message, cause);
    }
}
