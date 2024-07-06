prompt ==== **start table biruni** ====
@@module\setup\biruni_table.sql;
@@module\setup\biruni_sequenc.sql;
@@module\setup\biruni.pck;

exec fazo_z.run('biruni');

@@start.sql;
@@module\setup\biruni_setting.sql;
