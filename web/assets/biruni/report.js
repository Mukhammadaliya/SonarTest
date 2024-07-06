$(function () {
  $.urlParam = function (name) {
    var results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
    if (results == null) {
      return null;
    } else{
      return results[1] || 0;
    }
  }

  function replaceQueryParam(param, newval, search) {
    var regex = new RegExp("([?;&])" + param + "[^&;]*[;&]?");
    var query = search.replace(regex, "$1").replace(/&$/, '');

    return (query.length > 2 ? query + "&" : "?") + (newval ? param + "=" + newval : '');
  }

  var $tables = $('table');

  function go(tableParam, cellParam, menuId, newWindow) {
    var p = {
        url: location.pathname,
        method: 'POST',
        headers: {
          project_code: $.urlParam('-project_code'),
          filial_id: $.urlParam('-filial_id'),
          lang_code: $.urlParam('-lang_code')
        },
        data: {
          rt: 'go',
          table_param: tableParam,
          cell_param: cellParam,
          menu_id: menuId
        },
        dataType: 'json',
        contentType: 'application/json'
    };

    p.data = JSON.stringify(p.data);

    $.ajax(p).done(function (d) {
      if(d.param) {
        d.param.rt = 'html';
        d.param['-project_code'] = $.urlParam('-project_code');
        d.param['-filial_id'] = $.urlParam('-filial_id');
        d.param['-lang_code'] = $.urlParam('-lang_code');
      }

      var href = null;

      if (d.type == 'report') {
        href = d.context_path + '/b' + d.uri + '?' + $.param(d.param, true);
        if (newWindow) {
          window.open(href);
        } else {
          window.location.href = href;
        }
      } else if (d.type == 'form') {
        var spt = d.uri.indexOf('?') > -1? '&': '?';
        d.param['-filial_id'] = d.filial_id || d.param['-filial_id'];
        href = d.context_path + '/#' + d.uri + spt + $.param(d.param, true);
        window.open(href);
      } else if (d.type == 'window') {
        href = (d.context_path || '') + d.uri + (d.param ? '?' + $.param(d.param, true) : '');
        window.open(href);
      }
    });
  }

  function run(type) {
    window.open(window.location.pathname + replaceQueryParam('rt', type, window.location.search));
  }

  var tableParam, cellParam;

  function showMenu(element, menu_ids, left, top) {
    var html = '';

    menu_ids.forEach(function (id, index) {
      var item = reportMenu.find(function (m) {
        return m[0] == id;
      });
      html = html + '<li><a>' + item[1] + '<pm>' + id + '</pm><span style="float:right;padding:2px;font-size:13px;color:#1a0dab;cursor:pointer;" title="New window" class="fa fa-external-link"></span></a></li>';
    });

    var $cellMenu = $('#cell-menu');
    $('#cell-menu ul').html(html);
    $cellMenu.css('display', 'block');
    $cellMenu.css('left', left + 'px');
    $cellMenu.css('top', top + 'px');
  }

  $('#cell-menu').click(function (e) {
    var $l = $(e.target);
    if ($l.is('a')) {
      go(tableParam, cellParam, $l.children('pm').text(), e.ctrlKey);
    } else if ($l.is('span')) {
      go(tableParam, cellParam, $l.siblings('pm').text(), true);
    }
  });

  function closeCellMenu() {
    if ($('#cell-menu').css('display') == 'block') {
      $('#cell-menu').css('display', 'none');
    }
  }

  $tables.click(function (e) {
    var $table = $(e.currentTarget);
    var $td = $(e.target);
    if ($td.is('td')) {
      var $pm = $td.children('pm');
      if ($pm.length) {
        var $menu = $td.children('menu-ids');
        if ($menu.length) {
          tableParam = $table.prev('pm').text();
          cellParam = $pm.text();
          showMenu($td, $menu.text().split(','), $td.offset().left, $td.offset().top + $td.height() + 5);
        } else {
          go($table.prev('pm').text(), $pm.text(), null, e.ctrlKey);
        }
      } else {
        closeCellMenu();
      }
    }
  });

  $(document).click(function (e) {
    if (!$('td').is(e.target)) {
      closeCellMenu();
    }
  });

  let print_btn;
  switch ($.urlParam('-lang_code') || navigator.language || navigator.browserLanguage || navigator.userLanguage || '') {
    case 'en': print_btn = 'Print'; break;
    case 'ru': print_btn = 'Печать'; break;
    case 'uz': print_btn = 'Chop etish'; break;
  }

  $('#print-btn')
    .append($('<span>').html(print_btn ? print_btn.toUpperCase() : ''))
    .click(function () {
      window.print();
    });

  $('#report-types').click(function (e) {
    var $element = $(e.target), $pm;
    if ($element.is('button') || $element.is('a')) {
      $pm = $element.children('pm');
      if ($pm.length == 1) {
        run($pm.text());
      }
    } else if ($element.is('span') || $element.is('i')) {
      $pm = $element.next('pm');
      run($pm.text());
    }
  });

  var project_code = $.urlParam('-project_code');
  var defConfig = {
    about: "http://smartup.uz/",
    index: {
      img_src: {
        logo: "assets/img/logo_smartup.png"
      }
    }
  };

  function defaults(value, def) {
    if (value instanceof Object && def instanceof Object) {
      let keys = Object.keys(def);
      for (let i = 0; i < keys.length; i ++) {
        let key = keys[i],
            val = def[key];
        if (value.hasOwnProperty(key)) value[key] = defaults(value[key], val);
        else value[key] = val;
      }
    }
    return value;
  }

  function setReportHeader() {
    $.get(`/page/config/${project_code}/config.json`, null, null, 'json').done(function(result) {
      let config = defaults((result || {}), defConfig);
      let report_brand = $('.report-brand');
      report_brand.find('a').attr('href', config.about);
      report_brand.find('img').attr('src', '/' + config.index.img_src.logo);
    });
  }

  let headerParam = window.location.search.match(/(\?|&)header\=([^&]*)/);
  let hideHeader = headerParam != null && decodeURIComponent(headerParam[2]) == 'false';

  if (window != window.parent || hideHeader) {
    $('#report-header').hide();
  } else {
    setReportHeader();
  }
});