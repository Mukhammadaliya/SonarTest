package uz.greenwhite.biruni.easyreport;

import java.util.ArrayList;
import java.util.List;

public class ERRow {
    private final int rownum;
    private short rowHeight;
    private boolean pageBreak;

    private List<ERCell> cells = new ArrayList<>();

    public ERRow(int rowNum, short rowHeight) {
        this.rownum = rowNum;
        this.rowHeight = rowHeight;
    }

    public ERRow(int rowNum, short rowHeight, boolean pageBreak) {
        this(rowNum,rowHeight);
        this.pageBreak = pageBreak;
    }

    public int getRownum() {
        return rownum;
    }

    public short getRowHeight() {
        return rowHeight;
    }

    public void setRowHeight(short rowHeight) {
        this.rowHeight = rowHeight;
    }

    public List<ERCell> getCells() {
        return cells;
    }

    public void setCells(List<ERCell> cells) {
        this.cells = cells;
    }

    public ERCell getCell(int index) {
        return cells.get(index);
    }

    public void addCell(ERCell erCell) {
        cells.add(erCell);
    }

    public boolean hasPageBreak() {
        return pageBreak;
    }

    public void setPageBreak(boolean pageBreak) {
        this.pageBreak = pageBreak;
    }
}
