// My SocketStream 0.3 app

var http = require('http'),
    ss = require('socketstream');

// Define a single-page client called 'main'
ss.client.define('main', {
  view: 'main.jade',
  css:  [
    'libs/jquery-ui-1.9.2.min.css',
    'libs/bootstrap.min.css',
    'libs/bootstrap-responsive.min.css',
    'main.styl'],
  code: [
    'libs/jquery-1.8.3.min.js',
    'libs/jquery-ui-1.9.2.min.js',
    'libs/bootstrap.min.js',
    'shared', 'main'],
  tmpl: '*'
});

ss.client.define('spacecore', {
  view: 'spacecore.jade',
  css:  ['spacecore.styl'],
  code: [
	'libs/Stats.js',
	'shared', 'spacecore'],
  tmpl: '*'
});

ss.client.define('test', {
  view: 'test.jade',
  css:  ['test.styl'],
  code: [
	'libs/Stats.js',
	'shared', 'test'],
  tmpl: '*'
});

// Serve this client on the root URL
ss.http.route('/', function(req, res){
  res.serveClient('main');
});

ss.http.route('/spacecore', function(req, res){
  res.serveClient('spacecore');
});

ss.http.route('/test', function(req, res){
  res.serveClient('test');
});

// Code Formatters
ss.client.formatters.add(require('ss-coffee'));
ss.client.formatters.add(require('ss-jade'));
ss.client.formatters.add(require('ss-stylus'));

// Use server-side compiled Hogan (Mustache) templates. Others engines available
ss.client.templateEngine.use(require('ss-hogan'));

// Minimize and pack assets if you type: SS_ENV=production node app.js
if (ss.env === 'production') ss.client.packAssets();

// Start web server
var server = http.Server(ss.http.middleware);
server.listen(3000);

// Start SocketStream
ss.start(server);
