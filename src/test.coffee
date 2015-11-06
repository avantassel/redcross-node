async = require('async')
assert = require('assert')
utils = require('../lib/utils.js')

describe 'Test RedCross Shelters', ->
  it 'should have a response', (done) ->
    utils.getShelters (err, result) ->
      if !result
        assert.fail err, 'result'
      else
        assert true, !!result
      done()
    return
