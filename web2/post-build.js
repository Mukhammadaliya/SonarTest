const fs = require("fs-extra");

// deleting old bundle from prod
try {
  fs.removeSync('../web/a2/');
} catch (err) {
  console.error(err);
}

// replacing new bundle into prod
try {
  fs.moveSync('./dist/biruni/browser/', '../web/a2');
} catch (err) {
  console.error(err);
}

// renaming index.html into login.html
try {
  fs.moveSync('../web/a2/index.html', '../web/a2/login.html');
} catch (err) {
  console.error(err);
}

// deleting leftover bundle
try {
  fs.removeSync('./dist');
} catch (err) {
  console.error(err);
}
