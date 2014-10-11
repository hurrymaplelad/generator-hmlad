require './spec_helper'
assert = require('yeoman-generator').assert

describe '[files]', ->
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
        assert.fileContent 'package.json', /// "name":\s"#{@reposlug}" ///

      it 'includes author', ->
        assert.fileContent 'package.json', /"author": "Adam Hull <adam@hmlad.com>"/

      it 'doesnt add contributors', ->
        assert.noFileContent 'package.json', /"contributors":/

      it 'doesnt add keywords', ->
        assert.noFileContent 'package.json', /"keywords":/

      it 'adds an open source license', ->
        assert.fileContent 'package.json', /// "license":\s"MIT" ///

    describe 'README.md', ->
      it 'includes badges', ->
        assert.fileContent 'README.md', /// shields.io/travis ///
        assert.fileContent 'README.md', /// shields.io/npm ///

    describe 'mocha.opts', ->
      it 'bails on first failure', ->
        assert.fileContent 'test/mocha.opts', /// --bail ///

  describe 'when user supplies keywords', ->
    keywords = ['sesquipedalian', 'prolix']

    before (done) ->
      @runGenerator {keywords}, done

    describe 'package.json', ->
      it 'includes keywords', ->
        assert.fileContent 'package.json', /"keywords": \[/
        for keyword in keywords
          assert.fileContent 'package.json', /// "#{keyword} ///

  describe 'using javascript', ->
    before (done) ->
      @runGenerator {coffee: false}, done

    it 'creates a file for the module in the package root', ->
      assert.file 'node_french_omelette.js'

    describe 'package.json', ->
      it 'main links to source file', ->
        assert.fileContent 'package.json', /// "main":\s"node_french_omelette" ///

      it 'depends on jshint at development time', ->
        assert.fileContent 'package.json', /// "jshint": ///

      it 'runs jshint with tests', ->
        assert.fileContent 'package.json', /// "test":.*jshint ///

  describe 'using coffeescript', ->
    before (done) ->
      @runGenerator {coffee: true}, done

    it 'doesnt create source files in the pacakge root', ->
      assert.noFile 'node_french_omelette.js'

    it 'creates a file for the module in src directory', ->
      assert.file 'src/node_french_omelette.coffee'

    describe 'package.json', ->
      it 'main links to the compiled file', ->
        assert.fileContent 'package.json', /// "main":\s"lib/node_french_omelette" ///

      it 'includes compilation scripts', ->
        assert.fileContent 'package.json', /"prepublish": "npm run compile"/

