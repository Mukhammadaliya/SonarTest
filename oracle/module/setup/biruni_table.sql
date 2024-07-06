prompt Biruni
prompt (c) 2012-2024 Green White Solutions. www.greenwhite.uz
----------------------------------------------------------------------------------------------------
create table biruni_translations(
  message                         varchar2(500 char) not null,
  text_en                         varchar2(4000 char),
  custom                          varchar2(1)        not null,
  constraint biruni_translations_pk primary key (message) using index tablespace GWS_INDEX,
  constraint biruni_translations_c1 check (decode(lower(trim(message)), message, 1, 0) = 1),
  constraint biruni_translations_c2 check (custom in ('Y', 'N'))
) tablespace GWS_DATA;

----------------------------------------------------------------------------------------------------
create table biruni_custom_translations(
  code                            varchar2(50)       not null,
  message                         varchar2(500 char) not null,
  text_en                         varchar2(4000 char),
  constraint biruni_custom_translations_pk primary key (code, message) using index tablespace GWS_INDEX,
  constraint biruni_custom_translations_c1 check (decode(lower(trim(message)), message, 1, 0) = 1)
) tablespace GWS_DATA;

----------------------------------------------------------------------------------------------------
create table biruni_generated_translations(
  message                             varchar2(500 char) not null,
  lang_code                           varchar2(5)        not null,
  constraint biruni_generated_translations_pk primary key (message, lang_code) using index tablespace GWS_INDEX
) tablespace GWS_DATA;

----------------------------------------------------------------------------------------------------
create table biruni_settings(
  code                            varchar2(1 char) not null,
  lang_code                       varchar2(5 char),
  authenticate_procedure          varchar2(80 char),
  check_session_procedure         varchar2(80 char),
  check_subscription_procedure    varchar2(80 char),
  authorize_form_procedure        varchar2(80 char),
  authorize_procedure             varchar2(80 char),
  review_procedure                varchar2(80 char),
  check_query_procedure           varchar2(80 char),
  review_file_procedure           varchar2(80 char),
  review_log_procedure            varchar2(80 char),
  review_route_history_procedure  varchar2(80 char),
  review_easy_report_procedure    varchar2(80 char),
  lazy_report_review_procedure    varchar2(80 char),
  lazy_report_init_procedure      varchar2(80 char),
  lazy_report_notify_procedure    varchar2(80 char),
  hms_token_save_procedure        varchar2(80 char),
  log_policy                      varchar2(12 char),
  log_time_limit                  number(9),
  job_enabled                     varchar2(1 char),
  job_max_workers                 number(3),
  job_interval_in_seconds         number(6),
  timezone_code                   varchar2(100),
  ip_policy_enabled               varchar2(1),
  service_available               varchar2(1),
  constraint biruni_settings_pk  primary key (code) using index tablespace GWS_INDEX,
  constraint biruni_settings_c1  check (code = 'U'),
  constraint biruni_settings_c2  check (regexp_like(lang_code, '^[a-z0-9_]+$')),
  constraint biruni_settings_c3  check (regexp_like(authenticate_procedure, '^[A-Za-z0-9_.]+$')),
  constraint biruni_settings_c4  check (regexp_like(check_session_procedure, '^[A-Za-z0-9_.]+$')),
  constraint biruni_settings_c5  check (regexp_like(authorize_form_procedure, '^[A-Za-z0-9_.]+$')),
  constraint biruni_settings_c6  check (regexp_like(authorize_procedure, '^[A-Za-z0-9_.]+$')),
  constraint biruni_settings_c7  check (regexp_like(review_procedure, '^[A-Za-z0-9_.]+$')),
  constraint biruni_settings_c8  check (regexp_like(check_query_procedure, '^[A-Za-z0-9_.]+$')),
  constraint biruni_settings_c9  check (regexp_like(review_file_procedure, '^[A-Za-z0-9_.]+$')),
  constraint biruni_settings_c10  check (regexp_like(review_log_procedure, '^[A-Za-z0-9_.]+$')),
  constraint biruni_settings_c11 check (regexp_like(review_route_history_procedure, '^[A-Za-z0-9_.]+$')),
  constraint biruni_settings_c12 check (regexp_like(review_easy_report_procedure, '^[A-Za-z0-9_.]+$')),
  constraint biruni_settings_c13 check (regexp_like(lazy_report_review_procedure, '^[A-Za-z0-9_.]+$')),
  constraint biruni_settings_c14 check (regexp_like(lazy_report_init_procedure, '^[A-Za-z0-9_.]+$')),
  constraint biruni_settings_c15 check (regexp_like(lazy_report_notify_procedure, '^[A-Za-z0-9_.]+$')),
  constraint biruni_settings_c16 check (regexp_like(hms_token_save_procedure, '^[A-Za-z0-9_.]+$')),
  constraint biruni_settings_c17 check (regexp_like(log_policy, '^(Si?)?(Ei?)?(Fi?)?(Ui?)?(Ri?)?(Ni?)?$')),
  constraint biruni_settings_c18 check (job_enabled = 'Y'),
  constraint biruni_settings_c19 check (job_max_workers > 0),
  constraint biruni_settings_c20 check (ip_policy_enabled in ('Y', 'N')),
  constraint biruni_settings_c21 check (service_available in ('Y', 'N'))
) tablespace GWS_DATA;

