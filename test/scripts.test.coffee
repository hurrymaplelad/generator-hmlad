require './spec_helper'
{spawn} = require 'child_process'
split = require 'split'
assert = require 'assert'
logProcess = require 'process-logger'

describe '[scripts]', ->
  npm = (cmd, options, done) ->
    if not done
      done = options; options = {}
    child = spawn 'npm', [cmd]
    logProcess child, prefix: '[generated]'
    child.on 'close', done
    child

  install = (done) ->
    @timeout 10000
    npm 'install', (code) ->
      assert.equal code, 0, 'should not error'
      done()

  test = (done) ->
    loggedBused = false
    npm 'test', (code) ->
      assert loggedBused, 'should show the mocha test failure'
      done()
    .stderr.pipe(split()).on 'data', (data) ->
      if /\bbusted\b/.test data
        loggedBused = true

  describe 'using javascript', ->
    before (done) ->
      @runGenerator {coffee: false}, done

    it 'npm installs', install
    it 'npm test fails with expected message', test

  describe 'using coffeescript', ->
    before (done) ->
      @runGenerator {coffee: true}, done

    it 'npm installs', install
    it 'npm test fails with expected message', test

