package uz.greenwhite.biruni.report;

import com.google.common.escape.Escaper;
import com.google.common.escape.Escapers;

import java.io.*;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.HashSet;

public class Html {
    private final Escaper escaper = Escapers.builder()
            .addEscape('&', "&amp;")
            .addEscape('<', "&lt;")
            .addEscape('>', "&gt;")
            .addEscape('"', "&quot;")
            .addEscape('\'', "&#39;")
            .addEscape('/', "&#x2F;")
            .addEscape('`', "&#96;")
            .addEscape('=', "&#x3D;")
            .build();

    private final BrBook book;
    private final PrintWriter out;
    private final HashSet<Integer> rotatedClassIds = new HashSet<>();
    private final boolean isMobileVersion;

    public void addRotatedClassId(int id) {
        rotatedClassIds.add(id);
    }

    public Html(BrBook book, OutputStream os, boolean isMobileVersion) {
        this.book = book;
        this.out = new PrintWriter(new OutputStreamWriter(new BufferedOutputStream(os), StandardCharsets.UTF_8));
        this.isMobileVersion = isMobileVersion;
    }

    public void build(String contextPath) {

        out.println("<!DOCTYPE html>");
        out.println("<html lang='ru'>");
        out.println("<head>");
        out.println("<meta charset='utf-8'>");
        out.println("<meta http-equiv='X-UA-Compatible' content='IE=edge'>");
        out.println("<meta name='viewport' content='width=device-width, initial-scale=1'>");
        out.println("<title>Smartup</title>");
        out.println("<script src='" + contextPath + "/assets/jquery/jquery.min.js'></script>");
        out.println("<script src='" + contextPath + "/assets/jquery/jquery.resize.js'></script>");
        out.println("<script src='" + contextPath + "/assets/bootstrap/js/bootstrap.bundle.min.js'></script>");
        out.println("<script src='" + contextPath + "/assets/biruni/report.js'></script>");
        out.println("<link href='" + contextPath + "/assets/fontawesome/css/all.min.css' rel='stylesheet' type='text/css'/>");
        out.println("<link href='" + contextPath + "/assets/metronic/css/style.bundle.css' rel='stylesheet' type='text/css'/>");

        printStyles();

        out.println("</head><body class='h-auto'>");

        if (!this.isMobileVersion) {
            printHeader();
        }

        out.println("<div class='container-fluid' id='report-content'>");
        out.println("<div class='row'>");
        if (book.sheets.size() > 1) {
            out.println("<div class='col-sm-24' id='report-sheets'>");
            out.println("<div class='tabbable-line'>");
            out.println("<ul class='nav nav-tabs' style='border-bottom:1px solid #e7e7e7;'>");

            for (int i = 0; i < book.sheets.size(); i++) {
                out.println("<li class='nav-item'><a class='nav-link" + (i == 0 ? " active" : "") + "' data-target='#sheet" + (i + 1) + "' data-toggle='tab'>" + escaper.escape(book.sheets.get(i).name) + "</a></li>");
            }

            out.println("</ul>");
            out.println("</div>");
            out.println("</div>");
        }
        printSheets();
        out.println("</div>");
        out.println("</div>");

        if (book.menus != null && !book.menus.isEmpty()) {
            out.println("<script>var reportMenu = " + book.menus + ";</script>");
            out.println("<div id='cell-menu' style='position:absolute;display:none;'><ul class='nav'></ul></div>");
        }

        out.println("</body></html>");

        out.flush();
        out.close();
    }

