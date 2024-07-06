package uz.greenwhite.biruni.s3;

import io.minio.BucketExistsArgs;
import io.minio.MinioAsyncClient;
import io.minio.http.HttpUtils;

import java.security.KeyManagementException;
import java.security.NoSuchAlgorithmException;
import java.util.concurrent.TimeUnit;

public class S3Client {
    private static S3Client instance;

    private final MinioAsyncClient minioClient;
    private final String bucketName;
    private final int linkExpireInHours;

    private S3Client(String endpoint, String accessKey, String secretKey, String bucketName, int linkExpireInHours) throws NoSuchAlgorithmException, KeyManagementException {
        long DEFAULT_CONNECTION_TIMEOUT = TimeUnit.MINUTES.toMillis(5);

        if (endpoint == null || endpoint.isEmpty()
                || accessKey == null || accessKey.isEmpty()
                || secretKey == null || secretKey.isEmpty()
                || bucketName == null || bucketName.isEmpty()) {
            System.out.println("S3Client not initialized");
            throw new RuntimeException("S3Client not initialized");
        }

        minioClient = MinioAsyncClient.builder()
                .endpoint(endpoint)
                .credentials(accessKey, secretKey)
                .httpClient(HttpUtils.disableCertCheck(HttpUtils.newDefaultHttpClient(DEFAULT_CONNECTION_TIMEOUT, DEFAULT_CONNECTION_TIMEOUT, DEFAULT_CONNECTION_TIMEOUT)))
                .build();

        if (!checkBucketExist(bucketName)) {
            System.out.println("Bucket not exist");
            throw new RuntimeException("Bucket not exist");
        }

        this.bucketName = bucketName;
        this.linkExpireInHours = Math.max(linkExpireInHours, 1);
    }

    private boolean checkBucketExist(String bucketName) {
        try {
            return minioClient.bucketExists(BucketExistsArgs.builder().bucket(bucketName).build()).get();
        } catch (Exception e) {
            return false;
        }
    }

    public static synchronized void Init(String endpoint, String accessKey, String secretKey, String bucketName, int linkExpireInHours) {
        try {
            if (instance != null) return;
            instance = new S3Client(endpoint, accessKey, secretKey, bucketName, linkExpireInHours);
        } catch (Exception e) {
            instance = null;
        }
    }

    public static MinioAsyncClient getClient() {
        if (hasClient()) {
            return instance.minioClient;
        } else {
            throw new RuntimeException("S3Client not initialized");
        }
    }

    public static boolean hasClient() {
        return instance != null;
    }

    public static String getBucketName() {
        if (hasClient()) {
            return instance.bucketName;
        } else {
            throw new RuntimeException("S3Client not initialized");
        }
    }

    public static int getLinkExpireInHours() {
        if (hasClient()) {
            return instance.linkExpireInHours;
        } else {
            throw new RuntimeException("S3Client not initialized");
        }
    }
}
