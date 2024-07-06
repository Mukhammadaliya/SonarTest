biruni.directive('bDatePicker', function(bConfig) {
  function link(scope, elem, attr, ctrl) {
    let model_format = attr.bDatePicker,
        view_format = attr.viewFormat;

    if (!model_format) {
      model_format = 'DD.MM.YYYY';
    }

    function controlMinDate() {
      if (attr.minDate) {
        scope.$watch(attr.minDate, function(val) {
          val = val ? moment(val, model_format) : false;
          if (val._isValid) elem.data().DateTimePicker.minDate(val);
        });
      }
    }

    function controlMaxDate() {
      if (attr.maxDate) {
        scope.$watch(attr.maxDate, function(val) {
          val = val ? moment(val, model_format) : false;
          if (val._isValid) elem.data().DateTimePicker.maxDate(val);
        });
      }
    }

    try {
      elem.datetimepicker({
        locale : bConfig.langCode(),
        useCurrent : false,
        format : model_format,
        widgetPositioning: {
          vertical: 'auto',
          horizontal: attr.direction || 'left'
        }
      });
    } catch (e) {
      elem.datetimepicker({
        locale : 'en',
        useCurrent : false,
        format : model_format,
        widgetPositioning: {
          vertical: 'auto',
          horizontal: attr.direction || 'left'
        }
      });
    }

    controlMinDate();
    controlMaxDate();

    if (view_format) {
      scope.$watch(attr.ngModel, function(val) {
        if (val && val.toMoment(model_format)) {
          const date = val.toMoment(model_format).format(view_format);
          const words = date.split(" ");
          const capitalized = words.map((word) => {
              return word[0].toUpperCase() + word.substring(1);
          }).join(" ");
          elem.val(capitalized);
        }
      });
    }

    if (ctrl) {
      elem.on('dp.change', function(k) {
        scope.$apply(function() {
          ctrl.$setViewValue(k.target.value);
        });
      });

      elem.on('dp.show', function(k) {
        if (view_format) {
          scope.$apply(function() {
            let a = (k.target.value || ctrl.$modelValue);
            if (a && a.toMoment(model_format)) {
              const date = a.toMoment(model_format).format(view_format);
              const words = date.split(" ");
              const capitalized = words.map((word) => {
                  return word[0].toUpperCase() + word.substring(1);
              }).join(" ");
              elem.val(capitalized);
            }
          });
        }
      });
    }
    elem.attr("placeholder", attr.placeholder || bConfig.langs.select_date);
  }

  return {
    restrict : 'A',
    require : '?ngModel',
    link : link
  };
});
