package uz.greenwhite.biruni.report;

public class Point {

    public int r;
    public int c;

    public Point(int r, int c) {
        this.r = r;
        this.c = c;
    }

    @Override
    public String toString() {
        return "P(" + r + "," + c + ")";
    }
}
