package uz.greenwhite.biruni.easyreport;

import com.google.gson.Gson;
import org.apache.poi.ooxml.POIXMLException;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.xssf.usermodel.*;
import org.jetbrains.annotations.NotNull;
import uz.greenwhite.biruni.filemanager.FileManager;
import uz.greenwhite.biruni.util.FileUtil;

import java.io.InputStream;
import java.util.*;
import java.util.stream.Collectors;

public class ERMetadataReader {
    private static ERCell readCell(XSSFCell cell, boolean pageBreak) {
        ERCell erCell = new ERCell(cell.getColumnIndex(), cell.getCellType());

        switch (cell.getCellType()) {
            case STRING:
                erCell.setStringValue(cell.getStringCellValue());
                break;
            case NUMERIC:
                erCell.setNumericValue(cell.getNumericCellValue());
                break;
        }

        XSSFCellStyle style = cell.getCellStyle();
        XSSFFont font = style.getFont();

        erCell.setFormat(style);
        erCell.setWrapText(style.getWrapText());
        erCell.setPageBreak(pageBreak);

        erCell.setRotation(style.getRotation());
        erCell.setHorizontalAlignment(style.getAlignment().getCode());
        erCell.setVerticalAlignment(style.getVerticalAlignment().getCode());

        erCell.setBorderTop(style.getBorderTop().getCode());
        erCell.setBorderLeft(style.getBorderLeft().getCode());
        erCell.setBorderRight(style.getBorderRight().getCode());
        erCell.setBorderBottom(style.getBorderBottom().getCode());

        erCell.setFontName(font.getFontName());
        erCell.setFontHeight(font.getFontHeight());
        erCell.setFontBold(font.getBold());
        erCell.setFontItalic(font.getItalic());
        erCell.setFontUnderline(font.getUnderline());

        XSSFColor color = style.getFillForegroundColorColor();
        if (color != null) erCell.setColor(color.getRGBWithTint());

        XSSFColor fontColor = font.getXSSFColor();
        if (fontColor != null) erCell.setFontColor(fontColor.getRGBWithTint());

        return erCell;
    }

    private static void buildDefinitionItems(List<Map<String, Object>> definition, List<String> definitionItems, String cellValue, int rowNum, int colNum) {
        if (definitionItems.isEmpty()) {
            if (cellValue.isEmpty()) return;

            while (cellValue.contains("[") || cellValue.contains("]")) {
                Map<String, Object> definitionElement = new HashMap<>();
                String definitionKey;

                try {
                    definitionKey = ERUtil.getElementKey(cellValue);
                } catch (IndexOutOfBoundsException e) {
                    throw new RuntimeException("Biruni ER: element is not correctly defined in row " + (rowNum + 1) + " and column " + (colNum + 1));
                }

                cellValue = ERUtil.replaceElement(cellValue, definitionKey, "");

                if (definition.stream().noneMatch(stringObjectMap -> definitionKey.equals(stringObjectMap.get("key")))) {
                    definitionElement.put("key", definitionKey);
                    definition.add(definitionElement);
                }
            }
        } else {
            String definitionKey = definitionItems.getFirst();
            ArrayList<Map<String, Object>> items;

            Optional<Map<String, Object>> optionalItems = definition.stream()
                    .filter(stringObjectMap -> definitionKey.equals(stringObjectMap.get("key")))
                    .findFirst();

            if (optionalItems.isPresent()) {
                items = (ArrayList<Map<String, Object>>) optionalItems.get().get("items");
            } else {
                Map<String, Object> definitionElement = new HashMap<>();
                definitionElement.put("key", definitionKey);
                definitionElement.put("items", items = new ArrayList<>());
                definition.add(definitionElement);
            }

            if (cellValue.contains("{/")) {
                try {
                    cellValue = cellValue.substring(0, cellValue.indexOf("{/")) + cellValue.substring(cellValue.indexOf('}') + 1);
                } catch (IndexOutOfBoundsException e) {
                    throw new RuntimeException("Biruni ER: end cycle key is not correctly defined in row " + (rowNum + 1) + " and column " + (colNum + 1));
                }
            } else if (cellValue.contains("</")) {
                try {
                    cellValue = cellValue.substring(0, cellValue.indexOf("</")) + cellValue.substring(cellValue.indexOf('>') + 1);
                } catch (IndexOutOfBoundsException e) {
                    throw new RuntimeException("Biruni ER: end cycle key is not correctly defined in row " + (rowNum + 1) + " and column " + (colNum + 1));
                }
            }

            buildDefinitionItems(items, definitionItems.subList(1, definitionItems.size()), cellValue, rowNum, colNum);
        }
    }

