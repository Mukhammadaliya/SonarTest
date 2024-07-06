biruni.factory('bPgGrid', function($rootScope, $q, $http, bStorage, bRoutes, bConfig, bConstants) {

  function make(pg_name) {
    var name = pg_name;

    var g = {
      labelName: '',
      rownum: '',
      path: '',
      storageKey: '',
      withCheckbox: false,
      isInit: false,
      isStatic: false,
      fetchingId: 0,
      items: [],
      pageItems: [],
      filtered: [],
      cols: [],
      fields: [],
      colsDefault: [],
      customColSizes: {},
      freeCols: [],
      freeColAlign: 'top',
      freeColEnable: true,
      defaultSearch: [],
      defaultSearchable: [],
      defaultSearchNull: [],
      defaultSort: [],
      search: [],
      searchNull: [],
      filterFields: [],
      originFilters: [],
      filters: {},
      sortOrder: ['asc', 'desc', 'def'],
      sortValue: '',
      oldSortValue: '',
      sortType: '',
      searchValue: '',
      oldSearchValue: '',
      countableColumns: [],
      limits: [10, 50, 100, 500, 1000],
      currentLimit: 10,
      lastLimit: 10,
      pageNumbers: [],
      currentPage: 1,
      lastPage: 1,
      maxPage: 0,
      rowPerPageTitle: '',
      uncheckAll: null,
      onFilter: _.noop
    };

    function uncheckAll(fn) {
      if (typeof(fn) == "function") g.uncheckAll = fn;
      else if (g.uncheckAll) g.uncheckAll();
    }

    function getName() {
      return name;
    }

    function getLabelName() {
      return g.labelName;
    }

    function getPageItems() {
      return g.pageItems;
    }

    function freeColEnabled(status) {
      g.freeColEnable = !!status;
    }

    function reinitSettings() {
      g.cols = [];
      g.search = [];
    }

    function reload() {
      g.fetchingId = _.uniqueId();
    }

    function refresh(items) {
      if (items) {
        g.items = items;
      }

      reloadFiltered();
      reloadPageItems();
    }

    function onSort(val) {
      g.oldSortValue = g.sortValue;
      g.sortValue = val;

      if (g.sortValue == g.oldSortValue) {
        var ind = _.indexOf(g.sortOrder, g.sortType);
        if (ind < 2) {
          g.sortType = g.sortOrder[ind + 1];
        } else {
          g.sortType = g.sortOrder[0];
        }
      } else {
        g.sortType = g.sortOrder[0];
      }
      sortItems();
    }

    function sortItems() {
      if (g.sortValue && g.sortType) {
        let sort = g.sortValue;

        let field = _.findWhere(g.fields, {name: g.sortValue});
        if (field.format == 'amount' || field.format == 'number') {
          sort = (n) => +n[g.sortValue];

        } else if (field.format == 'date') {
          sort = n => {
            let x = moment(n[g.sortValue], field.date_format || 'DD.MM.YYYY HH:mm:ss').format('YYYYMMDDHHmmss');
            return !isNaN(+x) ? +x : -Infinity;
          };
        }

        if (g.sortType == 'asc') {
          g.filtered = _.sortBy(g.filtered, sort);
        } else if (g.sortType == 'desc') {
          g.filtered = g.filtered.reverse();
        } else if (g.sortType == 'def') {
          reloadFiltered();
        }

        setIndex();
        reloadPageItems();
      }
    }

    function onSearch() {
      if (g.searchValue != g.oldSearchValue) {
        g.oldSearchValue = g.searchValue;
        g.currentPage = 1;
        g.lastPage = 1;
        g.sortValue = '';
        g.oldSortValue = '';
        g.sortType = '';
        refresh();
      }
    }

    function setIndex() {
      let index = 1;
      _.each(g.filtered, x => x[g.rownum] = index ++ );
    }

    function filter(name, arg2, arg3) {
      switch (arguments.length) {
        case 3:
          var f = g.filters[name];
          if (!f) {
            g.filters[name] = { op: arg2, val: arg3 };
          } else {
            if (!_.isArray(f)) g.filters[name] = [f];
            g.filters[name].push({ op: arg2, val: arg3 });
          }
          break;
        case 2:
          g.filters[name] = { op: arg2, val: arg3 };
          break;
        case 1:
          if (_.isEmpty(name)) {
            g.filters = {};
            g.originFilters = {};
          }
      }
      return g.filters[name];
    }

    function filterOper(left, operator, right) {
      switch (operator) {
        case '=': return left == right; break;
        case '!=': return left != right; break;
        case '%': return String(left).toLowerCase().indexOf(right.toLowerCase()) > -1; break;
        case '!%': return String(left).toLowerCase().indexOf(right.toLowerCase()) == -1; break;
        case '>': return left > right; break;
        case '>=': return left >= right; break;
        case '<': return left < right; break;
        case '<=': return left <= right; break;
      }
    }

    function date2text(dt) {
      if (!dt) return null;
      var dt = dt.split(' ')[0] || null;
      return dt?.split('.').reverse().join('') || null;
    }

    function filterItem(item) {
      return _.all(g.filters, (f, name) => {
        var field = _.findWhere(g.filterFields, { name });
        if (!field) return;
        let fnc;
        if (field.type == 'number') fnc = parseFloat;
        else if (field.type == 'date') fnc = date2text;
        else fnc = String;

        if (_.isArray(f)) {
          var boolFnc = field.equal && f[0].op == '=' || f[0].op == '<' ? _.any : _.all;
          return boolFnc(f, v => filterOper(fnc(item[name]), v.op, fnc(v.val)));
        } else {
          return filterOper(fnc(item[name]), f.op, fnc(f.val));
        }
      });
    }

    function reloadFiltered() {
      if (g.searchValue || !_.isEmpty(g.filters)) {
        g.filtered = _.filter(g.items, function(item) {
          if (!filterItem(item)) return false;
          // return all rows if searchValue is null
          return !g.searchValue ||
          _.any(g.search, s => 
              // filter rows which are Null
              _.contains(g.searchNull, s) && _.isEmpty(item[s]) ||
              // return rows which are matched by searchValue
              String(item[s]).toLowerCase().indexOf(g.searchValue.toLowerCase()) > -1
          );
        });
      } else {
        g.filtered = g.items;
      }

      setIndex();

      g.maxPage = getMaxPage();
      g.currentPage = Math.max(1, Math.min(g.currentPage, g.maxPage));
      g.onFilter(g.filtered);
    }

    function reloadPageItems() {
      g.pageItems = makePageItems();
      g.pageNumbers = getPageNumbers();

      if (g.countableColumns && g.countableColumns.length > 0) {
        g.rowPerPageTitle = String(calcLength(g.pageItems)) + ' / ' + String(calcLength(g.filtered));
      } else {
        g.rowPerPageTitle = String(g.pageItems.length) + ' / ' + String(g.filtered.length);
      }
    }

    function calcLength(arr){
      if (arr && arr.length)
        return arr.reduce((acc, row) => checkCountableColumnExist(row) ? acc + 1 : acc, 0);
      return 0;
    }

    function checkCountableColumnExist(obj){
      for (let key of g.countableColumns){
        if (!obj[key]) return false;
      }
      return true;
    }

    function makePageItems() {
      var left = Math.max((g.currentPage - 1) * g.currentLimit, 0),
      right = Math.min(g.currentPage * g.currentLimit, g.filtered.length);
      return g.filtered.slice(left, right);
    }

    function getPageNumbers() {
      var r = [];
      for (var i = Math.max(1, g.currentPage - 4); i <= Math.min(g.maxPage, g.currentPage + 4); i++)
        r.push(i);
      return r;
    }

    function getMaxPage() {
      return Math.trunc((g.filtered.length + g.currentLimit - 1) / g.currentLimit);
    }

    function changeCurrentPage() {
      if (g.currentPage != g.lastPage) {
        g.lastPage = g.currentPage;
        reloadPageItems();
      }
    }

    function checkedApi(indexes) {
      function pickedRows() {
        var r = [];
        _.each(indexes, function(x) {
          r.push(g.pageItems[x]);
        });
        return r;
      }

      return {
        has : indexes.length > 0,
        size : indexes.length,
        rows : pickedRows
      };
    }

    // Calculate columns sizes
    function getTableSizes() {
      let result = _.map(g.cols, function(c) {
        if (String(c.size).endsWith('%')) {
          return (parseFloat(c.size) || 1) + '%';
        } else {
          return (bConstants.CELL_SHARE * parseInt(c.size) + '%');
        }
      });

      if (g.withCheckbox) {
        result.unshift(bConstants.CELL_SHARE + "%");
      }

      return result;
    }

    function drawHtml(iterator = 'row') {
      var first = true,
          hRow = '',
          fRows = '',
          hCells = '',
          bRow = '',
          bCells = '',
          result = '';
      let sizeArray = getTableSizes();

      if (g.cols.length > 0) {
        hCells = '';
        bCells = '';
        _.each(g.cols, function(cell) {
          if (cell.name) {
            var field = _.findWhere(g.fields, {name: cell.name});
            if (field) {
              if (field.header != undefined) {
                hCells += `<div class="tbl-header-cell"><div class="tbl-header-txt">${field.header}</div></div>`;
              } else {
                var sort = field.sort ? `sort="${field.name}"` : '';
                var sortIcon = field.sort ?
                `&nbsp;<i class="fa fa-angle-down" ng-show="g.sortValue == '${field.name}' && g.sortType == 'asc'"></i>
                <i class="fa fa-angle-up" ng-show="g.sortValue == '${field.name}' && g.sortType == 'desc'"></i>` : '';

                hCells += `<div class="tbl-header-cell" style="cursor:pointer;"><div ${sort} class="tbl-header-txt">${field.label}${sortIcon}</div></div>`;
              }

              if (g.hasNavigate && field.onNavigate) {
                bCells += `<div class="tbl-cell" ng-on-eventfocus="${field.onNavigate.split('(')[0]}($event.detail)">`;
              } else {
                bCells += `<div class="tbl-cell">`;
              }

              if (field.child) {
                bCells += field.child + `</div>`;
              } else {
                if (field.static) {
                  bCells += `{{::`;
                } else {
                  bCells += `{{`;
                }

                if (field.format == 'amount') {
                  bCells += `${iterator}.${field.name} | bNumber}}</div>`;
                } else {
                  bCells += `${iterator}.${field.name}}}</div>`;
                }
              }
            } else {
              hCells += `<div class="tbl-header-cell"></div>`;
              bCells += `<div class="tbl-cell"></div>`;
            }
          } else {
            hCells += `<div class="tbl-header-cell"></div>`;
            bCells += `<div class="tbl-cell"></div>`;
          }
        });
        hCells += `<div class="tbl-header-cell tbl-empty-cell"></div>`;
        bCells += `<div class="tbl-cell tbl-empty-cell"></div>`;

        if (hCells.length > 0) {
          hRow += `<div class="tbl-header pg-grid-header">`;

          if (first) {
            first = false;

            if (g.withCheckbox) {
              hRow += `<div class="tbl-header-cell tbl-checkbox-cell">
                          <label class="checkbox mt-0">
                            <input type="checkbox" bcheckall=""/>
                            <span></span>
                          </label>
                        </div>`;
              bRow += `<div class="tbl-cell tbl-checkbox-cell">
                          <label class="checkbox mt-0">
                            <input type="checkbox" data-bcheck='{{$index}}'/>
                            <span></span>
                          </label>
                        </div>`;
            }
          }

          hRow += hCells + `</div>`;
          bRow += bCells;
        }

        if (g.freeCols.length > 0) {
          fRows = '<div class="tbl-row" ng-if="g.freeColEnable">';

          _.each(g.freeCols, function(col) {
            fRows += `<div class="tbl-cell tbl-free-cell">`;
            fRows += col.child || '&nbsp;';
            fRows += '</div>';
          });

          fRows += '</div>';
        }

        if (hRow.length > 0) {
          result = `<div class="tbl-container">
                      <div class="tbl" style="grid-template-columns: ${sizeArray.join(" ")} 1fr;">
                        ${hRow}
                        <div class="tbl-body">
                        ${g.freeColAlign == 'top'? fRows: ''}
                        <div class="tbl-row" ng-repeat="${iterator} in g.pageItems">${bRow}</div>
                        <div ng-if="!g.pageItems.length" class="tbl-row tbl-no-data-row"><i class="fas fa-exclamation-circle"></i>&nbsp;${bConfig.langs.grid_no_results}</div>
                        ${g.freeColAlign == 'bottom'? fRows: ''}
                      </div>
                    </div>
                    </div>`;
        }
      }
      return result;
    }

    function loadSetting(storageKey) {
      if ($rootScope.is_debug) return $q.all([]);
      return $http.post(bRoutes.LOAD_USER_LARGE_SETTING, {
        setting_code: storageKey
      }).then(function(result) {
        if (result.data) {
          bStorage.json(storageKey, result.data);
        } else {
          bStorage.text(storageKey, null);
        }
      }, function(error) {
        console.error('pg_grid setting load', error);
      });
    }

    function customColSize(name, size) {
      g.customColSizes[name] = size;
    }

    return {
      g: g,
      getName: getName,
      getLabelName: getLabelName,
      getPageItems: getPageItems,
      freeColEnabled: freeColEnabled,
      reinitSettings: reinitSettings,
      loadSetting: loadSetting,
      reload: reload,
      refresh: refresh,
      filter: filter,
      onSort: onSort,
      onSearch: onSearch,
      changeCurrentPage: changeCurrentPage,
      checkedApi: checkedApi,
      drawHtml: drawHtml,
      uncheckAll: uncheckAll,
      customColSize: customColSize
    }
  }

  return make;
});
