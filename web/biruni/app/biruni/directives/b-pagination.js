biruni.directive('bPagination', function ($parse, bConfig) {
  function link(scope, elem, attr, ctrl, transclude) {

    var pageItemsSetter = $parse(attr.to).assign || _.noop;
    var filteredSetter = $parse(attr.filtered).assign || _.noop;
    var $modal = elem.find('.modal').first();
    $modal.modal({
      backdrop : false,
      keyboard : true,
      show : false
    });
    var fp = {};

    var o = {
      bConfig : bConfig,
      limits : [1, 10, 50, 100, 500, 1000],
      columnList : [],
      filtered : [],
      pageItems : [],
      items : [],
      pageNumbers : [],
      currentLimit : 10,
      lastLimit : 10,
      currentPage : 1,
      lastPage : 1,
      maxPage : 0,
      searchValue : '',
      oldSearchValue : '',
      hasSearch : false,
      hasFilter : false,
      hasColumnList : false,
      isViewAll : true,
      rowPerPageTitle : '',
      small : attr.small != undefined
    };

    function clearSearchValue() {
      o.searchValue = '';
      onSearch();
    }

    function getPageItems() {
      var left = Math.max((o.currentPage - 1) * o.currentLimit, 0),
      right = Math.min(o.currentPage * o.currentLimit, o.filtered.length);
      return o.filtered.slice(left, right);
    }

    function getPageNumbers() {
      var r = [];
      for (var i = Math.max(1, o.currentPage - 4); i <= Math.min(o.maxPage, o.currentPage + 4); i++)
        r.push(i);
      return r;
    }

    function getMaxPage() {
      return Math.trunc((o.filtered.length + o.currentLimit - 1) / o.currentLimit);
    }

    function reloadPageItems() {
      o.pageItems = getPageItems();
      o.pageNumbers = getPageNumbers();
      o.rowPerPageTitle = String(o.pageItems.length) + ' / ' + String(o.filtered.length);
      pageItemsSetter(scope, o.pageItems);
    }

    function reloadFiltered() {
      o.filtered = _.filter(o.items, filterItem);
      o.maxPage = getMaxPage();
      o.currentPage = Math.max(1, Math.min(o.currentPage, o.maxPage));
      filteredSetter(scope, o.filtered);
    }

    function changeCurrentPage() {
      if (o.currentPage != o.lastPage) {
        o.lastPage = o.currentPage;
        reloadPageItems();
      }
    }

    function filterCondition(item, data) {
      return true;
    }

    function searchCondition(item, search) {
      return true;
    }

    function filterItem(item) {
      return searchCondition(item, String(o.searchValue)) && filterCondition(item, fp);
    }

    function refreshPagination(items) {
      if (items) {
        o.items = items;
      }
      reloadFiltered();
      reloadPageItems();
    }

    function onSearch() {
      if (o.searchValue != o.oldSearchValue) {
        o.oldSearchValue = o.searchValue;
        o.currentPage = 1;
        o.lastPage = 1;
        refreshPagination();
      }
    }

    function isNullFilterParams() {
      var is = true;
      _.each(fp, function (val) {
        if (val)
          is = false;
      });
      return is;
    }

    function styleForCurrentPage(i) {
      return i == o.currentPage ? {
        'font-weight' : '900'
      }
       : {};
    }

    function styleForCurrentLimit(i) {
      return i == o.currentLimit ? {
        'font-weight' : '900'
      }
       : {};
    }

    function hasPrevPage() {
      return o.currentPage > 1;
    }

    function hasNextPage() {
      return o.currentPage < o.maxPage;
    }

    function changePage(p) {
      o.currentPage = parseInt(p);
      changeCurrentPage();
    }

    function nextPage() {
      o.currentPage = Math.min(o.currentPage + 1, o.maxPage);
      changeCurrentPage();
    }

    function prevPage() {
      o.currentPage = Math.max(o.currentPage - 1, 1);
      changeCurrentPage();
    }

    function lastPage() {
      o.currentPage = o.maxPage;
      changeCurrentPage();
    }

    function firstPage() {
      o.currentPage = 1;
      changeCurrentPage();
    }

    function changeLimit(limit) {
      o.currentLimit = parseInt(limit);
      if (o.currentLimit != o.lastLimit) {
        o.currentPage = Math.trunc((o.currentPage - 1) * o.lastLimit / o.currentLimit) + 1;
        o.lastLimit = o.currentLimit;
        o.lastPage = o.currentPage;
        refreshPagination();
      }
    }

    function onSearchKeyPress($event) {
      if ($event.charCode == 13) {
        onSearch();
      }
    }

    function openFilter() {
      $modal.modal('show');
    }

    function onClose() {
      $modal.modal('hide');
    }

    function onFilter() {
      o.isViewAll = isNullFilterParams();
      refreshPagination();
      onClose();
    }

    function onViewAll() {
      o.isViewAll = true;
      _.each(fp, function (val, key) {
        fp[key] = null;
      });
      refreshPagination();
      onClose();
    }

    function openColumnList() {
      if(o.hasColumnList)
      o.columnList = $parse(attr.columnList)(scope);
    }

    scope.o = o;
    scope.nextPage = nextPage;
    scope.prevPage = prevPage;
    scope.lastPage = lastPage;
    scope.firstPage = firstPage;
    scope.changePage = changePage;
    scope.onClose = onClose;
    scope.onFilter = onFilter;
    scope.onViewAll = onViewAll;
    scope.openFilter = openFilter;
    scope.changeLimit = changeLimit;
    scope.hasPrevPage = hasPrevPage;
    scope.hasNextPage = hasNextPage;
    scope.onSearchBlur = onSearch;
    scope.onSearchKeyPress = onSearchKeyPress;
    scope.styleForCurrentPage = styleForCurrentPage;
    scope.styleForCurrentLimit = styleForCurrentLimit;
    scope.openColumnList = openColumnList;

    scope.$watch(attr.limits, function(value) {
       if(value) {
          _.chain(value)
            .values()
            .each(function(item){
              if(_.isArray(item)) o.limits = item;
              else {
                o.currentLimit = item;
              }
            });
        if(!o.currentLimit) o.currentLimit = o.limits[0];
       }
    });

    if(!_.isUndefined(attr.columnList)) {
      o.hasColumnList = true;
    }

    if (!_.isUndefined(attr.searchBy)) {
      o.hasSearch = true;
      scope.$watch(attr.searchBy, function (value) {
        if(value) {
          searchCondition = value;
          if(!_.isUndefined(attr.clearSearchValue)) {
            $parse(attr.clearSearchValue).assign(scope, clearSearchValue);
          }
        }
      });
    }

    if (!_.isUndefined(attr.filterBy)) {
      o.hasFilter = true;
      scope.$watch(attr.filterBy, function (value) {
        filterCondition = value;
      });
    }



    scope.$watchCollection(attr.from, function (value) {
      if (value) {
        refreshPagination(value);
      }
    });

    transclude(function (clone, scopeInner) {
      scopeInner.fp = fp;
      elem.find('.modal .form-container').append(clone);
    });

  }

  return {
    restrict : 'E',
    scope : true,
    link : link,
    transclude : true,
    templateUrl : 'b-pagination.html'
  };
});
