biruni.factory('bHotkey', function ($timeout) {
  var key_info = [
    { "name": "backspace", "key": "Backspace", "code": "Backspace", "keyCode": 8 },
    { "name": "tab", "key": "Tab", "code": "Tab", "keyCode": 9 },
    { "name": "enter", "key": "Enter", "code": "Enter", "keyCode": 13 },
    { "name": "shift(left)", "key": "Shift", "code": "ShiftLeft", "keyCode": 16 },
    { "name": "shift(right)", "key": "Shift", "code": "ShiftRight", "keyCode": 16 },
    { "name": "ctrl(left)", "key": "Control", "code": "ControlLeft", "keyCode": 17 },
    { "name": "ctrl(right)", "key": "Control", "code": "ControlRight", "keyCode": 17 },
    { "name": "alt(left)", "key": "Alt", "code": "AltLeft", "keyCode": 18 },
    { "name": "alt(right)", "key": "Alt", "code": "AltRight", "keyCode": 18 },
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
    { "name": "left window key", "key": "Meta", "code": "MetaLeft", "keyCode": 91 },
    { "name": "right window key", "key": "Meta", "code": "MetaRight", "keyCode": 92 },
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
  var hotkeys = {};

  function Hotkey(combination, callback, is_global) {
    assert(!hotkeys[combination], `hotkey combination(${combination}) exist in global keys`);

    if (is_global) hotkeys[combination] = true;

    var t = this;
    t.mod_keys = {};
    t.keys = String(combination || '').toLowerCase().split('+');
    t.lastkeyCode = _.find(key_info, k => String(k.key).toLowerCase() == _.last(t.keys))['keyCode'];

    if (typeof(callback.isPrevent) === "function") {
      t.callback = event=> {
        if (callback.isPrevent()) event.preventDefault();
        $timeout(callback);
      }
    } else {
      t.callback = event=> {
        event.preventDefault();
        $timeout(callback);
      };
    }

    t.apply = function(event) {
      let is_special = _.every(['ctrl', 'alt', 'shift', 'meta'], c => t.mod_keys[c] == event[c + 'Key']);
      if (is_special && event.keyCode == t.lastkeyCode) t.callback(event);
    }

    _.each(['ctrl', 'alt', 'shift', 'meta'], function(c) {
      t.mod_keys[c] = _.indexOf(t.keys, c) > -1;
    });
  }

  return function(combination, callback, is_global) {
    return new Hotkey(combination, callback, is_global);
  };
});
