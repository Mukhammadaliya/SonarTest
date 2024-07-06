package uz.greenwhite.biruni;

import org.apache.poi.openxml4j.util.ZipSecureFile;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.NumberToTextConverter;

import java.io.IOException;
import java.io.InputStream;
import java.text.SimpleDateFormat;

public class ImportExcel {
    public static StringBuilder read(InputStream stream) throws IOException {
        StringBuilder sb = new StringBuilder();

        //temporary solution
        ZipSecureFile.setMinInflateRatio(0.001d);

        Workbook book = WorkbookFactory.create(stream);

        sb.append("[");

        for (int k = 0; k < book.getNumberOfSheets(); k++) {
            Sheet sheet = book.getSheetAt(k);

            if (sheet.getPhysicalNumberOfRows() == 0) {
                continue;
            }

            if (k > 0) {
                sb.append(",");
            }

            sb.append("{\"name\":\"");
            quoteAndAppend(sb, sheet.getSheetName());
            sb.append("\",\"table\":[");
            sb.append(getSheetData(sheet));
            sb.append("]}");
        }


        sb.append("]");
        book.close();

        return sb;
    }

    @SuppressWarnings("deprecation")
    private static StringBuilder getSheetData(Sheet sheet) {
        char rowSplitter = (char) 1;
        char cellSplitter = (char) 2;
        StringBuilder sb = new StringBuilder();

        int rows = sheet.getLastRowNum();

        for (int i = 0; i <= rows; i++) {
            Row row = sheet.getRow(i);
            if (i > 0) {
                sb.append(rowSplitter);
            }

            if (row == null) {
                continue;
            }

            int cells = row.getLastCellNum();

            for (int j = 0; j < cells; j++) {
                Cell cell = row.getCell(j);

                if (j > 0) {
                    sb.append(cellSplitter);
                }

                if (cell != null) {
                    String s;
                    switch (cell.getCellType()) {
                        case NUMERIC:
                            if (DateUtil.isCellDateFormatted(cell)) {
                                SimpleDateFormat sdf = new SimpleDateFormat("dd.MM.yyyy HH:mm:ss");
                                s = sdf.format(cell.getDateCellValue());
                            } else {
                                s = NumberToTextConverter.toText(cell.getNumericCellValue());
                            }
                            break;
                        case STRING:
                            s = cell.getStringCellValue();
                            s = s.replace(rowSplitter, ' ');
                            s = s.replace(cellSplitter, ' ');
                            s = s.replace((char) 0, ' ');
                            break;
                        default:
                            s = "";
                            break;
                    }
                    sb.append(s);
                }
            }
        }

        StringBuilder rs = new StringBuilder();
        int len = sb.length();
        rs.append('\"');
        for (int i = 0; i < len; i += 16000) {
            if (i > 0) {
                rs.append("\",\"");
            }
            quoteAndAppend(rs, sb.substring(i, Math.min(len, i + 16000)));
        }
        rs.append('\"');

        return rs;
    }

    private static void quoteAndAppend(StringBuilder sb, String s) {
        int len = s.length();
        for (int i = 0; i < len; i++) {
            char c = s.charAt(i);
            if (c == '"' || c == '\\') {
                sb.append('\\');
            }
            sb.append(c);
        }
    }
}
