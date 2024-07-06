package uz.greenwhite.biruni.report;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.HashSet;

public class HtmlStyle {
    private final BrBook book;
    private final PrintWriter out;
    private final HashSet<Integer> rotatedClassIds = new HashSet<>();
    private final boolean isMobileVersion;

    public void addRotatedClassId(int id) {
        rotatedClassIds.add(id);
    }

    public HtmlStyle(BrBook book, OutputStream os, boolean isMobileVersion) throws UnsupportedEncodingException {
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
        out.println("<script src='" + contextPath + "/assets/jquery/jquery-2.2.0.min.js'></script>");
        out.println("<script src='" + contextPath + "/assets/bootstrap/js/bootstrap.min.js'></script>");
        out.println("<script src='" + contextPath + "/assets/biruni/report.js'></script>");
        out.println("<link href='" + contextPath + "/assets/font-awesome/css/font-awesome.min.css' rel='stylesheet' type='text/css'/>");
        out.println("<link href='" + contextPath + "/assets/bootstrap/css/bootstrap.min.css' rel='stylesheet' type='text/css'/>");
        out.println("<link href='" + contextPath + "/assets/metronic/css/components-rounded.css' rel='stylesheet' type='text/css'/>");

        printStyles();

        out.println("</head><body>");

        if (!this.isMobileVersion) {
            printHeader(contextPath);
        }

        out.println("<div style='width:100%;' id='report-divider'></div>");
        out.println("<div class='container' id='report-content'>");
        out.println("<div class='row'>");
        if (book.sheets.size() > 1) {
            out.println("<div class='col-sm-24' id='report-sheets'>");
            out.println("<div class='tabbable-line'>");
            out.println("<ul class='nav nav-tabs' style='border-bottom:1px solid #e7e7e7;'>");

            for (int i = 0; i < book.sheets.size(); i++) {
                out.println("<li" + (i == 0 ? " class='active'" : "") + "><a data-target='#sheet" + (i + 1) + "' data-toggle='tab'>" + book.sheets.get(i).name + "</a></li>");
            }

            out.println("</ul>");
            out.println("</div>");
            out.println("</div>");
        }
        printSheets();
        out.println("</div>");
        out.println("</div>");

        if (book.menus != null && book.menus.length() > 0) {
            out.println("<script>var reportMenu = " + book.menus + ";</script>");
            out.println("<div id='cell-menu' style='position:absolute;display:none;'><ul class='nav'></ul></div>");
        }

        out.println("</body></html>");

        out.flush();
        out.close();
    }

