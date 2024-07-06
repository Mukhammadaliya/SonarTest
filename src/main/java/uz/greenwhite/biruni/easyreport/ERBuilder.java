package uz.greenwhite.biruni.easyreport;

import com.google.gson.Gson;
import com.google.gson.JsonIOException;
import com.google.gson.JsonSyntaxException;
import jakarta.servlet.http.HttpServletRequest;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.util.Units;
import org.apache.poi.xssf.streaming.*;
import org.apache.poi.xssf.usermodel.*;
import uz.greenwhite.biruni.filemanager.FileManager;
import uz.greenwhite.biruni.onlyoffice.OnlyofficeException;
import uz.greenwhite.biruni.onlyoffice.OnlyofficeProvider;
import uz.greenwhite.biruni.service.BarcodeService;

import jakarta.servlet.http.HttpServletResponse;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.*;

import java.util.concurrent.atomic.AtomicInteger;

public class ERBuilder {
    private SXSSFSheet sheet;

    private final Map<Integer, XSSFCellStyle> styles = new HashMap<>();

    private void putPhoto(ERPhoto erPhoto, int rowNum, int colNum) {
        int pictureIdx = sheet.getWorkbook().addPicture(FileManager.loadFile(erPhoto.getSha()), SXSSFWorkbook.PICTURE_TYPE_JPEG);

        CreationHelper helper = sheet.getWorkbook().getCreationHelper();
        SXSSFDrawing drawing = sheet.createDrawingPatriarch();
        ClientAnchor anchor = helper.createClientAnchor();
        anchor.setAnchorType(ClientAnchor.AnchorType.DONT_MOVE_AND_RESIZE);

        anchor.setRow1(rowNum);
        anchor.setRow2(rowNum + erPhoto.getRow2() - erPhoto.getRow1());
        anchor.setCol1(colNum);
        anchor.setCol2(colNum + erPhoto.getCol2() - erPhoto.getCol1());
        anchor.setDx1(erPhoto.getDx1());
        anchor.setDx2(erPhoto.getDx2());
        anchor.setDy1(erPhoto.getDy1());
        anchor.setDy2(erPhoto.getDy2());

        drawing.createPicture(anchor, pictureIdx);
    }

