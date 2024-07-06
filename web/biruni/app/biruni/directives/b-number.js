biruni.directive('bNumber', function ($filter) {
  function parseNumber(v, d) {
    try {
      if (v) {
        return parseInt(v);
      } else {
        return d;
      }
    } catch (e) {
      return d;
    }
  }

  function transformValue(val, type) {
    var transformed = val.replace(/[,]/g, '.').replace(/[^0-9.-]/g, '');
    if (transformed) {
      if (type == "signed") {
        transformed = transformed.replace(/[.]/, '#').replace(/[.]/g, '').replace(/[#]/, '.');
        transformed = transformed[0] + transformed.substr(1).replace(/[-]/g, '');
      } else {
        transformed = transformed.replace(/[.]/, '#').replace(/[.]/g, '').replace(/[#]/, '.').replace(/[-]/g, '');
      }
    }
    return transformed;
  }

  function parseModelVal(val, scale, fill_with_zero) {
    val = formatNumber(val, scale, fill_with_zero).replace(/\s/g, '');
    if (scale && /[.]/.test(val)) val =  val.replace(/[0]+$/, '');
    if (val.slice(-1) == '.') val = val.slice(0, -1);
    return val;
  }

  var formatNumber = $filter('bNumber'),
      NUMBER_REGEXP = /^\-?[0-9 ]*[.]?[0-9 ]*$/;

  var default_precision = 14,
      default_scale = 6;

  function link(scope, elem, attr, ctrl) {
    var precision = default_precision,
        scale = default_scale,
        fill_with_zero = !_.isUndefined(attr.fillWithZero);

    if (NUMBER_REGEXP.test(attr.precision)) {
      precision = parseNumber(attr.precision, default_precision);
    } else {
      scope.$watch(attr.precision, x => precision = parseNumber(x, default_precision));
    }

    if (NUMBER_REGEXP.test(attr.scale)) {
      scale = parseNumber(attr.scale, default_scale);
    } else {
      scope.$watch(attr.scale, function(x) {
        scale = parseNumber(x, default_scale);
        ctrl.$setViewValue(formatNumber(ctrl.$viewValue, scale, fill_with_zero));
      });
    }

    function parser(value) {
      if (value) {
        var transformed = transformValue(value, attr.bNumber);
        if (transformed != value) {
          ctrl.$setViewValue(transformed);
          ctrl.$render();
        }
        return parseModelVal(transformed, scale, fill_with_zero);
      }
      return value;
    }

    function validateNumber(modelValue, viewValue) {
      if (ctrl.$isEmpty(modelValue)) {
        return true;
      }
      return NUMBER_REGEXP.test(viewValue);
    }

    function validatePrecision(modelValue, viewValue) {
      if (ctrl.$isEmpty(modelValue)) {
        return true;
      }
      var v = viewValue.replace(/[- ]/g, '').split('.')[0];
      return v.length <= precision || v == '0';
    }

    function validateScale(modelValue, viewValue) {
      if (ctrl.$isEmpty(modelValue)) {
        return true;
      }
      var v = viewValue.replace(/[- ]/g, '').split('.')[1];
      return !v || v.length <= scale;
    }

    elem.css({
      'text-align' : 'right'
    });

    ctrl.$parsers.push(parser);
    ctrl.$validators.number = validateNumber;
    ctrl.$validators.precision = validatePrecision;
    ctrl.$validators.scale = validateScale;

    function OnFocus() {
      if (NUMBER_REGEXP.test(ctrl.$viewValue)) {
        elem.val(parseModelVal(ctrl.$viewValue, scale, fill_with_zero));
      } else {
        elem.val(ctrl.$viewValue);
      }
    }

    function OnBlur() {
      if (NUMBER_REGEXP.test(ctrl.$viewValue)) {
        var v = formatNumber(ctrl.$viewValue, scale, fill_with_zero);
        ctrl.$setViewValue(v);
        elem.val(v);
      }
    }

    elem.on('blur', OnBlur);
    elem.on('focus', OnFocus);

    scope.$watch(attr['ngModel'], function () {
      if (document.activeElement != elem[0]) {
        OnBlur();
      }
    });
  }

  return {
    restrict : 'A',
    require : '^ngModel',
    link : link
  };
});