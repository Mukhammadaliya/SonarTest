function assert(condition, message, callback) {
  if (!condition) {
    if (typeof(callback) === "function") callback();
    throw message || "unknown assert error";
  }
}

function textColor(backgroundHex) {
  if (!backgroundHex) return '#fff';
  var r = parseInt(backgroundHex.substr(1,2), 16);
  var g = parseInt(backgroundHex.substr(3,2), 16);
  var b = parseInt(backgroundHex.substr(5,2), 16);
  var res = Math.round((r * 299 + g * 587 + b * 114) / 1000);
  return res > 170 ? '#000' : '#fff';
}

function notify(message, type, from) {
  var icon = '';
  switch (type) {
    case 'info': icon = 'fa fa-info'; break;
    case 'warning': icon = 'fa fa-exclamation-triangle'; break;
    case 'danger': icon = 'fa fa-times'; break;
    default: icon = 'fa fa-check';
  }
  $.notify({
    message: message,
    icon: icon
  }, {
    type: type || "success",
    placement: {
      from: from || 'bottom'
    }
  });
}

function deepDefaults(value, def) {
  if (value instanceof Object && def instanceof Object) {
    let keys = Object.keys(def);
    for (let i = 0; i < keys.length; i ++) {
      let _key = keys[i],
          val = def[_key];
      if (value.hasOwnProperty(_key)) value[_key] = deepDefaults(value[_key], val);
      else value[_key] = val;
    }
  }
  return value;
}

function callScript(page, s) {
  try {
    eval('(function(page,s,biruni,callScript){' + s + '})(page)');
  } catch (e) {
    return {
      reason : e,
      type : 'script',
      message : 'Script error:<code>' + (e.message || e) + '</code>'
    };
  }
}

function hasTouchDevice() {
  return (('ontouchstart' in window) || (navigator.maxTouchPoints > 0) || (navigator.msMaxTouchPoints > 0));
}