    private void printHeader() {
        out.println("<div id='report-header' class='sticky-top'>");
        out.println("<div class='b-head-lines'>");
        out.println("<div class='b-head-line' style='background-color: #A2228D;'></div>");
        out.println("<div class='b-head-line' style='background-color: #525096;'></div>");
        out.println("<div class='b-head-line' style='background-color: #0095D9;'></div>");
        out.println("<div class='b-head-line' style='background-color: #8ED8F8;'></div>");
        out.println("<div class='b-head-line' style='background-color: #A7CE3A;'></div>");
        out.println("<div class='b-head-line' style='background-color: #D2E388;'></div>");
        out.println("<div class='b-head-line' style='background-color: #FFCA00;'></div>");
        out.println("<div class='b-head-line' style='background-color: #ED7822;'></div>");
        out.println("</div>");
        out.println("<nav class='navbar navbar-expand-lg navbar-light bg-light'>");
        out.println("<div class='navbar-brand report-brand'><a><img height='32' src=''/></a>&emsp;" + escaper.escape(book.setting.filename) + "</div>");
        out.println("<button type='button' id='print-btn' class='btn btn-default ml-auto mr-2'><i class='fa fa-print' aria-hidden='true'></i></button>");
        out.println("<div class='btn-group' id='report-types'>");
        out.println("<button type='button' class='btn btn-default rounded-left'><i class='fa fa-cloud-download-alt' aria-hidden='true'></i>&nbsp;EXCEL<pm>xlsx</pm></button>");
        out.println("<button type='button' class='btn btn-default rounded-right dropdown-toggle dropdown-toggle-split' data-toggle='dropdown' aria-haspopup='true' aria-expanded='false'>");
        out.println("<span class='sr-only'></span>");
        out.println("</button>");
        out.println("<div class='dropdown-menu dropdown-menu-right'>");
        out.println("<a class='dropdown-item'><i class='fa fa-cloud-download-alt' aria-hidden='true'></i>&nbsp;CSV<pm>csv</pm></a>");
        out.println("<a class='dropdown-item'><i class='fa fa-cloud-download-alt' aria-hidden='true'></i>&nbsp;XML<pm>xml</pm></a>");
        out.println("</div>");
        out.println("</div>");
        out.println("</nav>");
        out.println("</div>");
    }

    private void printSheets() {
        int sheetsCount = book.sheets.size();
        if (sheetsCount > 1) {
            out.println("<div class='tab-content'>");
            for (int i = 0; i < sheetsCount; i++) {
                out.println("<div id='sheet" + (i + 1) + "' class='tab-pane" + (i == 0 ? " active" : "") + "'>");
                printSheet(book.sheets.get(i));
                out.println("</div>");
            }
            out.println("</div>");
        } else {
            printSheet(book.sheets.get(0));
        }
    }

    private void openTable(Result r) {
        if (r.param != null && !r.param.isEmpty()) {
            out.println("<pm>" + escaper.escape(r.param) + "</pm>");
        }
        out.print("<table cellspacing='0' cellpadding='0' class='bsr-table'>");
        for (int i = 0; i < r.columnWidths.length; i++) {
            if (r.columnWidths[i] > 0) {
                out.println("<col width='" + r.columnWidths[i] + "'/>");
            } else {
                out.println("<col/>");
            }
        }
    }

    /**
     * This method collects page break and page breakables
     */
    private int collectPageBreaksAndPageBreakables(BrSheet sheet, int tableId, int rowNumber) {
        BrTable table = book.tables.get(tableId);
        BrRow row;
        BrCell cell;

        for (int i = 0; i < table.rows.size(); i++, rowNumber++) {
            row = table.rows.get(i);

            if (row.rowBreak) sheet.rowPageBreaks.add(rowNumber);
            if (sheet.wrapMergedCells && row.rowBreakable) sheet.rowPageBreakables.add(rowNumber);

            for (int x = 0; x < row.cells.size(); x++) {
                cell = row.cells.get(x);

                if (cell.isTypeTable()) {
                    rowNumber += collectPageBreaksAndPageBreakables(sheet, Integer.parseInt(cell.value), rowNumber);
                }
            }
        }

        return table.rows.size() - 1;
    }

