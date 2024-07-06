app.factory('AppHotkey', function () {
  var key_pressed = {};
  var key_set_getters = [];
  var paused = false;

  function keydown(ev) {
    if (paused || key_pressed[ev.key]) return;

    key_pressed[ev.key] = true;

    _.each(key_set_getters, key_set_getter => {
      _.each(key_set_getter(), hotkey=> hotkey.apply(ev));
    });
  }

  function keyup() {
    key_pressed = {};
  }

  function on() {
    $(document).on('keydown', keydown).on('keyup', keyup);
  }

  function off() {
    $(document).off('keydown', keydown).off('keyup', keyup);
  }

  function addKeySetGetter(key_set_getter) {
    if (typeof(key_set_getter) == "function") {
      key_set_getters.push(key_set_getter);
    }
  }

  function removeKeySetGetter(key_set_getter) {
    if (typeof(key_set_getter) == "function") {
      let index = _.indexOf(key_set_getters, key_set_getter);
      if (index > -1) key_set_getters.splice(index, 1);
    }
  }

  function pause(pause) {
    paused = pause;
  }

  return {
    on: on,
    off: off,
    pause: pause,
    addKeySetGetter: addKeySetGetter,
    removeKeySetGetter: removeKeySetGetter
  };
});
