biruni.factory('bSortForm', function (bConfig) {
  var $modal = $('#biruniSortForm'),
  m = {},
  def = [];
  $modal.modal({
    keyboard: true,
    show: false
  });

  init();

  bConfig.onLocationChange(function () {
    $modal.modal('hide');
  });

  var setDef = _.once(function(grid) {
    def = grid.query().sort();
  });

  function init() {
    m.query = null;
    m.grid = null;
    m.cols = [];
    m.open = open;
    m.sortIt = sortIt;
    m.setDefault = set;
    m.pinOrder = pinOrder;
  }

  function open(grid) {
    setDef(grid);
    init();
    m.pinned = !!grid.g.pinnedSort;
    m.grid = grid;
    m.query = grid.query();
    set(true);
    $modal.modal('show');
  }

  function getCols() {
    return _.chain(m.cols)
    .map(function (c) {
      return c.dir == 1 ? c.sortBy : c.dir == 2 ? '-' + c.sortBy : '';
    })
    .compact()
    .value();
  }

  function pinOrder() {
    m.grid.saveSort(getCols(), m.pinned);
    m.pinned = !m.pinned;
    m.grid.g.pinnedSort = m.pinned ? getCols() : undefined;
  }

  function set(opening) {
    var sc = {},
    r = opening ? m.query.sort() : def,
    fields = m.grid.g.fields;

    var cols = _.chain(m.grid.g.fields)
      .filter('column')
      .pluck('name')
      .value();

    for (var i = 0; i < r.length; i++) {
      if (_.first(r[i]) === '-') {
        sc[r[i].substr(1)] = [i, 2];
      } else {
        sc[r[i]] = [i, 1];
      }
    }
    var classes = ['fa-remove', 'fa-arrow-up', 'fa-arrow-down'];
    const sortTypes = [bConfig.langs.sort_off, bConfig.langs.sort_ascending, bConfig.langs.sort_descending];
    m.cols = _.chain(cols).map(function (c) {
      var r = {
        name : c,
        label : fields[c].label,
        dir : 0,
        orderNo: fields[c].label,
        sortBy : fields[c].sortBy || c
      },
      k = sc[r.sortBy];
      if (k) {
        r.orderNo = String(k[0]);
        r.dir = k[1];
      }
      r.clazz = function () {
        return classes[r.dir];
      }
      r.status = function (clazz) {
        let idx = clazz == classes[0] ? 0 : clazz == classes[1] ? 1 : clazz == classes[2] ? 2 : undefined;
        return sortTypes[idx];
      }
      return r;
    }).filter(function(c){
      return c.label.trim().length > 0;
    }).sortBy('orderNo').value();
  }

  function sortIt() {
    m.query.sort(getCols());
    m.query.fetch();
  }

  return m;
});
