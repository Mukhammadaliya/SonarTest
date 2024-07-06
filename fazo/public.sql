--
grant execute on FAZO_SCHEMA.W_ARRAY_VARCHAR2 to public;
grant execute on FAZO_SCHEMA.W_ARRAY_NUMBER to public;
grant execute on FAZO_SCHEMA.W_ARRAY_DATE to public;
grant execute on FAZO_SCHEMA.W_ARRAY_TIMESTAMP to public;
--
grant execute on FAZO_SCHEMA.W_WRAPPER to public;
grant execute on FAZO_SCHEMA.W_ARRAY_WRAPPER to public;
grant execute on FAZO_SCHEMA.W_CALC_BUCKET_ARRAY to public;
grant execute on FAZO_SCHEMA.W_COLUMN_NAME to public;
grant execute on FAZO_SCHEMA.W_TABLE_NAME to public;
--
grant execute on FAZO_SCHEMA.OPTION_VARCHAR2 to public;
grant execute on FAZO_SCHEMA.OPTION_NUMBER to public;
grant execute on FAZO_SCHEMA.OPTION_DATE to public;
grant execute on FAZO_SCHEMA.OPTION_TIMESTAMP to public;
--
grant execute on FAZO_SCHEMA.ARRAY_VARCHAR2 to public;
grant execute on FAZO_SCHEMA.ARRAY_NUMBER to public;
grant execute on FAZO_SCHEMA.ARRAY_DATE to public;
grant execute on FAZO_SCHEMA.ARRAY_TIMESTAMP to public;
--
grant execute on FAZO_SCHEMA.MATRIX_VARCHAR2 to public;
grant execute on FAZO_SCHEMA.MATRIX_NUMBER to public;
grant execute on FAZO_SCHEMA.MATRIX_DATE to public;
grant execute on FAZO_SCHEMA.MATRIX_TIMESTAMP to public;
--
grant execute on FAZO_SCHEMA.STREAM to public;
grant execute on FAZO_SCHEMA.FAZO_UTIL to public;
grant execute on FAZO_SCHEMA.FAZO_GEN to public;
grant execute on FAZO_SCHEMA.FAZO_ENV to public;
grant execute on FAZO_SCHEMA.FAZO_Z to public;
grant execute on FAZO_SCHEMA.FAZO to public;
grant execute on FAZO_SCHEMA.FAZO_AES to public;
grant execute on FAZO_SCHEMA.GWS_JSON_VALUE to public;
--
grant execute on FAZO_SCHEMA.CALC_ENTRY to public;
grant execute on FAZO_SCHEMA.CALC_BUCKET to public;
grant execute on FAZO_SCHEMA.CALC to public;
--
grant execute on FAZO_SCHEMA.ARRAYLIST to public;
grant execute on FAZO_SCHEMA.HASH_ENTRY to public;
grant execute on FAZO_SCHEMA.HASH_BUCKET to public;
grant execute on FAZO_SCHEMA.HASHMAP to public;
--
grant execute on FAZO_SCHEMA.GLIST to public;
grant execute on FAZO_SCHEMA.GMAP to public;
--
grant execute on FAZO_SCHEMA.FAZO_QUERY to public;
grant execute on FAZO_SCHEMA.FAZO_FILE to public;
grant execute on FAZO_SCHEMA.EXCEL_SHEET to public;
grant execute on FAZO_SCHEMA.ROUND_MODEL to public;

grant execute on SYS.SCHED$_LOG_ON_ERRORS_CLASS to public;

--
create or replace public synonym OPTION_VARCHAR2       for FAZO_SCHEMA.OPTION_VARCHAR2;
create or replace public synonym OPTION_NUMBER         for FAZO_SCHEMA.OPTION_NUMBER;
create or replace public synonym OPTION_DATE           for FAZO_SCHEMA.OPTION_DATE;
create or replace public synonym OPTION_TIMESTAMP      for FAZO_SCHEMA.OPTION_TIMESTAMP;
--
create or replace public synonym ARRAY_VARCHAR2        for FAZO_SCHEMA.ARRAY_VARCHAR2;
create or replace public synonym ARRAY_NUMBER          for FAZO_SCHEMA.ARRAY_NUMBER;
create or replace public synonym ARRAY_DATE            for FAZO_SCHEMA.ARRAY_DATE;
create or replace public synonym ARRAY_TIMESTAMP       for FAZO_SCHEMA.ARRAY_TIMESTAMP;
--
create or replace public synonym MATRIX_VARCHAR2       for FAZO_SCHEMA.MATRIX_VARCHAR2;
create or replace public synonym MATRIX_NUMBER         for FAZO_SCHEMA.MATRIX_NUMBER;
create or replace public synonym MATRIX_DATE           for FAZO_SCHEMA.MATRIX_DATE;
create or replace public synonym MATRIX_TIMESTAMP      for FAZO_SCHEMA.MATRIX_TIMESTAMP;
--
create or replace public synonym STREAM                for FAZO_SCHEMA.STREAM;
create or replace public synonym FAZO_GEN              for FAZO_SCHEMA.FAZO_GEN;
create or replace public synonym FAZO_ENV              for FAZO_SCHEMA.FAZO_ENV;
create or replace public synonym FAZO_Z                for FAZO_SCHEMA.FAZO_Z;
create or replace public synonym FAZO                  for FAZO_SCHEMA.FAZO;
create or replace public synonym FAZO_AES              for FAZO_SCHEMA.FAZO_AES;
create or replace public synonym GWS_JSON_VALUE        for FAZO_SCHEMA.GWS_JSON_VALUE;
--
create or replace public synonym CALC_ENTRY            for FAZO_SCHEMA.CALC_ENTRY;
create or replace public synonym CALC_BUCKET           for FAZO_SCHEMA.CALC_BUCKET;
create or replace public synonym CALC                  for FAZO_SCHEMA.CALC;
--
create or replace public synonym ARRAYLIST             for FAZO_SCHEMA.ARRAYLIST;
create or replace public synonym HASH_ENTRY            for FAZO_SCHEMA.HASH_ENTRY;
create or replace public synonym HASH_BUCKET           for FAZO_SCHEMA.HASH_BUCKET;
create or replace public synonym HASHMAP               for FAZO_SCHEMA.HASHMAP;
--
create or replace public synonym GLIST                 for FAZO_SCHEMA.GLIST;
create or replace public synonym GMAP                  for FAZO_SCHEMA.GMAP;
--
create or replace public synonym FAZO_QUERY            for FAZO_SCHEMA.FAZO_QUERY;
create or replace public synonym FAZO_FILE             for FAZO_SCHEMA.FAZO_FILE;
create or replace public synonym EXCEL_SHEET           for FAZO_SCHEMA.EXCEL_SHEET;
create or replace public synonym ROUND_MODEL           for FAZO_SCHEMA.ROUND_MODEL;
