prompt biruni job
declare
  Procedure Job
  (
    i_Start_Time     varchar2,
    i_Procedure_Name varchar2
  ) is
  begin
    z_Biruni_Job_Daily_Procedures.Insert_Try(i_Start_Time     => i_Start_Time,
                                             i_Procedure_Name => i_Procedure_Name);
  end;
begin
  Job('02:00', 'Biruni_Easy_Report.Clean_Easy_Reports');
  Job('02:00', 'Biruni_Core.Bf_Cleaner');
  Job('03:00', 'Biruni_Core.Biruni_Url_Params_Cleaner');
  Job('03:00', 'Biruni_Core.Biruni_Log_Cleaner');
  Job('03:30', 'Biruni_Core.Lazy_Report_Cleaner');
  
  commit;
end;
/
