biruni.directive('bGrid', function ($rootScope, $parse, $compile, $http, $timeout, $q, bAlert, bStorage, bRoutes) {
  let docMouseMove;
  let docMouseUp;
  let downEvents = 'mousedown touchstart';
  let moveEvents = 'mousemove touchmove';
  let upEvents = 'mouseup touchend'
  let hasTouch = hasTouchDevice();

  function getX(e) {
    return e.pageX ?? (e.touches && e.touches[0]?.pageX) ?? (e.changedTouches && e.changedTouches[0].pageX);
  }

  function parse(attr) {
    if (attr) {
      return $parse(attr);
    }
  }

  function applyProps(elem) {
    elem.find('.tbl').find('.tbl-header,.tbl-body').css('min-width', elem.data().width);
  }

  function justifyBtnPosition(elem, tbl) {
    elem.css('bottom', Math.max(tbl.offsetHeight - tbl.clientHeight - 2, 0));
  }

  function makeScroll(tbl, gridScroll, curId) {
    // Set to old scroll position if possible
    var preventScroll;

    if (curId != gridScroll.id()) {
      let scroll = gridScroll.scroll();
      if (String(scroll)) {
        preventScroll = true;
        tbl.scrollTop(scroll);
      }
    }
    gridScroll.id(curId);

    let isScrollToTopEnabled = false;
    let hParent = tbl.parent();
    let tblBody = tbl.find(".tbl-body");
    let scrollToTopBtn = $('<button class="tbl-scroll-to-top-btn"><i class="fas fa-chevron-up"></i></button>')
    .on("click", function() {
      tbl.get(0).scrollTo({
        top: 0,
        behavior: "smooth"
      });
    });

    let scrollToTopContainer = $('<div class="scroll-to-top-container"></div>').append(scrollToTopBtn).append('<div class="scroll-to-top-shadow"></div>');
    tbl.on("scroll", function() {
      if (!isScrollToTopEnabled && tbl.scrollTop() > 450) {
        tblBody.addClass('tbl-body-scroll-active');
        scrollToTopContainer.addClass("visible");
        isScrollToTopEnabled = true;
      } else if (isScrollToTopEnabled && tbl.scrollTop() <= 450) {
        isScrollToTopEnabled = false;
        tblBody.removeClass('.tbl-body-scroll-active')
        scrollToTopContainer.removeClass("visible");
      }
      if (preventScroll) {
        preventScroll = false;
      } else {
        gridScroll.scroll(tbl.scrollTop());
      }
      if (isScrollToTopEnabled) justifyBtnPosition(scrollToTopContainer, tbl.get(0));
    });
    hParent.append(scrollToTopContainer);
  }

  function enableResizers(table, grid) {
    var headerCells = table.find('.tbl-header-cell:not(.tbl-empty-cell)');
    var resizingCell,
        startOffset,
        sizeArray;

    docMouseMove = function (e) {
      if (resizingCell) {
        if (!hasTouch) e.preventDefault();
        sizeArray = table.css("grid-template-columns").split(" ");
        let tableWidth = table.find('.tbl-header').outerWidth();
        let pos = startOffset + getX(e);
        let calc = Math.max(pos / tableWidth * 100, 4); // 4 - the largest int, which is smaller than the size of col-1
        if (tableWidth) sizeArray[resizingCell.index()] = parseFloat(calc).toFixed(2) + "%";
        table.css("grid-template-columns", sizeArray.join(" "));
      }
    };
    docMouseUp = function () {
      if (resizingCell) {
        resizingCell.removeClass("active");
        table.css("user-select", "auto");
        if (grid.g.withCheckbox) sizeArray.shift();
        grid.g.cols = _.map(grid.g.cols, function (col, idx) {
          return {
            name: col.name,
            size: sizeArray[idx]
          };
        });
        grid.saveSettingChanges();
        resizingCell = undefined;

        let scrollToTopBtn = table.parent().find(".scroll-to-top-container");
        justifyBtnPosition(scrollToTopBtn, table.find(".tbl-body").get(0));
      }
    };
    _.each(headerCells, function(th) {
      let grip = $('<div></div>').addClass("tbl-cell-resizer");
      grip.on(downEvents, function (e) {
        e.preventDefault();
        resizingCell = $(this).closest('.tbl-header-cell');
        resizingCell.addClass("active");
        table.css("user-select", "none");
        startOffset = parseFloat(th.offsetWidth - getX(e));
      });
      if (hasTouch) grip.addClass("resizer-active");
      $(th).append(grip);
    });

    $(document).on(moveEvents, docMouseMove).on(upEvents, docMouseUp);
  }

  /** Calculate table's maxHeight */
  function calcTableMaxHeight(elem) {
    let headerHeight = ($(window).innerWidth() > 991 ? $("#kt_header").outerHeight(true) : $("#kt_header_mobile").outerHeight(true)) || 0;
    let subheaderHeight = $('.subheader').outerHeight(true) || 0;
    let toolbarHeight = elem.closest('b-page').find('.b-toolbar').outerHeight(true) || 0;
    let contentPadding = (parseFloat($('#kt_content').css('padding-bottom')) || 0) + (parseFloat($('#kt_content').css('padding-top')) || 0);
    let footerHeight = $('.footer').outerHeight(true) || 0;
    let tableContainerMaxHeight = $(window).innerHeight() - headerHeight - subheaderHeight - toolbarHeight - contentPadding - footerHeight;
    return tableContainerMaxHeight
  }

  function render(elem, html, query, grid, scope, attr, gridScroll, curId, newId, oldId) {
    if (newId && newId != oldId) {
      elem.html(html());
      const maxHeight = calcTableMaxHeight(elem);
      elem.append($compile(`
      <b-grid-filter-panel
        ng-style="{
                  'order': o.g.filterPanelDirection == 'left' ? '1' : '3',
                  'width': o.g.filterPanelWidth + 'px',
                  'padding': o.g.filterPanelDirection == 'left' ? '0px 5px 0px 0px' : '0px 0px 0px 5px'
                  }"
        style="max-height: ${maxHeight}px; position: relative;"
        ng-if="o.g.showFilterPanel && o.g.openFilterPanel"
        name="${attr.name}"/>`)(scope));
      var table = elem.find('.tbl');
      table.css('max-height', maxHeight + 'px');
      elem.css('display', 'flex');
      elem.show();
      elem.find('.tbl-header [sort-header]').click(function () {
        var name = $(this).attr('sort-header'),
          sortCol = _.first(query.sort()),
          sortDir = _.first(sortCol);
        if (sortDir === '-') {
          sortCol = sortCol.substring(1);
        }
        if (sortCol === name) {
          if (sortDir === '-') {
            query.sort([]);
          } else {
            query.sort(['-' + name]);
          }
        } else {
          query.sort([name]);
        }
        grid.refreshCheck();
        query.fetch();
      });

      enableResizers(table, grid);
      table.hScroll();
      makeScroll(table, gridScroll, curId);

      applyProps(elem.data({
        width: attr.minWidth ?? 880
      }));
    }

    scope.$on('$destroy', function() {
      $(document).off(moveEvents, docMouseMove);
      $(document).off(upEvents, docMouseUp);
    });
  }

  function showAction($t, grid, scope) {
    var acn = '.tbl-row-action';
    var $elem = $t.find('sliding');
    var $a = $elem.find(acn);

    if ($a.length == 0) {
      $elem.append(grid.g.actionHtml);
      $a = $elem.find(acn);
      var s = scope.$new(false);
      s.row = grid.rowAt($t.index());
      $compile($a.contents())(s);
    }
    $a.show();
  }

  function showRows($t, grid, scope, event) {
    var $elem = $t.find('sliding');
    var $rests;
    if ($(event.target).closest('.tbl-row-action').length == 0) {
      if ($elem.hasClass('opened-slider')) {
        $elem.removeClass('opened-slider');
        $elem.addClass('closed-slider');
        $elem.slideUp(100);
        $t.removeClass('open');
      } else {
        $rests = $t.parent().find('sliding.opened-slider');
        $rests.removeClass('opened-slider');
        $rests.addClass('closed-slider');
        $rests.slideUp(100);
        $rests.closest('.tbl-row-menu').removeClass('open');

        $elem.removeClass('closed-slider');
        $elem.addClass('opened-slider');
        $elem.slideDown(200);
        $t.addClass('open');
      }

      $elem.css({ display: 'flex' });
    }
  }

  function checkRow(elem) {
    elem.find('[data-bcheck]').click();

    var openSlider = elem.parent().find('sliding.opened-slider');

    if (openSlider.length > 0) {
      openSlider.removeClass('opened-slider');
      openSlider.addClass('closed-slider');
      openSlider.slideUp(100);
      openSlider.closest('.tbl-row-menu').removeClass('open');

      var openRow = openSlider.closest('.tbl-row-menu');

      if (!elem.is(openRow)) {
        var checkbox = openRow.parent().find('[data-bcheck]');
        if (!checkbox.prop('checked')) checkbox.click();
      }
    }
  }

  function onRowClick(scope, grid, event) {
    event.preventDefault();

    if (event.ctrlKey) {
      checkRow($(this));
      return;
    }

    if (grid.g.actionHtml) {
      scope.$apply(_.partial(showAction, $(this), grid, scope));
    }
    scope.$apply(_.partial(showRows, $(this), grid, scope, event));
  }

  function onRowDoubleClick(scope, gridRowAt, doubleClick, event) {
    event.preventDefault();
    if (_.isFunction(doubleClick)) {
      var val = {
        row: gridRowAt($(this).index())
      };
      scope.$apply(_.partial(doubleClick, scope, val));
    }
  }

  function onCellClick(scope, grid, event) {
    event.preventDefault();
    event.stopPropagation();
    var cb = grid.g.fields[$(this).attr('cn')];
    if (cb && cb.onClick) {
      if (_.isString(cb.onClick)) {
        cb = parse(cb.onClick);
      }
      var val = {
        row: grid.rowAt($(this).closest('.tbl-row').index())
      };
      scope.$apply(_.partial(cb, scope, val));
    }
  }

  function composeOnCheck(scope, onCheck, checkedApi, indices) {
    if (onCheck) {
      onCheck(scope, {
        checked: checkedApi(indices)
      });
    }
  }

  function whenCheck(elem, scope, onCheck, event) {
    event.stopPropagation();
    if (event.target.tagName != "INPUT") return;
    var checkAll = elem.find('input[bcheckall]');
    var checkboxes = elem.find('input[data-bcheck]');
    var indices = _.chain(checkboxes)
      .filter(function (x) {
        return x.checked;
      })
      .map(function (x) {
        return parseInt(x.dataset.bcheck);
      })
      .value();

    checkAll.prop('indeterminate', indices.length > 0 && indices.length != checkboxes.length);
    checkAll.prop('checked', indices.length > 0);

    scope.$apply(_.partial(onCheck, indices));
  }

  function whenCheckAll(elem, scope, onCheck, event) {
    var ch = this.checked;
    elem.find('input[data-bcheck]').each(function () {
      this.checked = ch;
    });
    whenCheck(elem, scope, onCheck, event);
  }

  function splitNames(xs) {
    if (xs) {
      return _.chain(xs.split(','))
        .invoke('trim')
        .compact()
        .value();
    }
    return [];
  }

  function setFieldFlags(grid, fieldNames, flagNames) {
    _.each(fieldNames, function (fn) {
      var f = grid.getField(fn);
      _.each(flagNames, function (n) {
        f[n] = true;
      });
    });
  }

  function translateFields(g, translate) {
    var prefix = g.translateKey;
    if (_.isUndefined(prefix)) {
      prefix = g.name + '.';
    }
    _.each(g.fields, function (f) {
      if (f.column || f.searchable) {
        f.label = translate(prefix + f.name);
      } else if (f.filter) {
        f.label = translate(prefix + (f.decorateWith || f.name));
      }
    });
  }

  function evalGridData(grid) {
    var path = grid.query().path(),
        s = bStorage.json(path);

    if (s.cols && _.every(s.cols, x => grid.g.fields[x.name])) {
      grid.g.cols = s.cols;
    }

    grid.g.openFilterPanel = s.openFilterPanel == true;
    grid.g.filterPanelDirection = s.filterPanelDirection ?? 'right';
    grid.g.filterPanelWidth = s.filterPanelWidth ?? 400;

    if (s.search && _.every(s.search, function (n) {
      var f = grid.g.fields[n];
      return f && (f.search || f.searchable);
    })) {
      _.each(grid.g.fields, function (field) {
        field.search = _.contains(s.search, field.name);
      });
      grid.query().searchFields(s.search);
    }

    grid.disableRevokedColumns();
  }

  function ctrl($scope, $attrs) {
    var grid = $scope.bPage.grid($attrs.name);
    $scope.row = {};

    function setFlags(names, flagNames) {
      names = names ? names.trim() : '';
      if (names.startsWith("{{") && names.endsWith("}}")) {
        names = $parse(names.substr(2, names.length - 4))($scope);
      }
      setFieldFlags(grid, splitNames(names), flagNames);
    }

    setFlags($attrs.required, ['required']);
    setFlags($attrs.search, ['search', 'searchable']);
    setFlags($attrs.searchable, ['searchable']);
    setFlags($attrs.extraColumns, ['column']);

    var searchNames =
      _.chain(grid.g.fields)
        .where({
          search: true
        })
        .pluck('name')
        .value();

    grid.query().searchFields(searchNames);

    var sortFields = splitNames($attrs.sort);
    if (sortFields.length) grid.query().sort(sortFields);

    grid.g.name = $attrs.name;
    grid.g.translateKey = $attrs.translateKey;
    this.grid = grid;
  }

  function loadGridData(path, grid) {
    if ($rootScope.is_debug) return $q.all([]);
    return $http.post(bRoutes.LOAD_GRID_DATA, {
      path: path
    }).then(function (result) {
      if (!_.isEmpty(result.data.revoked_columns)) {
        _.each(grid.g.fields, function(f, c) {
          f.revoked = !f.required && _.indexOf(result.data.revoked_columns, c) > -1;
        });
      }
      if (result.data.settings) {
        const settings = JSON.parse(result.data.settings);
        bStorage.json(path, settings);
      } else {
        bStorage.text(path, null);
      }
    }, function (error) {
      console.error('grid setting loader', error);
    });
  }

  function link(scope, elem, attr, ctrl) {
    var gridScroll = scope.bPage.gridScroll(attr.name);
    var curId = _.uniqueId();
    var grid = ctrl.grid;
    grid.onCheck = parse(attr.onCheck);

    var query = grid.query(),
        onDblclick = parse(attr.onDblclick),
        onCheck = _.partial(composeOnCheck, scope, grid.onCheck, grid.checkedApi, _),
        htmlTable = _.partial(grid.htmlTable, !!attr.onCheck);

    translateFields(grid.g, scope.bPage.translate);

    if (attr.onCheck) {
      grid.g.withCheckbox = true;
      grid.refreshCheck = function () {
        grid.onCheck(scope, {
          checked: grid.checkedApi([])
        });
      }
    } else {
      grid.refreshCheck = _.noop;
    }

    loadGridData(query.path(), grid).finally(function () {
      evalGridData(grid);
      scope.$watch(query.fetching, _.partial(render, elem, htmlTable, query, grid, scope, attr, gridScroll, curId));
      if (grid.g.enabled) {
        grid.fetch().then(null, function (result) {
          bAlert.open(result);
        });
      }
    });

    elem.on('click', '.tbl > .tbl-body > .tbl-row', _.partial(onRowClick, scope, grid, _));
    elem.on('click', '.tbl > .tbl-body a.b-grid-cell', _.partial(onCellClick, scope, grid, _));
    elem.on('dblclick', '.tbl > .tbl-body > .tbl-row:not(.no-data-row)', _.partial(onRowDoubleClick, scope, grid.rowAt, onDblclick, _));

    elem.on('click', 'input[bcheckall]', _.partial(whenCheckAll, elem, scope, onCheck, _));
    elem.on('click', '.tbl > .tbl-body .checkbox', _.partial(whenCheck, elem, scope, onCheck, _));
    elem.on('dblclick', '.tbl > .tbl-body .checkbox', function (e) {
      e.stopPropagation();
    });

    $(window).resize(function () {
      scope.$apply(function () {
        grid.g.showFilterPanel = window.innerWidth > 776;
      });
    });

    scope.o = grid;
    scope.bPage.qLoaded.promise.then(_.partial(onCheck, []));
  }

  return {
    restrict: 'E',
    scope: true,
    controller: ctrl,
    link: link
  };
});