    private void printSheet(BrSheet sheet) {
        collectPageBreaksAndPageBreakables(sheet, sheet.tableId, 0);

        Result r = evalResult(sheet);
        Object[][] m = r.matrix;
        boolean rotatedClassExist, styleExist, transExist;

        openTable(r);

        for (int i = 0; i < m.length; i++) {
            var hasRowBreak = sheet.rowPageBreaks.contains(i);
            var hasRowBreakable = sheet.rowPageBreakables.contains(i);
            var tRowPrintClass = "";

            if (hasRowBreak) {
                tRowPrintClass = " class='b-page-break'";
            } else if (hasRowBreakable) {
                tRowPrintClass = " class='b-page-breakable'";
            }

            if (i < r.rowHeights.length && r.rowHeights[i] > 0) {
                out.println("<tr style='height:" + r.rowHeights[i] + "px;'" + tRowPrintClass + ">");
            } else {
                out.println("<tr" + tRowPrintClass + ">");
            }

            Object[] cs = m[i];

            for (int j = 0; j < cs.length; j++) {
                Object c1 = cs[j];
                if (c1 == null) {
                    out.print("<td>&nbsp;</td>");
                    continue;
                } else if (c1 == Boolean.TRUE) {
                    continue;
                }

                BrCell c = (BrCell) c1;

                out.print("<td");

                styleExist = (0 <= c.meta.styleIndex && c.meta.styleIndex <= book.styles.size());
                transExist = (c.param != null && !c.param.isEmpty());

                if (styleExist || transExist) {
                    out.print(" class='");
                    if (styleExist) {
                        out.print("bsr-" + c.meta.styleIndex);
                    }
                    if (transExist) {
                        out.print((styleExist ? " " : "") + "bsr-trans");
                    }
                    out.print("'");
                }
                if (c.rowspan > 1) {
                    out.print(" rowspan=" + c.rowspan);
                }
                if (c.colspan > 1) {
                    out.print(" colspan=" + c.colspan);
                }

                out.print(">");

                rotatedClassExist = rotatedClassIds.contains(c.meta.styleIndex);

                if (rotatedClassExist) {
                    out.print("<div>");
                }

                if (c.meta.type == 'I') {
                    out.print("<img src='" + book.setting.url + "/core/m:load_image?sha=" + c.value + "' style='position:relative;");
                    if (c.meta.width > 0) {
                        out.print("width:" + c.meta.width + "px;");
                    }
                    if (c.meta.height > 0) {
                        out.print("height:" + c.meta.height + "px;");
                    }
                    out.print("'/>");
                } else if (c.meta.type == 'B') {
                    out.print("<img src='" + book.setting.contextPath + "/gen/barcode?text=" + encodeUrl(c.value) + "&width=" + c.meta.width + "&height=" + c.meta.height + "&label=" + c.meta.label + "&font-size=12' style='position:relative;'/>");
                } else if (c.meta.type == 'Q') {
                    out.print("<img src='" + book.setting.contextPath + "/gen/qrcode?text=" + encodeUrl(c.value) + "&width=" + c.meta.width + "&height=" + c.meta.height + "' style='position:relative;'/>");
                } else if (c.meta.type == 'M') {
                    out.print("<img src='" + book.setting.contextPath + "/gen/gs1datamatrix?text=" + encodeUrl(c.value) + "&width=" + c.meta.width + "&height=" + c.meta.height + "' style='position:relative;'/>");
                } else if (c.value != null && !c.value.isEmpty()) {
                    out.print(escaper.escape(c.value));

                } else {
                    out.print("&nbsp;");
                }

                if (c.param != null && !c.param.isEmpty()) {
                    out.print("<pm>" + escaper.escape(c.param) + "</pm>");
                }

                if (c.meta.menuIds != null && !c.meta.menuIds.isEmpty()) {
                    out.print("<menu-ids>" + escaper.escape(c.meta.menuIds) + "</menu-ids>");
                }

                if (rotatedClassExist) {
                    out.print("</div>");
                }

                out.println("</td>");

                if (c.rowspan > 1 || c.colspan > 1) {
                    for (int a = 0; a < c.rowspan; a++) {
                        for (int b = 0; b < c.colspan; b++) {
                            m[i + a][j + b] = Boolean.TRUE;
                        }
                    }
                }

            }
            out.println("</tr>");
        }
        out.println("</table>");
    }

    private String encodeUrl(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }

    private Result evalResult(BrSheet sheet) {
        BrTable table = book.tables.get(sheet.tableId);

        Result result = table.unroll();
        result.param = sheet.param;
        return result;
    }

