_.mixin({
  mapMatrix: function (vs, ns) {
    return _.map(_.zip.apply(null, vs), function (v) {
      return _.object(ns, v);
    });
  },
  mapRows: function (vs, ks) {
    return _.map(vs, function(v){
      return _.object(ks, v);
    });
  },
  padStart: function(str, cnt, pref) {
    str = String(str);
    if (cnt > str.length)  return pref.repeat(cnt - str.length) + str;
    return str;
  }
});