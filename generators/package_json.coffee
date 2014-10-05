merge = require 'deepmerge'
helpers = require './template_helpers'
{underscored} = require 'underscore.string'

module.exports = (data, overrides={}) ->
  json = base.apply(data)
  if data.coffee
    json = merge json, coffee.apply(data)
  json = merge json, overrides
  JSON.stringify json, null, 2

base = ->
  name: @pkgname
  version: "0.0.0"
  description: @description
  author: helpers.user @author
  keywords: @keywords?.length and @keywords or undefined
  main: underscored @pkgname
  repository:
    type: "git"
    url: "git://github.com/hurrymaplelad/#{@reposlug}.git"
  homepage: "https://github.com/hurrymaplelad/#{@reposlug}"
  bugs: "https://github.com/hurrymaplelad/#{@reposlug}/issues"
  dependencies: {}
  devDependencies:
    "coffee-script": ">=1.7.x"
    "mocha": "~1.x.x"
  scripts:
    "test": "mocha"

coffee = ->
  main: "lib/#{underscored @pkgname}"
  scripts:
    "prepublish": "npm run compile"
    "pretest": "npm run compile"
    "compile": "coffee --compile --output lib/ src/"
