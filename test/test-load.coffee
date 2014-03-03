assert = require 'assert'

describe 'hmlad generator', ->
  it 'can be imported without blowing up', ->
    hmladNpm = require '../app'
    assert(hmladNpm?)