comment on column biruni_settings.authenticate_procedure  is 'calls when route access type is either Verify_Session or Authorize';
comment on column biruni_settings.check_session_procedure is 'calls when route access type is either Verify_Session or Authorize and checks user concurrent sessions';
comment on column biruni_settings.authorize_procedure     is 'calls when route access type is Authorize';
comment on column biruni_settings.review_procedure        is 'calls when route review is Yes';
comment on column biruni_settings.check_query_procedure   is 'calls when checking access for query columns';
comment on column biruni_settings.log_time_limit          is 'The maximum query execution time in MilliSecond. Queries slower than this will be logged';
comment on column biruni_settings.log_policy              is 'Success,Error,Fatal,Unauthenticated,Refused,Not found;(i)-Input';
comment on column biruni_settings.ip_policy_enabled       is '(Y)es, (N)o';
comment on column biruni_settings.service_available       is '(Y)es, (N)o';

----------------------------------------------------------------------------------------------------  
create table biruni_auth_settings(
  code                            varchar2(20)      not null,
  close_session_procedure         varchar2(80 char) not null,
  check_oauth2_request_procedure  varchar2(80 char) not null,
  auth_code_procedure             varchar2(80 char) not null,
  oauth2_access_token_procedure   varchar2(80 char) not null,
  api_access_token_procedure      varchar2(80 char) not null,
  refresh_token_procedure         varchar2(80 char) not null,
  constraint biruni_auth_settings_pk primary key (code) using index tablespace GWS_INDEX,
  constraint biruni_auth_settings_c1 check (code = 'U'),
  constraint biruni_auth_settings_c2 check (regexp_like(close_session_procedure, '^[A-Za-z0-9_.]+$')),
  constraint biruni_auth_settings_c3 check (regexp_like(check_oauth2_request_procedure, '^[A-Za-z0-9_.]+$')),
  constraint biruni_auth_settings_c4 check (regexp_like(auth_code_procedure, '^[A-Za-z0-9_.]+$')),
  constraint biruni_auth_settings_c5 check (regexp_like(oauth2_access_token_procedure, '^[A-Za-z0-9_.]+$')),
  constraint biruni_auth_settings_c6 check (regexp_like(api_access_token_procedure, '^[A-Za-z0-9_.]+$')),
  constraint biruni_auth_settings_c7 check (regexp_like(refresh_token_procedure, '^[A-Za-z0-9_.]+$'))
) tablespace GWS_DATA;

