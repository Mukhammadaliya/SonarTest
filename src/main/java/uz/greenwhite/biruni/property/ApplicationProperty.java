package uz.greenwhite.biruni.property;

public class ApplicationProperty {
    private static ApplicationProperty instance;

    private final String applicationUrl;
    private final String contextPath;
    private final String onlyofficeUrl;
    private final String onlyofficeSecret;

    private ApplicationProperty(String applicationUrl, String contextPath, String onlyofficeUrl, String onlyofficeSecret) {
        this.applicationUrl = applicationUrl.replaceAll("/$", "");
        this.contextPath = contextPath.replaceAll("/$", "");
        this.onlyofficeUrl = onlyofficeUrl.replaceAll("/$", "");
        this.onlyofficeSecret = onlyofficeSecret;
    }

    public static synchronized void Init(String applicationUrl, String contextPath, String onlyofficeUrl, String onlyofficeSecret) {
        if (instance == null) {
            instance = new ApplicationProperty(applicationUrl, contextPath, onlyofficeUrl, onlyofficeSecret);
        }
    }

    private static void checkInitialization() {
        if (instance == null) throw new RuntimeException("ApplicationProperty is not initialized");
    }

    public static boolean applicationUrlConfigured() {
        return instance != null && instance.applicationUrl != null && !instance.applicationUrl.isEmpty();
    }

    public static String getApplicationUrl() {
        checkInitialization();
        return instance.applicationUrl;
    }

    public static String getContextPath() {
        checkInitialization();
        return instance.contextPath;
    }

    public static boolean onlyofficeDisabled() {
        return !applicationUrlConfigured()
                || instance.onlyofficeUrl == null || instance.onlyofficeSecret == null
                || instance.onlyofficeUrl.isEmpty() || instance.onlyofficeSecret.isEmpty();
    }

    public static String getOnlyofficeUrl() {
        checkInitialization();
        return instance.onlyofficeUrl;
    }

    public static String getOnlyofficeSecret() {
        checkInitialization();
        return instance.onlyofficeSecret;
    }
}