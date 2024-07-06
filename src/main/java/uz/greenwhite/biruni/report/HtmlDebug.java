package uz.greenwhite.biruni.report;

import java.io.*;
import java.nio.charset.StandardCharsets;

public class HtmlDebug {

    private final BrBook book;
    private final PrintWriter out;

    public HtmlDebug(BrBook book, OutputStream os) {
        this.book = book;
        this.out = new PrintWriter(new OutputStreamWriter(new BufferedOutputStream(os), StandardCharsets.UTF_8));
    }

    public void build() {
        print();
        out.flush();
        out.close();
    }

    private void print() {
        for (BrSheet sheet : book.sheets) {
            out.println("<p style='text-align:center'>" + sheet.name + "</p>");
            BrTable table = book.tables.get(sheet.tableId);
            printTable(table);
        }
    }

    private void printTable(BrTable table) {
        out.println("<table border=1 cellspacing=0>");
        for (BrRow row : table.rows) {
            out.println("<tr>");
            for (BrCell cell : row.cells) {
                if (cell.isTypeTable()) {
                    out.println("<td>");
                    printTable(cell.table);
                    out.println("</td>");
                } else {
                    String val = cell.value;
                    if (val == null || val.length() == 0) {
                        val = "&nbsp;";
                    }
                    out.println("<td colspan=" + cell.colspan + " rowspan=" + cell.rowspan + ">" + val + "</td>");
                }
            }
            out.println("</tr>");
        }
        out.println("</table>");
    }
}