comment on column biruni_auth_settings.check_oauth2_request_procedure is 'Check auth_code request procedure, calls before gen auth_code procedure';
comment on column biruni_auth_settings.auth_code_procedure is 'Gen auth_code for OAUTH2 authorization procedure';
comment on column biruni_auth_settings.oauth2_access_token_procedure is 'Gen access_token for OAUTH2 authorization procedure';
comment on column biruni_auth_settings.api_access_token_procedure is 'Gen access_token for API authorization procedure';
comment on column biruni_auth_settings.refresh_token_procedure is 'Refresh access token procedure';

----------------------------------------------------------------------------------------------------
create table biruni_qlik_settings(
  code                            varchar2(20)      not null,
  open_session_procedure          varchar2(80 char) not null,
  validate_session_procedure      varchar2(80 char) not null,
  close_session_procedure         varchar2(80 char) not null,
  check_session_procedure         varchar2(80 char) not null,
  load_settings_procedure         varchar2(80 char) not null,
  load_data_procedure             varchar2(80 char) not null,
  constraint biruni_qlik_settings_pk primary key (code) using index tablespace GWS_INDEX,
  constraint biruni_qlik_settings_c1 check (code = 'U'),
  constraint biruni_qlik_settings_c2 check (regexp_like(open_session_procedure, '^[A-Za-z0-9_.]+$')),
  constraint biruni_qlik_settings_c3 check (regexp_like(validate_session_procedure, '^[A-Za-z0-9_.]+$')),
  constraint biruni_qlik_settings_c4 check (regexp_like(close_session_procedure, '^[A-Za-z0-9_.]+$')),
  constraint biruni_qlik_settings_c5 check (regexp_like(check_session_procedure, '^[A-Za-z0-9_.]+$')),
  constraint biruni_qlik_settings_c6 check (regexp_like(load_settings_procedure, '^[A-Za-z0-9_.]+$')),
  constraint biruni_qlik_settings_c7 check (regexp_like(load_data_procedure, '^[A-Za-z0-9_.]+$'))
) tablespace GWS_DATA;

comment on column biruni_qlik_settings.open_session_procedure is 'Saves opened Qlik session UUID';
comment on column biruni_qlik_settings.validate_session_procedure is 'Marks opened Qlik session as VALID';
comment on column biruni_qlik_settings.close_session_procedure is 'Closes Qlik session by session UUID';
comment on column biruni_qlik_settings.check_session_procedure is 'Checks whether Qlik session is binded to web session and is still open';
comment on column biruni_qlik_settings.load_settings_procedure is 'Loads Qlik settings: cert shas, cert password and qlik route';
comment on column biruni_qlik_settings.load_data_procedure is 'Loads Qlik Data: settings, user name, directory, cookie settings';

----------------------------------------------------------------------------------------------------
create table biruni_messaging_service_setting(
  code                           varchar2(1) not null,
  smtp_host                      varchar2(100),
  smtp_port                      number(10),
  smtp_from_name                 varchar2(500),
  smtp_from_address              varchar2(500),
  smtp_password                  varchar2(100),
  smtp_transport_strategy        varchar2(1),
  sms_service_url                varchar2(4000),
  sms_service_auth_key           varchar2(4000),
  constraint biruni_messaging_service_setting_pk primary key (code) using index tablespace GWS_INDEX,
  constraint biruni_messaging_service_setting_c1 check (code = 'U'),
  constraint biruni_messaging_service_setting_c2 check (smtp_transport_strategy in ('T','S','H'))
) tablespace GWS_DATA;

comment on column biruni_messaging_service_setting.smtp_from_name is 'Username which email sent from';
comment on column biruni_messaging_service_setting.smtp_from_address is 'Email address which email sent from';
comment on column biruni_messaging_service_setting.smtp_transport_strategy is '(T) => SMTP_TLS, (S) => SMTPS, (H) => SMTP';

