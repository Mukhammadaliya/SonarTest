biruni.factory('bPgGridFilter', function (bConfig, bFrame) {
  var $modal = $('#biruniPgGridFilter'),
  fields = {},
  filters = {},
  m = {
    checkbox_limit: 5
  };

  bConfig.onLocationChange(close);
  init();

  var $wrapper = $modal.find('.b-filter-wrapper');

  $modal.modal({ show: false });

  function init() {
    m.page = _.last(bFrame.pages);
    m.grid = null;

    m.items = [];
    m.filters = [];

    m.run = run;
    m.open = open;
    m.close = close;
    m.showAll = showAll;
    m.selectAll = selectAll;
  }

  function selectAllState(f) {
    return f.val.length == f.count ? '1' : '0';
  }

  function selectAll(f) {
    if (f.checkbox_state == '0') {
      f.val = angular.copy(f.list);
      f.checkbox_state = '1';
    } else {
      f.val = [];
      f.checkbox_state = '0';
    }
  }

  function setOperation(mode) {
    let def_opers = [
      { op: '=', class: 'fas fa-equals', text: bConfig.langs.gf_equal },
      { op: '!=', class: 'fas fa-not-equal', text: bConfig.langs.gf_not_equal }
    ];
    if (_.contains(['number', 'date'], mode)) {
      return def_opers.concat([
        { op: '<', class: 'fas fa-less-than', text: bConfig.langs.gf_less_than },
        { op: '>', class: 'fas fa-greater-than', text: bConfig.langs.gf_greater_than },
        { op: '<=', class: 'fas fa-less-than-equal', text: bConfig.langs.gf_less_than_equal },
        { op: '>=', class: 'fas fa-greater-than-equal', text: bConfig.langs.gf_greater_than_equal }
      ]);
    } else if (mode == 'search') {
      return def_opers.concat([
        { op: '%', class: 'fas fa-search', text: bConfig.langs.gf_search },
        { op: '!%', class:'fas fa-unlink fa-rotate-90', text: bConfig.langs.gf_not_search }
      ]);
    } else {
      return def_opers;
    }
  }

  function prepareFilter(f, v) {
    f = angular.copy(f);
    var op,
    field = _.findWhere(fields, { name: f.name }),
    filter = _.findWhere(filters, { name: f.name }) || {};

    if (!field) return null;

    if (f.decorateWith) {
      var cur = _.flatten([m.grid.filter(f.name)]);
      f.list = _.chain(m.items).map(function(c) {
        let old = _.findWhere(filter.list, { id: c[f.name] });
        if (c[f.name] && c[f.decorateWith]) {
          return {
            id: c[f.name],
            name: c[f.decorateWith],
            val: !!old?.val
          };
        } else return null;
      }).compact().uniq('id').sortBy('id').value();
      f.count = f.list.length;

      if (f.count <= m.checkbox_limit) f.mode = 'checkbox';
      else {
        f.query_name = m.grid.getName() + '_' + f.name;
        f.val = filter.val || [];
        f.checkbox_state = selectAllState(f);
        f.mode = 'select';
      }
      op = filter.op;
    } else if (f.type == 'number' || f.type == 'date') {
      if (f.equal) {
        f.mode = f.type;
        f.val = filter.val;
      } else if (f.directive == 'range' || !f.directive) {
        f.mode = 'range-' + f.type;
        f.val = filter.val || {};
      }
      op = filter.op;
    } else {
      f.mode = 'search';
      f.val = filter.val;
      op = filter.op || '%';
    }
    f.label = field.label;
    f.operations = setOperation(f.mode);
    f.operation = _.findWhere(f.operations, { op }) || f.operations[0];
    f.op = op;

    return f;
  }

  function open(grid) {
    init();
    m.grid = grid;
    m.items = grid.g.items;
    fields = grid.g.fields;
    filters = grid.g.originFilters;

    m.filters = _.compact(_.map(grid.g.filterFields, prepareFilter));

    $modal.modal('show');
  }

  function close() {
    init();
    $modal.modal('hide');
  }

  function run() {
    m.grid.filter({});

    _.each(m.filters, function(f) {
      var op = f.operation.op;
      switch (f.mode) {
        case 'checkbox':
          _.each(f.list, function(v) {
            if (v.val) {
              m.grid.filter(f.name, op, v.id);
            }
          });
          break;
        case 'select':
          _.each(f.val, v => {
            m.grid.filter(f.name, op, v.id);
          });
          break;
        case 'number':
        case 'date':
        case 'search':
          f.val && m.grid.filter(f.name, op, f.val);
          break;
        case 'range-number':
        case 'range-date':
          let v = f.val || {},
          l = v.left, r = v.right;

          l && m.grid.filter(f.name, op == '=' ? '>=' : '<', l);
          r && m.grid.filter(f.name, op == '=' ? '<=' : '>', r);
          break;
      }
    });
    m.grid.refresh();
    m.grid.g.originFilters = angular.copy(m.filters);
    close();
  }

  function showAll() {
    m.grid.filter({});
    m.grid.refresh();
    close();
  }

  return m;
});
