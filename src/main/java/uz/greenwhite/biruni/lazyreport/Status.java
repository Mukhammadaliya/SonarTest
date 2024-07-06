package uz.greenwhite.biruni.lazyreport;

public enum Status {
    NEW,
    EXECUTING,
    COMPLETED,
    FAILED;

    public static Status fromString(String status) {
        switch (status) {
            case "N":
                return Status.NEW;
            case "E":
                return Status.EXECUTING;
            case "C":
                return Status.COMPLETED;
            case "F":
                return Status.FAILED;
            default:
                throw new IllegalArgumentException("Unknown status: " + status);
        }
    }

    public String toString() {
        switch (this) {
            case NEW:
                return "N";
            case EXECUTING:
                return "E";
            case COMPLETED:
                return "C";
            case FAILED:
                return "F";
            default:
                throw new IllegalArgumentException("Unknown status: " + this);
        }
    }
}