----------------------------------------------------------------------------------------------------
create table biruni_routes(
  uri                             varchar2(200 char) not null,
  action_name                     varchar2(80 char)  not null,
  action_in                       varchar2(2 char),
  action_out                      varchar2(2 char),
  access_type                     varchar2(1 char)   not null,
  allowed_auth_types              varchar2(10),
  review                          varchar2(1 char),
  log_policy                      varchar2(12 char),
  log_time_limit                  number(9),
  scope                           varchar2(2),
  constraint biruni_routes_pk primary key (uri) using index tablespace GWS_INDEX,
  constraint biruni_routes_c1 check (decode(trim(uri), uri, 1, 0) = 1),
  constraint biruni_routes_c2 check (decode(trim(action_name), action_name, 1, 0) = 1),
  constraint biruni_routes_c3 check (action_in in ('M', 'L', 'A', 'V', 'JO', 'JA')),
  constraint biruni_routes_c4 check (action_out in ('M', 'L', 'A', 'V', 'JO', 'JA', 'Q', 'F', 'R', 'LR', 'LC')),
  constraint biruni_routes_c5 check (access_type in ('P', 'E', 'S', 'A')),
  constraint biruni_routes_c6 check (regexp_like(allowed_auth_types, '^(S,?)?(T,?)?(BR,?)?(BS?)?$')),
  constraint biruni_routes_c7 check (review = 'Y'),
  constraint biruni_routes_c8 check (regexp_like(log_policy, '^(Si?)?(Ei?)?(Fi?)?(Ui?)?(Ri?)?(Ni?)?$')),
  constraint biruni_routes_c9 check (scope in ('R', 'W', 'RW'))
) tablespace GWS_DATA;

comment on column biruni_routes.action_in          is 'M-hashmap, L-arraylist, A-array_varchar2, V-varchar2, JO-json_object_t, JA-json_array_t';
comment on column biruni_routes.action_out         is 'M-hashmap, L-arraylist, A-array_varchar2, V-varchar2, JO-json_object_t, JA-json_array_t, Q-fazo_query, F-fazo_file, R-runtime_service, LR-lazy_report, LC-lazy_report_convertor';
comment on column biruni_routes.access_type        is 'P-public, E-edit session, S-verify session, A-authorize';
comment on column biruni_routes.allowed_auth_types is 'S-session, T-token, BR-bearer auth, BS-basic auth. Multiple auth types joined with "," by order';
comment on column biruni_routes.review             is 'Y-Yes to review result';
comment on column biruni_routes.log_policy         is 'Success,Error,Fatal,Unauthenticated,Refused;Not found;(i)-Input';
comment on column biruni_routes.log_time_limit     is 'The maximum query execution time in MilliSecond. Queries slower than this will be logged';
comment on column biruni_routes.scope              is 'R-read, W-write';

----------------------------------------------------------------------------------------------------
create table biruni_log(
  log_id                          number(20) not null,
  status                          varchar2(3 char),
  test_query                      varchar2(4000),
  error_message                   varchar2(4000),
  detail                          varchar2(4000),
  executed_in                     number(9),
  created_on                      date,
  constraint biruni_log_pk primary key (log_id) using index tablespace GWS_DATA_LOG
) tablespace GWS_DATA_LOG;

alter table biruni_log nologging;

comment on column biruni_log.status      is 'Success,Error,Fatal,Unauthorized,Refused,Not found,Log manually;(i)-Input';
comment on column biruni_log.executed_in is 'in millisecond';

----------------------------------------------------------------------------------------------------
declare
v varchar2(4000) := '
create table biruni_log_inputs(
  log_id                          number(20) not null,
  request                         varchar2(4000),
  input                           clob,
  constraint biruni_log_inputs_pk primary key (log_id) using index tablespace GWS_DATA_LOG,
  constraint biruni_log_inputs_f1 foreign key (log_id) references biruni_log(log_id) on delete cascade
)
lob(input) store as biruni_log_details_input(index biruni_log_details_i1)
tablespace GWS_DATA_LOG
';
begin
  execute immediate v;
