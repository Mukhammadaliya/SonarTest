package uz.greenwhite.biruni.json;

public class JsonToken {

    private int pos;
    private int len;
    private char[] elem;

    char kind;
    String st;

    public JsonToken(String json) {
        pos = 0;
        elem = json.toCharArray();
        len = elem.length;
    }

    public JsonError error() {
        return new JsonError(pos);
    }

    public boolean tryNext() {
        st = null;
        while (pos < len) {
            char ch = elem[pos++];
            if (!(ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r')) {
                if (ch == '"') {
                    st = parseString();
                }
                kind = ch;
                return true;
            }
        }
        return false;
    }

    public char next() {
        if (tryNext()) {
            return kind;
        }
        throw error();
    }

    private String parseString() {
        StringBuilder sb = new StringBuilder();
        char ch;
        while (pos < len) {
            ch = elem[pos++];
            if (ch == '"') {
                return sb.toString();
            } else if (ch == '\\') {
                if (pos < len) {
                    ch = elem[pos++];
                    switch (ch) {
                        case '"':
                            sb.append('"');
                            break;
                        case '\\':
                            sb.append('\\');
                            break;
                        case '/':
                            sb.append('/');
                            break;
                        case 'b':
                            sb.append((char) 8);
                            break;
                        case 't':
                            sb.append((char) 9);
                            break;
                        case 'r':
                            sb.append((char) 10);
                            break;
                        case 'f':
                            sb.append((char) 12);
                            break;
                        case 'n':
                            sb.append((char) 13);
                            break;
                    }
                } else {
                    break;
                }
            } else {
                sb.append(ch);
            }
        }
        throw error();
    }
}
