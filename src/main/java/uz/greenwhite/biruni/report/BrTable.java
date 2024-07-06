package uz.greenwhite.biruni.report;

import java.util.*;

public class BrTable {

    public int id;
    public List<BrRow> rows;
    public List<Integer> columnWidths;
    public List<String> columnDataSources;
    public List<Grouping> groupings;
    public List<GridContent> gridContents;

    // Variable values

    public int[] rowSizes;
    public int[] colSizes;

    public int totalRowSize = 0;
    public int totalColSize = 0;

    public List<BrCellMeta> cellMetas;

    private void setMetaAndTables(Map<Integer, BrTable> tables) {
        for (BrRow row : rows) {
            for (BrCell cell : row.cells) {
                cell.meta = cellMetas.get(cell.metaIndex);
                if (cell.isTypeTable()) {
                    cell.table = tables.get(Integer.parseInt(cell.value));
                }
                cell.colspan = cell.meta.colspan;
                cell.rowspan = cell.meta.rowspan;
            }
        }
    }

    private void initSpanUtil(SpanUtil su) {
        su.plus(0, 0);
        for (BrRow row : rows) {
            int c = 0;
            for (BrCell cell : row.cells) {
                while (su.has(c)) c++;

                for (int i = 0; i < cell.colspan; i++) {
                    su.plus(c + i, cell.rowspan);
                }
                c += cell.colspan;
            }
            su.fillZeroToOne();
            while (!su.hasZeroSpan()) {
                su.decreaseSpans();
            }
        }
        su.clear();
    }

    private void matchCellsLength(SpanUtil su) {
        for (BrRow row : rows) {
            int c = 0;
            for (BrCell cell : row.cells) {
                while (su.has(c)) c++;

                for (int i = 0; i < cell.colspan; i++) {
                    su.plus(c + i, cell.rowspan);
                }
                c += cell.colspan;
            }
            while (su.has(c)) c++;
            while (c < su.maxColSize()) {
                BrCell cell = new BrCell();
                cell.metaIndex = 0;
                cell.meta = cellMetas.get(cell.metaIndex);
                cell.colspan = cell.meta.colspan;
                cell.rowspan = cell.meta.rowspan;
                row.cells.add(cell);
                c++;
                while (su.has(c)) c++;
            }
            su.fillZeroToOne();
            while (!su.hasZeroSpan()) {
                su.decreaseSpans();
            }
        }
        su.clear();
    }

    private void fillPoints() {
        SpanUtil su = new SpanUtil();
        initSpanUtil(su);
        matchCellsLength(su);

        int r = 0;
        for (BrRow row : rows) {
            int c = 0;
            for (BrCell cell : row.cells) {
                while (su.has(c)) c++;
                cell.point = new Point(r, c);

                for (int i = 0; i < cell.colspan; i++) {
                    su.plus(c + i, cell.rowspan);
                }
                c += cell.colspan;
            }
            su.fillZeroToOne();
            while (!su.hasZeroSpan()) {
                su.decreaseSpans();
                r++;
            }
        }

        int MR = r + su.maxRowSize();
        int MC = su.maxColSize();

        rowSizes = new int[MR];
        colSizes = new int[MC];
        Arrays.fill(rowSizes, 1);
        Arrays.fill(colSizes, 1);
    }

    private void measure() {
        for (BrRow row : rows) {
            for (BrCell cell : row.cells) {
                int i = cell.point.r;
                int j = cell.point.c;
                if (cell.isTypeTable()) {
                    cell.table.measure();
                    rowSizes[i] = Math.max(rowSizes[i], cell.table.totalRowSize);
                    colSizes[j] = Math.max(colSizes[j], cell.table.totalColSize);
                }
            }
        }

        totalRowSize = 0;
        for (int s : rowSizes) {
            totalRowSize += s;
        }

        totalColSize = 0;
        for (int s : colSizes) {
            totalColSize += s;
        }
    }

    private int sum(int[] sizes, int start, int count) {
        int s = 0;
        for (int i = 0; i < count; i++) {
            s += sizes[start + i];
        }
        return s;
    }

    private void adjustColRowSpan() {
        for (BrRow row : rows) {
            for (BrCell cell : row.cells) {
                if (cell.isTypeTable()) {
                    cell.table.adjustColRowSpan();
                }
                cell.colspan = sum(colSizes, cell.point.c, cell.colspan);
                cell.rowspan = sum(rowSizes, cell.point.r, cell.rowspan);
            }
        }
        fillPoints();
    }

    private void fixGroupingsPosition(Point offset) {
        for (Grouping g : groupings) {
            switch (g.type) {
                case 'r':
                    g.fromIndex += offset.r;
                    g.toIndex += offset.r;
                    break;
                case 'c':
                    g.fromIndex += offset.c;
                    g.toIndex += offset.c;
                    break;
            }
        }
    }

