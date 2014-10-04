assert = require 'assert'

describe 'hmlad generator', ->
  it 'can be imported without blowing up', ->
    hmladNpm = require '../generators/app'
    assert(hmladNpm?)
