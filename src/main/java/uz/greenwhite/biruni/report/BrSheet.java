package uz.greenwhite.biruni.report;

import java.util.HashSet;

public class BrSheet {

    public String name;
    public int tableId;
    public String param;

    public int zoom;
    public boolean noGridlines;

    public int splitHorizontal;
    public int splitVertical;

    public double pageHeader;
    public double pageFooter;
    public double pageBottom;
    public double pageTop;
    public double pageRight;
    public double pageLeft;

    public boolean landscape;
    public boolean fitToPage;
    public boolean hidden = false;
    public boolean wrapMergedCells;

    public HashSet<Integer> rowPageBreaks = new HashSet<>();
    public HashSet<Integer> columnPageBreaks = new HashSet<>();
    public HashSet<Integer> rowPageBreakables = new HashSet<>();
    public HashSet<Integer> columnPageBreakables = new HashSet<>();
}
