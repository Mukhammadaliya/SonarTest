package uz.greenwhite.biruni.easyreport;

public class ERUtil {
    public static final String VERSION = "1.1.1";

    public static final int WORKBOOK_ROW_ACCESS = 50;

    private static final String MASK_FOR_ELEMENT_START = "~MFES~";
    private static final String MASK_FOR_ELEMENT_END = "~MFEE~";
    private static final String MASK_FOR_CYCLE_START = "~MFCS~";
    private static final String MASK_FOR_CYCLE_END = "~MFCE~";
    private static final String MASK_FOR_HORIZONTAL_CYCLE_START = "~MFHCS~";
    private static final String MASK_FOR_HORIZONTAL_CYCLE_END = "~MFHCE~";

    static String maskEscapedSymbols(String value) {
        value = value.replaceAll("\\\\\\[", MASK_FOR_ELEMENT_START);
        value = value.replaceAll("\\\\]", MASK_FOR_ELEMENT_END);
        value = value.replaceAll("\\\\<", MASK_FOR_CYCLE_START);
        value = value.replaceAll("\\\\>", MASK_FOR_CYCLE_END);
        value = value.replaceAll("\\\\\\{", MASK_FOR_HORIZONTAL_CYCLE_START);
        value = value.replaceAll("\\\\}", MASK_FOR_HORIZONTAL_CYCLE_END);
        return value;
    }

    static String unmaskEscapedSymbols(String value) {
        value = value.replaceAll(MASK_FOR_ELEMENT_START, "[");
        value = value.replaceAll(MASK_FOR_ELEMENT_END, "]");
        value = value.replaceAll(MASK_FOR_CYCLE_START, "<");
        value = value.replaceAll(MASK_FOR_CYCLE_END, ">");
        value = value.replaceAll(MASK_FOR_HORIZONTAL_CYCLE_START, "{");
        value = value.replaceAll(MASK_FOR_HORIZONTAL_CYCLE_END, "}");
        return value;
    }

    static String[] getStartLoopKey(String value) {
        return new String[]{value.substring(value.indexOf('<') + 1, value.indexOf('>')), value.substring(0, value.indexOf('<')) + value.substring(value.indexOf('>') + 1)};
    }

    static String[] getEndLoopKey(String value) {
        return new String[]{value.substring(value.indexOf("</") + 2, value.indexOf('>')), value.substring(0, value.indexOf("</")) + value.substring(value.indexOf('>') + 1)};
    }

    static String[] getStartHorizontalLoopKey(String value) {
        return new String[]{value.substring(value.indexOf('{') + 1, value.indexOf('}')), value.substring(0, value.indexOf('{')) + value.substring(value.indexOf('}') + 1)};
    }

    static String[] getEndHorizontalLoopKey(String value) {
        return new String[]{value.substring(value.indexOf("{/") + 2, value.indexOf('}')), value.substring(0, value.indexOf("{/")) + value.substring(value.indexOf('}') + 1)};
    }

    static String getElementKey(String value) {
        if (value.indexOf('[') < 0) throw new IndexOutOfBoundsException();
        return value.substring(value.indexOf('[') + 1, value.indexOf(']'));
    }

    static String replaceElement(String value, String key, Object data) {
        return value.replace("[" + key + "]", data != null ? String.valueOf(data) : "");
    }
}