    private void fixGroupingsRange(BrCell cell, Point offset, boolean isFirstRow, boolean isFirstColumn) {
        for (Grouping g : groupings) {
            switch (g.type) {
                case 'r':
                    if (isFirstColumn) {
                        if (g.fromIndex <= offset.r && offset.r <= g.toIndex) {
                            g.toIndex += cell.rowspan - 1;
                        } else if (offset.r < g.fromIndex) {
                            g.fromIndex += cell.rowspan - 1;
                            g.toIndex += cell.rowspan - 1;
                        }
                    }
                    break;
                case 'c':
                    if (isFirstRow) {
                        if (g.fromIndex <= offset.c && offset.c <= g.toIndex) {
                            g.toIndex += cell.colspan - 1;
                        } else if (offset.c < g.fromIndex) {
                            g.fromIndex += cell.colspan - 1;
                            g.toIndex += cell.colspan - 1;
                        }
                    }
                    break;
            }
        }
    }

    private void fixGridsPosition(Point offset) {
        for (GridContent gc : gridContents) {
            gc.fromIndex += offset.r;
            gc.toIndex += offset.r;
        }
    }

    private void fixGridsRange(BrCell cell, Point offset) {
        for (GridContent gc : gridContents) {
            if (gc.fromIndex > offset.r) {
                gc.fromIndex += cell.table.totalRowSize - 1;
                gc.toIndex += cell.table.totalRowSize - 1;
            } else if (offset.r <= gc.toIndex) {
                gc.toIndex += cell.table.totalRowSize - 1;
            }
        }
    }

    private void putInMatrix(Object[][] matrix, List<Grouping> allGroupings, List<GridContent> allGridContents, Point offset) {
        fixGroupingsPosition(offset);
        fixGridsPosition(offset);

        boolean isFirstRow = true, isFirstColumn, isGridRangeFixed;
        for (BrRow row : rows) {
            isFirstColumn = true;
            isGridRangeFixed = false;
            for (BrCell cell : row.cells) {
                Point p = new Point(offset.r + cell.point.r, offset.c + cell.point.c);
                if (isFirstRow || isFirstColumn) {
//                    fixGroupingsRange(cell, p, isFirstRow, isFirstColumn);
                    isFirstColumn = false;
                }
                if (matrix[p.r][p.c] != null) {
                    throw new RuntimeException("Matrix already is filled in given " + p);
                }
                if (cell.isTypeTable()) {
                    if (!isGridRangeFixed) {
                        fixGridsRange(cell, p);
                        isGridRangeFixed = true;
                    }
                    cell.table.putInMatrix(matrix, allGroupings, allGridContents, p);
                } else {
                    matrix[p.r][p.c] = cell;
                }
            }
            isFirstRow = false;
        }

        allGroupings.addAll(groupings);
        allGridContents.addAll(gridContents);
    }


    private void fillExtras() {
        int size = columnWidths.size() - 1;
        for (BrRow row : rows) {
            for (BrCell cell : row.cells) {
                cell.height = row.height;
                cell.width = size < cell.point.c ? 0 : columnWidths.get(cell.point.c);
            }
        }
    }

    public void init(Map<Integer, BrTable> tables) {
        setMetaAndTables(tables);
        fillPoints();
        fillExtras();
    }

    public Result unroll() {
        measure();

        Object[][] matrix = new Object[totalRowSize][totalColSize];
        List<Grouping> allGroupings = new ArrayList<>();
        List<GridContent> allGridContents = new ArrayList<>();
        Point offset = new Point(0, 0);
        adjustColRowSpan();
        putInMatrix(matrix, allGroupings, allGridContents, offset);

        Result r = new Result();
        r.matrix = matrix;
        r.columnWidths = new int[totalColSize];

        r.columnDataSources = new String[this.columnDataSources.size()];
        for (int i = 0; i < this.columnDataSources.size(); i++) {
            r.columnDataSources[i] = this.columnDataSources.get(i);
        }

        r.groupings = allGroupings;
        r.gridContents = allGridContents;
        r.rowHeights = new int[totalRowSize];

        for (int i = 0; i < totalRowSize; i++) {
            for (int j = 0; j < totalColSize; j++) {
                Object o = matrix[i][j];
                if (!(o instanceof BrCell)) {
                    continue;
                }
                BrCell cell = (BrCell) o;

                if (cell.rowspan > 1) {
                    for (int k = i; k < i + cell.rowspan; k++) {
                        r.rowHeights[k] = Math.max(r.rowHeights[k], cell.height / cell.rowspan);
                    }
                } else {
                    r.rowHeights[i] = Math.max(r.rowHeights[i], cell.height);
                }

                if (cell.colspan > 1) {
                    for (int k = j; k < j + cell.colspan; k++) {
                        r.columnWidths[k] = Math.max(r.columnWidths[k], cell.width / cell.colspan);
                    }
                } else {
                    r.columnWidths[j] = Math.max(r.columnWidths[j], cell.width);
                }
            }
        }

        return r;
    }

}
