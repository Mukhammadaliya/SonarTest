biruni.constant('bRoutes', {
  LOGIN                         : 'b/core/s$log_in',
  LOGOUT                        : 'b/core/m$logout',
  LOGOUT_AND_FORGET             : 'b/core/m$logout_and_forget',
  CHECK_SESSION                 : 'b/core/s$check_session',
  SAVE_FILE                     : 'b/core/m:save_temp_file',
  LOAD_FILE                     : 'b/core/m:load_file_v2',
  LOAD_IMAGE                    : 'b/core/m:load_image_v2?_v=1', // (_v=version) cache-busting
  DOWNLOAD_FILE                 : 'b/core/m:download_file_v2',
  PREFERENCES_CLEAR             : 'b/core/m:preferences_clear',
  FAVORITE                      : 'b/core/m:favorite',
  NOTIFICATIONS                 : 'b/core/m:notifications',
  ALERTS                        : 'b/core/m:alerts',
  SESSION                       : 'b/core/m:session',
  SESSION_INFO                  : 'util/session_info',
  LOAD_GRID_DATA                : 'b/core/m:load_grid_data',
  LOAD_USER_SETTING             : 'b/core/m:load_user_setting',
  SAVE_USER_SETTING             : 'b/core/m:save_user_setting',
  LOAD_USER_LARGE_SETTING       : 'b/core/m:load_user_large_setting',
  SAVE_USER_LARGE_SETTING       : 'b/core/m:save_user_large_setting',
  SEARCH_INFO                   : 'b/core/m:search_info',
  SEARCH_FORM_QUERY             : '/core/m:search_form_query',
  SEARCH_BARCODE_QUERY          : '/core/m:search_barcode_query',
  SEARCH_QUERY                  : '/core/m:search_query',
  LOAD_CUSTOM_HTML_TRANSLATIONS : 'b/core/m:load_custom_html_translations',
  UPLOAD_URL_PARAMS             : '/core/m:upload_url_params',
  SEND_FEEDBACK                 : 'b/core/m:send_feedback',
  LOAD_EIMZO_API_KEY            : 'b/core/m:load_eimzo_api_key',
  FILE_EXISTS                   : 'b/core/m:file_exists',
  FRESHCHAT_USER_UPDATE         : 'b/core/m:freshchat_user_update',
  QLIK_AUTH                     : 'qlik_session',
  RUN_ONLYOFFICE                : '/core/m:run_onlyoffice',
});