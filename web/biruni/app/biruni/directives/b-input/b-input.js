biruni.directive('bInput', function($rootScope, bConfig, AppSession, bAlert, bHttp, bFrame, $q, $document, $parse, bStorage, $http, bRoutes, $templateCache, $timeout) {
  var keydownHandler = null;

  $document.on('keydown', function(e) {
    if (keydownHandler) {
      keydownHandler(e);
    }
  });

  function link(scope, elem, attr) {
    var f = {
      searchValue: '',
      rows: [],
      langs: bConfig.langs,
      isAdd: false,
      isView: false,
      readonly: false,
      showHint: false,
      noRows: false,
      hasMoreRows: false,
      // Use only for query, when localData attribute is not provided
      queryFetching: false
    },
    delayDelete = false; // used to delay the deletion of selected values when backspace is pressed in the search

    f.showMultiple = showMultiple;
    f.onMultipleClick = onMultipleClick;

    f.getPlaceholder = getPlaceholder;
    f.onInputFocus = onInputFocus;
    f.onInputBlur = onInputBlur;
    f.onDeleteMousedown = onDeleteMousedown;
    f.onDeleteClick = onDeleteClick;
    f.onClearAllClick = onClearAllClick;
    f.onSaveDefaultValue = onSaveDefaultValue;
    f.onDeleteDefaultValue = onDeleteDefaultValue;
    f.onMouseOver = onMouseOver;
    f.onSelectClick = onSelectClick;
    f.onAddClick = onAddClick;
    f.onViewClick = onViewClick;
    f.onMoreClick = onMoreClick;

    scope._$bInput = f;

    var inputElement = elem.find('input').first();
    var hintElement = elem.find('.b-input > .hint');

    elem.on('mousedown', '.hint', function (e) {
      e.preventDefault();
    });

    var lastOrderNo = null;

    var isMultiple = false;
    var query = null;
    var isLocalData = false;
    var localData = [];
    var localDataReady = [];
    var multipleShowCount = -1; // if more than @multipleShowCount items are selected, they will be hidden if not in focus
    var tryDeleteMultiple = false;
    var placeholder = f.langs.input_placeholder;
    var inputFocused = false;
    var showOnFocus = true;
    var allowUpdate = false;
    var justSelected = false;

    var autoFill = false;
    var limit = 10;
    var lastLimit = limit;
    var pageNo = null;
    var maxPage = null;

    // Use only for query, when localData attribute is not provided
    var column = [];
    var sort = [];

    var search = [];

    const MIN_FILL_LIMIT = 2; // Mimimal limit for checking that results are more than 1

    let settingCode;

    if (isLocalData = attr.localData != undefined) {
      scope.$watchCollection(attr.localData, function (x) {
        localData = x;
        if (inputFocused) {
          update();
        }
      });
      settingCode = "b-input-local:" + scope.$id;
    } else {
      if (attr.name == undefined) {
        bAlert.open('bInput: attribute @name is required if attribute @local-data is not defined!');
        return;
      } else {
        if (attr.runPage == undefined) {
          query = !scope.bPage ? _.last(bFrame.pages).query(attr.name) : scope.bPage.query(attr.name);
        } else {
          let page = $parse(attr.runPage)(scope);
          query = page.query(attr.name);
        }
      }
      let path = query.path();
      let k = path.lastIndexOf("+")
      if (k > 0) {
        let p = path.lastIndexOf(":");
        if (p > 0) {
          path = path.substring(0, k) + path.substring(p)
        } else {
          path = path.substring(0, k);
        }
      }
      settingCode = path + (attr.referName ? '#' + attr.referName : '');
    }
    if($rootScope.is_debug){
      settingCode += ':filial_id:' + AppSession.si.filial.id;
    }

    if (attr.model == undefined) {
      bAlert.open('bInput: attribute @model is required!');
      return;
    }

    var autoChangeQuery = null;
    var autoSelectRow = null;
    var autoDeleteRow = null;

    if (attr.multiple == undefined) {
      /**
       * This code block is designed for "Single" b-input directive
       */
      f.modelKeySelected = false;
      var isModelKey = false;

      var modelAlias = null;
      var modelSetter = null;

      var model = attr.model.replace(/\s/g, '').split('|');
      if (model[1]) {
        modelAlias = model[1];
        modelSetter = $parse(model[0]).assign;
        sort.push(modelAlias);
        search.push(modelAlias);
        if (!isLocalData) column.push(modelAlias);
      }
      scope.$watch(model[0], function (value) {
        let oldValue = f.model;
        f.model = value == undefined ? '' : value;
        f.searchValue = f.model;
        if (value || oldValue) onSearchChange();
        else inputFocused && inputElement.focus();
      });

      if (isModelKey = attr.modelKey != undefined) {
        var modelKeyAlias = null;
        var modelKeySetter = null;

        var modelKey = attr.modelKey.replace(/\s/g, '').split('|');
        if (modelKey[1]) {
          modelKeyAlias = modelKey[1];
          modelKeySetter = $parse(modelKey[0]).assign;
          if (!isLocalData) column.push(modelKeyAlias);
        }
        scope.$watch(modelKey[0], function (value) {
          f.modelKey = value == undefined ? '' : value;
          f.modelKeySelected = f.modelKey != '';
          if (f.modelKeySelected) {
            inputElement[0].maxLength = null;
          } else {
            inputElement[0].removeAttribute('maxLength');
          }
        });
      }

      if (attr.required != undefined) {
        if (attr.required == '') f.required = true;
        else scope.$watch(attr.required, x => f.required = !!x);
      }

      if (attr.requiredKey != undefined) {
        if (attr.requiredKey == '') f.requiredKey = true;
        else scope.$watch(attr.requiredKey, x => f.requiredKey = !!x);
      }

      autoChangeQuery = function () {
        query.searchValue(f.searchValue);
      };
      autoSelectRow = function (row) {
        modelSetter(scope, row[modelAlias]);
        if (isModelKey) {
          modelKeySetter(scope, row[modelKeyAlias]);
        }
      };
      autoDeleteRow = function () {
        if (onDelete) {
          onDelete(scope);
        } else {
          modelSetter(scope, '');
          if (isModelKey) modelKeySetter(scope, '');
        }
      };
    } else {
      /**
       * This code block is designed for "Multiple" b-input directive
       */
      isMultiple = true;
      var dublicates = false;
      multipleShowCount = parseInt(attr.multiple || multipleShowCount);
      scope.$watch(() => f.searchValue, function (nw, old) {
        if (old.length && nw.length == 0) {
          delayDelete = true;
          $timeout(() => delayDelete = false, 500);
        }
        onSearchChange();
      });
      var modelSetter = $parse(attr.model).assign;
      scope.$watchCollection(attr.model, value => f.model = value || []);
      var modelKey = attr.modelKey;
      if (!isLocalData && modelKey) column.push(modelKey);

      f.label = attr.label;
      if (f.label == undefined) {
        f.label = 'name';
      }
      if (!isLocalData) column.push(f.label);
      search.push(f.label);
      sort.push(f.label);

      var closeOnSelect = false;
      if (attr.closeOnSelect != undefined) closeOnSelect = true;
      if (attr.modelKey != undefined && attr.dublicates != undefined) {
        bAlert.open('bInput: attribute @dublicates cannot be defined if attribute @model-key exists!');
        return;
      }
      if (attr.dublicates != undefined) dublicates = true;

      autoChangeQuery = function () {
        query.searchValue(f.searchValue);
        if (modelKey != undefined) {
          let where = null;
          if (f.model.length > 0) where = [modelKey, '<>', _.pluck(f.model, modelKey)];
          query.where(where);
        }
      };
      autoSelectRow = function (row, index) {
        f.model.push(row);
        modelSetter(scope, f.model);
        if (!dublicates) f.rows.splice(index, 1);
      };
      autoDeleteRow = function (row, index) {
        if (onDelete) {
          onDelete(scope, {row: row, index: index});
        } else {
          f.model.splice(index, 1);
        }
      };
    }

    if (!isLocalData && attr.column != undefined) column = column.concat(...attr.column.replace(/\s/g, '').split(','));
    if (column.length) {
      column = query.column().concat(column);
      query.column(column);
    }

    if (!isLocalData) {
      if (attr.sort != undefined) sort = attr.sort.replace(/\s/g, '').split(',');
      if (sort.length) query.sort(sort);
    }

    if (attr.search != undefined) search = search.concat(...attr.search.replace(/\s/g, '').split(','));
    if (!isLocalData && search.length) {
      query.searchFields(search);
    }

    var onChange = null;
    var onSelect = null;
    var onDelete = null;
    var onAdd = null;
    var onView = null;

    if (!isLocalData && attr.onChange != undefined) onChange = $parse(attr.onChange);
    if (attr.onSelect != undefined) onSelect = $parse(attr.onSelect);
    if (attr.onDelete != undefined) onDelete = $parse(attr.onDelete);

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

    if (attr.limit != undefined) scope.$watch(attr.limit, x => limit = x);
    if (attr.hideOnFocus != undefined) showOnFocus = false;
    if (attr.autoFill != undefined) {
      if (attr.autoFill == '') {
        autoFill = true;
        tryAutoFill();
      } else {
        scope.$watch(attr.autoFill, x => {
          autoFill = !!x;
          tryAutoFill();
        });
      }
    }
    if (attr.readonly != undefined) {
      if (attr.readonly == '') f.readonly = true;
      else scope.$watch(attr.readonly, x => f.readonly = !!x);
    }
    if (attr.placeholder != undefined) scope.$watch(attr.placeholder, x => placeholder = x);

    function autoFillInput() {
      autoFill = false;
      if (f.rows.length == 1) {
        runOnSelect(f.rows[0], 0);
        justSelected = false;
      }
    }

    function tryAutoFill() {
      $timeout(function () {
        if (autoFill && !f.modelKey) {
          var oldLimit = limit;
          limit = MIN_FILL_LIMIT;
          isLocalData ? updateLocalData(autoFillInput) : updateQuery(autoFillInput);
          lastLimit = limit = oldLimit;
        }
      });
    }

    function checkParams() {
      return (isMultiple || !f.modelKeySelected || !f.model) && !f.readonly && (f.searchValue != '' || showOnFocus);
    }

    function clear() {
      pageNo = 1;
      lastLimit = limit;
      f.noRows = true;
      f.hasMoreRows = false;
      f.activeRowIndex = -1;
      f.rows = [];
    }

    function evalQueryResult() {
      let result = query.result();

      pageNo = query.pageNo();
      maxPage = result.maxPage;
      f.hasMoreRows = maxPage > pageNo;

      if (result.table && result.table.length > 0) {
        f.rows = f.rows.concat(result.table);
        f.noRows = false;
      }
    }

    function genOrderNo() {
      return lastOrderNo = _.uniqueId('order');
    }

    function fetchTable() {
      let $promise = $q.defer();
      let orderNo = genOrderNo();
      query.fetch(null, attr.referName).then(function () {
        if (orderNo != lastOrderNo) $promise.reject();
        else $promise.resolve();
      }, bAlert.open);
      return $promise.promise;
    }

    function updateQuery(onDone) {
      if (onChange) {
        onChange(scope, {query: query, value: f.searchValue});
      } else {
        autoChangeQuery();
      }
      query.pageNo(1);
      query.limit(limit);
      bHttp.unblockOnce();
      f.queryFetching = true;
      f.activeRowIndex = -1;
      fetchTable().then(function () {
        if (inputFocused || autoFill) {
          clear();
          evalQueryResult();
          onDone();
        }
      }).finally(function () {
        f.queryFetching = false;
      });
    }

    function evalLocalData() {
      maxPage = Math.floor((localDataReady.length + lastLimit - 1) / lastLimit);
      f.hasMoreRows = maxPage > pageNo;

      let result = localDataReady.slice((pageNo - 1) * lastLimit, pageNo * lastLimit);

      return result;
    }

    function updateLocalData(onDone) {
      clear();
      localDataReady = localData;
      if (isMultiple && modelKey) {
        let selectedRows = _.pluck(f.model, modelKey);
        localDataReady = _.reject(localDataReady, row => _.contains(selectedRows, row[modelKey]));
      }
      if (f.searchValue != '' && search.length) {
        let searchValue = f.searchValue.toLowerCase();
        localDataReady = _.filter(localDataReady, row => _.find(search, searchKey => (row[searchKey] + '').toLowerCase().indexOf(searchValue) > -1));
      }
      if (localDataReady.length) {
        f.rows = evalLocalData();
        f.noRows = false;
      }
      onDone();
    }

    function update() {
      if (allowUpdate) {
        isLocalData ? updateLocalData(showHint) : updateQuery(showHint);
      }
    }

    function onSearchChange() {
      if (inputFocused) {
        if (justSelected) {
          justSelected = false;
          if (!isMultiple) return;
        }
        if (!isMultiple && f.modelKeySelected) {
          autoDeleteRow();
        }
        if (checkParams()) {
          allowUpdate = true;
          update();
        } else {
          allowUpdate = false;
          hideHint();
        }
      }
    }

    function showMultiple() {
      return tryDeleteMultiple || inputFocused || multipleShowCount == -1 || (f.model || []).length <= multipleShowCount;
    }

    function onMultipleClick() {
      inputElement.focus();
    }

    function getPlaceholder() {
      if (isMultiple) {
        return showMultiple() ? placeholder : '';
      } else {
        return placeholder;
      }
    }

    function onInputFocus() {
      inputFocused = true;
      keydownHandler = keydownCallback;
      if (checkParams()) {
        allowUpdate = true;
        update();
      }
    }

    function onInputBlur() {
      inputFocused = false;
      keydownHandler = null;
      hideHint();
    }

    function onDeleteMousedown() {
      tryDeleteMultiple = true;
      checkDefaultValueEquals();
    }

    function onDeleteClick(row, index) {
      if (isMultiple) tryDeleteMultiple = false;
      autoDeleteRow(row, index);
      $timeout(()=>inputElement.focus());
      checkDefaultValueEquals();
    }

    function onClearAllClick() {
      f.model.splice(0, f.model.length);
      allowUpdate = true;
      inputElement.focus();
      checkDefaultValueEquals();
    }

    function onMouseOver(index) {
      f.activeRowIndex = index;
    }

    function runOnSelect(row, index) {
      justSelected = true;
      if (onSelect) {
        onSelect(scope, {row: row});
        if (isMultiple && !dublicates) f.rows.splice(index, 1);
      } else {
        autoSelectRow(row, index);
      }
      checkDefaultValueEquals();
    }

    function onSelectClick(row, index) {
      if (f.queryFetching) return;
      runOnSelect(row, index);
      if (!isMultiple) {
        hideHint();
      } else {
        inputElement.select();
        if (closeOnSelect) {
          hideHint();
        } else if (!f.rows.length && f.hasMoreRows) {
          onMoreClick();
        } else if (f.activeRowIndex == f.rows.length) {
          f.activeRowIndex--;
        }
      }
      setTimeout(controlHint, 5);
    }

    function onAddClick() {
      onAdd(scope, {value: f.searchValue});
      hideHint();
    }

    function onViewClick() {
      onView(scope, {value: f.searchValue});
      hideHint();
    }

    function moreQuery() {
      if (f.queryFetching) return;
      if (pageNo <= maxPage) {
        query.pageNo(++pageNo);
        query.limit(lastLimit);
        bHttp.unblockOnce();
        f.queryFetching = true;
        fetchTable().then(function () {
          if (inputFocused) {
            let count = f.rows.count;
            evalQueryResult();
            if (f.rows.count > count) {
              f.activeRowIndex++;
              scrollIntoView();
            }
          }
        }).finally(function () {
          f.queryFetching = false;
        });
      }
    }

    function moreLocalData() {
      pageNo++;
      let count = f.rows.count;
      f.rows = f.rows.concat(evalLocalData());
      if (f.rows.count > count) {
        f.activeRowIndex++;
        scrollIntoView();
      }
    }

    function onMoreClick() {
      isLocalData ? moreLocalData() : moreQuery();
    }

    function getElementRect(elem) {
      elem = elem[0] == undefined ? elem : elem[0];
      return elem.getBoundingClientRect();
    }

    function controlHint() {
      var inputElemRect = getElementRect(inputElement);
      var bInput = inputElement.closest('.b-input');
      var scrollParent = bInput.scrollParent();

      scrollParent.scroll(function (ev) {
        hintElement.position({
          of: bInput,
          my: 'left top',
          at: 'left bottom',
          collision: 'fit flipfit',
          within: $(this)
        });
      });
      hintElement.css({
        opacity: 1,
        width: attr.hintWidth || inputElemRect.width
      });
      hintElement.position({
        of: bInput,
        my: 'left top',
        at: 'left bottom',
        collision: 'fit flipfit',
        within: $(scrollParent)
      });
    }

    function showHint() {
      f.showHint = true;
      hintElement.css({opacity: 0});
      setTimeout(controlHint, 5);
      if (f.rows.length) f.activeRowIndex = 0;
    }

    function hideHint() {
      f.showHint = false;
    }

    function scrollIntoView() {
      $timeout(() => {
        let target = elem.find('.hint-item.active')[0];
        target.parentNode.scrollTop = target.offsetTop - target.parentNode.offsetTop;
      });
    }

    function rowUp() {
      if (f.activeRowIndex > 0) {
        f.activeRowIndex--;
        scrollIntoView();
      }
    }

    function rowDown() {
      if (f.activeRowIndex + 1 < f.rows.length) {
        f.activeRowIndex++;
        scrollIntoView();
      } else if (f.hasMoreRows) {
        onMoreClick();
      }
    }

    function keydownCallback(e) {
      if (f.queryFetching || f.readonly) return;
      switch (e.keyCode) {
        // arrow up
        case 38:
          if (elem.find('.hint-body').is(':hover')) return;
          e.preventDefault();
          rowUp();
          break;
        // arrow down
        case 40:
          if (elem.find('.hint-body').is(':hover')) return;
          e.preventDefault();
          rowDown();
          break;
        // enter
        case 13:
          e.preventDefault();
          if (f.activeRowIndex > -1 && f.activeRowIndex < f.rows.length) {
            onSelectClick(f.rows[f.activeRowIndex], f.activeRowIndex);
          }
          break;
        // backspace
        case 8:
          if (isMultiple) {
            if (f.searchValue == '' && f.model.length && !delayDelete) {
              let index = f.model.length - 1;
              onDeleteClick(f.model[index], index);
            }
          }
          break;
        // escape
        case 27:
          hideHint();
          break;
      }
      scope.$apply();
    }

    function checkDefaultValueEquals() {
      if (isMultiple) {
        f.isValueEqualsDefaultValue = JSON.stringify(f.model) === JSON.stringify(f.defaultValueModel);
      }
    }

    function tryToSetDefaultValue(data) {
      if (!f.model || _.isEmpty(f.model)) {
        function resetQueryWhere() {
          query.where(null);
          if (onChange) {
            onChange(scope, {query: query, value: f.searchValue});
          } else {
            autoChangeQuery();
          }
        }
        resetQueryWhere();

        let keyField;
        if (modelKeyAlias) {
          keyField = modelKeyAlias;
        } else if (modelKey) {
          if (Array.isArray(modelKey)) {
            keyField = modelKey[0];
          } else {
            keyField = modelKey;
          }
          if (keyField.includes(".")) {
            keyField = keyField.substring(keyField.lastIndexOf(".") + 1);
          }
        }

        if (isMultiple) {
          if (keyField) {
            let a = [keyField, "=", _.pluck(data.model, keyField)];
            if (query.where()) {
              query.where(["and", [query.where(), a]]);
            } else {
              query.where(a);
            }
          }
          fetchTable().then(function () {
            let result = query.result().table;

            if (result.length == data.model.length) {
              f.defaultValueModel = result;
              for (let item of result) {
                runOnSelect(item);
              }
              checkDefaultValueEquals();
            } else {
              onDeleteDefaultValue();
            }
            resetQueryWhere();
          }, function () {
            resetQueryWhere();
          });
        } else {
          if (keyField) {
            let a = [keyField, "=", data.modelKey];
            if (query.where()) {
              query.where(["and", [query.where(), a]]);
            } else {
              query.where(a);
            }
          }
          fetchTable().then(function () {
            let result = query.result().table[0];
            f.defaultValueModel = data.model;
            f.defaultValueModelKey = data.modelKey;
            runOnSelect(result);
            resetQueryWhere();
          }, function () {
            resetQueryWhere();
          })
        }
      }
    }

    function loadDefaultValue() {
      if ($rootScope.is_debug) {
        let data = bStorage.json(settingCode);
        data = typeof data == 'string' ? JSON.parse(data) : undefined;
        if (!_.isEmpty(data)) {
          if (Array.isArray(data.model) && data.model.length == 0) return;
          tryToSetDefaultValue(data);
        }
      } else {
        $http.post(bRoutes.LOAD_USER_SETTING, {
          setting_code: settingCode
        }).then(function (result) {
          if (result.data) {
            if (Array.isArray(result.data.model) && result.data.model.length == 0) return;
            tryToSetDefaultValue(result.data);
          }
        }, function (error) {
          console.error('b-input default value loader', error);
        });
      }
    }

    function onDeleteDefaultValue() {
      if ($rootScope.is_debug) {
        f.defaultValueModel = undefined;
        f.defaultValueModelKey = undefined;
        bStorage.text(settingCode, null);
        checkDefaultValueEquals();
      } else {
        $http.post(bRoutes.SAVE_USER_SETTING, {
          setting_code: settingCode
        }).then(function () {
          f.defaultValueModel = undefined;
          f.defaultValueModelKey = undefined;
          checkDefaultValueEquals()
        }, function (error) {
          console.error('unable to delete default value', error);
        });
      }
    }

    function onSaveDefaultValue() {
      if (!f.model) return;
      let settingValue = JSON.stringify({
        model: f.model,
        modelKey: f.modelKey
      });
      if ($rootScope.is_debug) {
        f.defaultValueModel = angular.copy(f.model);
        f.defaultValueModelKey = angular.copy(f.modelKey);
        bStorage.json(settingCode, settingValue);
        checkDefaultValueEquals()
      } else {
        $http.post(bRoutes.SAVE_USER_SETTING, {
          setting_code: settingCode,
          setting_value: settingValue
        }).then(function () {
          f.defaultValueModel = angular.copy(f.model);
          f.defaultValueModelKey = angular.copy(f.modelKey);
          checkDefaultValueEquals()
        }, function (error) {
          console.error('unable to save default value', error);
        });
      }
    }

    if ('pinable' in attr) {
      let order = $parse(attr['pinable'])();
      if(!order){
        order = 1;
      }
      $timeout(loadDefaultValue, 500 * order);
    }
  }

  function template(elem, attr) {
    let headerHtml = elem.find('header').html();
    let inputHtml = null;
    let readonly = '';
    let deleteIcon = attr.deleteIcon || 'fa fa-times';
    let tSavePin = bConfig.langs.input_save_pin_value;
    let tRemovePinned = bConfig.langs.input_remove_pin_value;

    if (attr.multiple == undefined) {
      let model = attr.model.split('|')[0].trim();
      let inputIconClass = '';
      let inputIconSpan = '';
      let pinButton = '';

      readonly = attr.readonly == undefined ? '' : 'ng-readonly="_$bInput.readonly"';

      if ('pinable' in attr) {
        pinButton = `<button type="button" class='pin-button'>
                       <i class="edit fas fa-thumbtack cursor-pointer text-hover-primary fa-rotate-270" 
                          ng-show="!_$bInput.readonly && _$bInput.modelKeySelected && _$bInput.modelKey == _$bInput.defaultValueModelKey"
                          ng-click="_$bInput.onDeleteDefaultValue()"
                          b-toggle="tooltip" data-delay='{"show":"1000"}' title="${tRemovePinned}"></i>
                       <i class="edit fas fa-thumbtack cursor-pointer text-hover-primary"
                          ng-show="!_$bInput.readonly && _$bInput.modelKeySelected && _$bInput.modelKey != _$bInput.defaultValueModelKey"
                          ng-click="_$bInput.model && _$bInput.onSaveDefaultValue()"
                          b-toggle="tooltip" data-delay='{"show":"1000"}' title='${tSavePin}'></i>
                     </button>`;
      }

      if (attr.inputIcon != undefined) {
        inputIconSpan = `
          <span class="icon-left">
            <span>
              <i class="${attr.inputIcon}"></i>
            </span>
          </span>
        `;
      }

      // validate
      let validate = [];

      if (attr.required != undefined && attr.model != undefined) {
        validate.push('model: !_$bInput.required || !!_$bInput.model');
      }

      if (attr.requiredKey != undefined && attr.modelKey != undefined) {
        validate.push('modelKey: !_$bInput.requiredKey || !!_$bInput.modelKey');
      }

      validate = validate.length ? 'b-validate="{' + validate.join(', ') + '}"' : '';

      inputHtml = `
        <div class="simple">
          ${pinButton}
          ${inputIconSpan}
          <input type="text"
                 class="form-control"
                 placeholder="{{ _$bInput.getPlaceholder() }}"
                 ng-model="${model}"
                 ng-focus="_$bInput.onInputFocus()"
                 ng-blur="_$bInput.onInputBlur()"
                 ${readonly}
                 ${validate}>
          <span class="icon-right">
          <span>
              <i ng-show="_$bInput.queryFetching && !_$bInput.showHint" class="spinner"></i>
              <i class="edit ${deleteIcon}" ng-show="!_$bInput.readonly && _$bInput.modelKeySelected" ng-click="_$bInput.onDeleteClick()"></i>
            </span>
          </span>
        </div>
      `;
    } else {
      readonly = attr.readonly == undefined ? '' : 'ng-show="!_$bInput.readonly"';
      let pinButton = '';
      if ('pinable' in attr) {
        pinButton = `<button type="button" class='pin-button'>
                       <i class="edit fas fa-thumbtack cursor-pointer text-hover-primary fa-rotate-270" 
                          ng-show="!_$bInput.readonly && _$bInput.model.length > 0 && _$bInput.isValueEqualsDefaultValue"
                          ng-click="_$bInput.onDeleteDefaultValue()"
                          b-toggle="tooltip" data-delay='{"show":"1000"}' title="${tRemovePinned}"></i>
                       <i class="edit fas fa-thumbtack cursor-pointer text-hover-primary"
                          ng-show="!_$bInput.readonly && _$bInput.model.length > 0 && !_$bInput.isValueEqualsDefaultValue"
                          ng-click="_$bInput.model && _$bInput.onSaveDefaultValue()"
                          b-toggle="tooltip" data-delay='{"show":"1000"}' title="${tSavePin}"></i>
                     </button>`;
      }

      inputHtml = `
        <div class="multiple form-control" ng-class="{padding: _$bInput.showMultiple() && _$bInput.model.length, readonly: _$bInput.readonly}">
          <a class="btn btn-secondary" ng-show="_$bInput.showMultiple()" ng-repeat="row in _$bInput.model track by $index">
            <span>
              <i class="fa fa-times" ng-if="!_$bInput.readonly" ng-mousedown="_$bInput.onDeleteMousedown()" ng-click="_$bInput.onDeleteClick(row, $index)"></i>
              <span>{{ row[_$bInput.label] }}</span>
            </span>
          </a>
          <span class="title" ng-click="_$bInput.onMultipleClick()" ng-hide="_$bInput.showMultiple()">{{ _$bInput.model.length }}&nbsp;{{ _$bInput.langs.input_selected }}</span>
          <input type="text"
                 class="form-control"
                 placeholder="{{ _$bInput.getPlaceholder() }}"
                 ng-model="_$bInput.searchValue"
                 ng-focus="_$bInput.onInputFocus()"
                 ng-blur="_$bInput.onInputBlur()"
                 ${readonly}/>
          <span class="clear-button">
            <span><i class="edit ${deleteIcon}" ng-show="!_$bInput.readonly && _$bInput.model.length > 0" ng-click="_$bInput.onClearAllClick()"></i></span>
          </span>
          ${pinButton}
        </div>
      `;
    }

    return _.template($templateCache.get('b-input.html'))({
      inputHtml: inputHtml,
      headerHtml: headerHtml == undefined ? '' : '<div class="hint-header"><div class="form-row">' + headerHtml + '</div></div>',
      rowHtml: elem.find('content').html() || elem.html()
    });
  }

  return {
    restrict: 'E',
    scope: true,
    link: link,
    template: template
  };
});
