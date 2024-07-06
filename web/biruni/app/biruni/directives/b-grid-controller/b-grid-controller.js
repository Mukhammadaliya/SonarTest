biruni.directive('bGridController', function (bConfig, bGridFilter, bSortForm, bFrame, bQuery, bForms, bConstants) {

  function link(scope, elem, attr) {
    const grid = scope.bPage.grid(attr.name),
      query = grid.query(),
      o = {
        bConfig: bConfig,
        grid: grid
      };

    scope.o = o;

    scope.bPage.bindHotkey("F3", function () {
      elem.find("input").focus();
    });
    scope.bPage.bindHotkey("F4", openFilter);
    scope.bPage.bindHotkey("F7", reload);
    scope.bPage.bindHotkey("F8", openSortForm);
    scope.bPage.bindHotkey("F9", openGridSetting);

    o.startPage = 1;

    evalResult();
    scope.$watch(query.fetching, evalResult);

    function evalResult() {
      const r = query.result(),
        pn = r.offset / r.limit + 1;

      o.searchValue = query.searchValue();
      o.searchValueOld = o.searchValue;
      o.hasSearch = !!query.searchFields().length;
      o.filterClass = query.hasFilterValues() ? 'text-warning' : 'text-default';
      o.limit = r.limit;
      o.rowPerPageTitle = (Math.min(r.limit, r.count - r.offset) || 0) + ' / ' + r.count;
      o.curPageNo = pn;
      o.maxPage = r.maxPage;
      o.pages = _.range(1, o.maxPage + 1);
    }

    function reload() {
      query.fetch();
      grid.refreshCheck();
    }

    function changeLimit(v) {
      if (o.limit == v) return;
      query.limit(v);
      query.pageNo(1);
      reload();
    }

    function slidePageNo(shift) {
      if (shift && hasNextPage()) {
        o.startPage++;
      } else if (!shift && hasPrevPage()) {
        o.startPage--;
      }
    }

    function hasPrevPage() {
      return o.startPage > 1;
    }

    function hasNextPage() {
      return o.startPage <= o.maxPage - 5;
    }

    function changePageNo(v) {
      query.pageNo(v);
      reload();
    }

    function openFilter() {
      const query_name = attr.name + '_grid_filter';
      let q = scope.bPage.queries[query_name];

      if (!q) {
        q = bQuery(query.path());
        q.param(query.param());
        q.column(['code', 'name']);
        scope.bPage.queries[query_name] = q;
      }
      bGridFilter.open(query, grid, query_name, scope.bPage);
    }

    function search() {
      query.searchValue(o.searchValue);
      reload();
    }

    function onSearchKeyDown($event) {
      if ($event.keyCode == 13) {
        o.searchValueOld = o.searchValue;
        query.offset(0);
      }
    }

    function onSearchBlur() {
      o.searchValueOld = o.searchValue;
      query.offset(0);
    }

    function openSortForm() {
      bSortForm.open(grid);
    }

    function openGridSetting() {
      let path = query.path();
      path = path.substring(0, path.indexOf(':'));
      bFrame.open(bForms.GRID_SETTING, {
        name: attr.name
      }, undefined, {
        path: path
      });
    }

    function exportExcel() {
      const cols = _.chain(grid.g.cols)
        .flatten()
        .map(function (c) {
          if (c.name) {
            let img = grid.getField(c.name).img;
            if (img) img = img.join(';');
            let size = String(c.size).endsWith('%') ? (parseFloat(c.size) / bConstants.CELL_SHARE).toFixed(6) : parseFloat(c.size);
            return {
              name: c.name,
              label: grid.g.fields[c.name].label,
              size,
              img
            };
          }
        })
        .compact()
        .value();
      query.exportExcel(cols, scope.bPage.title);
    }

    function toggleFilterPanel(){
      grid.g.openFilterPanel = !grid.g.openFilterPanel;
      grid.saveSettingChanges();
    }

    scope.$watch('o.searchValueOld', function (v, o) {
      if (v !== o) {
        query.searchValue(v);
        reload();
      }
    });

    scope.reload = reload;
    scope.search = search;
    scope.openFilter = openFilter;
    scope.changeLimit = changeLimit;
    scope.slidePageNo = slidePageNo;
    scope.hasPrevPage = hasPrevPage;
    scope.hasNextPage = hasNextPage;
    scope.exportExcel = exportExcel;
    scope.changePageNo = changePageNo;
    scope.onSearchBlur = onSearchBlur;
    scope.openSortForm = openSortForm;
    scope.onSearchKeyDown = onSearchKeyDown;
    scope.openGridSetting = openGridSetting;
    scope.toggleFilterPanel = toggleFilterPanel;
  }

  return {
    restrict: 'E',
    scope: true,
    link: link,
    templateUrl: 'b-grid-controller.html'
  };
});
