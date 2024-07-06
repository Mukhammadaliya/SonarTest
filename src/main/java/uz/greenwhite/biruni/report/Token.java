package uz.greenwhite.biruni.report;

public class Token {

    public final String s;
    private int k;
    private String val;

    public Token(String s) {
        this.s = s;
        this.k = 0;
    }

    private char next() {
        val = null;
        char cur = s.charAt(k);
        k++;
        if (cur == '\0') {
            int p = s.indexOf('\0', k);
            if (p == -1) {
                throw new ParseError("Report syntax value error");
            }
            val = s.substring(k, p);
            k = p + 1;
            return cur;
        } else if (cur == '[' || cur == ']') {
            val = null;
            return cur;
        }
        throw new ParseError("Report syntax token error");
    }

    private String value() {
        return val;
    }

    public void completed() {
        if (k != s.length()) {
            throw new ParseError("Source is not consumed completely");
        }
    }

    public void open() {
        char c = next();
        if (c != '[') {
            throw new ParseError(String.format("Expected [ Found \\u%04x, pos=%d", (int) c, k));
        }
    }

    public void close() {
        char c = next();
        if (c != ']') {
            throw new ParseError(String.format("Expected ] Found \\u%04x, pos=%d", (int) c, k));
        }
    }

    public String nextString() {
        char c = next();
        if (c == '\0') {
            return value();
        } else {
            throw new ParseError(String.format("Expected string Found \\u%04x, pos=%d", (int) c, k));
        }
    }

    public int nextInt() {
        return Integer.parseInt(nextString());
    }

    public double nextDouble() {
        return Double.parseDouble(nextString());
    }

    public boolean nextBoolean() {
        return "Y".equals(nextString());
    }

    public char nextChar() {
        String s = nextString();
        if (s.length() != 1) {
            throw new ParseError("Expected char token");
        }
        return s.charAt(0);
    }

    public boolean hasNext() {
        return s.charAt(k) != ']';
    }

    public String ping(int count) {
        return s.substring(k, k + count).replace("\0", "");
    }

}
