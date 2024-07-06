package uz.greenwhite.biruni.onlyoffice;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.google.gson.Gson;
import jakarta.servlet.ServletContext;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import org.apache.commons.io.FileUtils;
import org.json.JSONWriter;
import uz.greenwhite.biruni.http.OkHttp3;
import uz.greenwhite.biruni.property.ApplicationProperty;

import java.io.File;
import java.io.IOException;
import java.net.URISyntaxException;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

public class OnlyofficeProvider {
    public static boolean isLive() {
        try {
            if (ApplicationProperty.onlyofficeDisabled()) return false;

            OkHttpClient okHttp3Client = OkHttp3.getUnsafeOkHttpClient();
            Request request = new Request.Builder()
                    .url(ApplicationProperty.getOnlyofficeUrl() + "/healthcheck")
                    .get()
                    .build();

            try (Response response = okHttp3Client.newCall(request).execute()) {
                if (Objects.equals(response.body().string(), "true")) return true;
            }

            return false;
        } catch (Exception e) {
            return false;
        }
    }

    public static String getDocsLoadUrl(String sha) {
        return ApplicationProperty.getApplicationUrl() + "/docs/load?sha=" + sha;
    }

    public static String prepareOnlyofficeHtml(ServletContext context,
                                               String documentSha,
                                               String documentUrl,
                                               String fileName,
                                               Map<String, String> properties) throws OnlyofficeException {
        if (!isLive())
            throw new OnlyofficeException("Onlyoffice service is not available.");

        try {
            properties.put("docSha", documentSha);
            properties.put("docUrl", documentUrl);
            properties.put("fileName", fileName);

            var file = new File(context.getResource("onlyoffice.html").toURI());
            var html = FileUtils.readFileToString(file, StandardCharsets.UTF_8.name());

            html = html.replace("_ONLY_OFFICE_URL_", ApplicationProperty.getOnlyofficeUrl());
            html = html.replace("_ONLY_OFFICE_CONFIG_", JSONWriter.valueToString(prepareOnlyofficeConfig(properties)));

            return html;
        } catch (OnlyofficeException e) {
            throw e;
        } catch (IOException | URISyntaxException e) {
            throw new OnlyofficeException("Onlyoffice HTML resource reading error", e);
        } catch (Exception e) {
            throw new OnlyofficeException("Onlyoffice HTML preparation error", e);
        }
    }

    public static String prepareOnlyofficeHtml(String source, ServletContext context) throws OnlyofficeException {
        Source sourceObject = new Gson().fromJson(source, Source.class);
        String sha = sourceObject.sha();
        return prepareOnlyofficeHtml(context, sha, getDocsLoadUrl(sha), sourceObject.fileName(), sourceObject.properties());
    }

    private static Map<String, Object> prepareOnlyofficeConfig(Map<String, String> properties) throws OnlyofficeException {
        try {
            Map<String, Object> config = new HashMap<>();

            String fileType = extractFileType(properties.get("fileName"));

            Map<String, Object> document = prepareDocument(properties);
            document.put("title", extractFileTitle(properties.get("fileName")));
            document.put("fileType", fileType);

            config.put("document", document);
            config.put("editorConfig", prepareEditorConfig(properties));
            config.put("documentType", getDocumentType(fileType));
            config.put("width", "100%");
            config.put("height", "100%");
            config.put("type", properties.get("type"));
            config.put("token", sign(preparePayload(properties)));

            return config;
        } catch (OnlyofficeException e) {
            throw e;
        } catch (Exception e) {
            throw new OnlyofficeException("Onlyoffice config preparation error", e);
        }
    }

    private static String extractFileTitle(String fileName) {
        return fileName.substring(0, fileName.lastIndexOf("."));
    }

    private static String extractFileType(String fileName) {
        return fileName.substring(fileName.lastIndexOf(".") + 1);
    }

    private static Map<String, ?> prepareEditorConfig(Map<String, String> properties) {
        Map<String, Object> editorConfig = preparePayloadEditorConfig(properties);
        editorConfig.put("coEditing", Map.of("mode", "strict", "change", false));
        editorConfig.put("customization", prepareCustomization());
        editorConfig.put("lang", properties.get("langCode"));
        return editorConfig;
    }

    private static Map<String, Object> prepareDocument(Map<String, String> properties) {
        Map<String, Object> document = new HashMap<>();
        document.put("key", properties.get("docSha"));
        document.put("url", properties.get("docUrl"));
        document.put("permissions", preparePermissions());
        return document;
    }

