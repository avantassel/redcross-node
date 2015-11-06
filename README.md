# RedCross node

[![NPM Version](http://img.shields.io/npm/v/redcross.svg)](https://www.npmjs.org/package/redcross)
[![Build Status](https://travis-ci.org/avantassel/redcross-node.svg)](https://travis-ci.org/avantassel/redcross-node)

An API for RedCross shelters. This module downloads shelters and stores them in a mongo database.

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

Set mongo and update schedule times here
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
