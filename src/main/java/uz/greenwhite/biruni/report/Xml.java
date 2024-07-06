package uz.greenwhite.biruni.report;

import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

public class Xml {
    private final BrBook book;

    public Xml(BrBook book) {
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
            zip.putNextEntry(new ZipEntry(sheet.name + ".xml"));
            printSheet(zip, sheet);
            zip.closeEntry();
        }
    }

    public void printSheet(OutputStream os, BrSheet sheet) {
        PrintWriter pWriter = new PrintWriter(new OutputStreamWriter(os, StandardCharsets.UTF_8.newEncoder()));

        Result rs = evalResult(sheet);
        Object[][] m = rs.matrix;

        pWriter.println("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
        pWriter.println("<t>");

        for (Object[] cs : m) {
            pWriter.print("<r>");

            for (Object c : cs) {
                BrCell cell = (BrCell) c;

                if (cell == null) {
                    pWriter.print("<c></c>");
                    continue;
                }

                pWriter.print("<c");
                switch (cell.meta.type) {
                    case 'N':
                        pWriter.print(" type=\"number\"");
                        break;
                    case 'D':
                        pWriter.print(" type=\"date\"");
                        break;
                    case 'I':
                        pWriter.print(" type=\"image\"");
                        break;
                }
                pWriter.print(">");
                if (cell.value != null && cell.value.length() > 0) {
                    pWriter.print(cell.value);
                }
                pWriter.print("</c>");
            }
            pWriter.println("</r>");
        }
        pWriter.println("</t>");

        pWriter.flush();
    }

    private Result evalResult(BrSheet sheet) {
        BrTable table = book.tables.get(sheet.tableId);
        return table.unroll();
    }
}
