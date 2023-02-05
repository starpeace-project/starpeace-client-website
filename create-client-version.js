const fs = require('fs')
const pjson = require('./package.json');

const now = new Date();
const year = now.toLocaleString('en-US', { timeZone: 'America/Los_Angeles', year: 'numeric'});
const month = now.toLocaleString('en-US', { timeZone: 'America/Los_Angeles', month: '2-digit'});
const day = now.toLocaleString('en-US', { timeZone: 'America/Los_Angeles', day: '2-digit'});
const nowDate = `${year}-${month}-${day}`;
const client_version = 'v' + pjson.version + '-' + nowDate;


if (!fs.existsSync('.output')) {
  fs.mkdirSync('.output');
}
if (!fs.existsSync('.output/public')) {
  fs.mkdirSync('.output/public');
}
if (!fs.existsSync('.output/public/client')) {
  fs.mkdirSync('.output/public/client');
}

fs.writeFileSync('.output/public/client/client-version.json', "{\"version\":\"" + client_version + "\"}");
