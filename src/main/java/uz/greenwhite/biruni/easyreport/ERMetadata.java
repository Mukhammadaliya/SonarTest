package uz.greenwhite.biruni.easyreport;

import org.jetbrains.annotations.NotNull;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

public class ERMetadata implements Iterable<ERSheet> {
    private List<ERSheet> sheets;

    {
        sheets = new ArrayList<>();
    }

    public List<ERSheet> getSheets() {
        return sheets;
    }

    public void setSheets(List<ERSheet> sheets) {
        this.sheets = sheets;
    }

    public ERSheet getSheet(int index) {
        return sheets.get(index);
    }

    public void addSheet(ERSheet sheet) {
        sheets.add(sheet);
    }

    @NotNull
    @Override
    public Iterator<ERSheet> iterator() {
        return sheets.iterator();
    }
}
