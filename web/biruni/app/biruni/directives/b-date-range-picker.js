biruni.directive('bDateRangePicker', function(bConfig, $parse) {
  function link(scope, elem, attrs) {
    moment.locale(bConfig.langCode());

    var $setBeginDate = $parse(attrs.begin).assign;
    var $setEndDate   = $parse(attrs.end).assign;

    var langs = bConfig.langs,
        $div  = elem.find('div'),
        $span = $div.find('span'),
        _start = '',
        _end = '',
        ranges = {},
        locale = {},
        format = "DD.MM.YYYY";

    function fillParams() {
      ranges[langs.dr_today] = [moment(), moment()];
      ranges[langs.dr_yesterday] = [moment().subtract(1, 'days'), moment().subtract(1, 'days')];
      ranges[langs.dr_last_7_days] = [moment().subtract(6, 'days'), moment()];
      if (attrs.hasOwnProperty('halfMonth')) {
        ranges[langs.dr_first_half_month] = [moment().startOf('month'), moment().startOf('month').add(14, 'days')];
        ranges[langs.dr_second_half_month] = [moment().startOf('month').add(15, 'days'), moment().endOf('month')];
      }
      ranges[langs.dr_last_30_days] = [moment().subtract(29, 'days'), moment()];
      ranges[langs.dr_this_month] = [moment().startOf('month'), moment().endOf('month')];
      ranges[langs.dr_last_month] = [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')];

      locale['format'] = format;
      locale['applyLabel'] = langs.dr_apply;
      locale['cancelLabel'] = langs.dr_cancel;
      locale['customRangeLabel'] = langs.dr_custom_range;
      locale['daysOfWeek'] = moment.weekdaysShort().map(x => x.toUpperCase());
      locale['monthNames'] = moment.months().map(x => x.toUpperCase());
      locale['firstDay'] = 1;
    }

    function initial() {
      if(attrs.class) {
        $div.addClass(attrs.class);
      }
      fillParams();
      $div.daterangepicker({
        opens : attrs.align || 'right',
        showDropdowns : false,
        showWeekNumbers : true,
        ranges : ranges,
        buttonClasses : ['btn'],
        applyClass : 'blue',
        cancelClass : 'btn-default',
        format : format,
        locale : locale
      },
      callback
      );
    }

    function viewDate(start, end) {
      $span.text(start.format('MMMM D, YYYY') + ' - ' + end.format('MMMM D, YYYY'));
    }

    function callback(start, end) {
      _start = start.format(format);
      _end   = end.format(format);

      $setBeginDate(scope, _start);
      $setEndDate(scope, _end);
      if(attrs.onChange) {
        $parse(attrs.onChange)(scope, {start : _start,
                                       end   : _end});
      }
      viewDate(start,end);
    }

    function refresh() {
      if(_start && _end) {
        var start = moment(_start, format);
        var end = moment(_end, format);
        $div.data('daterangepicker').setStartDate(start);
        $div.data('daterangepicker').setEndDate(end);
        viewDate(start, end);
      }
    }

    scope.$watch(attrs.begin, function(value) {
      if(value) {
        _start = value;
        refresh();
      }
    });

    scope.$watch(attrs.end, function(value) {
      if(value) {
        _end = value;
        refresh();
      }
    });

    scope.$watchCollection(attrs.custom, function(value) {
      if (value) {
        ranges = [];
        if (!!value.length) {
          _.each(value, x => {
            ranges[x.name()] = [x.begin_date, x.end_date];
          });

          $div.daterangepicker({
            opens : attrs.align || 'right',
            showDropdowns : false,
            showWeekNumbers : true,
            ranges : ranges,
            buttonClasses : ['btn'],
            applyClass : 'blue',
            cancelClass : 'btn-default',
            format : format,
            locale : locale
          },
          callback
          );
        }
      }
    });

    initial();
  }

  return {
    restrict : 'E',
    scope : true,
    template : function(tElem, tAttr) {
      return '<div class="btn btn-default">'
                  + '<i class="fa fa-calendar"></i> &nbsp;'
                  + '<span class="uppercase"></span> &nbsp;'
                  + '<b class="fa fa-angle-down"></b>'
              + '</div>';
    },
    link : link
  }
});