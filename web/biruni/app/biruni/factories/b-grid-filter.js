biruni.factory('bGridFilter', function (bConfig, bFrame, $timeout) {
  let fieldsData = {},
      $modal = $('#biruniGridFilter'),
      m = {
        md_max_count: 50,
        checkbox_limit: 5,

        doAction,
        setDefault,
        setTemplate,
        editListName,
        addFilterItem,

        addNewFilter,
        saveNewFilter,
        clearNewFilter,
        saveEditFilter,
        cancelEditFilter,
        keypressNewFilter,

        deleteFilterItem,
        getUncheckedFilters,

        selectNulls,

        templates: [],
        container: null
      };

  bConfig.onLocationChange(close);
  init();

  $modal.modal({ show: false });

  $modal.on('hide.bs.modal', clearNewFilter);

  function setTemplate(item) {
    m.container = item;
  }

  function selectNulls(f, val, ev) {
    ev.stopPropagation();
    f.nulls = f.nulls != val ? val : undefined;
  }

  function editListName(item, $event) {
    if ($event.charCode == 13) {
      $event.stopPropagation();
      saveEditFilter(item);
    }
  }

  function keypressNewFilter($event) {
    if ($event.keyCode == 13) {
      $event.stopPropagation();
      saveNewFilter();
    }
  }

  function doAction(item, action, $event) {
    $event.stopPropagation();
    if (action === 'remove') {
      m.templates = _.filter(m.templates, x => x.code != item.code);
      saveFilter();
    } else
    if (action === 'pin') {
      const pin = item.pin !== 'Y' ? 'Y' : 'N';
      _.each(m.templates, x => x.pin = 'N');
      item.pin = pin;
      saveFilter();
    } else
    if (action === 'edit') {
      m.oldName = item.name;
      item.editTextMode = true;

      $timeout(function() {
        $($event.target).closest('.dropdown-item').find('input').focus();
      });
    }
  }

  function saveFilter() {
    m.grid.saveStorageFilter(m.templates);
  }

  function saveNewFilter() {
    let temp = angular.copy(m.container);
    temp.pin = 'N';
    temp.code = _.uniqueId('grid');
    temp.name = m.new_filter_name || bConfig.langs.gf_unknown;
    m.templates.unshift(temp);
    clearNewFilter();
    saveFilter();
  }

  function clearNewFilter() {
    m.newFilterMode = false;
    m.new_filter_name = '';
  }

  function addNewFilter(ev) {
    ev.stopPropagation();
    m.newFilterMode = true;

    $timeout(function() {
      $modal.find('.add-new-field-wrapper').find('input').focus();
    });
  }

  function saveEditFilter(item) {
    item.name = item.name || bConfig.langs.gf_unknown;
    item.editTextMode = false;
    saveFilter();
  }

  function cancelEditFilter(item) {
    item.name = m.oldName;
    item.editTextMode = false;
  }

  function setDefault() {
    m.container.filters = _.map(m.def, prepareFilter);
  }

  function getUncheckedFilters() {
    return m.allFilterItems.filter(f => _.findIndex(m.container?.filters, { name : f.name }) === -1);
  }

  function deleteFilterItem(item) {
    m.container.filters = _.filter(m.container.filters, x=> x.name !== item.name);
  }

  function addFilterItem(name) {
    const r = _.findWhere(m.allFilterItems, {name});
    m.container.filters.unshift(prepareFilter(r));
  }

  function init() {
    m.page = null;
    m.query = null;
    m.grid = null;

    m.def = null;
    m.list = [];
    m.allFilterItems = [];

    m.open = open;
    m.loadFilterData = loadFilterData;
    m.init = init;
    m.close = close;
    m.run = run;
    m.showAll = showAll;
    m.selectAll = selectAll;
    m.onQueryChange = onQueryChange;
    m.onSelect = onSelect;
    m.onDelete = onDelete;
  }

  function mdCheckboxState(f) {
    return (f.val.length === 0) ? 'N' : (f.val.length === f.count ? 'A' : 'P');
  }

  function onDelete(f, index, row) {
    f.val = _.without(f.val, row);
    f.checkbox_state = mdCheckboxState(f);
  }

  function onSelect(f, row) {
    f.val.push(row);
    f.checkbox_state = mdCheckboxState(f);
  }

  function onQueryChange(f, query, value) {
    if (value != null) query.filter('name', 'search', '%' + (value || '') + '%');
    const codes = _.pluck(f.val, 'code');
    if (codes.length > 0) query.where(['code', '<>', codes]);
    else query.where(null);
  }

  function selectAll(f) {
    if (f.checkbox_state === 'N' || f.checkbox_state === 'P') {
      const query = m.page.query(m.query_name);
      query.offset(0);
      const limit = query.limit();
      query.limit(m.md_max_count);
      onQueryChange(f, query, null);
      query.fetch(null, f.decorateWith).then(function (r) {
        f.val = _.union(f.val, r.table);
      });
      query.limit(limit);
      f.checkbox_state = 'A';
    } else {
      f.val = [];
      f.checkbox_state = 'N';
    }
  }

  function trimPercent(v) {
    v = v || '';
    if (v.startsWith('%')) {
      v = v.substring(1);
    }
    if (v.endsWith('%')) {
      v = v.substring(0, v.length - 1);
    }
    return v;
  }

  function makeSearch(f, value) {
    f.mode = 'search';
    f.val = trimPercent(value || '');
  }

  function getReferValue(name) {
    return fieldsData.refers[name] || {};
  }

  function prepareMCValue(f, initValue, data) {
    f.val = _.map(data, function (v) {
      return {
        id : v[0],
        name : v[1],
        val : _.contains(initValue, v[0])
      };
    });
  }

  function prepareMTValue(f, initValue, data) {
    f.model = initValue;
    f.val = _.mapRows(data, ['id', 'name', 'parent_id']);
  }

  function fieldInfo(name) {
    const r = fieldsData.fields[name];
    if (!r) {
      throw name + '=> field is not found';
    }
    return r;
  }

  function setOperation(mode) {
    let def_operations = [
      { op: '=', class: 'fas fa-equals', text: bConfig.langs.gf_equal },
      { op: '<>', class: 'fas fa-not-equal', text: bConfig.langs.gf_not_equal }
    ];

    if (_.contains(['number', 'date'], mode)) {
      return def_operations.concat([
        { op: '<', class: 'fas fa-less-than', text: bConfig.langs.gf_less_than },
        { op: '>', class: 'fas fa-greater-than', text: bConfig.langs.gf_greater_than },
        { op: '<=', class: 'fas fa-less-than-equal', text: bConfig.langs.gf_less_than_equal },
        { op: '>=', class: 'fas fa-greater-than-equal', text: bConfig.langs.gf_greater_than_equal }
      ]);
    } else if (mode === 'search') {
      return def_operations.concat([
        { op: 'search', class: 'fas fa-search', text: bConfig.langs.gf_search },
        { op: 'not search', class:'fas fa-unlink fa-rotate-90', text: bConfig.langs.gf_not_search }
      ]);
    } else {
      return def_operations;
    }
  }

  function prepareFilterOrigin(f, v) {
    f = angular.copy(f);

    let field = fieldInfo(f.name);
    let op;
    f.type = field[0];
    f.nulls = v.nulls;

    if (f.decorateWith) {
      field = fieldInfo(f.decorateWith);
      const refData = getReferValue(f.decorateWith);
      op = _.keys(v)[0] || '=';
      f.val = v[op] || [];
      f.val = _.isArray(f.val) ? f.val : [f.val];
      f.val = _.map(f.val, x => String(x));

      if (field[0] === 'O') {
        f.has_value = f.val.length > 0;
        f.mode = 'mc';
        const buf = _.zip(field[2], field[3]);
        prepareMCValue(f, f.val, buf);
      } else if (field[0] === 'R' && refData) {
        f.has_value = f.val.length > 0;

        if (refData.data) {
          if (f.treeWithParent) {
            f.mode = 'mt';
            prepareMTValue(f, f.val, refData.data);
          } else {
            f.mode = 'mc';
            prepareMCValue(f, f.val, refData.data);
          }
        } else {
          f.mode = 'md';
          f.val = _.chain(refData.val || [])
                   .map(x => _.object(['code','name'], x))
                   .filter(x=> _.contains(f.val, x.code))
                   .value();

          f.count = refData.count;
          f.checkbox_state = mdCheckboxState(f);
        }
      } else {
        f.has_value = !_.isEmpty(v) && !!v[_.keys(v)[0]];
        op = _.keys(v)[0] || '=';
        makeSearch(f, v[op]);
      }
    } else if (field[0] === 'N' || field[0] === 'D') {
      let type = 'number', range = 'rangeNumber';

      if (field[0] === 'D') {
        type = 'date';
        range = 'rangeDate';
      }

      switch (f.dateLevel) {
        case 'year':
          f.dateModelFormat = 'YYYY';
          break;
        case 'month':
          f.dateModelFormat = 'MM.YYYY';
          f.dateViewFormat = 'MMMM YYYY';
          break;
        case 'time':
          f.dateModelFormat = 'DD.MM.YYYY hh.mm.ss';
          break;
        default:
          f.dateModelFormat = 'DD.MM.YYYY';
      }

      if (f.directive === 'equal') {
        f.mode = type;
        op = _.keys(v)[0] || '=';

        if (type === 'date') {
          f.val = v[op];
        } else {
          f.val = !_.isEmpty(v) ? v[_.keys(v)[0]] : undefined;
        }

        f.has_value = !!f.val;
      } else if (f.directive === 'range' || !f.directive) {
        f.mode = range;
        f.val  = {
          left : v['>='] || v['<'],
          right : v['<='] || v['>']
        };
        op = (v['<'] || v['>']) ? '<>' : '=';

        if (type === 'date') {
          if (!!f.val.left) f.val.left = moment(f.val.left, 'DD.MM.YYYY hh.mm.ss').format(f.dateModelFormat);
          if (!!f.val.right) f.val.right = moment(f.val.right, 'DD.MM.YYYY hh.mm.ss').format(f.dateModelFormat);
        }

        f.has_value = !!f.val.left || !!f.val.right;
      }
    } else {
      f.has_value = !_.isEmpty(v) && !!v[_.keys(v)[0]];
      op = _.keys(v)[0] || 'search';
      makeSearch(f, v[op]);
    }
    f.operations = setOperation(f.mode);
    f.operation = op ? _.find(f.operations, x => x.op === op) : f.operations[0];
    f.op = op;

    return f;
  }

  function prepareFilter(f) {
    const v = m.query.filter(f.name) || {};
    return prepareFilterOrigin(f, v);
  }

  function prepareFilterList(f) {
    const v = {};
    if (f.decorateWith) v[f.op] = f.val;
    else if (f.type === 'N' || f.type === 'D') {
      if (f.directive ==='equal') {
        v[f.op] = f.val;
      } else {
        const val = f.val || {};
        let left_op = f.op === '=' ? '>=' : '<';
        let right_op = f.op === '=' ? '<=' : '>';
        v[left_op] = val.left;
        v[right_op] = val.right;
      }
    } else {
      v[f.op] = f.val || '';
    }
    v.nulls = f.nulls;
    return prepareFilterOrigin(f, v);
  }

  function fetchFieldsInfo() {
    const fieldValue = {};
    const checkboxLimit = {};
    const treeWithParent = {};

    function pushField(name, val, tree) {
      if (tree) treeWithParent[name] = tree;
      if (_.isArray(fieldValue[name])) {
        fieldValue[name].push(val);
      } else fieldValue[name] = [val];
    }

    _.each(m.list, function(filter) {
      _.each(filter.filters, function(f) {
        if (f.decorateWith) {
          if (f.treeWithParent) pushField(f.decorateWith, f.val, f.treeWithParent);
          else pushField(f.decorateWith, f.val);
        }
      });
    });

    _.each(m.allFilterItems, function(f) {
      if (f.decorateWith) {
        let v = m.query.filter(f.name) || {},
            op = _.keys(v)[0] || '=';
        v = v[op] || [];
        checkboxLimit[f.decorateWith] = f.checkboxLimit;
        if (f.treeWithParent) pushField(f.decorateWith, v, f.treeWithParent);
        else pushField(f.decorateWith, v);
      }
    });

    const s = _.reduce(fieldValue, function (memo, v, k) {
      const val = _.chain(v).flatten().map(x => String(x)).uniq().value();
      memo[k] = {val: val, limit: checkboxLimit[k] || m.checkbox_limit};
      if (treeWithParent[k]) memo[k]['parent_field'] = treeWithParent[k];
      return memo;
    }, {});

    return m.query.fetchFieldsInfo(s);
  }

  function open(query, grid, query_name, page) {
    loadFilterData(query, grid, query_name, page).then(() => {
      $modal.modal('show');
    })
  }

  function loadFilterData(query, grid, query_name, page) {
    init();
    m.page = page;
    m.query = query;
    m.grid = grid;
    m.query_name = query_name;
    const filters = grid.getFilters();
    m.list = filters.list;
    m.def = filters.def;
    m.allFilterItems = filters.all;

    return fetchFieldsInfo().then(function (fds) {
      fieldsData = fds;

      const buf = _.chain(m.allFilterItems)
                   .map(prepareFilter)
                   .filter(x => x.mode === 'mc' && x.val && x.val.length === 0)
                   .pluck('name')
                   .value();
      m.allFilterItems = _.filter(m.allFilterItems, x=> !_.contains(buf, x.name));
      m.def = _.filter(m.def, x=> !_.contains(buf, x.name));

      const def_filter_names = _.pluck(m.def, 'name');

      _.each(m.allFilterItems, function(x) {
        const bf = prepareFilter(x);
        if (!_.contains(def_filter_names, x.name) && bf.has_value) {
          m.def.push(angular.copy(x));
        }
      });

      _.each(m.list, function(item) {
        item.filters = _.filter(item.filters, x=> !_.contains(buf, x.name));
      });

      m.templates = _.map(m.list, function(item) {
        return {
          code: item.code,
          name: item.name,
          pin: item.pin,
          filters: _.map(item.filters, prepareFilterList)
        }
      });

      m.container = _.findWhere(m.templates, { pin: 'Y' });

      if (m.container) m.container.filters = _.map(m.container.filters, prepareFilter);
      else m.container = {filters : _.map(m.def, prepareFilter)};
    });
  }

  function close() {
    if (m.grid) {
      saveFilter();
    }

    init();
    $modal.modal('hide');
  }

  function run() {
    m.query.filterClear();
    m.query.pageNo(1);

    _.each(m.container.filters, function(f) {
      let v, op = f.operation.op;

      switch (f.mode) {
        case 'mc':
          const val = _.chain(f.val).where({
            val: true
          }).pluck('id').value();
          m.query.filter(f.name, op, val, f.nulls);
          break;
        case 'mt':
          m.query.filter(f.name, op, f.model, f.nulls);
          break;
        case 'md':
          m.query.filter(f.name, op, _.pluck(f.val, 'code'), f.nulls);
          break;
        case 'number':
          v = f || {};
          m.query.filter(f.name, op, v.val, f.nulls);
          break;
        case 'rangeNumber':
        case 'rangeDate':
        case 'date':
          v = f.val || {};
          let l = f.val, r = f.val;

          if (f.mode !== 'date') {
            l = v.left;
            r = v.right;
          }

          if (f.mode === 'date' || f.mode === 'rangeDate') {
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
          }

          if (f.mode === 'date') {
            if (!_.isEmpty(v)) m.query.filter(f.name, op, v);
            if (!_.isEmpty(l)) m.query.filter(f.name, 'left', l);
            if (!_.isEmpty(r)) m.query.filter(f.name, 'right', r, f.nulls, 'date');
          } else {
            let op_l = op === '=' ? '>=' : '<';
            let op_r = op === '=' ? '<=' : '>';
            m.query.filter(f.name, op_l, l);
            m.query.filter(f.name, op_r, r, f.nulls);
          }

          break;
        case 'search':
          v = f.val ? _.contains(['=', '<>'], op) ? f.val : '%' + f.val + '%' : null;
          m.query.filter(f.name, op, v, f.nulls);
          break;
      }
    });
    m.grid.refreshCheck();
    m.query.fetch().then(close);
  }

  function showAll() {
    m.query.filterClear();
    m.grid.refreshCheck();
    m.query.fetch().then(close);
  }

  return m;
});