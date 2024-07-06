package uz.greenwhite.biruni.report;

import net.coobird.thumbnailator.Thumbnails;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.util.Units;
import org.apache.poi.xssf.streaming.*;
import org.apache.poi.xssf.usermodel.*;
import uz.greenwhite.biruni.filemanager.FileManager;
import uz.greenwhite.biruni.service.BarcodeService;

import javax.imageio.ImageIO;
import javax.swing.*;
import javax.swing.text.*;
import java.awt.Color;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.*;
import java.util.*;
import java.util.List;

@SuppressWarnings("deprecation")
public class Excel {
    private final BrBook book;
    private final SXSSFWorkbook wb;
    private final List<XSSFFont> fonts;
    private final List<XSSFCellStyle> styles;
    private final int dateFormat;

    public Excel(BrBook book) {
        try {
            this.book = book;
            this.wb = new SXSSFWorkbook(book.groupingExists ? 10000 : SXSSFWorkbook.DEFAULT_WINDOW_SIZE);
            this.fonts = new ArrayList<>(book.fonts.size());
            this.styles = new ArrayList<>(book.styles.size());
            CreationHelper ch = this.wb.getCreationHelper();
            this.dateFormat = ch.createDataFormat().getFormat("dd.MM.yyyy HH:mm:ss");
        } catch (Exception e) {
            tryToCloseWorkbook();
            throw e;
        }
    }

    public void write(OutputStream os) throws IOException {
        try {
            print();
            wb.write(os);
        } finally {
            tryToCloseWorkbook();
        }
    }

    private void tryToCloseWorkbook() {
        if (wb == null) return;

        wb.dispose();

        try {
            wb.close();
        } catch (IOException ex) {
            throw new RuntimeException(ex);
        }
    }


    private void print() {
        for (BrFont fi : book.fonts) {
            fonts.add(createFont(fi));
        }

        for (BrStyle si : book.styles) {
            styles.add(createStyle(si));
        }

        for (BrSheet sheet : book.sheets) {
            printSheet(sheet);
        }
    }

    private void printSheet(BrSheet sheet) {
        Result rs = evalResult(sheet);
        SXSSFSheet sh = createSheet(sheet.name);

        setSheetOptions(sheet, sh);

        setColumns(rs.columnWidths, sh);

        printCells(rs, sh, sheet.wrapMergedCells);

        collectAndSetPageBreaks(sheet, rs, sh);

        setGroupings(rs.groupings, sh);

        sh.setAutobreaks(false);
    }

    private Result evalResult(BrSheet sheet) {
        BrTable table = book.tables.get(sheet.tableId);
        return table.unroll();
    }


    private void setColumns(int[] columnWidths, SXSSFSheet sh) {
        for (int i = 0; i < columnWidths.length; i++) {
            int c = columnWidths[i];
            if (c > 0) {
                sh.setColumnWidth(i, PixelUtil.pixel2WidthUnits(c));
            } else {
                columnWidths[i] = 64;
            }
        }
    }

    private void setGroupings(List<Grouping> groupings, SXSSFSheet sh) {
        for (Grouping g : groupings) {
            switch (g.type) {
                case 'r':
                    sh.groupRow(g.fromIndex, g.toIndex);
                    if (!g.show) {
                        sh.setRowGroupCollapsed(g.fromIndex, true);
                    }
                    break;
                case 'c':
                    sh.groupColumn(g.fromIndex, g.toIndex);
                    if (!g.show) {
                        sh.setColumnGroupCollapsed(g.fromIndex, true);
                    }
                    break;
            }
        }
    }

