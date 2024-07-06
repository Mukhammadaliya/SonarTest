biruni.factory('bGrid', function ($filter, $rootScope, $http, $q, bConfig, bStorage, bRoutes, bConstants) {
  function make(query) {
    const keyFilter = query.path() + '&filter';
    const keySort = query.path() + '&sort';
    let isInit = true;

    const g = {
      enabled: true,
      fields: {},
      asHtmls: {},
      cols: [],
      colsDefault: [],
      filtersList: [],
      defaultFilters: [],
      filters: [],
      withCheckbox: false,
      pinnedSort: undefined,
      showFilterPanel: window.innerWidth > 776,
      openFilterPanel: false,
      filterPanelDirection: 'right',
      filterPanelWidth: 400
    };

    const promises = [];

    promises.push(loadSetting(keyFilter).finally(function () {
      const listObj = bStorage.json(keyFilter);
      if (!_.isEmpty(listObj)) g.filtersList = listObj.list;
    }));

    promises.push(loadSetting(keySort).finally(function () {
      const order = bStorage.text(keySort);
      if (order) {
        try {
          g.pinnedSort = JSON.parse(order);
        } catch (e) {
          console.error(e)
        }
      }
    }));

    const promise = $q.all(promises);

    function loadSetting(path) {
      if ($rootScope.is_debug) {
        return $q.all([]);
      } else {
        return $http.post(bRoutes.LOAD_USER_LARGE_SETTING, {
          setting_code: path
        }).then(function (result) {
          if (result.data) {
            bStorage.json(path, result.data);
          } else {
            bStorage.text(path, null);
          }
        }, function (error) {
          console.error('grid filter loader', error);
        });
      }
    }

    function prepareValue(f) {
      if (f.mode === 'mc') f.val = _.chain(f.val).where({ val: true }).pluck('id').value();
      else if (f.mode === 'mt') f.val = f.model;
      else if (f.mode === 'md') f.val = _.pluck(f.val, 'code');
    }

    function prepareFilters(f) {
      _.each(f, function (x) {
        if (x.mode === 'date' || x.mode === 'rangeDate') {
          switch (x.dateLevel) {
            case 'year':
              x.val.left = !!x.val.left ? '01.01.' + x.val.left + ' 00:00:00' : x.val.left;
              x.val.right = !!x.val.right ? '31.12.' + x.val.right + ' 23:59:59' : x.val.right;
              break;
            case 'month':
              x.val.left = !!x.val.left ? '01.' + x.val.left + ' 00:00:00' : x.val.left;
              x.val.right = !!x.val.right ? moment(x.val.right, x.dateModelFormat).endOf('month').format('DD') + '.' + x.val.right + ' 23:59:59' : x.val.right;
              break;
            case 'time':
              break;
            default:
              x.val.left = !!x.val.left ? x.val.left + ' 00:00:00' : x.val.left;
              x.val.right = !!x.val.right ? x.val.right + ' 23:59:59' : x.val.right;
          }
        }
      });

      return _.chain(f)
        .sortBy(x => parseInt(x.order_no))
        .map(x => _.pick(x, 'name', 'mode', 'decorateWith', 'val', 'nulls', 'directive', 'type', 'treeWithParent', 'model', 'op', 'dateLevel', 'dateModelFormat'))
        .each(prepareValue)
        .value();
    }

    function saveStorageFilter(l) {
      const list = _.chain(angular.copy(l))
          .sortBy(x => parseInt(x.order_no))
          .map(x => _.pick(x, 'name', 'filters', 'pin'))
          .each(x => x.filters = prepareFilters(x.filters))
          .value();

      g.filtersList = list;

      if (list.length > 0) {
        saveSetting(keyFilter, { list: list }, 'grid filter save');
      } else {
        saveSetting(keyFilter, undefined, 'grid filter save');
      }
    }

    function saveSort(cols, remove) {
      if (!remove) saveSetting(keySort, cols, 'grid pin sort');
      else saveSetting(keySort, undefined, 'grid pin sort')
    }

    function saveSettingChanges() {
      const search = [];
  
      _.each(g.fields, function(f, k) {
        if (f.search) search.push(k);
      });
  
      const cols = g.cols;
      const openFilterPanel = g.openFilterPanel;
      const filterPanelDirection = g.filterPanelDirection;
      const filterPanelWidth = g.filterPanelWidth;
  
      let data = {
        setting_code: getQuery().path(),
        setting_value: { cols, search, openFilterPanel, filterPanelDirection, filterPanelWidth }
      }
  
      if ($rootScope.is_debug) {
        bStorage.json(data.setting_code, data.setting_value);
      } else {
        data.setting_value = JSON.stringify(data.setting_value);
        $http.post(bRoutes.SAVE_USER_LARGE_SETTING, data).then(_, function (error) {
          console.error('unable to save settings', error);
        });
      }
    }

    function saveSetting(path, data, error_message) {
      if ($rootScope.is_debug) {
        if (data) bStorage.json(path, data);
        else bStorage.text(path, data);
      } else {
        $http.post(bRoutes.SAVE_USER_LARGE_SETTING, {
          setting_code: path,
          setting_value: JSON.stringify(data)
        }).then(_, function (error) {
          console.error(error_message, error);
        });
      }
    }

    function notEqual(v1, v2) {
      v1 = !v1 ? -1 : v1;
      v2 = !v2 ? -1 : v2;
      return v1 != v2;
    }

    function fixFilterList() {
      function isUseful(reserve) {
        const origin = _.findWhere(g.filters, { name: reserve.name });
        if (!origin) return false;
        if (notEqual(origin.decorateWith, reserve.decorateWith)) return false;
        return !notEqual(origin.directive, reserve.directive);
      }

      g.filtersList = _.chain(g.filtersList)
        .each(x => x.filters = _.filter(x.filters, isUseful))
        .filter(x => x.filters.length > 0).value();
    }

    function fixGridFilters() {
      fixFilterList();
      const pinnedFilter = _.findWhere(g.filtersList, { pin: 'Y' });

      if (pinnedFilter) {
        query.filterClear();

        _.each(pinnedFilter.filters, function (f) {
          if (f.decorateWith) {
            query.filter(f.name, f.op, f.val || [], f.nulls);
          } else if (f.type === 'N' || f.type === 'D') {
            if (f.directive === 'equal' && f.type === 'N') {
              query.filter(f.name, f.op, f.val || '', f.nulls);
            } else {
              let val = f.val || {};
              let l = val.left, r = val.right;

              if (f.type === 'D' && f.directive === 'equal') {
                l = r = val;

                switch (f.dateLevel) {
                  case 'year':
                    l = !!l ? '01.01.' + l + ' 00:00:00' : l;
                    r = !!r ? '31.12.' + r + ' 23:59:59' : r;
                    break;
                  case 'month':
                    l = !!l ? '01.' + l + ' 00:00:00' : l;
                    r = !!r ? moment(r, f.dateModelFormat).endOf('month').format('DD') + '.' + r + ' 23:59:59' : r;
                    break;
                  case 'time':
                    break;
                  default:
                    l = !!l ? l + ' 00:00:00' : l;
                    r = !!r ? r + ' 23:59:59' : r;
                }

                query.filter(f.name, f.op, val);
                query.filter(f.name, 'left', l);
                query.filter(f.name, 'right', r, f.nulls, 'date');
              } else {
                const left_op = f.op === '=' ? '>=' : '<';
                const right_op = f.op === '=' ? '<=' : '>';

                query.filter(f.name, left_op, l);
                query.filter(f.name, right_op, r, f.nulls);
              }
            }
          } else {
            const val = f.val ? _.contains(['<>', '='], f.op) ? f.val : '%' + f.val + '%' : null;
            query.filter(f.name, f.op, val, f.nulls);
          }
        });
      }
    }

    function getQuery() {
      return query;
    }

    function getField(name) {
      if (!name) {
        throw 'grid field name is empty';
      }
      let r = g.fields[name];

      if (!r) {
        r = {
          name: name
        };
        g.fields[name] = r;
      }

      return r;
    }

    function asHtml(name, required, fn) {
      if (!name) {
        throw 'grid as html field name is empty';
      }
      if (typeof (fn) !== "function") {
        throw 'grid as html field function is not function';
      }
      g.asHtmls[name] = {
        fn: fn,
        required: required
      };
    }

    function addCols(c) {
      const f = getField(c.name);
      f.column = true;
      f.sortBy = c.sortBy || f.sortBy;
      f.asHtml = c.asHtml === '' || c.asHtml || f.asHtml;
      f.img = null;

      if (c.img === '') {
        f.img = [50, 50]; // default image size [width, height]
      } else if (c.img) {
        let [width, height] = c.img.split(';');
        f.img = [width.trim(), height.trim()];
      }

      f.format = c.format || f.format;
      f.scale = c.scale || f.scale || 0;
      f.align = c.align || f.align;
      f.onClick = c.onClick || f.onClick;
    }

    function addCol(col, elem) {
      if (elem.parent().prop('nodeName') === 'B-ROW') {
        g.colsDefault.push(angular.copy(col));
        g.cols.push(col);
      }
      addCols(col);
    }

    function addFilter(name, decorateWith, checkboxLimit, directive, extra, treeWithParent, dateLevel) {
      if (!extra) {
        g.defaultFilters.push({
          name: name,
          decorateWith: decorateWith,
          directive: directive,
          treeWithParent: treeWithParent,
          dateLevel: dateLevel
        });
      }

      g.filters.push({
        name: name,
        decorateWith: decorateWith,
        directive: directive,
        treeWithParent: treeWithParent,
        dateLevel: dateLevel
      });

      const f = getField(name);
      f.filter = true;
      f.decorateWith = decorateWith;
      f.checkboxLimit = checkboxLimit;
      f.treeWithParent = treeWithParent;
    }

    function setActionHtml(html) {
      g.actionHtml = '<div class="tbl-row-action"><div>' + html + '</div></div>';
    }

    function requiredFieldNames() {
      return _.chain(g.fields)
        .where({
          required: true
        })
        .pluck('name')
        .value();
    }

    function reduceFieldNames(rdc, col) {
      if (!col.name) return rdc;
      const asHtml = getField(col.name).asHtml;
      if (asHtml != true && _.has(g.asHtmls, asHtml)) {
        return _.union(rdc, g.asHtmls[asHtml].required.split(',').map(x => x.trim()).concat(col.name));
      }
      return _.union(rdc, [col.name, asHtml == true ? '' : asHtml]);
    }

    function fetch() {
      return promise.then(() => {
        const s = _.chain(g.cols)
            .flatten()
            .reduce(reduceFieldNames, [])
            .compact()
            .union(requiredFieldNames())
            .value();
        query.column(s);
        g.pinnedSort && query.sort(g.pinnedSort);

        if (isInit) {
          isInit = false;
          fixGridFilters();
        }

        return query.fetch();
      });
    }

    function rowAt(i) {
      return _.pick(query.result().table[i], requiredFieldNames());
    }

    function checkedApi(c) {
      const table = query.result().table;

      function pickedRows() {
        const r = [],
            rfn = requiredFieldNames();
        for (let i = 0; i < c.length; i++) {
          r.push(_.pick(table[c[i]], rfn));
        }
        return r;
      }

      return {
        has: c.length > 0,
        size: c.length,
        rows: pickedRows
      };
    }

    function loadImage(sha, width, height) {
      return bRoutes.LOAD_IMAGE + '&sha=' + sha + '&width=' + width + '&height=' + height;
    }

    // Calculate columns sizes
    function getTableSizes(withCheckbox) {
      let sizeArray = _.map(g.cols, function(c) {
        if (String(c.size).endsWith('%')) {
          return (parseFloat(c.size) || 1) + '%';
        } else {
          return (bConstants.CELL_SHARE * parseInt(c.size) + '%');
        }
      });

      if (withCheckbox) {
        sizeArray.unshift(bConstants.CELL_SHARE + "%");
      }
      return sizeArray;
    }

    function escapeRow(row) {
      return _.mapObject(row, (value, key) => {
        let asHtmls = _.keys(g.asHtmls);
        if (_.contains(asHtmls, key)) return value;
        return bConfig.escapeHtml(value);
      });
    }

    function htmlTable(withCheckbox) {
      let sizeArray = getTableSizes(withCheckbox);
      let rs = query.result().table,
          meta = query.result().meta || [],
          sortCol = _.first(query.sort()),
          sortDir = _.first(sortCol),
          s = '<div class="tbl-container"><div class="tbl" style="grid-template-columns:' + sizeArray.join(" ") + ' 1fr;">',
          formatNumber = $filter('bNumber');

      for (let i = 0; i < meta.length; i++) {
        if (meta[i][0] === 'column' && g.fields[meta[i][1]]) {
          g.fields[meta[i][1]].label = meta[i][2] || ' ';
        }
      }

      if (sortDir === '-') {
        sortCol = sortCol.substring(1);
      }

      s += '<div class="tbl-header">';

      for (let i = 0; i < g.cols.length; i++) {
        if (withCheckbox && i === 0) {
          s += '<div class="tbl-header-cell tbl-checkbox-cell"><label class="checkbox mt-0"><input type="checkbox" bcheckall=""/><span></span></label></div>';
        }
        let c = g.cols[i];

        if (c.name) {
          let f = g.fields[c.name],
          name = f.sortBy || c.name,
          attr = ' style="cursor:pointer;';

          if (f.align) {
            attr += ' text-align:' + f.align;
          }

          s += '<div class="tbl-header-cell"><div sort-header="' + name + '"' + attr + '" class="tbl-header-txt">' + (f.label || c.name);

          if (name === sortCol) {
            if (sortDir === '-') {
              s += '<span class="fa fa-angle-up ml-1"></span>';
            } else {
              s += '<span class="fa fa-angle-down ml-1"></span>';
            }
          }

          s += '</div></div>';
        } else {
          s += '<div class="tbl-header-cell">&nbsp;</div>';
        }
      }

      s += '<div class="tbl-header-cell tbl-empty-cell"></div>';
      s += '</div>';
      s += '<div class="tbl-body">';

      if (rs.length > 0) {
        for (let k = 0; k < rs.length; k++) {
          s += '<div class="tbl-row">';
          let row = rs[k];

          for (let i = 0; i < g.cols.length; i++) {
            if (i === 0 && withCheckbox) {
              s += `<div class="tbl-cell tbl-checkbox-cell"><label class="checkbox mt-0"><input type="checkbox" data-bcheck=${k}><span></span></label></div>`;
            }

            let c = g.cols[i];

            if (c.name) {
              let val = row[c.name];
              let f = g.fields[c.name];
              let valHtml = row[f.asHtml];
              let valImg = '';
              let attr = '';

              if (f.asHtml && g.asHtmls[f.asHtml]) {
                valHtml = row[f.asHtml] = g.asHtmls[f.asHtml].fn(escapeRow(row));
              }

              if (f.img && val) {
                valImg = `<img src="${loadImage(val, f.img[0], f.img[1])}"/>`;
              }

              if (f.format && val) {
                if (f.format === 'amount') {
                  val = formatNumber(val, f.scale, true);
                }
              }

              if (f.align) {
                attr = ' style="text-align:' + f.align + '"';
              }

              if (f.asHtml) {
                s += `<div class="tbl-cell"${attr}>${(valHtml || val)}</div>`;
              } else if (f.img) {
                s += `<div class="tbl-cell"${attr}>${(valImg)}</div>`;
              } else if (f.onClick) {
                s += `<div class="tbl-cell"${attr}><a href class="b-grid-cell" cn="${f.name}">${bConfig.escapeHtml(val)}</a></div>`;
              } else {
                s += `<div class="tbl-cell"${attr}>${bConfig.escapeHtml(val)}</div>`;
              }
            } else {
              s += `<div class="tbl-cell"></div>`;
            }
          }
          s += '<div class="tbl-cell tbl-empty-cell"></div>';
          s += '<sliding style="display : none; width:100%" class="closed-slider tbl-row-menu"></sliding>';
          s += '</div>';
        }
      } else {
        s += `<div class="tbl-row tbl-no-data-row"><i class="fas fa-exclamation-circle"></i>&nbsp;${bConfig.langs.grid_no_results}</div>`
      }

      s += '</div></div></div>';
      return s;
    }

    function evalFiltersData(filters) {
      return _.chain(filters)
        .map(function (f) {
          let field = getField(f.name);
          f = _.defaults({}, field, f);

          if (f.decorateWith && g.fields[f.decorateWith]) {
            f.label = g.fields[f.decorateWith].label || f.label;
          }

          if (f.label.trim()) {
            return f;
          }
        })
        .compact()
        .value();
    }

    function getFilters() {
      const list = angular.copy(g.filtersList);
      _.each(list, x => {
        x.filters = evalFiltersData(x.filters);
        x.code = _.uniqueId('grid')
      });

      const def = evalFiltersData(angular.copy(g.defaultFilters));
      const all = evalFiltersData(angular.copy(g.filters));

      return {
        list: list,
        def: def,
        all: all,
      };
    }

    function disableRevokedColumns() {
      if (_.any(g.fields, 'revoked')) {
        g.cols = _.reject(g.cols, c => g.fields[c.name].revoked);
        g.colsDefault = _.reject(g.colsDefault, c => g.fields[c.name].revoked);
        g.filters = _.reject(g.filters, c => g.fields[c.name].revoked || g.fields[c.decorateWith]?.revoked);
        g.defaultFilters = _.reject(g.defaultFilters, c => g.fields[c.name].revoked || g.fields[c.decorateWith]?.revoked);

        const search = [];
        _.each(g.fields, function(field) {
          if (field.revoked) {
            field.column = field.filter = field.search = field.searchable = false;
            field.pinnedSort = undefined;
            field.sortBy = undefined;
            field.onClick = undefined;
          }
          if (field.search) search.push(field.name);
        });
        query.searchFields(search);
      }
    }

    return {
      g: g,
      query: getQuery,
      getField,
      asHtml,
      addCols,
      addCol,
      addFilter,
      setActionHtml,
      fetch,
      rowAt,
      checkedApi,
      htmlTable,
      getFilters,
      saveSort,
      saveStorageFilter,
      disableRevokedColumns,
      saveSettingChanges
    };
  }

  return make;
});
