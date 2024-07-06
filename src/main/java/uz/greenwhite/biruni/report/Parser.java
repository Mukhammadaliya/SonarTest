package uz.greenwhite.biruni.report;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class Parser {

    private final Token token;

    public Parser(Token token) {
        this.token = token;
    }

    public BrBook result() {
        return parseBook();
    }

    private BrBook parseBook() {
        BrBook book = new BrBook();
        book.sheets = new ArrayList<>();
        book.tables = new HashMap<>();

        token.open();
        while (token.hasNext()) {
            token.open();
            switch (token.nextString()) {
                case "table":
                    BrTable table = parseTable();
                    book.tables.put(table.id, table);
                    break;
                case "sheet":
                    book.sheets.add(parseSheet());
                    break;
                case "setting":
                    book.setting = parseSetting();
                    break;
                case "font":
                    book.fonts = parseFonts();
                    break;
                case "style":
                    book.styles = parseStyles();
                    break;
                case "cell_meta":
                    book.cellMetas = parseCellMetas();
                    break;
                case "menus":
                    book.menus = token.nextString();
                    break;
                default:
                    throw new ParseError("book match error");
            }
            token.close();
        }
        token.close();

        token.completed();
        book.init();

        book.groupingExists = this.groupingExists(book);

        return book;
    }

    private boolean groupingExists(BrBook book) {
        for (BrTable t : book.tables.values()) {
            if (t.groupings.size() > 0) {
                return true;
            }
        }
        return false;
    }

    private BrTable parseTable() {
        BrTable table = new BrTable();

        table.id = token.nextInt();
        table.rows = parseRows();
        table.columnWidths = parseColumnWidths();
        table.columnDataSources = parseColumnDataSources();
        table.groupings = parseGroupings();
        table.gridContents = parseGridContents();
        return table;
    }

    private List<BrRow> parseRows() {
        List<BrRow> rs = new ArrayList<>();
        token.open();
        while (token.hasNext()) {
            rs.add(parseRow());
        }
        token.close();
        return rs;
    }

    private BrRow parseRow() {
        BrRow r = new BrRow();
        token.open();
        token.open();
        while (token.hasNext()) {
            token.open();
            if (token.nextChar() == 'h') {
                r.height = token.nextInt();
            } else {
                throw new ParseError("row match error");
            }
            token.close();
        }
        token.close();
        r.cells = parseCells(r);
        if (r.cells.isEmpty()) {
            BrCell cell = new BrCell();
            cell.metaIndex = 0;
            cell.value = "";
            r.cells.add(cell);
        }
        token.close();
        return r;
    }

    private void parsePageBreak(BrRow r) {
        while (token.hasNext()) {
            token.open();
            switch (token.nextString()) {
                case "pbr":
                    r.rowBreak = token.nextBoolean();
                    break;
                case "pbc":
                    r.colBreaks.add(token.nextInt());
                    break;
                case "pbar":
                    r.rowBreakable = token.nextBoolean();
                    break;
                case "pbac":
                    r.colBreakables.add(token.nextInt());
                    break;
                default:
                    throw new ParseError("page break match error");
            }
            token.close();
        }
    }

    private List<BrCell> parseCells(BrRow r) {
        List<BrCell> cs = new ArrayList<>();
        while (token.hasNext()) {
            token.open();
            if (token.ping(4).equals("[pb")) {
                parsePageBreak(r);
                token.close();
                continue;
            }
            BrCell cell = new BrCell();
            cell.metaIndex = token.nextInt();
            cell.value = token.nextString();
            if (token.hasNext()) {
                cell.param = token.nextString();
            }
            token.close();
            cs.add(cell);
        }
        return cs;
    }

    private List<Integer> parseColumnWidths() {
        List<Integer> cs = new ArrayList<>();
        token.open();
        while (token.hasNext()) {
            String s = token.nextString();
            if (s != null && s.length() > 0) {
                cs.add(Integer.parseInt(s));
            } else {
                cs.add(0);
            }
        }
        token.close();
        return cs;
    }

    private List<String> parseColumnDataSources() {
        List<String> cs = new ArrayList<>();
        token.open();
        while (token.hasNext()) {
            String s = token.nextString();
            if (s != null && s.length() > 0) {
                cs.add(s);
            } else {
                cs.add("");
            }
        }
        token.close();
        return cs;
    }

    public List<Grouping> parseGroupings() {
        List<Grouping> rowGroupings = new ArrayList<>();
        List<Grouping> columnGroupings = new ArrayList<>();
        int rowIndex = 0, columnIndex = 0;

        token.open();
        while (token.hasNext()) {
            token.open();
            char position = token.nextChar();
            char type = token.nextChar();
            switch (position) {
                case 's':
                    switch (type) {
                        case 'r':
                            rowGroupings.add(new Grouping(type, token.nextInt(), token.nextBoolean()));
                            rowIndex = rowGroupings.size() - 1;
                            break;
                        case 'c':
                            columnGroupings.add(new Grouping(type, token.nextInt(), token.nextBoolean()));
                            columnIndex = columnGroupings.size() - 1;
                            break;
                    }
                    break;
                case 'e':
                    switch (type) {
                        case 'r':
                            rowGroupings.get(rowIndex).toIndex = token.nextInt();
                            rowIndex -= 1;
                            break;
                        case 'c':
                            columnGroupings.get(columnIndex).toIndex = token.nextInt();
                            columnIndex -= 1;
                            break;
                    }
                    break;
            }
            token.close();
        }
        token.close();

        rowGroupings.addAll(columnGroupings);

        return rowGroupings;
    }

    public List<GridContent> parseGridContents() {
        List<GridContent> gridContents = new ArrayList<>();
        int rowIndex;

        token.open();
        while (token.hasNext()) {
            token.open();
            String type = token.nextString();
            int index = token.nextInt();
            switch (type.charAt(1)) {
                case 'b':
                    gridContents.add(new GridContent(GridContent.getGridType(type.charAt(0)), index));
                    break;
                case 'e':
                    rowIndex = GridContent.lastGridTypeIndex(gridContents, type.charAt(0));
                    if (rowIndex >= 0) gridContents.get(rowIndex).toIndex = index;
                    break;
            }
            token.close();
        }
        token.close();

        return gridContents;
    }

    private BrSheet parseSheet() {
        BrSheet r = new BrSheet();
        while (token.hasNext()) {
            token.open();
            switch (token.nextString()) {
                case "name":
                    r.name = token.nextString();
                    break;
                case "table_id":
                    r.tableId = token.nextInt();
                    break;
                case "param":
                    r.param = token.nextString();
                    break;
                case "zoom":
                    r.zoom = token.nextInt();
                    break;
                case "no_gridlines":
                    r.noGridlines = token.nextBoolean();
                    break;
                case "split_horizontal":
                    r.splitHorizontal = token.nextInt();
                    break;
                case "split_vertical":
                    r.splitVertical = token.nextInt();
                    break;
                case "page_header":
                    r.pageHeader = token.nextDouble();
                    break;
                case "page_footer":
                    r.pageFooter = token.nextDouble();
                    break;
                case "page_top":
                    r.pageTop = token.nextDouble();
                    break;
                case "page_bottom":
                    r.pageBottom = token.nextDouble();
                    break;
                case "page_left":
                    r.pageLeft = token.nextDouble();
                    break;
                case "page_right":
                    r.pageRight = token.nextDouble();
                    break;
                case "fit_to_page":
                    r.fitToPage = token.nextBoolean();
                    break;
                case "landscape":
                    r.landscape = token.nextBoolean();
                    break;
                case "hidden":
                    r.hidden = token.nextBoolean();
                    break;
                case "wrap_merged_cells":
                    r.wrapMergedCells = token.nextBoolean();
                    break;
                default:
                    throw new ParseError("sheet option match error");
            }
            token.close();
        }
        return r;
    }

    private BrBookSetting parseSetting() {
        BrBookSetting r = new BrBookSetting();
        while (token.hasNext()) {
            token.open();
            switch (token.nextString()) {
                case "file_name":
                    r.filename = token.nextString();
                    break;
                case "report_type":
                    r.reportType = token.nextString();
                    break;
                case "url":
                    r.url = token.nextString();
                    break;
                case "context_path":
                    r.contextPath = token.nextString();
                    break;
                default:
                    throw new ParseError("setting match error");
            }
            token.close();
        }
        r.init();
        return r;
    }

    private List<BrFont> parseFonts() {
        List<BrFont> fs = new ArrayList<>();
        while (token.hasNext()) {
            fs.add(parseFont());
        }
        return fs;
    }

    private BrFont parseFont() {
        BrFont f = new BrFont();
        token.open();
        while (token.hasNext()) {
            token.open();
            switch (token.nextString()) {
                case "size":
                    f.size = token.nextInt();
                    break;
                case "color":
                    f.color = token.nextString();
                    break;
                case "family":
                    f.family = token.nextString();
                    break;
                case "bold":
                    f.bold = token.nextBoolean();
                    break;
                case "italic":
                    f.italic = token.nextBoolean();
                    break;
                case "underline":
                    f.underline = token.nextBoolean();
                    break;
                default:
                    throw new ParseError("parseFont match error");
            }
            token.close();
        }
        token.close();
        return f;
    }

    private List<BrStyle> parseStyles() {
        List<BrStyle> ss = new ArrayList<>();
        while (token.hasNext()) {
            ss.add(parseStyle());
        }
        return ss;
    }

    private BrStyle parseStyle() {
        BrStyle s = new BrStyle();
        token.open();
        while (token.hasNext()) {
            token.open();
            switch (token.nextString()) {
                case "font_index":
                    s.fontIndex = token.nextInt() - 1;
                    break;
                case "align":
                    s.align = token.nextInt();
                    break;
                case "valign":
                    s.valign = token.nextInt();
                    break;
                case "rotate":
                    s.rotate = (short) token.nextInt();
                    break;
                case "indent":
                    s.indent = (short) token.nextInt();
                    break;
                case "bg_color":
                    s.bgColor = token.nextString();
                    break;
                case "format":
                    s.format = token.nextString();
                    break;
                case "wrap":
                    s.wrap = token.nextBoolean();
                    break;
                case "shrink_to_fit":
                    s.shrinkToFit = token.nextBoolean();
                    break;
                case "b_top":
                    s.borderTop = token.nextString();
                    break;
                case "b_top_color":
                    s.borderTopColor = token.nextString();
                    break;
                case "b_bottom":
                    s.borderBottom = token.nextString();
                    break;
                case "b_bottom_color":
                    s.borderBottomColor = token.nextString();
                    break;
                case "b_left":
                    s.borderLeft = token.nextString();
                    break;
                case "b_left_color":
                    s.borderLeftColor = token.nextString();
                    break;
                case "b_right":
                    s.borderRight = token.nextString();
                    break;
                case "b_right_color":
                    s.borderRightColor = token.nextString();
                    break;
                default:
                    throw new ParseError("parseStyle match error");
            }
            token.close();
        }
        token.close();
        return s;
    }


    private List<BrCellMeta> parseCellMetas() {
        List<BrCellMeta> ms = new ArrayList<>();
        BrCellMeta meta = new BrCellMeta();
        meta.type = 'V';
        meta.init();
        ms.add(meta);
        while (token.hasNext()) {
            ms.add(parseCellMeta());
        }
        return ms;
    }

    private BrCellMeta parseCellMeta() {
        BrCellMeta m = new BrCellMeta();
        token.open();
        while (token.hasNext()) {
            token.open();
            switch (token.nextString()) {
                case "type":
                    m.type = token.nextChar();
                    break;
                case "style_index":
                    m.styleIndex = token.nextInt() - 1;
                    break;
                case "rowspan":
                    m.rowspan = token.nextInt();
                    break;
                case "colspan":
                    m.colspan = token.nextInt();
                    break;
                case "width":
                    m.width = token.nextInt();
                    break;
                case "height":
                    m.height = token.nextInt();
                    break;
                case "label":
                    m.label = token.nextBoolean();
                    break;
                case "menuIds":
                    m.menuIds = token.nextString();
                    break;
                default:
                    throw new ParseError("parseCellMeta match error");
            }
            token.close();
        }
        token.close();
        m.init();
        return m;
    }

}
