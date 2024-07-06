 biruni.factory('bQuery', function (bHttp, bConfig) {
  function makeQuery(path) {
    const q = {
      param: null,
      column: [],
      where: null,
      searchValue: '',
      searchFields: [],
      filters: {},
      sort: [],
      offset: 0,
      limit: 50,
      fetchId: 0,
      result: {
        count: 0,
        maxPage: 0,
        data: []
      }
    };

    function fetchFieldsInfo(refers) {
      return bHttp.queryFieldsInfo(path, q.param, refers);
    }

    function fetch(tag, referName) {
      const d = {
        refer_name: referName,
        param: q.param,
        column: q.column,
        filter: genFilter(),
        sort: q.sort,
        offset: q.offset,
        limit: q.limit
      };
      return bHttp.queryData(path, d, tag).then(onFetch);
    }

    function onFetch(result) {
      q.fetchId = _.uniqueId();
      q.result = result;
      return result;
    }

    function clear() {
      q.fetchId = _.uniqueId();
      q.result = {
        count : 0,
        maxPage : 0,
        data : []
      }
    }

    function genFilter() {
      const search = gatherSearch(),
          filter = gatherFilters(),
          r = [];

      if (!_.isEmpty(q.where)) {
        r.push(q.where);
      }
      if (!_.isEmpty(search)) {
        r.push(search);
      }
      if (!_.isEmpty(filter)) {
        r.push(filter);
      }

      return prepareFilter(r);
    }

    function gatherSearch() {
      const p = [];

      if (q.searchValue) {
        for (let i = 0; i < q.searchFields.length; i++) {
          p.push([q.searchFields[i], 'esearch', '%' + bConfig.escapeLikeValue(q.searchValue) + '%']);
        }
      }
      return prepareFilter(p, 'or');
    }

    function makeDateFilter(name, f) {
      switch (_.keys(f)[0]) {
        case '=':
          return ['and', [[name, '>=', f.left], [name, '<=', f.right]]];
        case '<>':
          return ['or', [[name, '<', f.left], [name, '>', f.right]]];
        case '>':
          return [name, '>', f.right];
        case '<':
          return [name, '<', f.left];
        case '>=':
          return [name, '>=', f.left];
        case '<=':
          return [name, '<=', f.right];
        default:
          return [];
      }
    }

    function gatherFilters() {
      const r = [];

      _.each(q.filters, function(f, name) {
        let ops = [];

        if (f.mode === 'date') {
          r.push(makeDateFilter(name, f));
        } else {
          _.each(_.keys(f), function(op) {
            if (op === 'nulls') return;
            const val = f[op];

            if (val && (!_.isArray(val) || val.length > 0)) {
              let arr = [name, op, val];

              if (op === 'not search') {
                arr = ['not', [name, 'search', val]];
              }

              if (!f.nulls) {
                if (op === '<>' || op === 'not search') {
                  arr = ['or', [arr, [name, '=', null]]];
                }

                r.push(arr);
              } else {
                ops.push(arr);
              }
            }
          });
        }

        const n_arr = [name, f.nulls, null];

        if (ops.length > 0) {
          if (ops.length > 1) {
            ops = ['or', [['and', ops], n_arr]];
          } else {
            ops = ['or', [ops[0], n_arr]];
          }
          r.push(ops);
        } else if (f.nulls) {
          r.push(n_arr);
        }
      });

      return prepareFilter(r);
    }

    function hasFilterValues() {
      return !_.isEmpty(gatherFilters());
    }

    function prepareFilter(r, op) {
      switch (r.length) {
        case 0:
          return [];
        case 1:
          return r[0];
        default:
          return [op || 'and', r];
      }
    }

    function param(p) {
      if (arguments.length) {
        q.param = p;
        return this;
      }
      return q.param;
    }

    function column(...arg) {
      if (arg.length) {
        q.column = _.chain(arg).flatten().compact().uniq().value();
        return this;
      }
      return q.column;
    }

    function where(w) {
      if (arguments.length) {
        q.where = w;
        return this;
      }
      return q.where;
    }

    function searchValue(v) {
      if (arguments.length) {
        q.searchValue = v;
        return this;
      }
      return q.searchValue;
    }

    function searchFields(...arg) {
      if (arg.length) {
        q.searchFields = _.chain(arg).flatten().compact().uniq().value();
        return this;
      }
      return q.searchFields;
    }

    function filterClear() {
      q.filters = {};
      return this;
    }

    function filter(name, op, val, nulls, mode, left, right) {
      switch (arguments.length) {
        case 3:
        case 4:
        case 5:
        case 6:
        case 7:
          let s = q.filters[name];

          if (!s) {
            s = {};
            q.filters[name] = s;
          }

          s[op] = val;
          s.nulls = nulls;
          s.mode = mode;

          if (!!left) s.left = left;
          if (!!right) s.right = right;

          return this;
        case 2:
          return angular.copy((q.filters[name] || {})[op]);
        case 1:
          return angular.copy(q.filters[name]);
        default:
          return angular.copy(q.filters);
      }
    }

    function sort(...arg) {
      if (arg.length) {
        q.sort = _.chain(arg).flatten().compact().uniq().value();
        return this;
      }
      return q.sort;
    }

    function offset(val) {
      if (arguments.length) {
        q.offset = val;
        return this;
      }
      return q.offset;
    }

    function limit(val) {
      if (arguments.length) {
        q.limit = val;
        return this;
      }
      return q.limit;
    }

    function pageNo(val) {
      return arguments.length ? offset((val - 1) * q.limit) : q.offset / q.limit + 1;
    }

    function getFetchId() {
      return q.fetchId;
    }

    function result() {
      return q.result;
    }

    function exportExcel(column_list, fileName) {
      const d = {
        param: q.param,
        column_list: column_list,
        filter: genFilter(),
        sort: q.sort,
        rt: 'xlsx',
        fileName: fileName + '.xlsx',
        fileType: 'application/vnd.ms-excel'
      };

      bHttp.queryExport(path, d);
    }

    return {
      path : _.constant(path),
      param : param,
      column : column,
      where : where,
      searchValue : searchValue,
      searchFields : searchFields,
      filterClear : filterClear,
      filter : filter,
      hasFilterValues : hasFilterValues,
      sort : sort,
      offset : offset,
      limit : limit,
      pageNo : pageNo,
      fetch : fetch,
      clear : clear,
      fetching : getFetchId,
      result : result,
      fetchFieldsInfo : fetchFieldsInfo,
      exportExcel : exportExcel
    };
  }

  return makeQuery;
});