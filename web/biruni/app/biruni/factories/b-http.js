biruni.factory('bHttp', function (bConfig, $http, $templateRequest, $q, Upload, bRoutes) {

  var unblock = false;

  function unblockOnce() {
    unblock = true;
  }

  function error(reason, type, message, path, data) {
    return {
      reason : reason,
      type : type,
      message : message,
      data: data,
      path : path
    };
  }

  function extractPath(uri) {
    var s = uri.match(/[^+$:?]+/);
    return s[0];
  }

  function loadUri(uri) {
    return $templateRequest(uri, true);
  }

  function fetchHtml(path) {
    const uri = 'page/form' + extractPath(path) + '.html';

    return r.loadUri(uri).then(null, function (reason) {
      switch (reason.status) {
      case 404:
        return $q.reject(error(reason, 'html404', 'Not found: <b>' + uri + '</b>', path));
      default:
        return $q.reject(error(reason, 'ex'));
      }
    });
  }

  function fetchLang(path) {
    var uri = 'page/lang/' + bConfig.langCode() + extractPath(path) + '.json';

    return r.loadUri(uri).then(function (d) {
      try {
        return JSON.parse(d);
      } catch (e) {
        return {};
      }
    }, function () {
      return {};
    });
  }

  function fetchCustomLang(path) {
    return $http.post(bRoutes.LOAD_CUSTOM_HTML_TRANSLATIONS, {path: path}, {unblock: true}).then(function(d) {
      try {
        return _.chain(d.data).filter(x=> !!x[1]).object().value();
      } catch (e) {
        return {};
      }
    }, function () {
      return {};
    });
  }
  
  function fetchTour(path) {
    var uri = 'page/tour/' + bConfig.langCode() + extractPath(path) + '.json';
    
    return r.loadUri(uri).then(function (d) {
      try {
        return JSON.parse(d);
      } catch (e) {
        return {};
      }
    }, function () {
      return {};
    });
  }
  
  function postError(path) {
    return function (reason) {
      if (_.contains([400, 401, 402, 403, 404, 409, 410, 500], reason.status)) {
        if (reason.status === 401) {
          bConfig.sessionOutFn()();
        }
        if (reason.status === 402) {
          bConfig.subscriptionEndFn()();
        }
        if (reason.status === 409) {
          bConfig.sessionConflictsFn()();
        }
        return $q.reject(error(reason, 'route' + reason.status, reason.data, path, reason.data))
      } else {
        return $q.reject(error(reason, 'ex'));
      }
    }
  }

  function postFileAlone(file) {
    return Upload.upload({
      url: bRoutes.SAVE_FILE,
      file: file,
      headers: {
        BiruniUpload: 'alone',
        filename: encodeURIComponent(file.name),
      },
    }).then(null, postError(bRoutes.SAVE_FILE));
  }

  function postData(path, data, type, headers) {
    const file = [], param = loop(data || {});

    function loop(d) {
      if (d instanceof File) {
        file.push(d);
        return '\0' + (file.length - 1);
      }
      if (_.isArray(d)) {
        return _.map(d, loop)
      } else if (_.isObject(d)) {
        return _.mapObject(d, loop);
      } else if (_.isString(d)) {
        return d.replace('\0', '');
      } else {
        return d;
      }
    }

    if (file.length) {
      return Upload.upload({
        url : 'b' + path,
        fields : {
          param : JSON.stringify(param)
        },
        file : file,
        headers : {
          'BiruniUpload' : type || 'param'
        }
      }).then(null, postError(path));
    } else {
      const ub = unblock;
      unblock = false;
      return $http.post('b' + path, param, {
        unblock : ub,
        headers : headers
      }).then(null, postError(path));
    }
  }

  function mapResult(param) {
    return function (result) {
      result = _.defaults(result.data, param);
      result.maxPage = calcMaxPage(result.count, result.limit);
      result.table = _.map(result.data, mapRow(result.column));
      return result;
    }
  }

  function calcMaxPage(count, limit) {
    return Math.floor(count / limit) + (count % limit ? 1 : 0)
  }

  function mapRow(col) {
    return function (row) {
      var r = {};
      for (var i = 0; i < col.length; i++) {
        r[col[i]] = row[i];
      }
      return r;
    }
  }

  function queryData(path, d, tag) {
    if (_.isEmpty(d.column)) {
      return $q.reject('Query column is empty');
    }

    var limit = d.limit ? d.limit : 100,
    data = {},
    param = angular.copy({
        column : d.column,
        offset : d.offset,
        limit : limit
      });
    param.tag = tag;
    data.p = {
      column : d.column,
      filter : d.filter,
      sort : d.sort,
      refer_name : d.refer_name,
      offset : d.offset,
      limit : limit
    };
    if (d.param) {
      data.d = d.param;
    }
    return postData(path, data).then(mapResult(param));
  }

  function queryFieldsInfo(path, param, refers) {
    var data = {
      d : param,
      p : {
        'do' : 1,
        refers : refers
      }
    };

    return postData(path, data).then(function (result) {
      return result.data;
    });
  }


  function queryExport(path, d) {
    if (_.isEmpty(d.column_list)) {
      throw 'Query column is empty';
    }

    var data = {
      d : d.param,
      p : {
        'do' : 2,
        column : _.pluck(d.column_list, 'name'),
        label : _.pluck(d.column_list, 'label'),
        size : _.pluck(d.column_list, 'size'),
        img : _.pluck(d.column_list, 'img'),
        filter : d.filter,
        sort : d.sort,
        rt : d.rt
      }
    };
    download('b' + path, data, d.fileName, d.fileType);
  }

  function download(uri, data, fileName, fileType) {
    var xhr = new XMLHttpRequest();
    xhr.open('POST', uri);
    xhr.responseType = 'blob';
    var auths = bConfig.auths();
    for (k in auths) {
      xhr.setRequestHeader(k, auths[k]);
    }

    xhr.setRequestHeader('Content-type', 'application/json; charset=utf-8');
    xhr.onload = function (e) {
      if (this.status == 200) {
        var blob = new Blob([this.response], {
            type : fileType
          });
        var downloadUrl = URL.createObjectURL(blob);
        var a = document.createElement("a");
        a.href = downloadUrl;
        a.download = fileName;
        document.body.appendChild(a);
        a.click();

        setTimeout(function () {
          URL.revokeObjectURL(downloadUrl);
        }, 100);
      }
    };
    xhr.send(JSON.stringify(data));
  }

  const r = {
    fetchHtml : fetchHtml,
    fetchLang : fetchLang,
    fetchCustomLang: fetchCustomLang,
    fetchTour : fetchTour,
    postFileAlone : postFileAlone,
    postData : postData,
    queryData : queryData,
    queryFieldsInfo : queryFieldsInfo,
    queryExport : queryExport,
    extractPath : extractPath,
    loadUri : loadUri,
    download : download,
    unblockOnce : unblockOnce
  };

  return r;
});
