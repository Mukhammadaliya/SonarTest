biruni.directive('bTreeSelect', function (bConfig, $document, $parse, $templateCache, $timeout) {
  var keydownHandler = null;

  $document.on('keydown', function (e) {
    if (keydownHandler) {
      keydownHandler(e);
    }
  });

  function link(scope, elem, attr) {
    var origin;
    var currentOrigin;
    var isMultiple = false;
    var inputFirstFocused = false;
    var inputElem = elem.find('input.form-control').first();
    var hintElement = elem.find('.hint');
    var bTreeViewNode = elem.find('.b-tree-view');
    var hideLimit = parseInt(attr.hideLimit) || 10;
    var row_limit = parseInt(attr.rowLimit) || 200;
    var groups = {};

    var onChange = $parse(attr.onChange);
    var onSelect = $parse(attr.onSelect);

    var keys = {
      id: attr.idKey || 'id',
      text: attr.labelKey || 'name',
      parent: attr.parentKey || 'parent_id'
    };

    var f = {
      searchValue: undefined,
      model: null,
      langs: bConfig.langs,
      showHint: false,
      disabled: false,
      onlyLeaf: false,
      required: false,
      inputBlurred: false,
      isAdd: false,
      isView: false,
      pageNo: 0,
      hasMore: false,

      inputElemFocus,
      getPlaceholder,
      onInputFocus,
      onInputBlur,
      showMore,
      clearAll,
    };

    f.onAddClick = onAddClick;
    f.onViewClick = onViewClick;

    scope._$bTree = f;

    elem.on('mousedown', '.hint', function(ev) {
      ev.preventDefault();
    });

    scope.$watchCollection(attr.origin, function(value) {
      if (value) {
        origin = [];
        f.searchValue = '';
        bTreeViewNode.html('');
        pushToOrigin('');
        currentOrigin = origin;

        function pushToOrigin(parent) {
          return _.reduce(value, function(m, x) {
            if (x[keys.parent] == parent) {
              origin.push(x);
              groups[x[keys.id]] = pushToOrigin(x[keys.id]) && f.onlyLeaf;
              return true;
            }
            return m;
          }, false);
        }
      }
    });

    scope.$watch(() => f.searchValue, search);
    scope.$watch(attr.disabled, x => f.disabled = x);

    if (_.has(attr, 'onlyLeaf')) f.onlyLeaf = true;
    if (_.has(attr, 'required')) f.required = true;

    let onAdd = null;
    let onView = null;
    let model = attr.model.replace(/\s/g, '');
    let modelSetter = $parse(model).assign;
    let autoSelectRow;
    let autoDeleteRow;
    let placeholder = f.langs.input_placeholder;

    if (attr.placeholder != undefined) scope.$watch(attr.placeholder, x => placeholder = x);

    function inputElemFocus() {
      inputElem.focus();
    }

    if (attr.onAdd != undefined) {
      onAdd = $parse(attr.onAdd);
      f.onAddClick = onAddClick;
      scope.$watch(attr.isAdd, x => f.isAdd = x);
    }

    if (attr.onView != undefined) {
      onView = $parse(attr.onView);
      f.onViewClick = onViewClick;
      scope.$watch(attr.isView, x => f.isView = x);
    }

    if (attr.multiple == undefined) {
      autoSelectRow = function(row) {
        modelSetter(scope, row[keys.id]);

        if (onSelect) {
          onSelect(scope, { row: row });
        }
      }

      autoDeleteRow = function() {
        modelSetter(scope, '');
      }

      var delayOnChange = _.after(2, function() {
        if (onChange) {
          onChange(scope);
        }
      });

      scope.$watch(attr.model, function(x) {
        // TODO check two times initializing
        let row = _.findWhere(origin, { [keys.id]: x });

        if (row) {
          _.each(origin, x => x.selected = false);
          f.model = row[keys.id];
          f.searchValue = row[keys.text];
          f.modelSelected = true;
          row.selected = true;
          bTreeViewNode.find(`#child-${f.model}`).children('.radio').find('input').prop('checked', true);
        } else {
          clearTreeView([f.model]);
          f.model = '';
          f.searchValue = '';
          f.modelSelected = false;
        }

        delayOnChange();
      });
    } else {
      isMultiple = true;

      autoSelectRow = function(datas) {
        !_.isArray(datas) && (datas = [datas]);
        _.each(datas, function(row) {
          let ind = _.indexOf(f.model, row[keys.id]);
          if (row.selected && ind == -1) {
            f.model.push(String(row[keys.id]));
          } else if (!row.selected && ind != -1) {
            f.model.splice(ind, 1);
          }
        });

        modelSetter(scope, f.model);

        if (onSelect) {
          onSelect(scope, { rows: datas });
        }
      }

      scope.$watchCollection(attr.model, function(val) {
        if (!_.isEmpty(val)) {
          _.each(origin, function(x) {
            x.selected = _.any(val, y => x[keys.id] == y);
            if (x.selected) {
              bTreeViewNode.find(`#child-${x[keys.id]}`).children('.checkbox').find('input').prop('checked', true);
            }
          });
        }
        if ((!val || _.isEmpty(val)) && !_.isEmpty(f.model)) {
          clearTreeView(f.model);
        }
        f.model = _.map(val, String) || [];

        if (onChange) {
          onChange(scope);
        }
      });
    }

    function clearAll() {
      _.each(origin, x => x.selected = false);
      if (isMultiple) {
        f.model = [];
      } else {
        f.model = '';
      }
      modelSetter(scope, f.model);
      inputElemFocus();
    }

    function setHasMore() {
      let len = currentOrigin?.length || 0;
      len -= f.pageNo * row_limit;
      f.hasMore = Math.ceil(len / row_limit) > 1;
    }

    function showMore() {
      f.pageNo++;
      setHasMore();
      addTreeView();
    }

    function getRow(id) {
      return _.findWhere(origin, _.object([keys.id], [id]));
    }

    function clearTreeView(model) {
      if (inputFirstFocused) {
        _.each(model, function(x) {
          let row = getRow(x);
          if (row) row.selected = false;
        });
      } else {
        _.each(model, function(x) {
          let row = getRow(x);
          if (row) row.selected = false;
        });
      }
    }

    function initHint() {
      f.pageNo = 0;
      setHasMore();
      bTreeViewNode.html('');
    }

    function onInputFocus() {
      keydownHandler = keydownCallback;

      if (!inputFirstFocused) {
        inputFirstFocused = true;
      }
      initHint();
      addTreeView();
      showHint();
    }

    function onInputBlur() {
      keydownHandler = null;
      f.inputBlurred = true;
      hideHint();
    }

    function onAddClick() {
      onAdd(scope);
      hideHint();
    }

    function onViewClick() {
      onView(scope);
      hideHint();
    }

    function keydownCallback(e) {
      if (e.keyCode == 27) {
        hideHint();
      } else if (e.keyCode == 8) {
        !isMultiple && f.modelSelected && onDeleteClick();
      }
      scope.$apply();
    }

    function treeViewNode(li, check) {
      let ul = $(li).children('ul');
      let sum = 1;

      if (ul.length == 0) return 1;

      _.each(ul.children('li'), function(x) {
        let res = { show: false };
        sum += treeViewNode(x, res);

        if (res.show || $(x).children('label').find('input').prop('checked')) {
          check.show = true;
        }
      });

      var limit = ($(li).parent('#root-').length > 0 ? 5 : 1) * hideLimit;

      if (!check.show && sum > limit) {
        ul.hide();
        ul.siblings('i').removeClass('fa-minus').addClass('fa-plus');
      }

      return sum;
    }

    function controlHint() {
      var elem = inputElem.closest('.b-tree-select');
      var scrollParent = elem.scrollParent();

      scrollParent.scroll(function(ev) {
        hintElement.position({
          of: elem,
          my: 'left top',
          at: 'left bottom',
          collision: 'fit flipfit',
          within: $(this)
        });
      });
      hintElement.css({
        opacity: 1,
        width: inputElem.outerWidth()
      });
      hintElement.position({
        of: elem,
        my: 'left top',
        at: 'left bottom',
        collision: 'fit flipfit'
      });
    }

    function showHint() {
      f.showHint = true;
      hintElement.css({ opacity: 0 });
      setTimeout(controlHint, 5);
    }

    function hideHint() {
      f.showHint = false;
    }

    function getPlaceholder() {
      return placeholder;
    }

    function onDeleteClick() {
      let row = _.findWhere(origin, { [keys.id]: f.model });
      row.selected = false;
      autoDeleteRow();
      !inputElem.is(':focus') && inputElem.focus();
    }

    function inputClicked(ev) {
      ev.preventDefault();
      let curElem = ev.currentTarget.firstElementChild;
      if (curElem.disabled) return;
      curElem.checked = !curElem.checked;
      let li = $(ev.currentTarget).closest('li');
      let data = getRow(li[0].id.substr(6));
      data.selected = curElem.checked;
      if (!isMultiple && curElem.checked) {
        _.each(origin, function(x) {
          if (x.selected) x.selected = false;
        });
        $timeout(function() {
          $(inputElem).blur();
        });
      }
      if (!isMultiple && !curElem.checked) {
        scope.$apply(_.partial(autoDeleteRow));
      } else {
        scope.$apply(_.partial(autoSelectRow, data));
        if (attr.optionCheckChilds != undefined && $(ev.currentTarget.previousSibling).hasClass('fa-plus')) {
          checkChilds($(ev.target).closest('li'), true);
        }
      }
      _.some(origin, x => x[keys.id] == data[keys.id] && (x.selected = curElem.checked));
    }

    function checkSpanText(ulNode, checked) {
      ulNode.find('.check-childs').each(function(i, spanElem) {
        if (checked) {
          spanElem.innerText = bConfig.langs.ts_uncheck_all;
          $(spanElem).removeClass('check-all');
        } else {
          spanElem.innerText = bConfig.langs.ts_check_all;
          $(spanElem).addClass('check-all');
        }
      });
    }

    function checkChilds(ev, optionCheckChilds = false) {
      let node = optionCheckChilds ? $(ev).find('ul') : $(ev.target).closest('ul');
      let checked = optionCheckChilds ? $(ev).find('.check-childs').hasClass('check-all') : $(ev.target).hasClass('check-all');
      checkSpanText(node, checked);
      let datas = [];
      node.find('input').each(function(i, input) {
        let inputNode = $(input);
        let liNode = inputNode.closest('li');
        let ulNode = inputNode.closest('ul');
        if (!optionCheckChilds && liNode.is(':hidden') || ulNode && ulNode.is(':hidden').length > 0 || input.disabled) return;
        input.checked = checked;
        let data = getRow(liNode[0].id.substr(6)); // "child-" prefix size is 6
        data.selected = checked;
        datas.push(data);
        _.some(origin, x => x[keys.id] == data[keys.id] && (x.selected = checked));
      });
      scope.$apply(_.partial(autoSelectRow, datas));
    }

    function addTreeView() {
      let inputClass = isMultiple ? 'checkbox' : 'radio';
      let from = f.pageNo * row_limit;
      let to = (f.pageNo + 1) * row_limit;
      currentOrigin.slice(from, to).forEach(function(node, idx) {
        let ulRoot = bTreeViewNode.find(`#root-${node[keys.parent]}`);
        if (!ulRoot.length) {
          ulRoot = $(`<ul id="root-${node[keys.parent]}"></ul>`);
          if (isMultiple && node[keys.parent] != '') {
            let checks = $(`<span class="text-muted check-childs check-all">${f.langs.ts_check_all}</span>`);
            checks.bind('click', checkChilds);
            ulRoot.append(checks);
          }
        }
        let input = $(`<input type="${inputClass}" />`);
        let is_group = groups[node[keys.id]] || node.is_group;
        input[0].checked = node.selected;
        input[0].disabled = node.disabled || is_group;
        !isMultiple && input[0].setAttribute('name', attr.name || 'b-tree-radio');
        let label = $(`<label class="${inputClass}"></label>`);
        label.bind('click', inputClicked).append(input).append(`<span>${node[keys.text]}</span>`);

        if (is_group) {
          label.addClass("group");
        }

        let liNode = $(`<li id="child-${node[keys.id]}"></li>`);
        let ulChild = bTreeViewNode.find(`#root-${node[keys.id]}`);
        ulChild.length && liNode.append(ulChild);
        ulRoot.append(liNode.append(label));
        let liRoot = bTreeViewNode.find(`#child-${node[keys.parent]}`);
        if (liRoot.length) {
          liRoot.append(ulRoot);
          if (liRoot.children().length == 2) {
            let iNode = $('<i class="fa fa-minus"></i>');
            iNode.click(function(ev) {
              $(ev.target).nextAll('ul').stop().slideToggle(100);
              if (iNode.hasClass('fa-plus')) {
                iNode.removeClass('fa-plus');
                iNode.addClass('fa-minus');
              } else {
                iNode.addClass('fa-plus');
                iNode.removeClass('fa-minus');
              }
            }).mouseover(function(ev) {
              $(ev.target).closest('li').css('background', '#f5faff');
            }).mouseleave(function(ev) {
              $(ev.target).closest('li').css('background', 'transparent');
            });
            liRoot.prepend(iNode);
          }
        } else {
          bTreeViewNode.append(ulRoot);
        }
      });
      // Collapse elements with more children
      _.each(bTreeViewNode.find('#root-').children('li'), function(li) {
        treeViewNode(li, { show: false });
      });
    }

    function toLower(val) {
      return String(val || '').toLowerCase();
    }

    function checkWord(searchValue, row) {
      return searchValue && toLower(row[keys.text]).indexOf(toLower(searchValue)) > -1;
    }

    function search() {
      if (!inputFirstFocused) return;
      let searchValue = !f.modelSelected ? f.searchValue : '';
      if (!searchValue) {
        currentOrigin = origin;
      } else {
        let enabled = {};
        _.each(origin, function(x) {
          if (checkWord(searchValue, x)) {
            enabled[x[keys.id]] = true;
            let id = x[keys.parent];
            while (id) {
              enabled[id] = true;
              let par = _.find(origin, z => z[keys.id] == id);
              id = par[keys.parent];
            }
          }
        });
        currentOrigin = _.filter(origin, x => enabled[x[keys.id]]);
      }
      initHint();
      addTreeView();
    }
  }

  function template(elem, attr) {
    let inputHtml = null;
    if (attr.multiple == undefined) {
      inputHtml = `
        <div class="simple">
          <input type="text"
                 class="form-control"
                 placeholder="{{ _$bTree.getPlaceholder() }}"
                 ng-model="_$bTree.searchValue"
                 ng-focus="_$bTree.onInputFocus()"
                 ng-blur="_$bTree.onInputBlur()"
                 ng-disabled="_$bTree.disabled"
                 ng-required="_$bTree.required" />
          <span class="clear-button" ng-show="!_$bTree.disabled && _$bTree.model.length > 0" ng-click="_$bTree.clearAll()">
            <span><i class="edit fa fa-times"></i></span>
          </span>
        </div>
      `;
    } else {
      inputHtml = `
        <div class="multiple form-control" ng-class="{'blurred': _$bTree.inputBlurred && _$bTree.required, 'empty': _$bTree.required && !_$bTree.model.length}">
          <span class="title" ng-click="_$bTree.inputElemFocus()" ng-hide="!_$bTree.model.length">
            {{ _$bTree.model.length }}&nbsp;{{ _$bTree.langs.input_selected }}
          </span>
          <input type="text"
                 class="form-control"
                 placeholder="{{ _$bTree.getPlaceholder() }}"
                 ng-model="_$bTree.searchValue"
                 ng-focus="_$bTree.onInputFocus()"
                 ng-blur="_$bTree.onInputBlur()"
                 ng-disabled="_$bTree.disabled"
                 ng-required="_$bTree.required && !_$bTree.model.length" />
          <span class="clear-button" ng-show="!_$bTree.disabled && _$bTree.model.length > 0" ng-click="_$bTree.clearAll()">
            <span><i class="edit fa fa-times"></i></span>
          </span>
        </div>
      `;
    }
    return _.template($templateCache.get('b-tree-select.html'))({ inputHtml: inputHtml });
  }


  return {
    restrict: 'E',
    scope: true,
    link: link,
    template: template
  };
});
