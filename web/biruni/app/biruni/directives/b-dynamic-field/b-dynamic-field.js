biruni.directive('bDynamicField', function($parse) {
  function validate(_$b) {
    _$b.q.is_valid = true;
    let fields = _$b.d?.dynamic_fields;
    assert(_.isEmpty(_$b.d?.filled_field_id) || !isNaN(+_$b.d?.filled_field_id), `INVALID PROPERTY "filled_field_id". filled_field_id is not a number!`, invalidate);
    // validation of fields
    assert(Array.isArray(fields), `INVALID PROPERTY "dynamic_fields". dynamic_fields is not iterable!`, invalidate);
    _.each(fields, (f, i) => {
      assert(!isNaN(+f.field_id), `INVALID FIELD PROPERTY "field_id". dynamic_fields[${i}].field_id is not a number!`, invalidate);
      assert(typeof f.name === 'string', `INVALID FIELD PROPERTY "name". dynamic_fields[${i}].name is not a string!`, invalidate);
      assert(_.contains(['N', 'T', 'S', 'C', 'D'], f.type), `INVALID FIELD PROPERTY "type". dynamic_fields[${i}].type is invalid!`, invalidate);
      assert(_.isEmpty(f.required) || _.contains(['Y', 'N'], f.required), `INVALID FIELD PROPERTY "required". dynamic_fields[${i}].required is invalid!`, invalidate);
      assert(_.isEmpty(f.order_no) || !isNaN(+f.order_no), `INVALID FIELD PROPERTY "order_no". dynamic_fields[${i}].order_no is not a number!`, invalidate);
      // validation of options
      if (_.contains(['C', 'D'], f.type)) {
        assert(Array.isArray(f.options), `INVALID FIELD PROPERTY "options". dynamic_fields[${i}].options is not iterable!`, invalidate);
        _.each(f.options, (o, j) => {
          assert(!isNaN(+o.option_id), `INVALID OPTION PROPERTY "option_id". dynamic_fields[${i}].options[${j}].option_id is not a number!`, invalidate);
          assert(typeof o.option_name === 'string', `INVALID OPTION PROPERTY "option_name". dynamic_fields[${i}].options[${j}].name is not a string!`, invalidate);
          assert(_.isEmpty(o.option_order) || !isNaN(+o.option_order), `INVALID OPTION PROPERTY "option_order". dynamic_fields[${i}].options[${j}].option_order is not a number!`, invalidate);
          assert(_.isEmpty(o.preselected) && typeof o.preselected !== 'number' || _.contains(['Y', 'N'], o.preselected), `INVALID OPTION PROPERTY "preselected". dynamic_fields[${i}].options[${j}].preselected is not valid!`, invalidate);
        });
        // validation of value options
        assert(_.isEmpty(f.value_options) || Array.isArray(f.value_options), `INVALID FIELD PROPERTY "value_options". dynamic_fields[${i}].value_options is not iterable!`, invalidate);
        if (!_.isEmpty(f.value_options)) {
          _.each(f.value_options, vo => assert(!isNaN(+vo), `INVALID FIELD PROPERTY "value_options". dynamic_fields[${i}].value_options is not Array<Number>!`, invalidate));
        }
      }
      // validation of values
      if (f.type === 'N') {
        assert(_.isEmpty(f.value) || !isNaN(+f.value), `INVALID FIELD PROPERTY "value". dynamic_fields[${i}].value is not a number!`, invalidate);
      } else {
        assert(_.isEmpty(f.value) && typeof f.value !== 'number' || typeof f.value === 'string', `INVALID FIELD PROPERTY "value". dynamic_fields[${i}].value is not a string!`, invalidate);
      }
    });

    function invalidate() {
      _$b.q.is_valid = false
    }
  }

  function init(_$b) {
    validate(_$b);
    _.each(_$b.d.dynamic_fields, (field, index) => {
      if (!_.contains(['C', 'D'], field.type)) return;
      let is_edit = !!_$b.d?.filled_field_id;
      let is_touched = _.any(field.options, o => o.selected);

      if (is_edit || is_touched) {
        _.each(field.options, o => {
          if (_.contains(field.value_options, o.option_id)) o.selected = 'Y';
          else o.selected = 'N';
        });
      } else {
        _.each(field.options, o => o.selected = o.preselected);
      }
      field.options = _.sortBy(field.options, o => +o.option_order);

      if (field.type === 'C') {
        _$b.onChangeCheckbox(index);

      } else if (field.type === 'D') {
        _.any(field.options, option => {
          if (option.selected !== 'Y') return false;
          _$b.onSelectDropdown(option, index);
          return true;
        });
      }
    });

    _$b.d.dynamic_fields = _.sortBy(_$b.d.dynamic_fields, x => +x.order_no);
  }

  function ctrl($scope, $attrs) {
    let d = {}, q = {};
    q.col_size = +attrValue('size') || 24;
    if (q.col_size < 1 || q.col_size > 24) q.col_size = 24;
    q.row_col_count = Math.floor(24 / q.col_size) || 1;
    q.mode = isAttrTruthy('editable') ? 'E' : 'V';
    d = attrValue('localData');

    $scope.$watch($attrs.localData, localData => {
      if (_.isUndefined(localData) || _.isEmpty(localData)) return;
      $scope._$bFields.d = d = localData;
      init($scope._$bFields);
    });

    function attrValue(key) {
      return $parse($attrs[key])($scope);
    }

    function isAttrTruthy(key) {
      if (_.has($attrs, key)) {
        let value = attrValue(key);
        return _.isUndefined(value) || value === '' || !!value;
      } else return false;
    }

    function onChangeCheckbox(field_index) {
      let field = d.dynamic_fields[field_index];
      field.value = '';
      field.value_options = _.chain(field.options)
                              .filter(o => o.selected === 'Y')
                              .pluck('option_id')
                              .compact()
                              .value();
    }

    function onSelectDropdown(option, field_index) {
      let field = d.dynamic_fields[field_index];
      _.each(field.options, o => {
        if (o.option_id == option.option_id) o.selected = 'Y';
        else o.selected = 'N';
      });
      field.selected_option_id = option.option_id;
      field.selected_option_name = option.option_name;
      field.value = '';
      field.value_options = _.compact([option.option_id]);
    }

    $scope._$bFields = {
      d,
      q,
      onChangeCheckbox,
      onSelectDropdown,
      contains: _.contains
    };
  }

  return {
    restrict: 'E',
    scope: true,
    controller: ctrl,
    templateUrl: 'b-dynamic-field.html'
  }
});