exception
  when others then
    if sqlcode = -955 then
      execute immediate v;
    else
      raise;
    end if;
end;
/

alter table biruni_log_inputs nologging;

----------------------------------------------------------------------------------------------------
create or replace view biruni_log_today as
select log_id,
       status,
       error_message,
       detail,
       test_query,
       executed_in,
       created_on
  from biruni_log t
 where t.created_on > trunc(sysdate)
 order by log_id desc
/

----------------------------------------------------------------------------------------------------
create table biruni_manual_log(
  log_id                          number(20) not null,
  origin                          varchar2(100),
  error_message                   varchar2(4000),
  detail                          varchar2(4000),
  executed_in                     number(9),
  created_on                      date,
  constraint biruni_manual_log_pk primary key (log_id) using index tablespace GWS_DATA_LOG
) tablespace GWS_DATA_LOG nologging;

comment on column biruni_manual_log.origin is 'Origin source of the log';
comment on column biruni_manual_log.executed_in is 'In millisecond';

----------------------------------------------------------------------------------------------------
create or replace view biruni_manual_log_today as
select *
  from biruni_manual_log
 where created_on > trunc(sysdate)
 order by log_id desc
/

----------------------------------------------------------------------------------------------------
create table biruni_final_service_log(
  log_id                          number(20) not null,
  log_date                        date,
  error_message                   varchar2(4000),
  constraint biruni_final_service_log_pk primary key (log_id) using index tablespace GWS_DATA_LOG
) tablespace GWS_DATA_LOG nologging;

----------------------------------------------------------------------------------------------------
create table biruni_job_daily_procedures(
  start_time                      varchar2(5)  not null,
  procedure_name                  varchar2(80) not null,
  constraint biruni_job_daily_procedures_pk primary key (start_time, procedure_name) using index tablespace GWS_INDEX,
  constraint biruni_job_daily_procedures_c1 check (regexp_like(start_time, '[0-2][0-9][:][0-5][0-9]')),
  constraint biruni_job_daily_procedures_c2 check (to_number(substr(start_time, 1, 2)) < 24)
) tablespace GWS_DATA;

----------------------------------------------------------------------------------------------------
create table biruni_job_once_procedures(
  id                              number(12)   not null,
  start_time                      date         not null,
  procedure_name                  varchar2(80) not null,
  procedure_args                  varchar2(4000),
  constraint biruni_job_once_procedures_pk primary key (id) using index tablespace GWS_INDEX
) tablespace GWS_DATA;

comment on column biruni_job_once_procedures.procedure_args is 'procedure_name must accept a varchar2 parameter if procedure_args is not null';

----------------------------------------------------------------------------------------------------
create table biruni_filespace(
  sha                             varchar2(64)                   not null,
  file_content                    blob                           not null,
  constraint biruni_filespace_pk primary key (sha) using index tablespace GWS_FILE_INDEX
) tablespace GWS_FILE_DATA nologging;

----------------------------------------------------------------------------------------------------
create table biruni_files(
  sha                             varchar2(64) not null,
  created_on                      date         not null,
  file_size                       number(20)   not null,
  store_kind                      varchar2(1)  not null,
  file_name                       varchar2(200 char),
  content_type                    varchar2(200),
  constraint biruni_files_pk primary key (sha) using index tablespace GWS_INDEX
) tablespace GWS_DATA;

comment on column biruni_files.store_kind is 'Indicates where the file was saved (D)atabase or (S)3 object storage';

----------------------------------------------------------------------------------------------------
create table biruni_file_links(
  sha                             varchar2(64)   not null,
  kind                            varchar2(1)    not null,
  access_link                     varchar2(1000) not null,
  link_expires_on                 date           not null,
  constraint biruni_file_links_pk primary key (sha, kind) using index tablespace GWS_INDEX
) tablespace GWS_DATA;

