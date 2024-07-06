package uz.greenwhite.biruni.s3;

public class S3ClientException extends Exception {
    public S3ClientException(String message) {
        super(message);
    }

    public S3ClientException(String message, Throwable cause) {
        super(message, cause);
    }
}
