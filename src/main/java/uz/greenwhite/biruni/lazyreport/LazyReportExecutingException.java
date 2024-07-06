package uz.greenwhite.biruni.lazyreport;

public class LazyReportExecutingException extends RuntimeException {
    public LazyReportExecutingException() {
    }

    public LazyReportExecutingException(String message) {
        super(message);
    }

    public LazyReportExecutingException(String message, Throwable cause) {
        super(message, cause);
    }
}
