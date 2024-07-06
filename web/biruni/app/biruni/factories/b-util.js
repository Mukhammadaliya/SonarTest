biruni.factory('bUtil', function() {
  function isObject (value) {
    return value && typeof value === 'object' && value.constructor === Object;
  }

  function isArray (value) {
    return value && typeof value === 'object' && value.constructor === Array;
  }

  function str2(val) {
    return val < 10 ? '0' + val: val;
  }

  function timeToMinutes(time) {
    if (time === undefined || time === null) return null;
    time = String(time);
    [hour, minute] = time.split(':');
    if (minute === undefined) return null;
    return parseInt(hour) * 60 + parseInt(minute);
  }

  function minutesToTime(minutes) {
    minutes = parseInt(minutes);
    if (isNaN(minutes)) return null;
    return [str2(parseInt(minutes / 60)), str2(minutes % 60)].join(':');
  }

  function doConvert(converter) {
    return function () {
      if (arguments.length == 1) return converter(arguments[0]);
      if (arguments.length >= 2) {
        obj = null; keys = null;
        for (let i = 0; i < 2; i ++) {
          if (isObject(arguments[i])) obj = arguments[i];
          else
          if (isArray(arguments[i])) keys = arguments[i];
        }
        if (obj === null || keys === null) return null;

        for (let i = 0; i < keys.length; i ++) {
          let key = keys[i];
          if (obj.hasOwnProperty(key)) {
            let new_value = converter(obj[key]);
            if (new_value !== null) obj[key] = new_value;
          }
        }
        return obj;
      }
      return null;
    }
  }

  return {
    timeToMinutes: doConvert(timeToMinutes),
    minutesToTime: doConvert(minutesToTime)
  };
});