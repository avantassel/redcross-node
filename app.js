// Generated by CoffeeScript 1.10.0
(function() {
  var action, app, bodyParser, endpoints, express, http, i, len, middleware, morgan, point, redCross, utils, ware;

  bodyParser = require('body-parser');

  express = require('express');

  morgan = require('morgan');

  http = require('http');

  redCross = require('./lib/redCross.js');

  utils = require('./lib/utils.js');

  endpoints = {
    '/redcross/shelters': function(req, res) {
      return redCross.allShelters(req, res);
    },
    '/redcross/shelters/:lat/:long': function(req, res) {
      return redCross.closestShelters(req, res);
    }
  };

  middleware = [morgan('dev'), bodyParser.json(), utils.allowCrossDomain, express["static"](__dirname + "/public")];

  app = express();

  app.set("port", process.env.PORT || 8080);

  for (i = 0, len = middleware.length; i < len; i++) {
    ware = middleware[i];
    app.use(ware);
  }

  for (point in endpoints) {
    action = endpoints[point];
    app.get(point, action);
  }

  http.createServer(app).listen(app.get("port"), function() {
    return console.log("Express server listening on port " + app.get("port"));
  });

}).call(this);