    private void putPhoto(byte[] bytes, int colNum, int colSpan, int rowNum, short align) {
        int pictureIndex = sheet.getWorkbook().addPicture(bytes, SXSSFWorkbook.PICTURE_TYPE_JPEG);

        CreationHelper helper = sheet.getWorkbook().getCreationHelper();
        ClientAnchor anchor = helper.createClientAnchor();
        anchor.setAnchorType(ClientAnchor.AnchorType.MOVE_DONT_RESIZE);
        anchor.setRow1(rowNum);

        SXSSFDrawing drawing = sheet.createDrawingPatriarch();
        Picture pict = drawing.createPicture(anchor, pictureIndex);

        //horizontal position of the picture
        //2 - central, 3 - right position of the picture
        if (align == 2 || align == 3) {
            //get the picture width
            int pictWidthPx = pict.getImageDimension().width;
            //get the cell width
            float cellWidthPx = 0f;
            for (int col = colNum; col < colNum + colSpan; col++) {
                cellWidthPx += sheet.getColumnWidthInPixels(col);
            }
            //determine the new first anchor column dependent of the center position
            //and the remaining pixels as Dx
            int anchorCol1 = colNum, centerPosPx, columnWidth;
            if (align == 2) {
                centerPosPx = Math.round(cellWidthPx / 2f - (float) pictWidthPx / 2f);
                for (int col = colNum; col < colNum + colSpan; col++) {
                    columnWidth = Math.round(sheet.getColumnWidthInPixels(col));
                    if (columnWidth < centerPosPx) {
                        centerPosPx -= columnWidth;
                        anchorCol1 = col + 1;
                    } else {
                        break;
                    }
                }
            } else {
                centerPosPx = 0;
                for (int col = colNum; col < colNum + colSpan; col++) {
                    columnWidth = Math.round(sheet.getColumnWidthInPixels(col));
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
            anchor.setCol1(colNum);
        }

        //resize the picture to original size
        pict.resize(1.0);
    }

    private XSSFFont createFont(ERCell erCell) {
        XSSFFont font = (XSSFFont) sheet.getWorkbook().createFont();

        if (erCell.getFontName() != null && !erCell.getFontName().isEmpty()) {
            font.setFontName(erCell.getFontName());
        }

        if (erCell.getFontHeight() > 0) {
            font.setFontHeight(erCell.getFontHeight());
        }

        if (erCell.getFontColor() != null) {
            XSSFColor fontColor = new XSSFColor(erCell.getFontColor(), new DefaultIndexedColorMap());
            font.setColor(fontColor);
        }

        font.setBold(erCell.isFontBold());
        font.setItalic(erCell.isFontItalic());
        font.setUnderline(erCell.getFontUnderline());

        return font;
    }

    private XSSFCellStyle createStyle(ERCell erCell) {
        SXSSFWorkbook workbook = sheet.getWorkbook();
        XSSFCellStyle style = (XSSFCellStyle) workbook.createCellStyle();

        if (erCell.getFormat() != null) {
            style.setDataFormat(workbook.createDataFormat().getFormat(erCell.getFormat()));
        }

        if (erCell.getColor() != null) {
            XSSFColor color = new XSSFColor(erCell.getColor(), new DefaultIndexedColorMap());
            style.setFillForegroundColor(color);
            style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        }

        if (erCell.getHorizontalAlignment() > 0) {
            style.setAlignment(HorizontalAlignment.forInt(erCell.getHorizontalAlignment()));
        }

        if (erCell.getVerticalAlignment() > 0) {
            style.setVerticalAlignment(VerticalAlignment.forInt(erCell.getVerticalAlignment()));
        }

        style.setBorderTop(BorderStyle.valueOf(erCell.getBorderTop()));
        style.setBorderLeft(BorderStyle.valueOf(erCell.getBorderLeft()));
        style.setBorderRight(BorderStyle.valueOf(erCell.getBorderRight()));
        style.setBorderBottom(BorderStyle.valueOf(erCell.getBorderBottom()));

        style.setRotation(erCell.getRotation());
        style.setWrapText(erCell.isWrapText());

        return style;
    }

    private void printCellStyle(ERCell erCell, SXSSFCell cell) {
        XSSFCellStyle style;

        if (styles.containsKey(erCell.hashCode())) {
            style = styles.get(erCell.hashCode());
        } else {
            style = createStyle(erCell);
            style.setFont(createFont(erCell));
            styles.put(erCell.hashCode(), style);
        }

        cell.setCellStyle(style);
    }

    private void setCellValue(ERCell erCell, SXSSFCell cell, String value) {
        try {
            if (erCell.isDateFormat()) {
                cell.setCellValue(new SimpleDateFormat("dd.MM.yyyy HH:mm:ss").parse(value));
            } else if (erCell.isNumberFormat()) {
                cell.setCellValue(Double.parseDouble(value));
            } else {
                cell.setCellValue(value);
            }
        } catch (Exception e) {
            cell.setCellValue(value);
        }
    }

    private int printRow(Map<String, Object> data,
                         List<ERHorizontalLoop> horizontalLoops,
                         List<String> mergedRegions,
                         List<ERPhoto> photos,
                         List<ERCell> erCells,
                         SXSSFRow row,
                         int realRowNum,
                         int currentStartColNum,
                         int lastTemplateColNum) {
        int rowNum = row.getRowNum();
        int loopIterator = 0;
        int currentEndColNum = currentStartColNum;

        for (int i = 0; i < erCells.size(); i++) {
            ERCell erCell = erCells.get(i);
            int colNum = erCell.getColnum();

            if (horizontalLoops.size() > loopIterator && colNum == horizontalLoops.get(loopIterator).getStartColnum()) {
                String loopKey = horizontalLoops.get(loopIterator).getKey();
                int fromCol = horizontalLoops.get(loopIterator).getStartColnum();
                int toCol = horizontalLoops.get(loopIterator).getEndColnum();
                int subLoopsStart = ++loopIterator;
                int subColsStart = i;

                List<Map<String, Object>> loopData = data.containsKey(loopKey) ? (ArrayList<Map<String, Object>>) data.get(loopKey) : new ArrayList<>();

                while (loopIterator < horizontalLoops.size() &&
                        toCol >= horizontalLoops.get(loopIterator).getStartColnum()) {
                    loopIterator++;
                }

                while (erCells.get(i).getColnum() < toCol && i < erCells.size()) i++;

                for (int j = 0; j < loopData.size(); j++) {
                    currentEndColNum = printRow(loopData.get(j),
                            horizontalLoops.subList(subLoopsStart, loopIterator),
                            mergedRegions,
                            photos,
                            erCells.subList(subColsStart, i + 1),
                            row,
                            realRowNum,
                            currentStartColNum,
                            lastTemplateColNum);

                    if (j + 1 == loopData.size()) {
                        currentStartColNum = currentEndColNum;
                    } else {
                        currentStartColNum = currentEndColNum - (colNum - lastTemplateColNum - 1);
                    }
                }

                if (loopData.isEmpty()) currentEndColNum = currentStartColNum + toCol - fromCol + 1;

                lastTemplateColNum = toCol;
            } else {
                currentStartColNum = currentEndColNum + colNum - lastTemplateColNum;
                currentEndColNum = currentStartColNum;
                lastTemplateColNum = colNum;

                CellType cellType = erCell.getCellType();
                SXSSFCell cell = row.createCell(currentStartColNum, cellType);
                sheet.setColumnWidth(currentEndColNum, sheet.getColumnWidth(colNum));

                if (erCell.hasPageBreak()) sheet.setColumnBreak(currentStartColNum);

                switch (cellType) {
                    case STRING:
                        String stringValue = erCell.getStringValue();
                        boolean cellValueIsString = true;

                        while (stringValue.contains("[") || stringValue.contains("]")) {
                            String key, value;

                            try {
                                key = ERUtil.getElementKey(stringValue);
                            } catch (IndexOutOfBoundsException ex) {
                                throw new EasyReportException("Biruni ER: element is not correctly defined in row " + (rowNum + 1) + " and column " + (colNum + 1));
                            }

                            Object d = data.getOrDefault(key, "");

                            if (d instanceof Map) {
                                Map<String, String> p = (Map<String, String>) d;
                                String type = p.getOrDefault("type", "");
                                value = p.getOrDefault("value", "");
                                int width = Integer.parseInt(p.getOrDefault("width", "200"));
                                int height = Integer.parseInt(p.getOrDefault("height", "200"));
                                cellValueIsString = false;

                                byte[] photo = switch (type) {
                                    case "photo" -> FileManager.loadFile(value);
                                    case "barcode" -> BarcodeService.generateByteArrayBarcode(value, height, width);
                                    case "qrcode" -> BarcodeService.generateByteArrayQRcode(value, height, width);
                                    default -> new byte[0];
                                };

                                if (photo.length != 0) {
                                    AtomicInteger colSpan = new AtomicInteger(1);

                                    mergedRegions.stream()
                                            .filter(m -> CellRangeAddress.valueOf(m).getFirstColumn() == colNum)
                                            .findFirst()
                                            .ifPresent(mr -> {
                                                CellRangeAddress cellAddresses = CellRangeAddress.valueOf(mr);
                                                colSpan.set(cellAddresses.getLastColumn() - cellAddresses.getFirstColumn() + 1);
                                            });
                                    putPhoto(photo, currentStartColNum, colSpan.get(), rowNum, erCell.getHorizontalAlignment());
                                }
                            }

                            stringValue = ERUtil.replaceElement(stringValue, key, d);
                        }

                        if (cellValueIsString) {
                            setCellValue(erCell, cell, ERUtil.unmaskEscapedSymbols(stringValue));
                        }
                        break;
                    case NUMERIC:
                        cell.setCellValue(erCell.getNumericValue());
                        break;
                }

                printCellStyle(erCell, cell);

                int realColNum = currentStartColNum;

                mergedRegions.stream().filter(m -> CellRangeAddress.valueOf(m).getFirstColumn() == colNum).forEach(m -> {
                    CellRangeAddress cellAddresses = CellRangeAddress.valueOf(m);

                    cellAddresses.setLastRow(realRowNum + cellAddresses.getLastRow() - cellAddresses.getFirstRow());
                    cellAddresses.setFirstRow(realRowNum);
                    cellAddresses.setLastColumn(realColNum + cellAddresses.getLastColumn() - cellAddresses.getFirstColumn());
                    cellAddresses.setFirstColumn(realColNum);

                    try {
                        sheet.addMergedRegion(cellAddresses);
                    } catch (Exception ex) {
                        System.out.println("Biruni ER: error found when adding merged region with cell address " + m + ". Error message " + ex.getMessage());
                    }
                });

                photos.stream().filter(erPhoto -> erPhoto.getCol1() == colNum).forEach(erPhoto -> putPhoto(erPhoto, realRowNum, realColNum));
            }
        }

        return currentEndColNum;
    }

    private int generate(Map<String, Object> data,
                         List<ERVerticalLoop> verticalLoops,
                         List<ERHorizontalLoop> horizontalLoops,
                         List<String> mergedRegions,
                         List<ERPhoto> photos,
                         List<ERRow> erRows,
                         int realRowNumStart,
                         int lastTemplateRowNum) {
        int realRowNumEnd = realRowNumStart;

        for (int i = 0; i < erRows.size(); i++) {
            ERRow erRow = erRows.get(i);
            int loopIterator = 0;
            int rowNum = erRow.getRownum();

            if (verticalLoops.size() > loopIterator && rowNum == verticalLoops.get(loopIterator).getStartRownum()) {
                String loopKey = verticalLoops.get(loopIterator).getKey();
                int fromRow = verticalLoops.get(loopIterator).getStartRownum();
                int toRow = verticalLoops.get(loopIterator).getEndRownum();
                int subLoopsStart = ++loopIterator;
                int subRowsStart = i;

                List<Map<String, Object>> loopData = data.containsKey(loopKey) ? (ArrayList<Map<String, Object>>) data.get(loopKey) : new ArrayList<>();

                while (loopIterator < verticalLoops.size() &&
                        toRow >= verticalLoops.get(loopIterator).getStartRownum()) {
                    loopIterator++;
                }

                while (erRows.get(i).getRownum() < toRow && i < erRows.size()) i++;

                for (int j = 0; j < loopData.size(); j++) {
                    realRowNumEnd = generate(loopData.get(j),
                            verticalLoops.subList(subLoopsStart, loopIterator),
                            horizontalLoops,
                            mergedRegions,
                            photos,
                            erRows.subList(subRowsStart, i + 1),
                            realRowNumStart,
                            lastTemplateRowNum);

                    if (j + 1 == loopData.size()) {
                        realRowNumStart = realRowNumEnd;
                    } else {
                        realRowNumStart = realRowNumEnd - (rowNum - lastTemplateRowNum - 1);
                    }
                }

                if (loopData.isEmpty()) realRowNumEnd = realRowNumStart + toRow - fromRow + 1;

                lastTemplateRowNum = toRow;
            } else {
                realRowNumStart = realRowNumEnd + rowNum - lastTemplateRowNum;
                realRowNumEnd = realRowNumStart;
                lastTemplateRowNum = rowNum;

                SXSSFRow row = sheet.createRow(realRowNumStart);
                row.setHeight(erRow.getRowHeight());

                if (erRow.hasPageBreak()) sheet.setRowBreak(realRowNumStart);

                List<ERHorizontalLoop> subHorizontalLoops = horizontalLoops.stream()
                        .filter(horizontalLoop -> horizontalLoop.getStartRownum() <= rowNum && horizontalLoop.getEndRownum() >= rowNum)
                        .toList();

                List<String> subMergedRegions = mergedRegions.stream()
                        .filter(s -> CellRangeAddress.valueOf(s).getFirstRow() == rowNum)
                        .toList();

                List<ERPhoto> subPhotos = photos.stream()
                        .filter(erPhoto -> erPhoto.getRow1() == rowNum)
                        .toList();

                printRow(data,
                        subHorizontalLoops,
                        subMergedRegions,
                        subPhotos,
                        erRow.getCells(),
                        row,
                        realRowNumStart,
                        0,
                        0);
            }
        }

        return realRowNumEnd;
    }

    private void setSheetPrintSetup(ERPrintSetupData erSheetPrintSetupData, XSSFPrintSetup sheetPrintSetup) {
        if (Objects.nonNull(erSheetPrintSetupData)) {
            sheetPrintSetup.setFitWidth(erSheetPrintSetupData.getFitWidth());
            sheetPrintSetup.setFitHeight(erSheetPrintSetupData.getFitHeight());
            sheetPrintSetup.setPaperSize(erSheetPrintSetupData.getPaperSize());
            sheetPrintSetup.setScale(erSheetPrintSetupData.getScale());
            sheetPrintSetup.setHResolution(erSheetPrintSetupData.getHResolution());
            sheetPrintSetup.setPageStart(erSheetPrintSetupData.getPageStart());
            sheetPrintSetup.setLandscape(erSheetPrintSetupData.isLandscape());
            sheetPrintSetup.setUsePage(erSheetPrintSetupData.isUsePage());
            sheetPrintSetup.setValidSettings(erSheetPrintSetupData.isValidSettings());

            if (erSheetPrintSetupData.getTopMargin() > 0)
                sheetPrintSetup.setTopMargin(erSheetPrintSetupData.getTopMargin());

            if (erSheetPrintSetupData.getBottomMargin() > 0)
                sheetPrintSetup.setBottomMargin(erSheetPrintSetupData.getBottomMargin());

            if (erSheetPrintSetupData.getLeftMargin() > 0)
                sheetPrintSetup.setLeftMargin(erSheetPrintSetupData.getLeftMargin());

            if (erSheetPrintSetupData.getRightMargin() > 0)
                sheetPrintSetup.setRightMargin(erSheetPrintSetupData.getRightMargin());

            if (erSheetPrintSetupData.getHeaderMargin() > 0)
                sheetPrintSetup.setHeaderMargin(erSheetPrintSetupData.getHeaderMargin());

            if (erSheetPrintSetupData.getFooterMargin() > 0)
                sheetPrintSetup.setFooterMargin(erSheetPrintSetupData.getFooterMargin());
        }
    }

    public void build(String source, HttpServletRequest request, HttpServletResponse response) {
        Gson gson = new Gson();
        ERSourceData sourceData;
        ERMetadata metadata;

        try {
            sourceData = gson.fromJson(source, ERSourceData.class);
        } catch (JsonSyntaxException ex) {
            throw new EasyReportException("Biruni ER: failed to parse source data");
        }

        if (!ERUtil.VERSION.equals(sourceData.getVersion()))
            throw new EasyReportException("Biruni ER: easy report version is not match");

        try {
            metadata = gson.fromJson(ERJdbc.getMetadata(sourceData.getFileSha()), ERMetadata.class);
        } catch (JsonIOException | JsonSyntaxException ex) {
            throw new EasyReportException("Biruni ER: failed to parse metadata");
        }

        SXSSFWorkbook workbook = new SXSSFWorkbook(ERUtil.WORKBOOK_ROW_ACCESS);
        ByteArrayOutputStream baos = new ByteArrayOutputStream();

        try {
            for (ERSheet erSheet : metadata) {
                sheet = workbook.createSheet(erSheet.getSheetName());
                sheet.setDefaultColumnWidth(erSheet.getDefaultColWidth());
                setSheetPrintSetup(erSheet.getPrintSetupData(), (XSSFPrintSetup) sheet.getPrintSetup());

                Map<Integer, Integer> colWidths = erSheet.getColWidths();
                colWidths.forEach((k, v) -> sheet.setColumnWidth(k, v));

                generate(sourceData.getData(),
                        erSheet.getVerticalLoops(),
                        erSheet.getHorizontalLoops(),
                        erSheet.getMergedRegions(),
                        erSheet.getPhotos(),
                        erSheet.getRows(),
                        0,
                        0);
            }

            workbook.write(baos);
        } catch (EasyReportException e) {
            throw e;
        } catch (Exception e) {
            throw new EasyReportException("Biruni ER: failed to generate workbook");
        } finally {
            closeWorkbook(workbook);
        }

        String sha = null;

        try {
            String contentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
            response.setCharacterEncoding("UTF-8");

            if (sourceData.getViewProperties() == null || !OnlyofficeProvider.isLive()) {
                response.setHeader("Content-Disposition", "attachment;filename*=UTF-8''" + URLEncoder.encode(sourceData.getFileName(), StandardCharsets.UTF_8));
                response.setContentLength(baos.size());
                response.setContentType(contentType + ";charset=UTF-8");
                baos.writeTo(response.getOutputStream());
            } else {
                try {
                    sha = FileManager.uploadEasyReportEntityAndSaveProperties(baos.toByteArray(), sourceData.getFileName(), contentType);
                } catch (Exception e) {
                    throw new EasyReportException("Biruni ER: failed to save generated workbook", e);
                }
                String documentLink = OnlyofficeProvider.getDocsLoadUrl(sha);
                String html = OnlyofficeProvider.prepareOnlyofficeHtml(request.getServletContext(),
                        sha,
                        documentLink,
                        sourceData.getFileName(),
                        sourceData.getViewProperties());

                response.setContentType("text/html;charset=UTF-8");
                response.getWriter().write(html);
            }

        } catch (OnlyofficeException | IOException e) {
            try {
                if (sha != null) FileManager.deleteEasyReport(sha);
            } catch (Exception ignored) {
            }

            if (e instanceof OnlyofficeException) {
                throw new EasyReportException("Biruni ER: " + e.getMessage());
            } else {
                throw new EasyReportException("Biruni ER: failed to write generated workbook to response");
            }
        }
    }

    private void closeWorkbook(SXSSFWorkbook workbook) {
        try {
            workbook.dispose();
            workbook.close();
        } catch (IOException ex) {
            System.out.println("Biruni ER: failed to close generated workbook");
        }
    }
}