package uz.greenwhite.biruni.lazyreport;

public enum ReportType {
    EXCEL("xlsx"),
    HTML("html");

    private final String value;

    ReportType(String value) {
        this.value = value;
    }

    public String getValue() {
        return value;
    }

    public static ReportType fromValue(String value) {
        for (ReportType type : ReportType.values()) {
            if (type.value.equals(value)) {
                return type;
            }
        }
        throw new IllegalArgumentException(value);
    }
}