    private void printCells(Result rs, SXSSFSheet sh, boolean wrapMergedCells) {
        HashSet<Integer> mergedCellRowNum = new HashSet<>();
        HashMap<Integer, HashMap<Integer, Short>> rowMergedCellsGeneralLengths = new HashMap<>();
        Object[][] m = rs.matrix;

        for (int i = 0; i < m.length; i++) {
            SXSSFRow r = sh.createRow(i);
            short rowHeightInPoint = (short) sh.getDefaultRowHeightInPoints();
            boolean setRowHeight = mergedCellRowNum.contains(i);

            if (i < rs.rowHeights.length && rs.rowHeights[i] > 0) {
                rowHeightInPoint = (short) Units.pixelToPoints(rs.rowHeights[i]);
                r.setHeightInPoints(rowHeightInPoint);
                setRowHeight = true;
            }

            Object[] cs = m[i];
            for (int j = 0; j < cs.length; j++) {
                Object c1 = cs[j];
                if (c1 == null) {
                    continue;
                } else if (c1 instanceof XSSFCellStyle) {
                    r.createCell(j).setCellStyle((XSSFCellStyle) c1);
                    continue;
                }

                BrCell cell = (BrCell) c1;
                SXSSFCell c = r.createCell(j);
                XSSFCellStyle style = null;

                if (0 <= cell.meta.styleIndex && cell.meta.styleIndex <= styles.size()) {
                    style = styles.get(cell.meta.styleIndex);
                    c.setCellStyle(style);
                }

                if (cell.value != null && cell.value.length() > 0) {
                    if (cell.meta.type == 'N') {
                        try {
                            c.setCellValue(Double.parseDouble(cell.value));
                        } catch (NumberFormatException e) {
                            c.setCellValue(cell.value);
                        }
                    } else if (cell.meta.type == 'D') {
                        assert style != null;
                        style.setDataFormat(dateFormat);
                        c.setCellStyle(style);
                        c.setCellValue(cell.value);
                    } else if (cell.meta.type == 'I' || cell.meta.type == 'B' || cell.meta.type == 'Q' || cell.meta.type == 'M') {
                        byte[] bytes;

                        if (cell.meta.type == 'I') {
                            bytes = FileManager.loadFile(cell.value);

                            if (bytes.length > 0) {
                                try {
                                    if (cell.meta.width > 0 || cell.meta.height > 0) {
                                        ByteArrayOutputStream os = new ByteArrayOutputStream();
                                        Thumbnails.Builder<? extends InputStream> tb = Thumbnails.of(new ByteArrayInputStream(bytes));
                                        if (cell.meta.width > 0) {
                                            tb.width(cell.meta.width);
                                        }
                                        if (cell.meta.height > 0) {
                                            tb.height(cell.meta.height);
                                        }

                                        tb.toOutputStream(os);

                                        bytes = os.toByteArray();
                                        os.close();
                                    }
                                } catch (IOException e) {
                                    throw new RuntimeException("put image to excel", e);
                                }
                            }
                        } else if (cell.meta.type == 'B') {
                            try {
                                String text = cell.value;
                                int width = 300;
                                int height = 100;
                                int extraHeight = 20;
                                int fontSize = 14;

                                if (cell.meta.width > 0) width = cell.meta.width;
                                if (cell.meta.height > 0) height = cell.meta.height;
                                if (style != null) {
                                    XSSFFont font = style.getFont();
                                    if (font != null) {
                                        fontSize = font.getFontHeight() / 20;
                                    }
                                }

                                if (cell.meta.label) {
                                    BufferedImage image = BarcodeService.generateBufferedImageBarcode(text, width, height, extraHeight, fontSize);
                                    ByteArrayOutputStream baos = new ByteArrayOutputStream();
                                    ImageIO.write(image, "png", baos);
                                    baos.flush();
                                    bytes = baos.toByteArray();
                                    baos.close();
                                } else {
                                    bytes = BarcodeService.generateByteArrayBarcode(text, height, width);
                                }
                            } catch (Exception e) {
                                throw new RuntimeException("put image to excel", e);
                            }
                        } else if (cell.meta.type == 'Q') {
                            try {
                                String text = cell.value;
                                int width = 300;
                                int height = 300;

                                if (cell.meta.width > 0) width = cell.meta.width;
                                if (cell.meta.height > 0) height = cell.meta.height;


                                bytes = BarcodeService.generateByteArrayQRcode(text, height, width);
                            } catch (Exception e) {
                                throw new RuntimeException("put image to excel", e);
                            }
                        } else {
                            try {
                                String text = cell.value;
                                int width = 88;
                                int height = 88;

                                if (cell.meta.width > 0) width = cell.meta.width;
                                if (cell.meta.height > 0) height = cell.meta.height;

                                bytes = BarcodeService.generateByteArrayGS1DataMatrix(text, height, width);
                            } catch (Exception e) {
                                throw new RuntimeException("put image to excel", e);
                            }
                        }

                        if (bytes.length > 0) {
                            int pictureIndex = wb.addPicture(bytes, SXSSFWorkbook.PICTURE_TYPE_JPEG);

                            CreationHelper helper = wb.getCreationHelper();
                            ClientAnchor anchor = helper.createClientAnchor();
                            anchor.setAnchorType(ClientAnchor.AnchorType.MOVE_DONT_RESIZE);
                            anchor.setRow1(i);

                            SXSSFDrawing drawing = sh.createDrawingPatriarch();
                            Picture pict = drawing.createPicture(anchor, pictureIndex);

                            //horizontal position of the picture
                            if (0 <= cell.meta.styleIndex && cell.meta.styleIndex <= styles.size()) {
                                int align = book.styles.get(cell.meta.styleIndex).align;
                                //2 - central, 3 - right position of the picture
                                if (align == 2 || align == 3) {
                                    //get the picture width
                                    int pictWidthPx = pict.getImageDimension().width;
                                    //get the cell width
                                    float cellWidthPx = 0f;
                                    for (int col = j; col < j + cell.colspan; col++) {
                                        cellWidthPx += sh.getColumnWidthInPixels(col);
                                    }
                                    //determine the new first anchor column dependent of the center position
                                    //and the remaining pixels as Dx
                                    int anchorCol1 = j, centerPosPx, columnWidth;
                                    if (align == 2) {
                                        centerPosPx = Math.round(cellWidthPx / 2f - (float) pictWidthPx / 2f);
                                        for (int col = j; col < j + cell.colspan; col++) {
                                            columnWidth = Math.round(sh.getColumnWidthInPixels(col));
                                            if (columnWidth < centerPosPx) {
                                                centerPosPx -= columnWidth;
                                                anchorCol1 = col + 1;
                                            } else {
                                                break;
                                            }
                                        }
                                    } else {
                                        centerPosPx = 0;
                                        for (int col = j; col < j + cell.colspan; col++) {
                                            columnWidth = Math.round(sh.getColumnWidthInPixels(col));
                                            if (cellWidthPx - columnWidth > pictWidthPx) {
                                                cellWidthPx -= columnWidth;
                                                anchorCol1 = col + 1;
                                            } else {
                                                centerPosPx = Math.round(cellWidthPx - pictWidthPx);
                                                if (centerPosPx < 0) centerPosPx = 0;
                                                break;
                                            }
                                        }
                                    }
                                    //set the new upper left anchor position
                                    anchor.setCol1(anchorCol1);
                                    //set the remaining pixels up to the center position as Dx in unit EMU
                                    anchor.setDx1(centerPosPx * Units.EMU_PER_PIXEL);
                                } else {
                                    anchor.setCol1(j);
                                }

                                //resize the picture to original size
                                pict.resize(1.0);
                            }
                        }
                        c.setCellValue("");
                    } else {
                        c.setCellValue(cell.value);

                        if (wrapMergedCells && c.getCellStyle().getWrapText() && wb.getRandomAccessWindowSize() > cell.rowspan) {
                            try {
                                CellRangeAddress cellAddresses = null;
                                short mergedCellTextHeight;

                                if (c.getCellStyle().getRotation() == 0) {
                                    short textHeightInPoint = 0;

                                    if (cell.colspan > 1 || cell.rowspan > 1) {
                                        setRowHeight = true;
                                        cellAddresses = new CellRangeAddress(i, i, j, j + cell.colspan - 1);
                                    }
                                    mergedCellTextHeight = getHorizontalTextPreferredHeightInPoint(c, cell.value, cellAddresses);

                                    if (cell.rowspan == 1) {
                                        textHeightInPoint = mergedCellTextHeight;
                                    } else {
                                        addPreferredRowMergedCellLengths(i, i + cell.rowspan - 1, mergedCellTextHeight, rowMergedCellsGeneralLengths);

                                        for (int k = i + 1; k < i + cell.rowspan; k++) {
                                            mergedCellRowNum.add(k);
                                        }
                                    }

                                    if (textHeightInPoint > rowHeightInPoint) {
                                        rowHeightInPoint = textHeightInPoint;
                                    }
                                } else if (Math.abs(c.getCellStyle().getRotation()) == 90) {
                                    if (cell.colspan > 1 || cell.rowspan > 1) {
                                        cellAddresses = new CellRangeAddress(i, i + cell.rowspan - 1, j, j);
                                    }
                                    mergedCellTextHeight = getVerticalTextPreferredHeightInPixel(c, cell.value, cellAddresses);
                                    addExtraLengthToSpanCells(j, j + cell.colspan - 1, mergedCellTextHeight, sh, rs.columnWidths, true);
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }
                    }
                }

                if (cell.rowspan > 1 || cell.colspan > 1) {
                    sh.addMergedRegion(new CellRangeAddress(i, i + cell.rowspan - 1, j, j + cell.colspan - 1));

                    for (int a = 0; a < cell.rowspan; a++) {
                        for (int b = 0; b < cell.colspan; b++) {
                            m[i + a][j + b] = style;
                        }
                    }
                }
            }

            if (wrapMergedCells) {
                if (setRowHeight && sh.getRow(i).getHeightInPoints() < rowHeightInPoint) {
                    sh.getRow(i).setHeightInPoints(rowHeightInPoint);
                }
                rs.rowHeights[i] = rowHeightInPoint;

                if (rowMergedCellsGeneralLengths.containsKey(i)) {
                    for (Map.Entry<Integer, Short> beginRowAndLength : rowMergedCellsGeneralLengths.get(i).entrySet()) {
                        addExtraLengthToSpanCells(beginRowAndLength.getKey(), i, beginRowAndLength.getValue(), sh, rs.rowHeights, false);
                    }
                }
            }
        }
    }

    private void addExtraLengthToSpanCells(int beginNum, int endNum, short length, SXSSFSheet sh, int[] lengths, boolean verticalText) {
        int sumLength = 0;

        for (int k = beginNum; k <= endNum; k++) {
            sumLength += lengths[k];
        }

        if (sumLength < length) {
            int averageForAdd = (int) ((length - sumLength) * 1.0 / (endNum - beginNum + 1));

            for (int k = beginNum; k <= endNum; k++) {
                lengths[k] += averageForAdd;

                if (verticalText) sh.setColumnWidth(k, PixelUtil.pixel2WidthUnits(lengths[k]));
                else sh.getRow(k).setHeightInPoints(lengths[k]);
            }
        }
    }

    private void addPreferredRowMergedCellLengths(int beginRowNum, int endRowNum, short mergedCellTextHeight, HashMap<Integer, HashMap<Integer, Short>> rowMergedCellLengths) {
        if (rowMergedCellLengths.containsKey(endRowNum)) {
            HashMap<Integer, Short> beginRowNumAndTextHeight = rowMergedCellLengths.get(endRowNum);

            if (!beginRowNumAndTextHeight.containsKey(beginRowNum) || beginRowNumAndTextHeight.get(beginRowNum) < mergedCellTextHeight) {
                beginRowNumAndTextHeight.put(beginRowNum, mergedCellTextHeight);
            }
        } else {
            rowMergedCellLengths.put(endRowNum, new HashMap<Integer, Short>() {{
                put(beginRowNum, mergedCellTextHeight);
            }});
        }
    }

    private short getVerticalTextPreferredHeightInPixel(SXSSFCell cell, String text, CellRangeAddress cellAddresses) throws Exception {
        float length = 0;

        if (cellAddresses != null) {
            for (int c = cellAddresses.getFirstRow(); c <= cellAddresses.getLastRow(); c++) {
                if (cell.getSheet().getRow(c) == null) {
                    length += cell.getSheet().getDefaultRowHeightInPoints();
                } else {
                    length += cell.getSheet().getRow(c).getHeightInPoints();
                }
            }
        } else {
            length = cell.getSheet().getRow(cell.getRowIndex()).getHeightInPoints();
        }

        return getPreferredHeightInPixel(cell, text, Units.pointsToPixel(length));
    }

    private short getHorizontalTextPreferredHeightInPoint(SXSSFCell cell, String text, CellRangeAddress cellAddresses) throws Exception {
        float length = 0;

        if (cellAddresses != null) {
            for (int c = cellAddresses.getFirstColumn(); c <= cellAddresses.getLastColumn(); c++) {
                length += cell.getSheet().getColumnWidthInPixels(c);
            }
        } else {
            length = cell.getSheet().getColumnWidthInPixels(cell.getColumnIndex());
        }

        return (short) Units.pixelToPoints(getPreferredHeightInPixel(cell, text, length));
    }

    private short getPreferredHeightInPixel(Cell cell, String text, float length) throws Exception {
        Font usedFont = wb.getFontAt(cell.getCellStyle().getFontIndex());
        java.awt.Font awtFont = new java.awt.Font(usedFont.getFontName(), java.awt.Font.PLAIN, Units.pointsToPixel(usedFont.getFontHeightInPoints()));
        JTextPane textPane = new CustomTextPane();
        textPane.setFont(awtFont);
        Dimension dimension = new Dimension(Math.round(length), Integer.MAX_VALUE);
        textPane.setSize(dimension);
        MutableAttributeSet attributeSet = new SimpleAttributeSet(textPane.getParagraphAttributes());
        StyleConstants.setBold(attributeSet, usedFont.getBold());
        StyleConstants.setItalic(attributeSet, usedFont.getItalic());
        StyledDocument document = textPane.getStyledDocument();
        document.setParagraphAttributes(0, document.getLength(), attributeSet, true);
        document.insertString(0, text, null);
        dimension.setSize(Math.round(length), textPane.getPreferredSize().getHeight());
        textPane.setPreferredSize(dimension);

        return (short) (dimension.getHeight() - 5);
    }

    private SXSSFSheet createSheet(String name) {
        if (name != null && name.length() > 0) {
            return wb.createSheet(name);
        } else {
            return wb.createSheet();
        }
    }

    /**
     * This method collects and sets the page breaks and page breakables of the given sheet
     */
    private void collectAndSetPageBreaks(BrSheet sheet, Result rs, SXSSFSheet sh) {
        collectPageBreaksAndPageBreakables(sheet, sheet.tableId, 0);

        if (!sheet.columnPageBreaks.isEmpty() || !sheet.columnPageBreakables.isEmpty() || !sheet.rowPageBreakables.isEmpty() || !sheet.rowPageBreaks.isEmpty()) {
            final double inch = 2.54;
            int heightPaddingInPoint = (int) ((sheet.pageTop + sheet.pageBottom) / inch * Units.POINT_DPI);
            int widthPaddingInPixel = (int) ((sheet.pageRight + sheet.pageLeft) / inch * Units.PIXEL_DPI);
            int heightInPoint = sheet.landscape ? 623 - heightPaddingInPoint : 869 - heightPaddingInPoint;
            int widthInPixel = sheet.landscape ? 1042 - widthPaddingInPixel : 736 - widthPaddingInPixel;

            float heightScale = findScale(rs.rowHeights, heightInPoint, sheet.rowPageBreakables, sheet.rowPageBreaks);
            float widthScale = findScale(rs.columnWidths, widthInPixel, sheet.columnPageBreakables, sheet.columnPageBreaks);
            float scale = Math.min(widthScale, heightScale);

            if (scale < 0.1) return;
            else if (scale < 1) {
                short setScale = (short) (scale * 100);
                sh.getPrintSetup().setScale(setScale);
                scale = (float) (setScale * 0.01);
            } else scale = 1;

            setPageBreaks(sh, rs.rowHeights, sheet.rowPageBreaks, sheet.rowPageBreakables, (int) (heightInPoint / scale), true);
            setPageBreaks(sh, rs.columnWidths, sheet.columnPageBreaks, sheet.columnPageBreakables, (int) (widthInPixel / scale), false);
        }
    }

    /**
     * This method collects page break and page breakables
     */
    private int collectPageBreaksAndPageBreakables(BrSheet sheet, int tableId, int rowNumber) {
        BrTable table = book.tables.get(tableId);
        BrRow row;
        BrCell cell;

        for (int i = 0, colSpan = 0; i < table.rows.size(); i++, rowNumber++, colSpan = 0) {
            row = table.rows.get(i);

            if (row.rowBreak) sheet.rowPageBreaks.add(rowNumber);
            if (sheet.wrapMergedCells && row.rowBreakable) sheet.rowPageBreakables.add(rowNumber);

            for (int x = 0; x < row.cells.size(); x++) {
                cell = row.cells.get(x);
                colSpan += cell.colspan;

                if (cell.isTypeTable()) {
                    rowNumber += collectPageBreaksAndPageBreakables(sheet, Integer.parseInt(cell.value), rowNumber);
                }

                if (row.colBreaks.contains(x)) sheet.columnPageBreaks.add(colSpan - 1);
                if (sheet.wrapMergedCells && row.colBreakables.contains(x)) sheet.columnPageBreakables.add(colSpan - 1);
            }
        }

        return table.rows.size() - 1;
    }

    /**
     * This method finds the scale to fit the largest page.
     * Scale is Min(defaultHeightPage/heightPage,defaultWidthPage/widthPage)
     */
    private float findScale(int[] lengths, int pageLength, HashSet<Integer> pageBreaks, HashSet<Integer> pageBreakables) {
        int sumLength = 0;
        int maxPageLength = 0;

        for (int i = 0; i < lengths.length; i++) {
            sumLength += lengths[i];

            if (pageBreakables.contains(i) || pageBreaks.contains(i)) {
                maxPageLength = Math.max(sumLength, maxPageLength);
                sumLength = 0;
            }
        }

        maxPageLength = Math.max(sumLength, maxPageLength);

        return (float) (pageLength * 1.0 / maxPageLength);
    }

    /**
     * This method sets page breaks on the given sheet.
     */
    private void setPageBreaks(SXSSFSheet sh, int[] lengths, HashSet<Integer> breaks, HashSet<Integer> breakables, int paperLength, boolean isRowBreak) {
        int sumLengths = 0;
        int lastBreakable = 0;
        int lastBreakSumLengths = 0;

        for (int i = 0; i < lengths.length; i++) {
            if ((sumLengths + lengths[i] == paperLength) && breakables.contains(i) || breaks.contains(i)) {
                if (isRowBreak) sh.setRowBreak(i);
                else sh.setColumnBreak(i);
                sumLengths = 0;
                lastBreakable = i;
                lastBreakSumLengths = 0;
            } else if (sumLengths + lengths[i] > paperLength) {
                if (isRowBreak) sh.setRowBreak(lastBreakable);
                else sh.setColumnBreak(lastBreakable);
                sumLengths -= (lastBreakSumLengths - lengths[i]);
                lastBreakSumLengths = sumLengths;

                if (breakables.contains(i)) lastBreakable = i;
            } else {
                sumLengths += lengths[i];

                if (breakables.contains(i)) {
                    lastBreakable = i;
                    lastBreakSumLengths = sumLengths;
                }
            }
        }
    }

    private void setSheetOptions(BrSheet o, SXSSFSheet sh) {
        XSSFPrintSetup ps = (XSSFPrintSetup) sh.getPrintSetup();
        ps.setPaperSize(PaperSize.A4_PAPER);

        if (o == null) {
            return;
        }

        if (o.zoom > 0 && o.zoom < 100) {
            sh.setZoom(o.zoom);
        }

        if (o.noGridlines) {
            sh.setPrintGridlines(false);
        }

        if (o.landscape) {
            ps.setLandscape(true);
            ps.setOrientation(PrintOrientation.LANDSCAPE);
        } else {
            ps.setLandscape(false);
            ps.setOrientation(PrintOrientation.PORTRAIT);
        }

        if (o.hidden) {
            wb.setSheetHidden(wb.getSheetIndex(sh), true);
        }

        if (o.fitToPage) {
            ps.setFitHeight((short) 0);
            ps.setFitWidth((short) 1);
            sh.setFitToPage(true);
        }

        if (o.splitVertical > 0 && o.splitHorizontal > 0) {
            sh.createFreezePane(o.splitHorizontal, o.splitVertical);
        } else if (o.splitVertical > 0) {
            sh.createFreezePane(0, o.splitVertical);
        } else if (o.splitHorizontal > 0) {
            sh.createFreezePane(o.splitHorizontal, 0);
        }

        final double inch = 2.54;
        if (o.pageTop >= 0) {
            sh.setMargin(XSSFSheet.TopMargin, o.pageTop / inch);
        }
        if (o.pageHeader >= 0) {
            sh.setMargin(XSSFSheet.HeaderMargin, o.pageHeader / inch);
        }
        if (o.pageBottom >= 0) {
            sh.setMargin(XSSFSheet.BottomMargin, o.pageBottom / inch);
        }
        if (o.pageFooter >= 0) {
            sh.setMargin(XSSFSheet.FooterMargin, o.pageFooter / inch);
        }
        if (o.pageLeft >= 0) {
            sh.setMargin(XSSFSheet.LeftMargin, o.pageLeft / inch);
        }
        if (o.pageRight >= 0) {
            sh.setMargin(XSSFSheet.RightMargin, o.pageRight / inch);
        }
    }

    private XSSFColor createColor(String color) {
        try {
            return new XSSFColor(Color.decode(color), new DefaultIndexedColorMap());
        } catch (Exception ex) {
            return null;
        }
    }

    private XSSFFont createFont(BrFont fi) {
        XSSFFont f = (XSSFFont) wb.createFont();

        if (notEmpty(fi.color)) {
            f.setColor(createColor(fi.color));
        }

        if (notEmpty(fi.family)) {
            f.setFontName(fi.family);
        }

        if (fi.size > 0) {
            f.setFontHeight(fi.size);
        }

        if (fi.bold) {
            f.setBold(true);
        }

        if (fi.italic) {
            f.setItalic(true);
        }

        if (fi.underline) {
            f.setUnderline(XSSFFont.U_SINGLE);
        }

        return f;
    }

    private XSSFCellStyle createStyle(BrStyle si) {
        XSSFCellStyle s = (XSSFCellStyle) wb.createCellStyle();

        if (si.fontIndex >= 0) {
            s.setFont(fonts.get(si.fontIndex));
        }

        if (notEmpty(si.bgColor)) {
            s.setFillForegroundColor(createColor(si.bgColor));
            s.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        }

        if (si.rotate != 0) {
            s.setRotation((short) (-si.rotate));
        }

        if (si.wrap) {
            s.setWrapText(true);
        }

        switch (si.align) {
            case 1:
                s.setAlignment(HorizontalAlignment.LEFT);
                break;
            case 2:
                s.setAlignment(HorizontalAlignment.CENTER);
                break;
            case 3:
                s.setAlignment(HorizontalAlignment.RIGHT);
                break;
        }

        switch (si.valign) {
            case 1:
                s.setVerticalAlignment(VerticalAlignment.TOP);
                break;
            case 2:
                s.setVerticalAlignment(VerticalAlignment.CENTER);
                break;
            case 3:
                s.setVerticalAlignment(VerticalAlignment.BOTTOM);
                break;
        }

        if (si.indent != 0) {
            s.setIndention(si.indent);
        }

        if (notEmpty(si.format)) {
            s.setDataFormat(wb.createDataFormat().getFormat(si.format));
        }

        if (si.shrinkToFit) {
            s.setShrinkToFit(true);
        }

        if (si.borderTop != null) {
            s.setBorderTop(getBorderStyle(si.borderTop));
            if (notEmpty(si.borderTopColor)) {
                s.setTopBorderColor(createColor(si.borderTopColor));
            }
        }

        if (si.borderBottom != null) {
            s.setBorderBottom(getBorderStyle(si.borderBottom));
            if (notEmpty(si.borderBottomColor)) {
                s.setBottomBorderColor(createColor(si.borderBottomColor));
            }
        }

        if (si.borderLeft != null) {
            s.setBorderLeft(getBorderStyle(si.borderLeft));
            if (notEmpty(si.borderLeftColor)) {
                s.setLeftBorderColor(createColor(si.borderLeftColor));
            }
        }

        if (si.borderRight != null) {
            s.setBorderRight(getBorderStyle(si.borderRight));
            if (notEmpty(si.borderRightColor)) {
                s.setRightBorderColor(createColor(si.borderRightColor));
            }
        }

        return s;
    }

    private BorderStyle getBorderStyle(String borderStyle) {
        switch (borderStyle) {
            case "hair":
                return BorderStyle.HAIR;
            case "thin":
                return BorderStyle.THIN;
            case "thick":
                return BorderStyle.THICK;
            case "double":
                return BorderStyle.DOUBLE;
            case "dotted":
                return BorderStyle.DOTTED;
            case "dashed":
                return BorderStyle.DASHED;
            case "dash_dot":
                return BorderStyle.DASH_DOT;
            case "dash_dot_dot":
                return BorderStyle.DASH_DOT_DOT;
            case "medium":
                return BorderStyle.MEDIUM;
            case "medium_dashed":
                return BorderStyle.MEDIUM_DASHED;
            case "medium_dash_dot":
                return BorderStyle.MEDIUM_DASH_DOT;
            /*case "medium_dash_dot_dot": DEPRECATED
                return BorderStyle.MEDIUM_DASH_DOT_DOTC;*/
            case "slanted_dash_dot":
                return BorderStyle.SLANTED_DASH_DOT;
            default:
                return BorderStyle.NONE;
        }
    }

    private boolean notEmpty(String s) {
        return s != null && s.length() > 0;
    }

    private static class CustomTextPane extends JTextPane {

        public CustomTextPane() {
            setEditorKit(new WrapEditorKit());
        }

        private static class WrapEditorKit extends StyledEditorKit {
            private final ViewFactory defaultFactory = new WrapColumnFactory();

            @Override
            public ViewFactory getViewFactory() {
                return defaultFactory;
            }
        }

        private static class WrapColumnFactory implements ViewFactory {
            @Override
            public View create(final Element element) {
                final String kind = element.getName();

                if (kind != null) {
                    switch (kind) {
                        case AbstractDocument.ContentElementName:
                            return new WrapLabelView(element);
                        case AbstractDocument.ParagraphElementName:
                            return new ParagraphView(element);
                        case AbstractDocument.SectionElementName:
                            return new BoxView(element, View.Y_AXIS);
                        case StyleConstants.ComponentElementName:
                            return new ComponentView(element);
                        case StyleConstants.IconElementName:
                            return new IconView(element);
                    }
                }

                return new LabelView(element);
            }
        }

        private static class WrapLabelView extends LabelView {
            public WrapLabelView(final Element element) {
                super(element);
            }

            @Override
            public float getMinimumSpan(final int axis) {
                switch (axis) {
                    case View.X_AXIS:
                        return 0;
                    case View.Y_AXIS:
                        return super.getMinimumSpan(axis);
                    default:
                        throw new IllegalArgumentException("Invalid axis: " + axis);
                }
            }
        }
    }
}