    private static ERSheet readSheet(XSSFSheet sheet,
                                     List<Map<String, Object>> definitions,
                                     List<Map<String, Object>> photo_infos) {
        ERSheet erSheet = new ERSheet(sheet.getSheetName(), sheet.getDefaultColumnWidth());

        List<Map<String, Object>> definition = new ArrayList<>();
        List<String> definitionItems = new ArrayList<>();
        Set<Integer> rowPageBreaks = Arrays.stream(sheet.getRowBreaks()).boxed().collect(Collectors.toSet());
        Set<Integer> colPageBreaks = Arrays.stream(sheet.getColumnBreaks()).boxed().collect(Collectors.toSet());

        for (int rowNum = sheet.getFirstRowNum(); rowNum <= sheet.getLastRowNum(); rowNum++) {
            Row row = sheet.getRow(rowNum);

            if (Objects.isNull(row)) {
                if (rowPageBreaks.contains(rowNum)) {
                    erSheet.addRow(new ERRow(rowNum, sheet.getDefaultRowHeight(), true));
                }
            } else {
                ERRow erRow = new ERRow(rowNum, row.getHeight(), rowPageBreaks.contains(rowNum));

                if (row.getLastCellNum() > 100) {
                    throw new RuntimeException("Biruni ER: maximum column number can not be more than 100");
                }

                for (int colNum = 0; colNum <= row.getLastCellNum(); colNum++) {
                    Cell cell = row.getCell(colNum);

                    if (Objects.isNull(cell)) {
                        if (colPageBreaks.contains(colNum)) {
                            erRow.addCell(new ERCell(colNum, true));
                        }
                    } else {
                        if (CellType.STRING == cell.getCellType()) {
                            String cellValue = ERUtil.maskEscapedSymbols(cell.getStringCellValue());

                            while (cellValue.contains("<") && (cellValue.indexOf("<") < cellValue.indexOf("</") || !cellValue.contains("</"))) {
                                try {
                                    String[] keys = ERUtil.getStartLoopKey(cellValue);
                                    erSheet.addVerticalLoop(new ERVerticalLoop(keys[0], rowNum));
                                    definitionItems.add(keys[0]);
                                    cellValue = keys[1];
                                } catch (IndexOutOfBoundsException e) {
                                    throw new RuntimeException("Biruni ER: start cycle key is not correctly defined in row " + (rowNum + 1) + " and column " + (colNum + 1));
                                }
                            }

                            while (cellValue.contains("{") && (cellValue.indexOf("{") < cellValue.indexOf("{/") || !cellValue.contains("{/"))) {
                                try {
                                    String[] keys = ERUtil.getStartHorizontalLoopKey(cellValue);
                                    erSheet.addHorizontalLoop(new ERHorizontalLoop(keys[0], rowNum, colNum));
                                    definitionItems.add(keys[0]);
                                    cellValue = keys[1];
                                } catch (IndexOutOfBoundsException e) {
                                    throw new RuntimeException("Biruni ER: start cycle key is not correctly defined in row " + (rowNum + 1) + " and column " + (colNum + 1));
                                }
                            }

                            try {
                                buildDefinitionItems(definition, definitionItems, cellValue.contains("[") || cellValue.contains("]") ? cellValue : "", rowNum, colNum);
                            } catch (Exception e) {
                                throw new RuntimeException("Biruni ER: error found when build definitions. Error message " + e.getMessage());
                            }

                            while (cellValue.contains("{/")) {
                                try {
                                    String[] keys = ERUtil.getEndHorizontalLoopKey(cellValue);
                                    erSheet.setHorizontalLoopEndRowNum(keys[0], rowNum, colNum);
                                    cellValue = keys[1];

                                    if (!keys[0].equals(definitionItems.removeLast())) {
                                        throw new RuntimeException("Biruni ER: cycles intersection is not allowed: Intersection found in loop key " + keys[0] + " in row " + (rowNum + 1) + " and column " + (colNum + 1));
                                    }
                                } catch (IndexOutOfBoundsException e) {
                                    throw new RuntimeException("end loop");
                                }
                            }

                            while (cellValue.contains("</")) {
                                try {
                                    String[] keys = ERUtil.getEndLoopKey(cellValue);
                                    erSheet.setVerticalLoopEndRowNum(keys[0], rowNum, colNum);
                                    cellValue = keys[1];

                                    if (!keys[0].equals(definitionItems.removeLast())) {
                                        throw new RuntimeException("Biruni ER: cycles intersection is not allowed: Intersection found in loop key " + keys[0] + " in row " + (rowNum + 1) + " and column " + (colNum + 1));
                                    }
                                } catch (IndexOutOfBoundsException e) {
                                    throw new RuntimeException("Biruni ER: end cycle key is not correctly defined in row " + (rowNum + 1) + " and column " + (colNum + 1));
                                }
                            }

                            if (cellValue.contains("<") || cellValue.contains(">") || cellValue.contains("{") || cellValue.contains("}")) {
                                throw new RuntimeException("Biruni ER: cycle symbols were used incorrectly in row " + (rowNum + 1) + " and column " + (colNum + 1));
                            }

                            cell.setCellValue(cellValue);
                        }

                        try {
                            erRow.addCell(readCell((XSSFCell) cell, colPageBreaks.contains(colNum)));
                        } catch (Exception e) {
                            throw new RuntimeException("Biruni ER: error found while reading cell in row " + (rowNum + 1) + "and column " + (colNum + 1));
                        }
                    }

                    erSheet.setColWidth(colNum, sheet.getColumnWidth(colNum));
                    erSheet.setPrintSetupData(new ERPrintSetupData(sheet.getPrintSetup()));
                }

                erSheet.addRow(erRow);
            }
        }

        XSSFDrawing drawing = sheet.getDrawingPatriarch();

        if (drawing != null) {
            try {
                for (XSSFShape shape : drawing) {
                    XSSFPicture picture = (XSSFPicture) shape;
                    XSSFPictureData pictureData = picture.getPictureData();
                    byte[] pictureBytes = pictureData.getData();
                    String sha = FileUtil.calcSHA(pictureBytes);
                    ERPhoto photo = getPhoto(picture, sha);

                    erSheet.addPhoto(photo);
                    erSheet.addRowWithCell(photo.getRow1(), photo.getCol1(), sheet.getDefaultRowHeight());

                    FileManager.uploadFileEntity(pictureBytes, pictureData.getMimeType(), sha);

                    Map<String, Object> image_info = new HashMap<>();

                    image_info.put("sha", sha);
                    image_info.put("photo_size", pictureBytes.length);
                    image_info.put("content_type", pictureData.getMimeType());

                    photo_infos.add(image_info);
                }
            } catch (POIXMLException e) {
                throw new RuntimeException("Biruni ER: failed to read picture from sheet. Error message: " + e.getMessage());
            }
        }

        sheet.getMergedRegions().forEach(cellAddresses -> erSheet.addMergedRegion(cellAddresses.formatAsString()));

        definitions.addAll(definition);

        erSheet.sortRows();

        return erSheet;
    }

