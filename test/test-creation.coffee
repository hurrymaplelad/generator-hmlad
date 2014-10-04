path = require 'path'
helpers = require('yeoman-generator').test
assert = require('yeoman-generator').assert

describe 'hmlad generator', ->
  reposlug = 'node-french-omelette' # prefix with node to test module name different from repo name

  before ->
    @runGenerator = (responses, done) ->
      helpers.testDirectory path.join(__dirname, 'generated', reposlug), (err) =>
        if err
          return done(err)

        @app = helpers.createGenerator('hmlad:app', ['../../../app/index.js'])
        @app.options['skip-install'] = true

        helpers.mockPrompt @app, responses
        @app.run {pkgname: 'foo'}, ->
          done()


  describe 'with default prompt values', ->
    before (done) ->
      @runGenerator {}, done

    it 'creates expected files', (done) ->
      assert.file [
        '.editorconfig'
        '.gitignore'
        '.travis.yml'
        'test/mocha.opts'
      ]
      done()

    describe 'package.json', ->
      it 'includes package name matching parent directory', ->
        assert.fileContent 'package.json', /// "name":\s"#{reposlug}" ///

      it 'includes author', ->
        assert.fileContent 'package.json', /"author": "Adam Hull <adam@hmlad.com>"/

    describe 'README.md', ->
      it 'includes badges', ->
        assert.fileContent 'README.md', /// travis-ci ///
        assert.fileContent 'README.md', /// badge.fury.io/js ///

    describe 'test', ->
      it 'fails', (done) ->
        Mocha = require 'mocha'
        mocha = new Mocha reporter: (runner) ->
          runner.on 'fail', (test, err) ->
            assert /busted/.test err
            done()
        mocha.addFile "test/node_french_omelette.test.coffee"
        mocha.run()

  describe 'when user supplies a package name and description', ->
    pkgname = 'french-omelette'
    description = "Dish made from beaten eggs quickly cooked with butter or oil in a frying pan"

    before (done) ->
      @runGenerator {pkgname, description}, done

    describe 'package.json', ->
      it 'includes supplied package name and description', ->
        assert.fileContent 'package.json', /// "name":\s"#{pkgname}" ///
        assert.fileContent 'package.json', /// "description":\s"#{description}" ///

      it 'does not use parent directory name', ->
        assert.noFileContent 'package.json', /// "name":\s"#{reposlug}" ///

    describe 'README.md', ->
      it 'includes package name and description', ->
        assert.fileContent 'README.md', /// #{pkgname} ///
        assert.fileContent 'README.md', /// #{description} ///