comment on column biruni_file_links.kind is '(L)oad - view mode, (D)ownload - download mode';
comment on column biruni_file_links.access_link is 'Link to download file, not null if file stored in S3 object storage';

----------------------------------------------------------------------------------------------------
create table biruni_files_to_delete(
  sha                             varchar2(64) not null,
  status                          varchar2(1)  not null,
  constraint biruni_files_to_delete_pk primary key (sha) using index tablespace GWS_INDEX,
  constraint biruni_files_to_delete_c1 check (status in ('N', 'D', 'F'))
) tablespace GWS_DATA;

comment on table biruni_files_to_delete is 'This table stores file shas which should be deleted from S3';
comment on column biruni_files_to_delete.status is '(N)ew, (D)eleting, (F)ailed to delete';

create bitmap index biruni_files_to_delete_i1 on biruni_files_to_delete(status) tablespace GWS_INDEX;

----------------------------------------------------------------------------------------------------
create table biruni_file_desolates(
  sha                             varchar2(64) not null,
  desolate_procedure              varchar2(80) not null,
  constraint biruni_file_desolates_pk primary key (sha, desolate_procedure) using index tablespace GWS_INDEX
) tablespace GWS_DATA;

----------------------------------------------------------------------------------------------------
create table biruni_watchers(
  watching_expr                   varchar2(80) not null,
  watcher_procedure               varchar2(80) not null,
  order_no                        number(5)    not null,
  constraint biruni_watchers_pk primary key (watching_expr, watcher_procedure) using index tablespace GWS_INDEX,
  constraint biruni_watchers_c1 check (regexp_like(watching_expr, '^[a-z0-9_.]+$')),
  constraint biruni_watchers_c2 check (regexp_like(watcher_procedure, '^[a-z0-9_.]+'))
) tablespace GWS_DATA;

----------------------------------------------------------------------------------------------------
create table biruni_ip_ranges(
  order_no                        number(9)    not null,
  ip_begin                        varchar2(15) not null,
  ip_end                          varchar2(15) not null,
  value_begin                     number(15)   not null,
  value_end                       number(15)   not null,
  action                          varchar2(1)  not null,
  state                           varchar2(1)  not null,
  note                            varchar2(100 char),
  constraint biruni_ip_ranges_pk primary key (order_no) using index tablespace GWS_INDEX,
  constraint biruni_ip_ranges_c1 check (action in ('P', 'D')),
  constraint biruni_ip_ranges_c2 check (state in ('A', 'P'))
) tablespace GWS_DATA;

comment on column biruni_ip_ranges.action is '(P)ermit, (D)eny';

----------------------------------------------------------------------------------------------------
create table biruni_oauth2_servers(
  code                            varchar2(20)       not null,
  name                            varchar2(200 char) not null,
  client_id                       varchar2(200)      not null,
  client_secret                   varchar2(200)      not null,
  scope                           varchar2(200)      not null,
  authorize_url                   varchar2(500)      not null,
  redirect_uri                    varchar2(500)      not null,
  logo_sha                        varchar2(64),
  apply_procedure                 varchar2(80 char)  not null,
  constraint biruni_oauth2_servers_pk primary key (code) using index tablespace GWS_INDEX,
  constraint biruni_oauth2_servers_f1 foreign key (logo_sha) references biruni_files(sha)
) tablespace GWS_DATA;

create index biruni_oauth2_servers_i1 on biruni_oauth2_servers(logo_sha) tablespace GWS_INDEX;

----------------------------------------------------------------------------------------------------
create table biruni_oauth2_logs(
  log_date                        date not null,
  code                            varchar2(20),
  request                         varchar2(4000),
  error                           varchar2(500 char)
) tablespace GWS_DATA_LOG;