    @NotNull
    private static ERPhoto getPhoto(XSSFPicture picture, String sha) {
        XSSFClientAnchor clientAnchor = picture.getClientAnchor();

        ERPhoto photo = new ERPhoto(sha);

        photo.setRow1(clientAnchor.getRow1());
        photo.setRow2(clientAnchor.getRow2());
        photo.setCol1(clientAnchor.getCol1());
        photo.setCol2(clientAnchor.getCol2());
        photo.setDx1(clientAnchor.getDx1());
        photo.setDx2(clientAnchor.getDx2());
        photo.setDy1(clientAnchor.getDy1());
        photo.setDy2(clientAnchor.getDy2());

        return photo;
    }

    public static Map<String, String> read(InputStream inputStream) {
        try (XSSFWorkbook workbook = new XSSFWorkbook(inputStream)) {
            ERMetadata metadata = new ERMetadata();
            List<Map<String, Object>> definitions = new ArrayList<>();
            List<Map<String, Object>> photoInfos = new ArrayList<>();

            workbook.forEach(sheet -> metadata.addSheet(readSheet((XSSFSheet) sheet, definitions, photoInfos)));

            Gson gson = new Gson();

            Map<String, String> templateData = new HashMap<>();

            templateData.put("metadata", gson.toJson(metadata, ERMetadata.class));
            templateData.put("definitions", gson.toJson(definitions));
            templateData.put("version", ERUtil.VERSION);
            templateData.put("photoInfos", gson.toJson(photoInfos));

            return templateData;
        } catch (Exception e) {
            throw new RuntimeException(e.getMessage());
        }
    }
}
