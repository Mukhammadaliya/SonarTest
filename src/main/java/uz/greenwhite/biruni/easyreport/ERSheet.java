package uz.greenwhite.biruni.easyreport;

import java.util.*;

public class ERSheet {
    private final String sheetName;
    private final int defaultColWidth;

    private List<ERRow> rows;
    private List<ERVerticalLoop> verticalLoops;
    private List<ERHorizontalLoop> horizontalLoops;
    private List<String> mergedRegions;
    private List<ERPhoto> photos;
    private ERPrintSetupData printSetupData;
    private Map<Integer, Integer> colWidths;

    {
        rows = new ArrayList<>();
        verticalLoops = new ArrayList<>();
        horizontalLoops = new ArrayList<>();
        mergedRegions = new ArrayList<>();
        photos = new ArrayList<>();
        colWidths = new HashMap<>();
    }

    public ERSheet(String sheetName, int defaultColWidth) {
        this.sheetName = sheetName;
        this.defaultColWidth = defaultColWidth;
    }

    public String getSheetName() {
        return sheetName;
    }

    public int getDefaultColWidth() {
        return defaultColWidth;
    }

    public List<ERRow> getRows() {
        return rows;
    }

    public void setRows(List<ERRow> rows) {
        this.rows = rows;
    }

    public ERRow getRow(int index) {
        return rows.get(index);
    }

    public void addRow(ERRow erRow) {
        rows.add(erRow);
    }

    public void addRowWithCell(int rownum, int colnum, short rowHeight) {
        Optional<ERRow> optionalERRow = rows.stream().filter(r -> r.getRownum() == rownum).findFirst();
        ERRow erRow;

        if (optionalERRow.isPresent()) {
            erRow = optionalERRow.get();
        } else {
            erRow = new ERRow(rownum, rowHeight);
            rows.add(erRow);
        }

        if (erRow.getCells().stream().noneMatch(erCell -> erCell.getColnum() == colnum)) {
            erRow.addCell(new ERCell(colnum));
            erRow.getCells().sort(Comparator.comparing(ERCell::getColnum));
        }
    }

    public List<ERVerticalLoop> getVerticalLoops() {
        return verticalLoops;
    }

    public void setVerticalLoops(List<ERVerticalLoop> verticalLoops) {
        this.verticalLoops = verticalLoops;
    }

    public ERVerticalLoop getVerticalLoop(int index) {
        return verticalLoops.get(index);
    }

    public void addVerticalLoop(ERVerticalLoop verticalLoop) {
        verticalLoops.add(verticalLoop);
    }

    public void setVerticalLoopEndRowNum(String key, int rowNum, int colNum) {
        Optional<ERVerticalLoop> verticalLoop = verticalLoops.stream()
                .filter(a -> key.equals(a.getKey()) && a.getEndRownum() < 0)
                .reduce((f, s) -> s);

        if (verticalLoop.isPresent()) {
            verticalLoop.get().setEndRownum(rowNum);
        } else {
            throw new RuntimeException("Cycle with key " + key + " is not opened in row " + (rowNum + 1) + " and column " + (colNum + 1) + ". Open cycle before closing");
        }
    }

    public List<ERHorizontalLoop> getHorizontalLoops() {
        return horizontalLoops;
    }

    public void setHorizontalLoops(List<ERHorizontalLoop> horizontalLoops) {
        this.horizontalLoops = horizontalLoops;
    }

    public void addHorizontalLoop(ERHorizontalLoop horizontalLoop) {
        horizontalLoops.add(horizontalLoop);
    }

    public void setHorizontalLoopEndRowNum(String key, int rowNum, int colNum) {
        Optional<ERHorizontalLoop> optionalHorizontalLoop = horizontalLoops.stream()
                .filter(a -> key.equals(a.getKey()) && a.getEndRownum() < 0 && a.getEndColnum() < 0 && a.getStartColnum() <= colNum)
                .reduce((f, s) -> s);

        if (optionalHorizontalLoop.isPresent()) {
            ERHorizontalLoop horizontalLoop = optionalHorizontalLoop.get();
            horizontalLoop.setEndRownum(rowNum);
            horizontalLoop.setEndColnum(colNum);
        } else {
            throw new RuntimeException("Cycle with key " + key + " is not opened in row " + (rowNum + 1) + " and column " + (colNum + 1) + ". Open cycle before closing");
        }
    }

    public List<String> getMergedRegions() {
        return mergedRegions;
    }

    public void setMergedRegions(List<String> mergedRegions) {
        this.mergedRegions = mergedRegions;
    }

    public String getMergedRegion(int index) {
        return mergedRegions.get(index);
    }

    public void addMergedRegion(String mergedRegion) {
        mergedRegions.add(mergedRegion);
    }

    public List<ERPhoto> getPhotos() {
        return photos;
    }

    public void setPhotos(List<ERPhoto> photos) {
        this.photos = photos;
    }

    public ERPhoto getPhoto(int index) {
        return photos.get(index);
    }

    public void addPhoto(ERPhoto photo) {
        photos.add(photo);
    }

    public Map<Integer, Integer> getColWidths() {
        return colWidths;
    }

    public void setColWidths(Map<Integer, Integer> colWidths) {
        this.colWidths = colWidths;
    }

    public Integer getColWidth(Integer colNum) {
        return colWidths.get(colNum);
    }

    public void setColWidth(Integer colNum, Integer colWidth) {
        colWidths.put(colNum, colWidth);
    }

    public void sortRows() {
        rows.sort(Comparator.comparing(ERRow::getRownum));
    }

    public ERPrintSetupData getPrintSetupData() {
        return printSetupData;
    }

    public void setPrintSetupData(ERPrintSetupData printSetupData) {
        this.printSetupData = printSetupData;
    }
}