----------------------------------------------------------------------------------------------------
create table biruni_application_server_jobs(
  code                            varchar2(20)  not null,
  class_name                      varchar2(120) not null,
  request_procedure               varchar2(120),
  response_procedure              varchar2(120),
  start_time                      number(20),
  period                          number(20)    not null,
  state                           varchar2(1)   not null,
  constraint biruni_application_server_jobs_pk primary key (code) using index tablespace GWS_INDEX,
  constraint biruni_application_server_jobs_c1 check (decode(trim(request_procedure), request_procedure, 1, 0) = 1),
  constraint biruni_application_server_jobs_c2 check (decode(trim(response_procedure), response_procedure, 1, 0) = 1),
  constraint biruni_application_server_jobs_c3 check (start_time >= 0 and start_time < 1440),
  constraint biruni_application_server_jobs_c4 check (period > 0 and period <= 1440)
) tablespace GWS_DATA;

comment on column biruni_application_server_jobs.start_time is 'this time is measured by minutes, if value is empty then job starts momentium';
comment on column biruni_application_server_jobs.period is 'measured by minutes';

----------------------------------------------------------------------------------------------------
create table biruni_app_server_job_logs(
  log_id                          number(20)   not null,
  code                            varchar2(20) not null,
  status                          varchar2(1)  not null,
  log_date                        date         not null,
  failed_in                       varchar2(2),
  error_message                   varchar2(500),
  constraint biruni_app_server_job_logs_pk primary key(log_id) using index tablespace GWS_DATA_LOG,
  constraint biruni_app_server_job_logs_c1 check (status in ('S', 'F')),
  constraint biruni_app_server_job_logs_c2 check (failed_in in ('RQ', 'RS', 'JB'))
) tablespace GWS_DATA_LOG nologging;

create index biruni_app_server_job_logs_i1 on biruni_app_server_job_logs(code) tablespace GWS_DATA_LOG;

comment on column biruni_app_server_job_logs.status is 'S-success, F-fail';
comment on column biruni_app_server_job_logs.failed_in is 'RQ-REQUEST_PROCEDURE, RS-RESPONSE_PROCEDURE, JB-JOB_PROVIDER';

----------------------------------------------------------------------------------------------------
create table biruni_app_server_exceptions(
  log_id                          number(20) not null,
  source_class                    varchar2(100),
  detail                          varchar2(4000),
  stacktrace                      clob,
  created_on                      date,
  constraint biruni_app_server_exceptions_pk primary key(log_id) using index tablespace GWS_DATA_LOG
) tablespace GWS_DATA_LOG nologging;

comment on table biruni_app_server_exceptions is 'Stores errors thrown from application server';

----------------------------------------------------------------------------------------------------
create or replace view biruni_app_server_exceptions_today as
select *
  from biruni_app_server_exceptions
 where created_on > trunc(sysdate)
 order by log_id desc
/

----------------------------------------------------------------------------------------------------
create table biruni_easy_report_templates(
  sha                             varchar2(64) not null,
  metadata                        clob         not null,
  definition                      clob         not null,
  version                         varchar2(10) not null,
  constraint biruni_easy_report_templates_pk primary key(sha) using index tablespace GWS_INDEX
) tablespace GWS_DATA;

---------------------------------------------------------------------------------------------------
create table biruni_easy_report_template_photos(
  sha                             varchar2(64) not null,
  photo_sha                       varchar2(64) not null,
  constraint biruni_easy_report_template_photos_pk primary key (sha, photo_sha) using index tablespace GWS_INDEX,
  constraint biruni_easy_report_template_photos_f1 foreign key (sha) references biruni_easy_report_templates(sha) on delete cascade,
  constraint biruni_easy_report_template_photos_f2 foreign key (photo_sha) references biruni_files(sha)
) tablespace GWS_DATA;

create index biruni_easy_report_template_photos_i1 on biruni_easy_report_template_photos(photo_sha) tablespace GWS_INDEX;
create index biruni_easy_report_template_photos_i2 on biruni_easy_report_template_photos(sha) tablespace GWS_INDEX;

