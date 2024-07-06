package uz.greenwhite.biruni.report;

import java.util.List;

public class GridContent {
    public String type;
    public int fromIndex;
    public int toIndex;

    public GridContent(String type, int fromIndex) {
        this.type = type;
        this.fromIndex = fromIndex;
        this.toIndex = -1;
    }

    public static String getGridType(char t) {
        String type = null;
        switch (t) {
            case 't':
                type = "table";
                break;
            case 'h':
                type = "thead";
                break;
            case 'b':
                type = "tbody";
                break;
            case 'f':
                type = "tfoot";
                break;
        }
        return type;
    }

    public static int lastGridTypeIndex(List<GridContent> gridContents, char t) {
        for (int i = gridContents.size() - 1; i >= 0; i--) {
            GridContent gc = gridContents.get(i);
            if (gc.type.equals(getGridType(t)) && gc.toIndex == -1) {
                return i;
            }
        }
        return -1;
    }
}
