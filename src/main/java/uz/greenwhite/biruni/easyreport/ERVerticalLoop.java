package uz.greenwhite.biruni.easyreport;

public class ERVerticalLoop {
    private String key;

    private int startRownum;
    private int endRownum;

    public ERVerticalLoop(String key, int startRowNum) {
        this.key = key;
        this.startRownum = startRowNum;
        this.endRownum = -1;
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
}