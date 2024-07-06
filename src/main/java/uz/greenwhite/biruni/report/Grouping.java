package uz.greenwhite.biruni.report;

public class Grouping {
    public char type;
    public int fromIndex;
    public int toIndex;
    public boolean show;

    public Grouping(char type, int fromIndex, boolean show) {
        this.type = type;
        this.fromIndex = fromIndex;
        this.show = show;
    }
}
