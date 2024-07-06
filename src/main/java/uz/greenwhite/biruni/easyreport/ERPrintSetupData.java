package uz.greenwhite.biruni.easyreport;

import org.apache.poi.xssf.usermodel.XSSFPrintSetup;

public class ERPrintSetupData {
    private final short paperSize;
    private final short scale;
    private final short fitWidth;
    private final short fitHeight;
    private final short pageStart;
    private final short hResolution;
    private final boolean landscape;
    private final boolean usePage;
    private final boolean validSettings;
    private final double topMargin;
    private final double bottomMargin;
    private final double leftMargin;
    private final double rightMargin;
    private final double headerMargin;
    private final double footerMargin;

    public ERPrintSetupData(XSSFPrintSetup printSetup) {
        /**
         * more parameters of printSetup can be used here if needed
         */
        this.paperSize = printSetup.getPaperSize();
        this.scale = printSetup.getScale();
        this.fitWidth = printSetup.getFitWidth();
        this.fitHeight = printSetup.getFitHeight();
        this.pageStart = printSetup.getPageStart();
        this.hResolution = printSetup.getHResolution();
        this.landscape = printSetup.getLandscape();
        this.usePage = printSetup.getUsePage();
        this.validSettings = printSetup.getValidSettings();
        this.topMargin = printSetup.getTopMargin();
        this.bottomMargin = printSetup.getBottomMargin();
        this.leftMargin = printSetup.getLeftMargin();
        this.rightMargin = printSetup.getRightMargin();
        this.headerMargin = printSetup.getHeaderMargin();
        this.footerMargin = printSetup.getFooterMargin();
    }

    public short getPaperSize() {
        return paperSize;
    }

    public short getScale() {
        return scale;
    }

    public short getFitWidth() {
        return fitWidth;
    }

    public short getFitHeight() {
        return fitHeight;
    }

    public short getPageStart() {
        return pageStart;
    }

    public boolean isLandscape() {
        return landscape;
    }

    public short getHResolution() {
        return hResolution;
    }

    public boolean isUsePage() {
        return usePage;
    }

    public boolean isValidSettings() {
        return validSettings;
    }

    public double getTopMargin() {
        return topMargin;
    }

    public double getBottomMargin() {
        return bottomMargin;
    }

    public double getLeftMargin() {
        return leftMargin;
    }

    public double getRightMargin() {
        return rightMargin;
    }

    public double getHeaderMargin() {
        return headerMargin;
    }

    public double getFooterMargin() {
        return footerMargin;
    }
}
