app.factory('AppSearch', function($http, bConfig, AppSession, AppHotkey, bRoutes, bHttp, bQuery, bFrame, bRequire, $timeout) {
  const search = {
    // used inside
    info: {},
    elem: $('#search-content'),
    opened: false,
    moment: '',
    result_index: 0,
    max_limit: 0,
    result_rows: $(''),
    // used outside
    ready: false,
    searching: false,
    header: '',
    headers: [],
    value: '',
    sources: [],
    searchKeyDown: searchKeyDown,
    getAllResultsLength: getAllResultsLength,
    resetSearchValue: resetSearchValue,
    openSearch: openSearch,
    closeSearch: closeSearch,
    openBarcode: openBarcode,
    closeBarcode: closeBarcode,
    changeSearchValue: changeSearchValue,
    selectHeader: selectHeader,
    sourceOpen: sourceOpen,
    showMore: showMore,
  };

  bConfig.closeSearch = search.closeSearch;
  let scannerDetectionLoaded = false;

  AppSession.registerSetFilialObserver(function(data) {
    prepareSearchInfo(data.project_code);
  });

  function prepareSearchInfo(project_code) {
    if (!search.info[project_code]) {
      search.info[project_code] = [];

      $http.post(bRoutes.SEARCH_INFO, null).then(function(result) {
        search.info[project_code] = _.map(result.data.sources, function(x) {
          let data = {
            name: x.name,
            code: x.source_code,
            enabled: true,
            open: function(data) {
              bFrame.open(x.form, _.object([x.field_id], [data[x.field_id]]));
            },
            field_name: x.field_name,
            view_fields: _.mapRows(x.view_fields, ['key', 'value'])
          };

          let column = _.union([x.field_id, x.field_name], x.search_fields, _.pluck(x.view_fields, 'key'));

          data.query = bQuery(bRoutes.SEARCH_QUERY)
            .column(column)
            .param({source_code: x.source_code})
            .searchFields(x.search_fields)
            .sort(data.field_name)
            .limit(5);

          return data;
        });

        // Forms
        let data = {
          name: bConfig.langs.sb_result_forms,
          code: 'forms',
          enabled: true,
          open: function(data) {
            bFrame.open(data.form);
          },
          field_name: 'name',
          view_fields: []
        };
        data.query = bQuery(bRoutes.SEARCH_FORM_QUERY)
          .column('form', 'name', 'code')
          .searchFields('form', 'name', 'code')
          .limit(10);

        search.info[project_code].unshift(data);

        // Barcodes
        data = {
          name: '',
          code: 'barcodes',
          enabled: true,
          custom_search: true,
          open: function(data) {
            bFrame.open(data.form, _.object([data.id_field], [data.id]));
          },
          field_name: 'name',
          view_fields: []
        };
        data.query = bQuery(bRoutes.SEARCH_BARCODE_QUERY).column('name', 'id', 'id_field', 'form');

        search.info[project_code].unshift(data);

        setSearch(project_code);
      });
    } else {
      setSearch(project_code);
    }
  }

  function setSearch(project_code) {
    if (search.project_code === project_code) return;

    search.project_code = project_code;
    search.sources = search.info[project_code] || [];
    search.headers = [];
    _.each(search.sources, function(x) {
      if (!x.custom_search) {
        search.headers.push(_.pick(x, 'code', 'name'));
      }
    });
    search.headers.unshift({
      code: '',
      name: bConfig.langs.sb_result_all
    });
  }

  function selectHeader(code) {
    search.header = code;
    $timeout(function() {
      search.result_rows = search.elem.find('.cursor-row');
      search.max_limit = search.result_rows.length - 1;
      search.result_index = 0;
      scrollToIndex();
    });
  }

  function getAllResultsLength() {
    if (search.sources && search.sources.length) {
      return search.sources.reduce((acc, cur) => (cur?.result?.length ?? 0) + acc, 0);
    }
    return 0;
  }

  function resetSearchValue() {
    search.value = "";
    onChangeSearchValue();
  }

  function searchUpdateResult(source, ignore_indexing, moment, is_barcode) {
    bHttp.unblockOnce();
    source.query.pageNo(source.pageNo);
    source.query.fetch().then(function(result) {
      search.searching = false;

      if (search.moment != moment || !source.enabled) return;
      source.maxPage = result.maxPage;
      source.pageNo = source.query.pageNo();
      source.hasMore = source.maxPage > source.pageNo;
      source.result = _.union(source.result, result.table);
      source.hasResult = source.result.length > 0;

      if (is_barcode) {
        if (source.result.length === 1) {
          search.sourceOpen(source, source.result[0]);
        } else {
          search.no_barcode_result = true;
        }
      } else {
        _.each(source.result, function(row) {
          _.each(row, function(val, key) {
            row.source_name = source.name;
            if (source.code === 'forms' && key === 'form') return;
            if (val.toLowerCase().indexOf(search.value.toLowerCase()) > -1) {
              row.found = key;
              row[key] = val.replace(RegExp('(' + search.value + ')', 'gi'), '<strong>$1</strong>');
            } else if (!val) {
              row[key] = `<i class="transparent">${bConfig.langs.sb_not_specified}</i>`;
            }
          });
        });
      }

      search.ready = true;
      $timeout(function() {
        search.result_rows = search.elem.find('.cursor-row');
        search.max_limit = search.result_rows.length - 1;
        if (!ignore_indexing) {
          search.result_index = 0;
          scrollToIndex();
        }
      });
    });
  }

  function onBarCodeChange() {
    search.searching = true;
    search.moment = _.now();
    let source = search.sources[0];

    if (source) {
      source.maxPage = 0;
      source.pageNo = 1;
      source.hasMore = false;
      source.result = [];
      source.hasResult = false;

      source.query.param({ search_value: search.value });
      searchUpdateResult(source, false, search.moment, true);
    }
  }

  function onChangeSearchValue() {
    let indexed = false;
    search.searching = true;
    search.moment = _.now();
    _.each(search.sources, function(source) {
      source.maxPage = 0;
      source.pageNo = 1;
      source.hasMore = false;
      source.result = [];
      source.hasResult = false;

      if (search.value && (!search.header || source.code == search.header) && source.code !== 'barcodes') {
        if (source.custom_search) {
          source.query.param({ search_value: search.value });
        } else {
          source.query.searchValue(search.value);
        }
        searchUpdateResult(source, indexed, search.moment);
        indexed = true;
      }
    });
  }

  var changeSearchValueDebounced = _.debounce(onChangeSearchValue, 1000);

  function changeSearchValue() {
    search.searching = true;
    changeSearchValueDebounced();

    if (search.value.length == 0) {
      resetSearchValue();
      search.ready = false;
    }
  }

  function searchKeyDown(event) {
    if (event.keyCode === 13) {
      search.result_rows.filter('.active').click();
    } else if (event.keyCode === 38 && search.result_index > 0) {
      event.preventDefault();
      search.result_index--;
      scrollToIndex();
    } else if (event.keyCode === 40 && search.result_index < search.max_limit) {
      event.preventDefault();
      search.result_index++;
      scrollToIndex();
    } else if (event.altKey && event.keyCode >= 49 && event.keyCode <= 57) {
      event.preventDefault();
      const ind = Math.min(event.keyCode - 49, search.headers.length - 1);
      selectHeader(search.headers[ind].code);
    }
  }

  function scrollToIndex() {
    const s = search.result_rows.removeClass('active').get(search.result_index);
    if (!s) return;
    $(s).addClass('active');
    s.scrollIntoView({ behavior: "smooth", block: "nearest" });
  }

  function showMore(source) {
    search.searching = true;
    source.pageNo++;
    searchUpdateResult(source, true, search.moment);
    focusSearch();
  }

  function sourceOpen(source, row) {
    source.open(row);
    closeSearch();
  }

  function openSearch() {
    activateScannerDetection();
    $('#searchModal').modal('show');
    search.elem.addClass('open').css('display', 'block');
    search.opened = true;
    search.ready = false;
    AppHotkey.pause(true);
  }

  function closeSearch() {
    closeBarcode();
    search.elem.removeClass('open');
    $('#searchModal').modal('hide');
    search.opened = false;
    search.value = '';
    search.ready = false;
    AppHotkey.pause(false);
  }

  function detectBarcode(event, data) {
    if (data.string.length === 13 || true) {
      search.value = data.string;
      onBarCodeChange();
      search.value = '';
    }
  }

  function addScannerDetectionEvent() {
    $('body').scannerDetection();
    $('body').bind('scannerDetectionComplete', detectBarcode);
  }

  function activateScannerDetection() {
    if (scannerDetectionLoaded) {
      addScannerDetectionEvent();
    } else {
      scannerDetectionLoaded = true;
      bRequire.load('jquery-scannerdetection').then(addScannerDetectionEvent);
    }
  }

  function openBarcode() {
    activateScannerDetection();
    search.no_barcode_result = false;
    AppHotkey.pause(true);
  }

  function closeBarcode() {
    $('body').scannerDetection(false);
    $('#barcodeModal').modal('hide');
    AppHotkey.pause(false);
  }

  function focusSearch() {
    $timeout(function() {
      search.elem.find('.search-form').find('.form-control').focus();
    });
  }

  search.elem.on('mouseenter', '.cursor-row', function(ev) {
    search.result_index = $('.cursor-row').index($(this));
    scrollToIndex();
  });

  $('#searchModal').on('shown.bs.modal', focusSearch).on('hidden.bs.modal', closeSearch);
  $('#barcodeModal').on('hidden.bs.modal', closeBarcode);

  return search;
});
