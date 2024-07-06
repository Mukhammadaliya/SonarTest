package uz.greenwhite.biruni.report;

import java.util.ArrayList;

public class SpanUtil {
    private final ArrayList<Col> cols = new ArrayList<>();

    private Col get(int pos) {
        for (int i = cols.size(); i <= pos; i++) {
            cols.add(new Col(0));
        }
        return cols.get(pos);
    }

    public void set(int pos, int count) {
        get(pos).count = count;
    }

    public void plus(int pos, int count) {
        Col c = get(pos);
        c.count += count;
    }

    public boolean has(int pos) {
        if (pos < cols.size()) {
            return cols.get(pos).count > 0;
        }
        return false;
    }

    public void decreaseSpans() {
        for (Col c : cols) {
            c.count = Math.max(0, c.count - 1);
        }
    }

    public boolean hasZeroSpan() {
        for (Col c : cols) {
            if (c.count == 0) {
                return true;
            }
        }
        return false;
    }

    public void fillZeroToOne() {
        for (Col c : cols) {
            c.count = Math.max(c.count, 1);
        }
    }

    public int maxRowSize() {
        int MR = 0;
        for (Col col : cols) MR = Math.max(MR, col.count);
        return MR;
    }

    public int maxColSize() {
        return cols.size();
    }

    public void clear() {
        for (Col c : cols) {
            c.count = 0;
        }
    }

    public String mkString() {
        StringBuilder sb = new StringBuilder();
        for (Col c : cols) {
            sb.append(c.count).append(',');
        }
        return sb.toString();
    }

    public static String mkString(int[] as) {
        StringBuilder sb = new StringBuilder("[");
        for (int c : as) {
            sb.append(c).append(',');
        }
        sb.append("]");
        return sb.toString();
    }

    static class Col {
        public int count;

        public Col(int count) {
            this.count = count;
        }
    }
}
