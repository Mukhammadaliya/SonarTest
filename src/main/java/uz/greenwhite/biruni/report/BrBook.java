package uz.greenwhite.biruni.report;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class BrBook {

    public BrBookSetting setting;
    public List<BrSheet> sheets;
    public List<BrFont> fonts;
    public List<BrStyle> styles;
    public List<BrCellMeta> cellMetas;
    public Map<Integer, BrTable> tables;
    public String menus;
    public boolean groupingExists = false;

    public void init() {
        if (setting == null) {
            setting = new BrBookSetting();
        }
        if (sheets == null) {
            sheets = new ArrayList<>();
        }
        if (fonts == null) {
            fonts = new ArrayList<>();
        }
        if (styles == null) {
            styles = new ArrayList<>();
        }
        if (cellMetas == null) {
            cellMetas = new ArrayList<>();
        }
        if (tables == null) {
            tables = new HashMap<>();
        }
        for (BrTable table : tables.values()) {
            table.cellMetas = cellMetas;
            table.init(tables);
        }
    }

}
