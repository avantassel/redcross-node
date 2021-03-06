# modules
async = require 'async'
request = require 'request'

module.exports =
  allowCrossDomain: (req, res, next) ->
    res.header 'Access-Control-Allow-Origin', '*'
    res.header 'Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE'
    res.header 'Access-Control-Allow-Headers', 'Content-Type'

    if 'OPTIONS' is req.method
      res.send 200
    else
      next()

  calcDistance: (coord1, coord2) ->
    [lat1, lon1] = [coord1.lat, coord1.long]
    [lat2, lon2] = [coord2.lat, coord2.long]
    radlat1 = Math.PI * lat1 / 180
    radlat2 = Math.PI * lat2 / 180
    radlon1 = Math.PI * lon1 / 180
    radlon2 = Math.PI * lon2 / 180
    theta = lon1 - lon2
    radtheta = Math.PI * theta / 180
    dist = Math.sin(radlat1) * Math.sin(radlat2)
    dist += Math.cos(radlat1) * Math.cos(radlat2) * Math.cos(radtheta)
    dist = Math.acos(dist)
    dist *= 180 / Math.PI
    dist *= 60 * 1.1515
    distance =
        'mi': Math.floor dist
        'km': Math.floor dist * 1.609344

  getShelters: (done) ->
    async.waterfall [
      (next) -> request {method: 'GET', url: 'http://app.redcross.org/nss-app/pages/mapServicesList.jsp?action=list'}, next
      (resp, body, next) ->
        return next 'resp is undefined. uh oh.' unless resp

        # check for bad status code
        if resp.statusCode < 200 or resp.statusCode > 302
          return next "bad #{body}"

        parseJSON = ->
          try
            body = JSON.parse body
            body = body.Locations
            return next null, body
          catch err
            return next err

        parseJSON()

    ], (err, body) ->
      done err, body


 String::toProperCase = ->
  @replace /\w\S*/g, (txt) ->
    txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()
