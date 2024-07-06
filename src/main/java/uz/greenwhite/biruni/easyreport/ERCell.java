package uz.greenwhite.biruni.easyreport;


import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.ss.usermodel.DateUtil;
import org.apache.poi.xssf.usermodel.XSSFCellStyle;

public class ERCell {
    private int colnum;

    private CellType cellType;
    private String stringValue;
    private double numericValue;

    private boolean wrapText;

    private short rotation;
    private short horizontalAlignment;
    private short verticalAlignment;

    private short borderTop;
    private short borderLeft;
    private short borderRight;
    private short borderBottom;

    private String fontName;
    private short fontHeight;
    private boolean fontBold;
    private boolean fontItalic;
    private byte fontUnderline;

    private byte[] color;
    private byte[] fontColor;

    private String format;
    private boolean numberFormat;
    private boolean dateFormat;
    private boolean pageBreak;

    public ERCell(int colnum) {
        this.colnum = colnum;
        this.cellType = CellType.BLANK;
    }

    public ERCell(int colnum, CellType cellType) {
        this(colnum);
        this.cellType = cellType;
    }

    public ERCell(int colnum, boolean pageBreak) {
        this(colnum);
        this.pageBreak = pageBreak;
    }

    public int getColnum() {
        return colnum;
    }

    public void setColnum(int colnum) {
        this.colnum = colnum;
    }

    public CellType getCellType() {
        return cellType;
    }

    public void setCellType(CellType cellType) {
        this.cellType = cellType;
    }

    public String getStringValue() {
        return stringValue;
    }

    public void setStringValue(String stringValue) {
        this.stringValue = stringValue;
    }

    public double getNumericValue() {
        return numericValue;
    }

    public void setNumericValue(double numericValue) {
        this.numericValue = numericValue;
    }

    public boolean isWrapText() {
        return wrapText;
    }

    public void setWrapText(boolean wrapText) {
        this.wrapText = wrapText;
    }

    public short getRotation() {
        return rotation;
    }

    public void setRotation(short rotation) {
        this.rotation = rotation;
    }

    public short getHorizontalAlignment() {
        return horizontalAlignment;
    }

    public void setHorizontalAlignment(short horizontalAlignment) {
        this.horizontalAlignment = horizontalAlignment;
    }

    public short getVerticalAlignment() {
        return verticalAlignment;
    }

    public void setVerticalAlignment(short verticalAlignment) {
        this.verticalAlignment = verticalAlignment;
    }

    public short getBorderTop() {
        return borderTop;
    }

    public void setBorderTop(short borderTop) {
        this.borderTop = borderTop;
    }

    public short getBorderLeft() {
        return borderLeft;
    }

    public void setBorderLeft(short borderLeft) {
        this.borderLeft = borderLeft;
    }

    public short getBorderRight() {
        return borderRight;
    }

    public void setBorderRight(short borderRight) {
        this.borderRight = borderRight;
    }

    public short getBorderBottom() {
        return borderBottom;
    }

    public void setBorderBottom(short borderBottom) {
        this.borderBottom = borderBottom;
    }

    public String getFontName() {
        return fontName;
    }

    public void setFontName(String fontName) {
        this.fontName = fontName;
    }

    public short getFontHeight() {
        return fontHeight;
    }

    public void setFontHeight(short fontHeight) {
        this.fontHeight = fontHeight;
    }

    public boolean isFontBold() {
        return fontBold;
    }

    public void setFontBold(boolean fontBold) {
        this.fontBold = fontBold;
    }

    public boolean isFontItalic() {
        return fontItalic;
    }

    public void setFontItalic(boolean fontItalic) {
        this.fontItalic = fontItalic;
    }

    public byte getFontUnderline() {
        return fontUnderline;
    }

    public void setFontUnderline(byte fontUnderline) {
        this.fontUnderline = fontUnderline;
    }

    public byte[] getColor() {
        return color;
    }

    public void setColor(byte[] color) {
        this.color = color;
    }

    public byte[] getFontColor() {
        return fontColor;
    }

    public void setFontColor(byte[] fontColor) {
        this.fontColor = fontColor;
    }

    public String getFormat() {
        return format;
    }

    public void setFormat(XSSFCellStyle style) {
        try {
            this.format = style.getDataFormatString();
            this.numberFormat = !(format.equals("@") || format.equals("General"));
            this.dateFormat = DateUtil.isADateFormat(style.getDataFormat(), format);
        } catch (Exception ex) {
            this.numberFormat = false;
            this.dateFormat = false;
        }

    }

    public boolean isNumberFormat() {
        return numberFormat;
    }

    public boolean isDateFormat() {
        return dateFormat;
    }

    public boolean hasPageBreak() {
        return pageBreak;
    }

    public void setPageBreak(boolean pageBreak) {
        this.pageBreak = pageBreak;
    }
}
