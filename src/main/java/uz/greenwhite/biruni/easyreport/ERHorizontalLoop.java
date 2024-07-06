package uz.greenwhite.biruni.easyreport;

public class ERHorizontalLoop {
    private String key;

    private int startRownum;
    private int endRownum;
    private int startColnum;
    private int endColnum;

    public ERHorizontalLoop(String key, int startRowNum, int startColNum) {
        this.key = key;
        this.startRownum = startRowNum;
        this.endRownum = -1;
        this.startColnum = startColNum;
        this.endColnum = -1;
    }

    public String getKey() {
        return key;
    }

    public void setKey(String key) {
        this.key = key;
    }

    public int getStartRownum() {
        return startRownum;
    }

    public void setStartRownum(int startRownum) {
        this.startRownum = startRownum;
    }

    public int getEndRownum() {
        return endRownum;
    }

    public void setEndRownum(int endRownum) {
        this.endRownum = endRownum;
    }

    public int getStartColnum() {
        return startColnum;
    }

    public void setStartColnum(int startColnum) {
        this.startColnum = startColnum;
    }

    public int getEndColnum() {
        return endColnum;
    }

    public void setEndColnum(int endColnum) {
        this.endColnum = endColnum;
    }
}