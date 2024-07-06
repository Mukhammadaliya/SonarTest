package uz.greenwhite.biruni.report;

import java.util.ArrayList;
import java.util.List;

public class BrRow {

    public int height = 0;
    public boolean rowBreak = false;
    public boolean rowBreakable = false;
    public List<Integer> colBreaks = new ArrayList<>();
    public List<Integer> colBreakables = new ArrayList<>();
    public List<BrCell> cells;

}