    private void printHeader(String contextPath) {
        out.println("<div id='report-header'>");
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
        out.println("<nav class='navbar navbar-default navbar-fixed-top'>");
        out.println("<div class='container-fluid'>");
        out.println("<div class='row'>");
        out.println("<div class='navbar-header'>");
        out.println("<a class='navbar-brand report-brand'>");
        out.println("<img alt='SMARTUP' src='" + contextPath + "/assets/img/logo_small.png'>");
        out.println("</a>");
        out.println("<a class='navbar-title'>" + book.setting.filename + "</a>");
        out.println("</div>");
        out.println("<div class='pull-right' style='margin-top:10px;'>");
        out.println("<div class='btn-group' id='report-types' style='width:100px;'>");
        out.println("<button type='button' class='btn btn-sm btn-default' tabindex='-1' style='width:75px;'><i class='fa fa-cloud-download' aria-hidden='true'></i>&nbsp;EXCEL<pm>xlsx</pm></button>");
        out.println("<button type='button' class='btn btn-sm btn-default dropdown-toggle' data-toggle='dropdown' tabindex='-1' aria-expanded='true' style='width:25px;'><i class='fa fa-angle-down'></i></button>");
        out.println("<ul class='dropdown-menu pull-right' role='menu' style='min-width:100px;width:100px;margin-top:2px;border:1px solid #ccc;'>");
        out.println("<li><a style='padding:6px 8px;'><i class='fa fa-cloud-download' aria-hidden='true'></i>&nbsp;CSV<pm>csv</pm></a></li>");
        out.println("<li><a style='padding:6px 8px;'><i class='fa fa-cloud-download' aria-hidden='true'></i>&nbsp;XML<pm>xml</pm></a></li>");
        out.println("</ul>");
        out.println("</div>");
        out.println("</div>");
        out.println("</div>");
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
        if (r.param != null && r.param.length() > 0) {
            out.println("<pm>" + r.param + "</pm>");
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

    private boolean belongToGrid(Result r, String type, int index) {
        for (GridContent gc: r.gridContents) {
            if (gc.type.equals(GridContent.getGridType(type.charAt(0)))) {
                if (type.charAt(1) == 'b' && gc.fromIndex == index) {
                    return true;
                } else if (type.charAt(1) == 'e' && gc.toIndex == index) {
                    return true;
                }
            }
        }
        return false;
    }

    private void printSheet(BrSheet sheet) {
        Result r = evalResult(sheet);

        Object[][] m = r.matrix;
        boolean rotatedClassExist, styleExist, transExist;

        openTable(r);

        for (int i = 0; i < m.length; i++) {
            if (belongToGrid(r, "tb", i)) {
                out.println("<tr>\n<td colspan='"+ m[i].length +"'>\n<table class='table table-striped table-bordered table-hover bsr-grid'>");
                for (int j = 0; j < m[i].length; j++) {
                    if (r.columnWidths[j] > 0) {
                        out.println("<col width='" + r.columnWidths[j] + "'/>");
                    } else {
                        out.println("<col/>");
                    }
                }
            }

            if (belongToGrid(r, "hb", i)) {
                out.println("<thead>");
            } else if (belongToGrid(r, "bb", i)) {
                out.println("<tbody>");
            } else if (belongToGrid(r, "fb", i)) {
                out.println("<tfoot>");
            }

            if (i < r.rowHeights.length && r.rowHeights[i] > 0) {
                out.println("<tr style='height:" + r.rowHeights[i] + "px;'>");
            } else {
                out.println("<tr>");
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
                transExist = (c.param != null && c.param.length() > 0);

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
                    out.print("<img src='" + book.setting.url + "/core/m:load_image?sha=" + c.value + "' style='position:absolute;");
                    if (c.meta.width > 0) {
                        out.print("width:" + c.meta.width + "px;");
                    }
                    if (c.meta.height > 0) {
                        out.print("height:" + c.meta.height + "px;");
                    }
                    out.print("'/>");
                } else if (c.value != null && c.value.length() > 0) {
                    out.print(c.value);
                } else {
                    out.print("&nbsp;");
                }

                if (c.param != null && c.param.length() > 0) {
                    out.print("<pm>" + c.param + "</pm>");
                }

                if (c.meta.menuIds != null && c.meta.menuIds.length() > 0) {
                    out.print("<menu-ids>" + c.meta.menuIds + "</menu-ids>");
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

            if (belongToGrid(r, "he", i)) {
                out.println("</thead>");
            }
            if (belongToGrid(r, "be", i)) {
                out.println("</tbody>");
            }
            if (belongToGrid(r, "fe", i)) {
                out.println("</tfoot>");
            }

            if (belongToGrid(r, "te", i)) {
                out.println("</table>\n</td>\n</tr>");
            }
        }
        out.println("</table>");
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
        out.println(".b-head-line{background-color:#A2228D;width:12.5%;height:2px;float:left;}");
        out.println("#report-content{height:100%;width:100%;background-color:#fcfcfc;}");
        out.println(".report-brand{padding:10px 20px;}");
        out.println(".navbar-title{float:left;padding:16px 15px;font-size:14px;line-height:18px;height:50px;text-decoration:none !important;cursor:default !important;color:#333;}");
        out.println(".navbar-title:hover{color:#333;}");
        out.println(".report-brand img{width:107px;height:34px;}");
        out.println("#report-sheets{padding:0;}");
        if (book.menus != null && book.menus.length() > 0) {
            out.println("#cell-menu>ul{width:auto;width:250px;background-color:white;border:1px solid #ccc;}");
            out.println("#cell-menu>ul>li>a{padding:4px 6px;font-size:12px;color:#333;}");
            out.println("#cell-menu>ul>li>a:hover{background-color:#e8e8e8;}");
        }
        out.println("@media screen{.bsr-pb{visibility:hidden;}.bsr-trans{cursor:pointer;color:#1a0dab !important;}.bsr-trans:hover{text-decoration:underline;}}");
        out.println("@media print{@page{size:auto;}#report-header{display:none;}#report-sheets{display:none;}#report-divider{display:none;}#cell-menu{display:none !important;}}");
        out.println("pm{display:none;}");
        out.println("menu-ids{display:none;}");
        out.println(".bsr-table{margin:auto;color:black;border-collapse:collapse;}.bsr-table td{padding:2px;}");
        out.println(".bsr-grid{margin-bottom:0;}");
        out.println(".bsr-grid td{font-size:8pt;padding:5px !important;}");
        out.println(".bsr-grid thead td, .bsr-grid tfoot td{vertical-align:middle !important;}");
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
        switch (type) {
            case "hair":
            case "thin":
            case "double":
                return "1px solid";
            case "thick":
                return "3px solid";
            case "dotted":
            case "dash_dot_dot":
                return "1px dotted";
            case "dashed":
            case "dash_dot":
                return "1px dashed";
            case "medium":
                return "2px solid";
            case "medium_dashed":
            case "medium_dash_dot":
                return "2px dashed";
            case "medium_dash_dot_dot":
            case "slanted_dash_dot":
                return "2px dotted";
            default:
                return "none";
        }
    }

    private String mkBorder(String type, String color) {
        if (color == null || color.length() == 0) {
            color = "#000000";
        }
        return mkBorderStyle(type) + " " + color;
    }

    private boolean notEmpty(String s) {
        return s != null && s.length() > 0;
    }
}
