package uz.greenwhite.biruni.report;

import net.coobird.thumbnailator.Thumbnails;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.ss.util.CellRangeAddressList;
import org.apache.poi.util.Units;
import org.apache.poi.xssf.usermodel.*;
import uz.greenwhite.biruni.filemanager.FileManager;

import java.awt.Color;
import java.io.*;
import java.util.ArrayList;
import java.util.List;

@SuppressWarnings("deprecation")
public class ImpExcel {
    private final BrBook book;
    private final XSSFWorkbook wb;
    private final List<XSSFFont> fonts;
    private final List<XSSFCellStyle> styles;
    private final int DDMMYYYYhhmm;

    public ImpExcel(BrBook book) {
        this.book = book;
        this.wb = new XSSFWorkbook();
        this.fonts = new ArrayList<>(book.fonts.size());
        this.styles = new ArrayList<>(book.styles.size());
        CreationHelper ch = this.wb.getCreationHelper();
        this.DDMMYYYYhhmm = ch.createDataFormat().getFormat("dd.MM.yyyy HH:mm:ss");
    }

    public void write(OutputStream os) {
        print();
        try {
            wb.write(os);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }


    public void print() {
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
        XSSFSheet sh = createSheet(sheet.name);

        setSheetOptions(sheet, sh);

        setColumns(rs.columnWidths, rs.columnDataSources, sh);

        printCells(rs, sh);

        setGroupings(rs.groupings, sh);

        sh.setAutobreaks(false);
    }

    private Result evalResult(BrSheet sheet) {
        BrTable table = book.tables.get(sheet.tableId);
        return table.unroll();
    }


    private void setColumns(int[] columnWidths, String[] columnDataSources, XSSFSheet sh) {
        for (int i = 0; i < columnWidths.length; i++) {
            int c = columnWidths[i];
            if (c > 0) {
                sh.setColumnWidth(i, PixelUtil.pixel2WidthUnits(c));
            }
        }

        XSSFDataValidationHelper dvHelper = new XSSFDataValidationHelper(sh);
        XSSFDataValidationConstraint dvConstraint;
        XSSFDataValidation validation;
        String[] sources;
        String source;
        String columnName;

        for (int i = 0; i < columnDataSources.length; i++) {
            if (!"".equals(columnDataSources[i])) {
                sources = columnDataSources[i].split(":");
                CellRangeAddressList address = new CellRangeAddressList(Integer.parseInt(sources[0]), Integer.parseInt(sources[1]), i, i);

                columnName = String.valueOf((char) ('A' + Integer.parseInt(sources[3]) - 1));
                source = String.format("=%s!$%s$1:$%s$%s", sources[2], columnName, columnName, sources[4]);

                dvConstraint = (XSSFDataValidationConstraint) dvHelper.createFormulaListConstraint(source);
                validation = (XSSFDataValidation) dvHelper.createValidation(dvConstraint, address);
                sh.addValidationData(validation);
            }
        }
    }

    private void setGroupings(List<Grouping> groupings, XSSFSheet sh) {
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

    private void printCells(Result rs, XSSFSheet sh) {
        Object[][] m = rs.matrix;

        for (int i = 0; i < m.length; i++) {
            XSSFRow r = sh.createRow(i);

            if (i < rs.rowHeights.length && rs.rowHeights[i] > 0) {
                r.setHeightInPoints((float) (rs.rowHeights[i] * 0.75));
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
                XSSFCell c = r.createCell(j);
                XSSFCellStyle style = null;

                if (0 <= cell.meta.styleIndex && cell.meta.styleIndex <= styles.size()) {
                    style = styles.get(cell.meta.styleIndex);
                    c.setCellStyle(style);
                }

                if (cell.value != null && cell.value.length() > 0) {
                    switch (cell.meta.type) {
                        case 'N':
                            try {
                                c.setCellValue(Double.parseDouble(cell.value));
                            } catch (NumberFormatException e) {
                                c.setCellValue(cell.value);
                            }
                            break;
                        case 'D':
                            assert style != null;
                            style.setDataFormat(DDMMYYYYhhmm);
                            c.setCellStyle(style);
                            c.setCellValue(cell.value);
                            break;
                        case 'I':
                            byte[] bytes = FileManager.loadFile(cell.value);

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

                                    int pictureIndex = wb.addPicture(bytes, Workbook.PICTURE_TYPE_JPEG);

                                    CreationHelper helper = wb.getCreationHelper();
                                    ClientAnchor anchor = helper.createClientAnchor();
                                    anchor.setCol1(j);
                                    anchor.setRow1(i);
                                    anchor.setAnchorType(ClientAnchor.AnchorType.MOVE_DONT_RESIZE);

                                    Drawing drawing = sh.createDrawingPatriarch();
                                    Picture pict = drawing.createPicture(anchor, pictureIndex);
                                    pict.resize();

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
                                            //resize the pictutre to original size again
                                            //this will determine the new bottom right anchor position
                                            pict.resize();
                                        }

                                    }
                                } catch (IOException e) {
                                    throw new RuntimeException("put image to excel", e);
                                }
                            }
                            c.setCellValue("");
                            break;
                        default:
                            c.setCellValue(cell.value);
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
        }
    }

    private XSSFSheet createSheet(String name) {
        if (name != null && name.length() > 0) {
            return wb.createSheet(name);
        } else {
            return wb.createSheet();
        }
    }

    private void setSheetOptions(BrSheet o, XSSFSheet sh) {
        XSSFPrintSetup ps = sh.getPrintSetup();
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
            return new XSSFColor(Color.decode(color),new DefaultIndexedColorMap());
        } catch (Exception ex) {
            return null;
        }
    }

    private XSSFFont createFont(BrFont fi) {
        XSSFFont f = wb.createFont();

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
        XSSFCellStyle s = wb.createCellStyle();

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
}