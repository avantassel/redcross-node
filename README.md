# RedCross node

[![NPM version](https://badge.fury.io/js/redcross.svg)](https://npmjs.org/package/redcross)
[![Build Status](https://travis-ci.org/avantassel/redcross-node.svg)](https://travis-ci.org/avantassel/redcross-node)
[![Dependencies](https://david-dm.org/avantassel/redcross-node.svg)](https://david-dm.org/avantassel/redcross-node)&nbsp;


An API for RedCross shelters. This module downloads shelters and stores them in a mongo database.

[![Deploy to Bluemix](https://bluemix.net/deploy/button.png)](https://bluemix.net/deploy)

## Development
```
# install node modules
npm install

# if you want to compile CoffeeScript
cake build

# run the app
node app
```

## Config

Set mongo and update schedule times here.  Mongo URI can also be set with the environment variable MONGO_URI
```
cronUpdateSchedule
```

## All active shelters
```
http://localhost:8080/redcross/shelters/?active=true
```

## All shelters sorted from closest to farthest
```
http://localhost:8080/redcross/shelters/:lat/:long/
```
