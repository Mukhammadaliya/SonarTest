package uz.greenwhite.biruni.easyreport;

import java.util.Map;

public class ERSourceData {
    private String fileSha;
    private String fileName;
    private String version;
    private Map<String, Object> data;
    private Map<String, String> viewProperties;

    public String getFileSha() {
        return fileSha;
    }

    public String getFileName() {
        return fileName;
    }

    public String getVersion() {
        return version;
    }

    public Map<String, Object> getData() {
        return data;
    }

    public Map<String, String> getViewProperties() {
        return viewProperties;
    }
}
