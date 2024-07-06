biruni.directive('bPgController', function (bConfig, bFrame, bForms, bPgGridFilter, $parse) {

  function ctrl($scope, $attrs) {
    var name = $attrs.name.trim();

    if (name.startsWith("{{") && name.endsWith("}}")) {
      name = $parse(name.substr(2, name.length - 4))($scope);
    }

    this.pgname = name;
  }

  function link(scope, elem, attr, ctrl) {
    var pgGrid = scope.bPage.pgGrid(ctrl.pgname);
    var g = pgGrid.g;

    var o = {
      bConfig: bConfig,
      startPage: 1
    };

    function onSearchKeyPress($event) {
      if ($event.charCode == 13) {
        pgGrid.onSearch();
        pgGrid.uncheckAll();
      }
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
      return o.startPage <= g.maxPage - 5;
    }

    function changePage(pg) {
      g.currentPage = parseInt(pg);
      pgGrid.changeCurrentPage();
      pgGrid.uncheckAll();
      g.pageNumbers = _.range(1, g.maxPage + 1);
    }

    function changeLimit(limit) {
      g.currentLimit = parseInt(limit);
      if (g.currentLimit != g.lastLimit) {
        pgGrid.refresh();
        pgGrid.uncheckAll();
        g.currentPage = Math.trunc((g.currentPage - 1) * g.lastLimit / g.currentLimit) + 1;
        g.lastLimit = g.currentLimit;
        g.lastPage = g.currentPage;
        g.pageNumbers = _.range(1, g.maxPage + 1);
      }
    }

    function openPgGridSetting() {
      pgGrid.uncheckAll();
      bFrame.openDialog(bForms.GRID_SETTING, {
        name: pgGrid.getName(),
        isPgGrid: true
      }, function () {
        pgGrid.loadSetting(pgGrid.g.storageKey).finally(function () {
          pgGrid.reinitSettings();
          pgGrid.reload();
        });
      }, 
      { 
        path: pgGrid.g.path,
      });
    }

    function hasFilter() {
      return g.filterFields.length > 0;
    }

    function openFilter() {
      bPgGridFilter.open(pgGrid);
    }

    function filterClass() {
      return !_.isEmpty(g.filters) ? 'btn-warning' : 'btn-default';
    }

    scope.g = g;
    scope.o = o;
    scope.hasFilter = hasFilter;
    scope.openFilter = openFilter;
    scope.filterClass = filterClass;
    scope.changePage = changePage;
    scope.changeLimit = changeLimit;
    scope.hasPrevPage = hasPrevPage;
    scope.hasNextPage = hasNextPage;
    scope.slidePageNo = slidePageNo;
    scope.onSearchKeyPress = onSearchKeyPress;
    scope.openPgGridSetting = openPgGridSetting;
  }

  return {
    scope: true,
    controller: ctrl,
    link: link,
    templateUrl: 'b-pg-controller.html'
  }
});