    private void printStyles() {
        out.print("<style>");
        out.println(".b-head-lines{top:0;z-index:10000;position:fixed;width:100%;}");
        out.println(".b-head-line{background-color:#A2228D;width:12.5%;height:1px;float:left;}");
        out.println("#report-content{height:100%;min-width:100%;width:unset!important;background-color:#fcfcfc;}");
        out.println(".report-brand{padding:3px;color:#c7c5d8;}");
        out.println("#report-sheets{padding:0;}");
        if (book.menus != null && !book.menus.isEmpty()) {
            out.println("#cell-menu>ul{width:auto;width:250px;background-color:white;border:1px solid #ccc;}");
            out.println("#cell-menu>ul>li>a{padding:4px 6px;font-size:12px;color:#333;}");
            out.println("#cell-menu>ul>li>a:hover{background-color:#e8e8e8;}");
        }
        out.println("@media screen{.bsr-pb{visibility:hidden;}.bsr-trans{cursor:pointer;color:#1a0dab !important;}.bsr-trans:hover{text-decoration:underline;}}");
        out.println("@media print{@page{size:auto;}#report-header{display:none;}#report-sheets{display:none;}#cell-menu{display:none !important;}}");
        out.println("pm{display:none;}");
        out.println("menu-ids{display:none;}");
        out.println(".bsr-table{margin:auto;color:black;border-collapse:collapse;}.bsr-table td{padding:2px;}");
        out.println(".bsr-table tr{page-break-after:avoid;}");
        out.println(".bsr-table tr.b-page-break{page-break-after:always;}");
        out.println(".bsr-table tr.b-page-breakable{page-break-after:auto;}");
        for (int i = 0; i < book.styles.size(); i++) {
            BrStyle s = book.styles.get(i);
            out.print(".bsr-" + i + "{");

            if (s.fontIndex >= 0) {
                BrFont f = book.fonts.get(s.fontIndex);
                if (notEmpty(f.color)) {
                    out.print("color:" + f.color + ";");
                }
                if (notEmpty(f.family)) {
                    out.print("font-family:" + f.family + ";");
                }
                if (f.size > 0) {
                    out.print("font-size:" + f.size + "pt;");
                }
                if (f.bold) {
                    out.print("font-weight:bold;");
                }
                if (f.italic) {
                    out.print("font-style:italic;");
                }
                if (f.underline) {
                    out.print("text-decoration:underline;");
                }
            }

            if (notEmpty(s.bgColor)) {
                out.print("background-color:" + s.bgColor + ";");
            }

            if (s.wrap) {
                out.print("word-wrap:break-word;");
            } else {
                out.print("white-space:nowrap;");
            }

            switch (s.align) {
                case 1:
                    out.print("text-align:left;");
                    break;
                case 2:
                    out.print("text-align:center;");
                    break;
                case 3:
                    out.print("text-align:right;");
                    break;
            }

            switch (s.valign) {
                case 1:
                    out.print("vertical-align:top;");
                    break;
                case 2:
                    out.print("vertical-align:middle;");
                    break;
                case 3:
                    out.print("vertical-align:bottom;");
                    break;
            }

            if (s.indent != 0) {
                out.print("text-indent:" + s.indent + "em;");
            }

            if (s.borderTop != null) {
                out.print("border-top:" + mkBorder(s.borderTop, s.borderTopColor) + ";");
            }
            if (s.borderBottom != null) {
                out.print("border-bottom:" + mkBorder(s.borderBottom, s.borderBottomColor) + ";");
            }
            if (s.borderLeft != null) {
                out.print("border-left:" + mkBorder(s.borderLeft, s.borderLeftColor) + ";");
            }
            if (s.borderRight != null) {
                out.print("border-right:" + mkBorder(s.borderRight, s.borderRightColor) + ";");
            }
            if (s.rotate != 0) {
                out.print("overflow:hidden;");
            }

            out.println("}");

            if (s.rotate != 0) {
                out.print(".bsr-" + i + " > div{");
                out.print("-webkit-transform:rotate(" + s.rotate + "deg);" +
                        "-moz-transform:rotate(" + s.rotate + "deg);" +
                        "-o-transform:rotate(" + s.rotate + "deg);" +
                        "display: block;" +
                        "height: 41px;" +
                        "width: 146px;");

                if (s.rotate == -90) {
                    out.print("margin-left: -54.5px;margin-bottom: 54.5px;");
                } else if (s.rotate == 90) {
                    out.print("margin-right: -54.5px;margin-top: 54.5px;");
                }

                out.println("}");

                addRotatedClassId(i);
            }
        }
        out.print("</style>");
    }

    private String mkBorderStyle(String type) {
        return switch (type) {
            case "hair", "thin" -> "1px solid";
            case "medium" -> "2px solid";
            case "thick" -> "3px solid";
            case "double", "dotted", "dash_dot_dot" -> "1px dotted";
            case "medium_dash_dot_dot", "slanted_dash_dot" -> "2px dotted";
            case "dashed", "dash_dot" -> "1px dashed";
            case "medium_dashed", "medium_dash_dot" -> "2px dashed";
            default -> "none";
        };
    }

    private String mkBorder(String type, String color) {
        if (color == null || color.isEmpty()) {
            color = "#000000";
        }
        return mkBorderStyle(type) + " " + color;
    }

    private boolean notEmpty(String s) {
        return s != null && !s.isEmpty();
    }
}
