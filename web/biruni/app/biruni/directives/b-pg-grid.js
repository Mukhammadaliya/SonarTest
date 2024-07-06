biruni.directive('bPgGrid', function($rootScope, $compile, $parse, $timeout, bStorage, bConstants, $http, bRoutes) {
  let docMouseMove;
  let docMouseUp;
  let downEvents = 'mousedown touchstart';
  let moveEvents = 'mousemove touchmove';
  let upEvents = 'mouseup touchend';
  let hasTouch = hasTouchDevice();

  let keyInfo = [
    { "name": "backspace", "key": "Backspace", "code": "Backspace", "keyCode": 8 },
    { "name": "tab", "key": "Tab", "code": "Tab", "keyCode": 9 },
    { "name": "enter", "key": "Enter", "code": "Enter", "keyCode": 13 },
    { "name": "pause/break", "key": "Pause", "code": "Pause", "keyCode": 19 },
    { "name": "caps lock", "key": "CapsLock", "code": "CapsLock", "keyCode": 20 },
    { "name": "escape", "key": "Escape", "code": "Escape", "keyCode": 27 },
    { "name": "space", "key": "", "code": "Space", "keyCode": 32 },
    { "name": "page up", "key": "PageUp", "code": "PageUp", "keyCode": 33 },
    { "name": "page down", "key": "PageDown", "code": "PageDown", "keyCode": 34 },
    { "name": "end", "key": "End", "code": "End", "keyCode": 35 },
    { "name": "home", "key": "Home", "code": "Home", "keyCode": 36 },
    { "name": "left arrow", "key": "ArrowLeft", "code": "ArrowLeft", "keyCode": 37 },
    { "name": "up arrow", "key": "ArrowUp", "code": "ArrowUp", "keyCode": 38 },
    { "name": "right arrow", "key": "ArrowRight", "code": "ArrowRight", "keyCode": 39 },
    { "name": "down arrow", "key": "ArrowDown", "code": "ArrowDown", "keyCode": 40 },
    { "name": "print screen", "key": "PrintScreen", "code": "PrintScreen", "keyCode": 44 },
    { "name": "insert", "key": "Insert", "code": "Insert", "keyCode": 45 },
    { "name": "delete", "key": "Delete", "code": "Delete", "keyCode": 46 },
    { "name": 0, "key": 0, "code": "Digit0", "keyCode": 48 },
    { "name": 1, "key": 1, "code": "Digit1", "keyCode": 49 },
    { "name": 2, "key": 2, "code": "Digit2", "keyCode": 50 },
    { "name": 3, "key": 3, "code": "Digit3", "keyCode": 51 },
    { "name": 4, "key": 4, "code": "Digit4", "keyCode": 52 },
    { "name": 5, "key": 5, "code": "Digit5", "keyCode": 53 },
    { "name": 6, "key": 6, "code": "Digit6", "keyCode": 54 },
    { "name": 7, "key": 7, "code": "Digit7", "keyCode": 55 },
    { "name": 8, "key": 8, "code": "Digit8", "keyCode": 56 },
    { "name": 9, "key": 9, "code": "Digit9", "keyCode": 57 },
    { "name": "a", "key": "a", "code": "KeyA", "keyCode": 65 },
    { "name": "b", "key": "b", "code": "KeyB", "keyCode": 66 },
    { "name": "c", "key": "c", "code": "KeyC", "keyCode": 67 },
    { "name": "d", "key": "d", "code": "KeyD", "keyCode": 68 },
    { "name": "e", "key": "e", "code": "KeyE", "keyCode": 69 },
    { "name": "f", "key": "f", "code": "KeyF", "keyCode": 70 },
    { "name": "g", "key": "g", "code": "KeyG", "keyCode": 71 },
    { "name": "h", "key": "h", "code": "KeyH", "keyCode": 72 },
    { "name": "i", "key": "i", "code": "KeyI", "keyCode": 73 },
    { "name": "j", "key": "j", "code": "KeyJ", "keyCode": 74 },
    { "name": "k", "key": "k", "code": "KeyK", "keyCode": 75 },
    { "name": "l", "key": "l", "code": "KeyL", "keyCode": 76 },
    { "name": "m", "key": "m", "code": "KeyM", "keyCode": 77 },
    { "name": "n", "key": "n", "code": "KeyN", "keyCode": 78 },
    { "name": "o", "key": "o", "code": "KeyO", "keyCode": 79 },
    { "name": "p", "key": "p", "code": "KeyP", "keyCode": 80 },
    { "name": "q", "key": "q", "code": "KeyQ", "keyCode": 81 },
    { "name": "r", "key": "r", "code": "KeyR", "keyCode": 82 },
    { "name": "s", "key": "s", "code": "KeyS", "keyCode": 83 },
    { "name": "t", "key": "t", "code": "KeyT", "keyCode": 84 },
    { "name": "u", "key": "u", "code": "KeyU", "keyCode": 85 },
    { "name": "v", "key": "v", "code": "KeyV", "keyCode": 86 },
    { "name": "w", "key": "w", "code": "KeyW", "keyCode": 87 },
    { "name": "x", "key": "x", "code": "KeyX", "keyCode": 88 },
    { "name": "y", "key": "y", "code": "KeyY", "keyCode": 89 },
    { "name": "z", "key": "z", "code": "KeyZ", "keyCode": 90 },
    { "name": "select key (Context Menu)", "key": "ContextMenu", "code": "ContextMenu", "keyCode": 93 },
    { "name": "numpad 0", "key": 0, "code": "Numpad0", "keyCode": 96 },
    { "name": "numpad 1", "key": 1, "code": "Numpad1", "keyCode": 97 },
    { "name": "numpad 2", "key": 2, "code": "Numpad2", "keyCode": 98 },
    { "name": "numpad 3", "key": 3, "code": "Numpad3", "keyCode": 99 },
    { "name": "numpad 4", "key": 4, "code": "Numpad4", "keyCode": 100 },
    { "name": "numpad 5", "key": 5, "code": "Numpad5", "keyCode": 101 },
    { "name": "numpad 6", "key": 6, "code": "Numpad6", "keyCode": 102 },
    { "name": "numpad 7", "key": 7, "code": "Numpad7", "keyCode": 103 },
    { "name": "numpad 8", "key": 8, "code": "Numpad8", "keyCode": 104 },
    { "name": "numpad 9", "key": 9, "code": "Numpad9", "keyCode": 105 },
    { "name": "multiply", "key": "*", "code": "NumpadMultiply", "keyCode": 106 },
    { "name": "add", "key": "+", "code": "NumpadAdd", "keyCode": 107 },
    { "name": "subtract", "key": "-", "code": "NumpadSubtract", "keyCode": 109 },
    { "name": "decimal point", "key": ".", "code": "NumpadDecimal", "keyCode": 110 },
    { "name": "divide", "key": "/", "code": "NumpadDivide", "keyCode": 111 },
    { "name": "f1", "key": "F1", "code": "F1", "keyCode": 112 },
    { "name": "f2", "key": "F2", "code": "F2", "keyCode": 113 },
    { "name": "f3", "key": "F3", "code": "F3", "keyCode": 114 },
    { "name": "f4", "key": "F4", "code": "F4", "keyCode": 115 },
    { "name": "f5", "key": "F5", "code": "F5", "keyCode": 116 },
    { "name": "f6", "key": "F6", "code": "F6", "keyCode": 117 },
    { "name": "f7", "key": "F7", "code": "F7", "keyCode": 118 },
    { "name": "f8", "key": "F8", "code": "F8", "keyCode": 119 },
    { "name": "f9", "key": "F9", "code": "F9", "keyCode": 120 },
    { "name": "f10", "key": "F10", "code": "F10", "keyCode": 121 },
    { "name": "f11", "key": "F11", "code": "F11", "keyCode": 122 },
    { "name": "f12", "key": "F12", "code": "F12", "keyCode": 123 },
    { "name": "num lock", "key": "NumLock", "code": "NumLock", "keyCode": 144 },
    { "name": "scroll lock", "key": "ScrollLock", "code": "ScrollLock", "keyCode": 145 },
    { "name": "audio volume mute", "key": "AudioVolumeMute", "code": "", "keyCode": 173 },
    { "name": "audio volume down", "key": "AudioVolumeDown", "code": "", "keyCode": 174 },
    { "name": "audio volume up", "key": "AudioVolumeUp", "code": "", "keyCode": 175 },
    { "name": "media player", "key": "LaunchMediaPlayer", "code": "", "keyCode": 181 },
    { "name": "launch application 1", "key": "LaunchApplication1", "code": "", "keyCode": 182 },
    { "name": "launch application 2", "key": "LaunchApplication2", "code": "", "keyCode": 183 },
    { "name": "semi-colon", "key": ";", "code": "Semicolon", "keyCode": 186 },
    { "name": "equal sign", "key": "=", "code": "Equal", "keyCode": 187 },
    { "name": "comma", "key": ",", "code": "Comma", "keyCode": 188 },
    { "name": "dash", "key": "-", "code": "Minus", "keyCode": 189 },
    { "name": "period", "key": ".", "code": "Period", "keyCode": 190 },
    { "name": "forward slash", "key": "/", "code": "Slash", "keyCode": 191 },
    { "name": "Backquote/Grave accent", "key": "`", "code": "Backquote", "keyCode": 192 },
    { "name": "open bracket", "key": "[", "code": "BracketLeft", "keyCode": 219 },
    { "name": "back slash", "key": "\\", "code": "Backslash", "keyCode": 220 },
    { "name": "close bracket", "key": "]", "code": "BracketRight", "keyCode": 221 },
    { "name": "single quote", "key": "'", "code": "Quote", "keyCode": 222 }
  ];

  let metaKeyInfo = [
    { "name": "shift", "key": "Shift", "code": "Shift", "keyCode": 16 },
    { "name": "ctrl", "key": "Control", "code": "Control", "keyCode": 17 },
    { "name": "alt", "key": "Alt", "code": "Alt", "keyCode": 18 },
    { "name": "meta", "key": "Meta", "code": "Meta", "keyCode": 91 }
  ];

  function getKeyCodeFromKey(key) {
    if(_.isUndefined(key)) return [];

    let keys = String(key).toLowerCase().split('+');

    if (keys.length > 2) {
      console.error('Combination of two keys is allowed only');
      return [];
    }

    let metaKey = keys.length > 1 ? keys[0] : false;
    let modifierKeyCode = _.find(keyInfo, e => String(e.key).toLowerCase() == _.last(keys))['keyCode'];

    if (metaKey && !_.find(metaKeyInfo, k => k.name.toLowerCase() === metaKey)) {
      console.error('Meta key must be in Ctrl, Shift, Alt')
      return [];
    }
    return [metaKey, modifierKeyCode];
  }

  function getX(e) {
    return e.pageX ?? (e.touches && e.touches[0]?.pageX) ?? (e.changedTouches && e.changedTouches[0].pageX);
  }

  function parse(attr) {
    if (attr) {
      return $parse(attr);
    }
  }

  function splitNames(xs) {
    if (xs) {
      return _.chain(xs.split(','))
              .invoke('trim')
              .compact()
              .map(x => (x[x.length - 1] == '?') ? x.slice(0, x.length - 1) : x)
              .value();
    }
    return [];
  }

  function splitSearchNull(search, searchable) {
    return _.chain([...(search || "").split(','), ...(searchable || "").split(',')])
            .invoke('trim')
            .compact()
            .uniq()
            .filter(x => (x[x.length - 1] == '?'))
            .map(x => x.slice(0, x.length - 1))
            .value();
  }

  function composeOnCheck(scope, onCheck, checkedApi, indexes) {
    if (onCheck) {
      onCheck(scope, {
        checked: checkedApi(indexes)
      });
    }
  }

  function whenCheck(elem, scope, onCheck, event) {
    event.stopPropagation();
    var checkAll = elem.find('input[bcheckall]');
    var checkboxes = elem.find('input[data-bcheck]');
    var indexes = _.chain(checkboxes)
      .filter('checked')
      .map(function (x) {
        return parseInt(x.dataset.bcheck);
      })
      .value();

    checkAll.prop('indeterminate', indexes.length > 0 && indexes.length != checkboxes.length);
    checkAll.prop('checked', indexes.length > 0);

    scope.$apply(_.partial(onCheck, indexes));
  }

  function whenCheckAll(elem, scope, onCheck, event) {
    var ch = this.checked;
    elem.find('input[data-bcheck]').each(function () {
      this.checked = ch;
    });
    whenCheck(elem, scope, onCheck, event);
  }

  function whenSort(scope, elem, onSort, pgGrid, event) {
    event.stopPropagation();
    pgGrid.uncheckAll();
    onSort($(this).attr('sort'));
    scope.$apply();
  }

  function saveSetting(data) {
    if ($rootScope.is_debug) {
      bStorage.json(data.setting_code, data.setting_value);
    } else {
      data.setting_value = JSON.stringify(data.setting_value);
      $http.post(bRoutes.SAVE_USER_LARGE_SETTING, data).then(_, function (error) {
        console.error('unable to save settings', error);
      });
    }
  }

  function getSearch(g) {
    return _.chain(g.fields).filter('search').pluck('name').value();
  }

  function getSearchNull(g) {
    return _.chain(g.fields).filter('search_null').pluck('name').value();
  }

  function parseElems(scope, html, attr, translate, pgGrid) {
    function isAttrTruthy(key) {
      if (_.has(attr, key)) {
        let value = $parse(attr[key])(scope);
        return _.isUndefined(value) || value === '' || !!value;
      } else return false;
    }

    var g = pgGrid.g;
    if (!g.isInit) {
      var headers = [];

      if (attr.sort) g.defaultSort = splitNames(attr.sort);
      if (attr.search) g.defaultSearch = splitNames(attr.search);
      if (attr.searchable) g.defaultSearchable = splitNames(attr.searchable);
      if (attr.search || attr.searchable) g.defaultSearchNull = splitSearchNull(attr.search, attr.searchable);

      g.hasNavigate = isAttrTruthy('bNavigate');
      g.naviRight = attr.naviRight;
      g.naviLeft = attr.naviLeft;
      g.naviUp = attr.naviUp || 'ArrowUp';
      g.naviDown = attr.naviDown || 'ArrowDown';

      var cols = [];

      function extractCols(x) {
        if (!x.attr('access') || $parse(x.attr('access'))(scope)) {
          cols.push({
            name: x.attr('name'),
            size: parseInt(g.customColSizes[x.attr('name')] || x.attr('size'))
          });
          g.fields.push({
            name: x.attr('name'),
            label: translate(`pg.${pgGrid.getLabelName() || pgGrid.getName()}.${x.attr('name')}`),
            sort: _.contains(g.defaultSort, x.attr('name')),
            search: _.contains(g.defaultSearch, x.attr('name')),
            search_null: _.contains(g.defaultSearchNull, x.attr('name')),
            searchable: _.contains(g.defaultSearch, x.attr('name')) || _.contains(g.defaultSearchable, x.attr('name')),
            format: x.attr('format'),
            date_format: x.attr('date-format'),
            required: x.attr('required') != undefined,
            static: g.isStatic || x.attr('static') != undefined,
            column: true,
            child: x.html().trim(),
            header: undefined,
            onNavigate: x.attr('on-navigate')
          });
        }
      }

      _.each($(html), function(col) {
        var x = $(col);

        if (col.nodeName == 'B-PG-ROW') {
          _.each(x.children(), function(cell) {
            if (cell.nodeName == 'B-PG-COL') {
              let c = $(cell);
              extractCols(c);
            }
          });
        } else if (col.nodeName == 'B-PG-COL') {
          extractCols(x);
        } else if (col.nodeName == 'B-PG-EXTRA-COL') {
          if (!x.attr('access') || $parse(x.attr('access'))(scope)) {
            g.fields.push({
              name: x.attr('name'),
              label: translate(`pg.${pgGrid.getLabelName() || pgGrid.getName()}.${x.attr('name')}`),
              sort: _.contains(g.defaultSort, x.attr('name')),
              search: _.contains(g.defaultSearch, x.attr('name')),
              search_null: _.contains(g.defaultSearchNull, x.attr('name')),
              searchable: _.contains(g.defaultSearch, x.attr('name')) || _.contains(g.defaultSearchable, x.attr('name')),
              format: x.attr('format'),
              date_format: x.attr('date-format'),
              required: false,
              static: g.isStatic || x.attr('static') != undefined,
              column: true,
              child: x.html().trim(),
              header: undefined,
              onNavigate: x.attr('on-navigate')
            });
          }
        } else if (col.nodeName == 'B-FREE-COL') {
          if (g.colsDefault.length) g.freeColAlign = 'bottom';
          g.freeCols.push({
            size: x.attr('size'),
            child: x.html().trim()
          });
        } else if (col.nodeName == 'B-PG-HEADER') {
          headers.push({
            name: x.attr('name'),
            child: x.html().trim()
          });
        } else if (col.nodeName == 'B-PG-FILTER') {
          let dw = x.attr('decorate-with');
          g.filterFields.push({
            name: x.attr('name'),
            type: dw ? 'number' : x.attr('type') || 'text',
            equal: !!dw || (x.attr('directive') == 'equal'),
            decorateWith: dw
          });
        }
      });

      _.each(g.filterFields, function(f) {
        if (_.findIndex(g.fields, { name: f.name }) == -1) {
          g.fields.push({
            name: f.name,
            label: translate(`pg.${pgGrid.getLabelName() || pgGrid.getName()}.${f.decorateWith || f.name}`),
            required: false,
            column: false
          });
        }
      })

      if (cols.length > 0) {
        g.colsDefault = cols;
      }

      _.each(headers, function(x) {
        var field = _.findWhere(g.fields, {name: x.name});
        if (field) {
          field.header = x.child.replace(/::label/, field.label);
        }
      });

      g.isInit = true;
    } else {
      _.each(g.fields, c => c.search = _.contains(g.defaultSearch, c.name));
    }

    var s = bStorage.json(g.storageKey);

    if (s.cols && _.every(s.cols, x => _.findWhere(g.fields, { name: x.name }))) {
      g.cols = s.cols
    } else {
      g.cols = angular.copy(g.colsDefault);
    }

    if (s.search && _.every(s.search, function (n) {
      var f = _.findWhere(g.fields, { name: n });
      return f && (f.search || f.searchable);
    })) {
      _.each(g.fields, function (field) {
        field.search = _.contains(s.search, field.name);
      });
    }
    g.search = getSearch(g);
    g.searchNull = getSearchNull(g);
  }

  function uncheckAll(pgGrid, elem) {
    if (pgGrid.onCheck) {
      elem.find('input[data-bcheck]').each(function () {
        this.checked = false;
      });

      elem.find('input[bcheckall]').each(function () {
        this.checked = false;
        this.indeterminate = false;
      });

      pgGrid.onCheck([]);
    }
  }

  function onFilter(scope, setter, items) {
    setter(scope, items);
  }

  function ctrl($scope, $attrs) {
    var name = $attrs.name.trim();
    if (name.startsWith("{{") && name.endsWith("}}")) {
      name = $parse(name.substr(2, name.length - 4))($scope);
    }

    var pgGrid = $scope.bPage.pgGrid(name);
    var currentLimit = $attrs.limit ? parseInt($attrs.limit): null;
    if (currentLimit) pgGrid.g.currentLimit = currentLimit;

    pgGrid.g.labelName = ($attrs.labelName || "").trim();
    pgGrid.g.rownum = ($attrs.rownum || "rownum").trim();
    pgGrid.g.path = $scope.bPage.path;
    pgGrid.g.storageKey = pgGrid.g.path + ':pg_' + pgGrid.getName();
    pgGrid.g.withCheckbox = !!$attrs.onCheck;
    pgGrid.g.isStatic = $attrs.static != undefined;

    if ($attrs.filteredData) {
      pgGrid.g.onFilter = _.partial(onFilter, $scope, $parse($attrs.filteredData).assign);
    }

    $scope.bPage.qLoaded.promise.then(pgGrid.reload);

    this.pgGrid = pgGrid;
  }

  function compile(element) {
    var innerHTML = element.html();
    element.empty();

    function link(scope, elem, attr, ctrl) {
      var pgGrid = ctrl.pgGrid;
      pgGrid.reinitSettings();
      pgGrid.uncheckAll(_.partial(uncheckAll, pgGrid, elem));
      pgGrid.onCheck = _.partial(composeOnCheck, scope, parse(attr.onCheck), pgGrid.checkedApi, _);

      if (attr.countableColumns){
        pgGrid.g.countableColumns = splitNames(attr.countableColumns);
      }

      function applyProps(elem) {
        elem.find('.tbl').css({
          'min-height': elem.data().min_height,
          'max-height': elem.data().max_height
        }).find('.tbl-header,.tbl-body').css({
          'min-width': elem.data().width
        });
      }

      if (!_.isUndefined(attr.freeColEnabled)) {
        scope.$watch(attr.freeColEnabled, function(status) {
          if (status === true || status === false) {
            pgGrid.freeColEnabled(status);
          }
        });
      }

      function justifyBtnPosition(elem, tbl) {
        elem.css('bottom', Math.max(tbl.offsetHeight - tbl.clientHeight - 2, 0));
      }

      function makeScrollToTop(tbl) {
        let isScrollToTopEnabled = false;
        let hParent = tbl.parent();
        let tblBody = tbl.find(".tbl-body");
        let scrollToTopBtn = $('<button type="button" class="tbl-scroll-to-top-btn"><i class="fas fa-chevron-up"></i></button>')
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

          if (isScrollToTopEnabled) justifyBtnPosition(scrollToTopContainer, tbl.get(0));
        });

        hParent.append(scrollToTopContainer);
      }

      function enableResizers(table, grid) {
        var headerCells = table.find('.tbl-header-cell:not(.tbl-empty-cell)');
        var resizingCell,
            startOffset,
            sizeArray,
            path = grid.g.storageKey,
            search = getSearch(grid.g);

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
            $(resizingCell).removeClass("active");
            table.css("user-select", "auto");
            if (grid.g.withCheckbox) sizeArray.shift();
            let cols = _.map(grid.g.cols, function(col, idx) {
              return {
                name: col.name,
                size: sizeArray[idx]
              };
            });
            grid.g.cols = cols;
            saveSetting({
              setting_code: path,
              setting_value: { cols, search }
            });
            resizingCell = undefined;

            let scrollToTopBtn = table.parent().find(".scroll-to-top-container");
            justifyBtnPosition(scrollToTopBtn, table.get(0));
          }
        };
        _.each(headerCells, function(th) {
          let grip = $('<div></div>').addClass("tbl-cell-resizer");
          grip.on(downEvents, function (e) {
            e.preventDefault();
            resizingCell = $(this).closest('.tbl-header-cell');
            $(resizingCell).addClass("active");
            table.css("user-select", "none");
            startOffset = parseFloat(th.offsetWidth - getX(e));
          });
          if (hasTouch) grip.addClass("resizer-active");
          $(th).append(grip);
        });
        $(document).on(moveEvents, docMouseMove).on(upEvents, docMouseUp);
      }

      function onNavigate(event, dir) {
        var nextElem;
        var currElem = $(event.target).closest('.tbl-cell');
        var colIndex = currElem.index();

        function navigate(nextElement) {
          if (nextElement.length < 1 || !nextElement.attr('ng-on-eventfocus')) return;
          var myEvent = new CustomEvent('eventfocus', { detail: nextElement });
          nextElement[0].dispatchEvent(myEvent);
        };

        function getNextRow(cell, dir) {
          if (dir == 'down') {
            return cell.closest('.tbl-row').next();
          } else {
            return cell.closest('.tbl-row').prev();
          };
        };

        if (dir == 'down' || dir == 'up') {
          var nextRow = getNextRow(currElem, dir);

          if (nextRow.length) {
            nextElem = $(nextRow.find('.tbl-cell').get(colIndex));
            navigate(nextElem);
          };

        } else if (dir == 'right') {
          nextElem = currElem.next();
          navigate(nextElem);

        } else if (dir == 'left') {
          nextElem = currElem.prev();
          navigate(nextElem);
        };
      };

      function run() {
        scope.$watch(function() {
          return pgGrid.g.fetchingId;
        }, function(val) {
          if (val) {
            parseElems(scope, innerHTML, attr, scope.bPage.translate, pgGrid);
            elem.html(pgGrid.drawHtml(attr.iterator));
            elem.show();

            $compile(elem.contents())(scope);

            var table = elem.find('.tbl');
            enableResizers(table, pgGrid);
            table.hScroll();
            makeScrollToTop(table);

            if (pgGrid.g.hasNavigate) {
              function navigator(event) {
                let [rightMetaKey, rightModifierKeyCode] = getKeyCodeFromKey(pgGrid.g.naviRight);
                let [leftMetaKey, leftModifierKeyCode] = getKeyCodeFromKey(pgGrid.g.naviLeft);
                let [upMetaKey, upModifierKeyCode] = getKeyCodeFromKey(pgGrid.g.naviUp);
                let [downMetaKey, downModifierKeyCode] = getKeyCodeFromKey(pgGrid.g.naviDown);

                if (!!upModifierKeyCode && (!upMetaKey || event[upMetaKey + 'Key']) && event.keyCode === upModifierKeyCode) {
                  table.trigger('cell-navigate-up', [event]);

                } else if (!!leftModifierKeyCode && (!leftMetaKey || event[leftMetaKey + 'Key']) && event.keyCode === leftModifierKeyCode) {
                  table.trigger('cell-navigate-left', [event]);

                } else if (!!rightModifierKeyCode && (!rightMetaKey || event[rightMetaKey + 'Key']) && event.keyCode === rightModifierKeyCode) {
                  table.trigger('cell-navigate-right', [event]);

                } else if (!!downModifierKeyCode && (!downMetaKey || event[downMetaKey + 'Key']) && event.keyCode === downModifierKeyCode) {
                  table.trigger('cell-navigate-down', [event]);
                }
              }

              table.on('cell-navigate-up', (event, e) => onNavigate(e, 'up'));
              table.on('cell-navigate-down', (event, e) => onNavigate(e, 'down'));
              table.on('cell-navigate-right', (event, e) => onNavigate(e, 'right'));
              table.on('cell-navigate-left', (event, e) => onNavigate(e, 'left'));

              table.on('keydown', (event) => {
                navigator(event);
              });
            }

            applyProps(elem.data({
              width: attr.minWidth ?? 880,
              min_height: attr.minHeight ?? 100,
              max_height: attr.maxHeight ?? 600,
            }));
          }
        });
      }

      if (_.has(attr, "useDefaultSetting")) run();
      else pgGrid.loadSetting(pgGrid.g.storageKey).finally(run);

      scope.$watchCollection(attr.localData, function(val) {
        if (val) {
          pgGrid.uncheckAll();
          pgGrid.refresh(val);
        }
      });

      elem.on('click', 'input[bcheckall]', _.partial(whenCheckAll, elem, scope, pgGrid.onCheck, _));
      elem.on('click', '.tbl .tbl-body .checkbox input[data-bcheck]', _.partial(whenCheck, elem, scope, pgGrid.onCheck, _));
      elem.on('dblclick', '.tbl .tbl-body .checkbox', function (e) {
        e.stopPropagation();
      });
      elem.on('click', '.tbl .tbl-header .tbl-header-cell .tbl-header-txt[sort]', _.partial(whenSort, scope, elem, pgGrid.onSort, pgGrid, _));

      scope.bPage.qLoaded.promise.then(_.partial(pgGrid.onCheck, []));
      scope.g = pgGrid.g;
      scope.$on('$destroy', function() {
        $(document).off(moveEvents, docMouseMove);
        $(document).off(upEvents, docMouseUp);
      });
    }

    return {
      post: link
    }
  }

  return {
    scope: true,
    controller: ctrl,
    compile: compile
  }
});