---------------------------------------------------------------------------------------------------
create table biruni_easy_report_generated_files(
  sha                             varchar2(64) not null,
  constraint biruni_easy_report_generated_files_pk primary key (sha) using index tablespace GWS_INDEX,
  constraint biruni_easy_report_generated_files_f1 foreign key (sha) references biruni_files(sha)
) tablespace GWS_DATA;

----------------------------------------------------------------------------------------------------
create table biruni_url_params(
  sha                             varchar2(40) not null,
  params                          clob         not null,
  modified_on                     date         not null,
  constraint biruni_url_params_pk primary key (sha) using index tablespace GWS_INDEX
) tablespace GWS_DATA nologging;

comment on table biruni_url_params is 'Request URL params. Used when GET request params are too large';

----------------------------------------------------------------------------------------------------
create table biruni_eimzo_api_keys(
  domain_name                     varchar2(100) not null,
  api_key                         varchar2(200) not null,
  constraint biruni_eimzo_api_keys_pk primary key (domain_name) using index tablespace GWS_INDEX
) tablespace GWS_DATA;

comment on table biruni_url_params is 'Stores e-imzo api keys for specific domain';

----------------------------------------------------------------------------------------------------
create table biruni_lazy_report_register(
  register_id                     number(20)     not null,
  status                          varchar2(1)    not null,
  request_uri                     varchar2(200)  not null,
  run_procedure                   varchar2(4000) not null,
  input_data                      clob,
  file_sha                        varchar2(64),
  html_sha                        varchar2(64),
  has_metadata                    varchar2(1)    not null,
  error_message                   varchar2(4000),
  error_backtrace                 varchar2(4000),
  created_on                      date           not null,
  constraint biruni_lazy_report_register_pk primary key (register_id) using index tablespace GWS_INDEX,
  constraint biruni_lazy_report_register_f1 foreign key (file_sha) references biruni_files(sha),
  constraint biruni_lazy_report_register_f2 foreign key (html_sha) references biruni_files(sha),
  constraint biruni_lazy_report_register_c1 check(status in ('N', 'E', 'C', 'F')),
  constraint biruni_lazy_report_register_c2 check(has_metadata in ('Y', 'N'))
) tablespace GWS_DATA;

comment on column biruni_lazy_report_register.status is '(N)ew, (E)xecuting, (C)ompleted, (F)ailed';

create index biruni_lazy_report_register_i1 on biruni_lazy_report_register(file_sha) tablespace GWS_INDEX;
create index biruni_lazy_report_register_i2 on biruni_lazy_report_register(html_sha) tablespace GWS_INDEX;

----------------------------------------------------------------------------------------------------
create table biruni_lazy_report_metadata(
  register_id                     number(20) not null,
  metadata                        clob       not null,
  constraint biruni_lazy_report_metadata_pk primary key (register_id) using index tablespace GWS_INDEX,
  constraint biruni_lazy_report_metadata_f1 foreign key (register_id) references biruni_lazy_report_register(register_id) on delete cascade
) tablespace GWS_DATA;

comment on table biruni_lazy_report_metadata is 'Stores generated metadata from Lazy Report';
comment on column biruni_lazy_report_metadata.metadata is 'Report data from which HTML or EXCEL can be generated';

----------------------------------------------------------------------------------------------------
create global temporary table biruni_report_lines(
  table_id                        number(9)      not null,
  order_no                        number(9)      not null,
  line                            varchar2(4000) not null
);

create index biruni_report_lines_i1 on biruni_report_lines(table_id);

----------------------------------------------------------------------------------------------------
create global temporary table biruni_anti_commit(
  dummy                           varchar2(1) not null,
  constraint biruni_anti_commit_pk primary key (dummy),
  constraint biruni_anti_commit_c1 check (dummy is null) deferrable initially deferred
);

