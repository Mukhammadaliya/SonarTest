package uz.greenwhite.biruni.report;


public class BrCellMeta {

    public char type;
    public int styleIndex = -1;
    public int rowspan;
    public int colspan;
    public int width;
    public int height;
    public boolean label = true;
    public String menuIds;

    public void init() {
        if (rowspan < 1) {
            rowspan = 1;
        }

        if (colspan < 1) {
            colspan = 1;
        }
    }

    public boolean isTypeTable(){
        return type == 'T';
    }
}
