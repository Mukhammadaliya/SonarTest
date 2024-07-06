package uz.greenwhite.biruni.s3;

import io.minio.*;
import io.minio.http.Method;
import org.apache.commons.io.IOUtils;

import java.io.InputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;

public class S3Util {
    public static void uploadObject(InputStream stream, String sha, String contentType, long fileSize) {
        try {
            MinioAsyncClient client = S3Client.getClient();
            assert client != null;

            if (!checkObjectExist(client, sha)) {
                client.putObject(PutObjectArgs.builder()
                        .bucket(S3Client.getBucketName())
                        .object(sha)
                        .stream(stream, fileSize, -1)
                        .contentType(contentType)
                        .build()).get();
            }
        } catch (Exception e) {
            throw new RuntimeException("Error while uploading file to S3", e);
        }
    }

    private static String getDownloadLink(MinioAsyncClient client, String sha, Map<String, String> reqParams) throws S3ClientException {
        try {
            return client.getPresignedObjectUrl(GetPresignedObjectUrlArgs.builder()
                    .method(Method.GET)
                    .bucket(S3Client.getBucketName())
                    .object(sha)
                    .expiry(S3Client.getLinkExpireInHours(), TimeUnit.HOURS)
                    .extraQueryParams(reqParams)
                    .build());
        } catch (Exception e) {
            throw new S3ClientException("Error while getting download link from S3", e);
        }
    }

    public static String getDownloadLink(String sha, String fileName) throws S3ClientException {
        Map<String, String> reqParams = new HashMap<>();
        reqParams.put("response-content-disposition", "attachment;filename=\"" + URLEncoder.encode(fileName, StandardCharsets.UTF_8) + "\"");

        return getDownloadLink(S3Client.getClient(), sha, reqParams);
    }

    public static String getLoadLink(String sha, String fileName) throws Exception {
        Map<String, String> reqParams = new HashMap<>();
        reqParams.put("response-content-disposition", "inline;filename=\"" + URLEncoder.encode(fileName, StandardCharsets.UTF_8) + "\"");

        return getDownloadLink(S3Client.getClient(), sha, reqParams);
    }

    public static byte[] getObject(String sha) {
        MinioAsyncClient client = S3Client.getClient();
        assert client != null;

        try (InputStream stream = client.getObject(GetObjectArgs.builder()
                .bucket(S3Client.getBucketName())
                .object(sha)
                .build()).get()) {
            return IOUtils.toByteArray(stream);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private static boolean checkObjectExist(MinioAsyncClient client, String sha) {
        assert client != null;

        try {
            return client.statObject(StatObjectArgs.builder()
                    .bucket(S3Client.getBucketName())
                    .object(sha)
                    .build()).get() != null;
        } catch (Exception e) {
            return false;
        }
    }

    public static boolean removeObject(String sha) {
        try {
            MinioAsyncClient client = S3Client.getClient();
            assert client != null;

            client.removeObject(RemoveObjectArgs.builder()
                    .bucket(S3Client.getBucketName())
                    .object(sha)
                    .build()).get();
            return true;
        } catch (Exception e) {
            System.out.println("Error while removing file from S3. Error message: " + e.getMessage());
            return false;
        }
    }
}
