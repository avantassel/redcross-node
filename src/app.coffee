# feeds = require './feeds.json'
bodyParser = require 'body-parser'
express = require 'express'
morgan = require 'morgan'
http = require 'http'

# utilities
redCross = require './lib/redCross.js'
utils = require './lib/utils.js'

# endpoints
endpoints =
  '/redcross/shelters': (req, res) ->
    redCross.allShelters req, res

  '/redcross/shelters/:lat/:long': (req, res) ->
    redCross.closestShelters req, res

# middleware
middleware = [
  morgan 'dev'
  bodyParser.json()
  utils.allowCrossDomain
  express.static "#{__dirname}/public"
]

app = express()

app.set "port", process.env.PORT or 8080
app.use ware for ware in middleware
app.get point, action for point, action of endpoints

http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")
