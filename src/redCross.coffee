#! /usr/local/bin/node
async = require 'async'
mongo = require 'mongodb'
parser = require 'cron-parser'
schedule = require 'node-schedule'
utils = require './utils'

# constants
config = require './config.json'

# set up server
mongoURI = process.env.MONGO_URI or config.mongo.uri or 'mongodb://'+config.mongo.host+':'+config.mongo.port+'/'+config.mongo.dbName

remapLatLong = (shelter) ->
  latitude = parseFloat shelter.lat
  longitude = parseFloat shelter.lng
  shelter.active = true
  shelter.city = shelter.city.toProperCase()
  shelter.location = {type: 'Point', coordinates: [longitude, latitude]}
  delete shelter.lat
  delete shelter.lng
  return shelter

remapData = (shelter, done) ->
  shelter = remapLatLong shelter
  shelter.lastUpdated = new Date()
  done null, shelter

translateData = (shelters, next) ->
  async.map shelters, remapData, next

# DB update shortcut
update = (collection, query, update, next) ->
  mongo.MongoClient.connect mongoURI, (err, db) ->
    collection = db.collection collection
    collection.ensureIndex {location: '2dsphere'}, (err) ->
      options = {safe: true, upsert: true}
      collection.update query, {'$set':update,'$setOnInsert':{created:new Date()}}, options, next

saveAllShelters = (shelters, done) ->
  console.log "Updating #{shelters.length} shelters #{new Date()}"
  async.eachSeries shelters, ((shelter, next) ->
    query = {'location.coordinates': shelter.location.coordinates}
    update 'shelters', query, shelter, next
  ), done

deActivateShelters = (done) ->
  mongo.MongoClient.connect mongoURI, (err, db) ->
    collection = db.collection 'shelters'
    options = {safe: true}
    collection.update {}, {'$set':{active:false}}, options, done()

updateShelters = (done) ->
  sheltersCount = 0
  async.waterfall [
    (next) -> deActivateShelters next
    (next) -> utils.getShelters next
    (shelters, next) -> translateData shelters, next
    (shelters, next) ->
      sheltersCount = shelters.length
      saveAllShelters shelters, next
  ], (err) ->
    done err, sheltersCount

startUpdateSchedule = ->
  #startup update
  setTimeout (->
    updateShelters (err, sheltersCount) ->
      time = Date.now()
      log = {err, time, sheltersCount}
      update 'logs', log, log
    ), 1000

  if(!config.cronUpdateSchedule)
    console.log "Shelters not scheduled to update, set config cronUpdateSchedule to cron format"
    return

  interval = parser.parseExpression config.cronUpdateSchedule
  console.log "Shelters scheduled to update #{interval.next().toString()}"

  schedule.scheduleJob config.cronUpdateSchedule, ->
    updateShelters (err, sheltersCount) ->
      time = Date.now()
      log = {err, time, sheltersCount}
      update 'logs', log, log, (err, results) ->
        return next err if err
        results

run = ->
  startUpdateSchedule()

run()

addDistance = (shelters, coords, next) ->
  {lat, long} = coords
  for shelter in shelters
    {coordinates} = shelter.location
    shelter_loc = {lat: coordinates[1], long:coordinates[0]}
    user_loc = {lat: lat, long: long}
    shelter.distance = utils.calcDistance user_loc, shelter_loc
  next null, shelters

module.exports =
  allShelters: (req, res) ->
    mongo.MongoClient.connect mongoURI, (err, db) ->
      shelters = db.collection 'shelters'
      query = req.query
      if query.active
        query.active = if query.active is 'false' then false else true

      async.waterfall [
        (next) -> shelters.find query, next
        (results, next) -> results.toArray next
      ], (err, shelters) ->
        return res.send 'Database error' if err
        res.send shelters

  closestShelters: (req, res) ->
    mongo.MongoClient.connect mongoURI, (err, db) ->
      {city, lat, long} = req.params
      [lat, long] = [parseFloat(lat), parseFloat(long)]
      shelters = db.collection 'shelters'
      coord = {type: "Point", coordinates: [long, lat]}
      query = {location: {$near: {$geometry: coord}}}
      if req.active
        query.active = if query.active is 'false' then false else true

      async.waterfall [
        (next) -> shelters.find query, next
        (results, next) -> results.toArray next
        (shelters, next) -> addDistance shelters, {lat, long}, next
      ], (err, shelters) ->
        return res.send {error: "Database error - #{err}"} if err
        res.send shelters
