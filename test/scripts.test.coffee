require './spec_helper'
{spawn} = require 'child_process'
{split} = require 'event-stream'
assert = require 'assert'

describe '[scripts]', ->
  log = (message) ->
    console.log '[generated]', message.toString()

  npm = (cmd, options, done) ->
    if not done
      done = options; options = {}

    child = spawn 'npm', [cmd]
    child.stdout.pipe(split()).on 'data', log
    child.stderr.pipe(split()).on 'data', (data) ->
      log data
      options.err? data
    child.on 'close', done
    child

  install = (done) ->
    @timeout 10000
    npm 'install', (code) ->
      assert.equal code, 0, 'should not error'
      done()

  test = (done) ->
    loggedBused = false
    npm 'test',
      err: (data) ->
        if /\bbusted\b/.test data
          loggedBused = true
      (code) ->
        assert loggedBused, 'should show the mocha test failure'
        done()

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

