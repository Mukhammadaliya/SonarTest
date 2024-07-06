package uz.greenwhite.biruni.report;

import java.io.*;
import java.nio.charset.Charset;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

public class Csv {
    private final BrBook book;
    private static final char DEFAULT_SEPARATOR = ';';

    public Csv(BrBook book) {
        this.book = book;
    }

    public void write(OutputStream os) throws IOException {
        if (book.sheets.size() > 1) {
            ZipOutputStream zip = new ZipOutputStream(os);
            print(zip);
            zip.close();
        } else {
            printSheet(os, book.sheets.get(0));
        }
    }

    public void print(ZipOutputStream zip) throws IOException {
        for (BrSheet sheet : book.sheets) {
            zip.putNextEntry(new ZipEntry(sheet.name + ".csv"));
            printSheet(zip, sheet);
            zip.closeEntry();
        }
    }

    private static String csvFormat(String value) {
        String result = value;
        if (result.contains("\"")) {
            result = result.replace("\"", "\"\"");
        }
        return result;
    }

    public void printSheet(OutputStream os, BrSheet sheet) {
        PrintWriter pWriter = new PrintWriter(new OutputStreamWriter(os, Charset.forName("windows-1251").newEncoder()));

        Result rs = evalResult(sheet);
        Object[][] m = rs.matrix;

        boolean isFirstColumn;

        for (Object[] cs : m) {
            isFirstColumn = true;

            for (Object c : cs) {
                BrCell cell = (BrCell) c;

                if (!isFirstColumn) {
                    pWriter.print(DEFAULT_SEPARATOR);
                }
                if (cell != null && cell.value != null && cell.value.length() > 0) {
                    pWriter.print('"');
                    pWriter.print(csvFormat(cell.value));
                    pWriter.print('"');
                }
                isFirstColumn = false;
            }
            pWriter.println();
        }
        pWriter.flush();
    }

    private Result evalResult(BrSheet sheet) {
        BrTable table = book.tables.get(sheet.tableId);
        return table.unroll();
    }
}