    private static Map<String, ?> prepareUser(Map<String, String> properties) {
        return Map.of("id", Long.parseLong(properties.get("userId")),
                "name", properties.get("username"),
                "image", ApplicationProperty.getApplicationUrl() + "/b/core/m$load_image_v2?sha=" + properties.get("userPhotoSha") + "&type=S");
    }

    private static Map<String, Object> preparePayloadEditorConfig(Map<String, String> properties) {
        Map<String, Object> editorConfig = new HashMap<>();
        editorConfig.put("callbackUrl", ""); // TODO implement callback
        editorConfig.put("mode", "view");
        editorConfig.put("user", prepareUser(properties));
        return editorConfig;
    }

    private static Map<String, Object> preparePayload(Map<String, String> properties) {
        return Map.of("document", prepareDocument(properties), "editorConfig", preparePayloadEditorConfig(properties));
    }

    private static String sign(Map<String, Object> payload) throws OnlyofficeException {
        try {
            Algorithm algorithm = Algorithm.HMAC256(ApplicationProperty.getOnlyofficeSecret());
            Instant now = Instant.now();

            return JWT.create()
                    .withPayload(payload)
                    .withIssuedAt(now)
                    .withExpiresAt(now.plusSeconds(60 * 2))
                    .sign(algorithm);
        } catch (Exception e) {
            throw new OnlyofficeException("Onlyoffice token signing error", e);
        }
    }

    private static Map<String, ?> prepareCustomization() {
        Map<String, Object> customization = new HashMap<>();
        customization.put("anonymous", Map.of("request", false, "label", "Guest"));
        customization.put("autosave", false);
        customization.put("comments", false);
        customization.put("compactHeader", true);
        customization.put("compactToolbar", true);
        customization.put("features", Map.of("spellcheck", Map.of("mode", false, "change", false)));
        customization.put("feedback", Map.of("visible", false));
        customization.put("forcesave", false);
        customization.put("help", false);
        customization.put("hideNotes", false);
        customization.put("hideRightMenu", true);
        customization.put("hideRulers", true);
        customization.put("hideSave", true);
        customization.put("macros", false);
        customization.put("macrosMode", "disable");
        customization.put("plugins", false);
        customization.put("review", Map.of("hideReviewDisplay", true, "hoverMode", false, "reviewDisplay", "original", "showReviewChanges", false, "trackChanges", false));
        customization.put("submitForm", false);
        customization.put("toolbarHideFileName", false);
        customization.put("toolbarNoTabs", false);
        customization.put("uiTheme", "theme-light");
        customization.put("unit", "cm");
        customization.put("zoom", 100);
        return customization;
    }

    private static Map<String, Boolean> preparePermissions() {
        Map<String, Boolean> permissions = new HashMap<>();
        permissions.put("chat", false);
        permissions.put("comment", false);
        permissions.put("copy", true);
        permissions.put("download", true);
        permissions.put("edit", false);
        permissions.put("fillForms", false);
        permissions.put("modifyContentControl", false);
        permissions.put("modifyFilter", false);
        permissions.put("print", true);
        permissions.put("protect", false);
        permissions.put("review", false);
        return permissions;
    }

    private static String getDocumentType(String fileType) {
        return switch (fileType) {
            case "csv":
            case "xls":
            case "xlsb":
            case "xlsm":
            case "xlsx":
            case "xlt":
            case "xltm":
            case "xltx":
            case "ods":
            case "fods":
            case "fodt":
                yield "cell";
            case "djvu":
            case "epub":
            case "fb2":
            case "htm":
            case "html":
            case "mht":
            case "oxps":
            case "rtf":
            case "txt":
            case "xml":
            case "doc":
            case "docm":
            case "docx":
            case "docxf":
            case "dot":
            case "dotm":
            case "dotx":
                yield "word";
            case "fodp":
            case "odp":
            case "oform":
            case "otp":
            case "ott":
            case "pot":
            case "potm":
            case "potx":
            case "pps":
            case "ppsm":
            case "ppsx":
            case "ppt":
            case "pptm":
            case "pptx":
                yield "slide";
            case "pdf":
                yield "pdf";
            default:
                yield "text";
        };
    }

    record Source(String sha, String fileName, Map<String, String> properties) {
    }
}
