package uz.greenwhite.biruni.report;

public class BrCell {

    public int metaIndex;
    public String value;
    public String param;

    // Variable values

    public BrCellMeta meta;
    public BrTable table;

    public Point point;

    public int colspan;
    public int rowspan;

    public int width;
    public int height;

    public boolean isTypeTable() {
        return meta.isTypeTable();
    }
}
