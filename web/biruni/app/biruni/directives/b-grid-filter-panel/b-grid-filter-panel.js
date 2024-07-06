biruni.directive('bGridFilterPanel', function(bConfig, bQuery, bGridFilter,  $timeout) {
  function link(scope, elem, attr) {
    const grid = scope.bPage.grid(attr.name),
        query = grid.query();
    var   md; // remember mouse down info
    elem.find('.splitter')[0].onmousedown = onMouseDown;

    function onMouseDown(e) {
      md = {e, width: grid.g.filterPanelWidth};

      document.onmousemove = onMouseMove;
      document.onmouseup = () => {
          document.onmousemove = document.onmouseup = null;
          grid.saveSettingChanges();
      }
      e.preventDefault();
    }

    function onMouseMove(e) {
      let dx = e.clientX - md.e.clientX;
  
      if (grid.g.filterPanelDirection == 'right') {
        grid.g.filterPanelWidth = md.width - dx;
      } else {
        grid.g.filterPanelWidth = md.width + dx;
      }
      
      if (grid.g.filterPanelWidth < 305) grid.g.filterPanelWidth = 305;
      else if (grid.g.filterPanelWidth > 800) grid.g.filterPanelWidth = 900;

      elem.css('width', grid.g.filterPanelWidth + 'px')
    }

    function toogleDirection() {
      grid.g.filterPanelDirection = grid.g.filterPanelDirection == 'left' ? 'right' : 'left';
      grid.saveSettingChanges();
    }

    function focusNesFilter() {
      $timeout(()=> {
        elem.find('.add-new-field-wrapper').find('input').focus();
      });  
    }

    const query_name = attr.name + '_grid_filter';
    let q = scope.bPage.queries[query_name];

    if (!q) {
      q = bQuery(query.path());
      q.param(query.param());
      q.column(['code', 'name']);
      scope.bPage.queries[query_name] = q;
    }
    bGridFilter.loadFilterData(query, grid, query_name, scope.bPage);
 
    scope.a = {
      bConfig: bConfig,
      bGridFilter: bGridFilter,
      grid: grid
    };

    scope.toogleDirection = toogleDirection;
    scope.focusNesFilter = focusNesFilter;
  }

  return {
    restrict: 'E',
    scope: true,
    link: link,
    templateUrl: 'b-grid-filter-panel.html'
  };
});
