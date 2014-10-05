path = require 'path'
helpers = require('yeoman-generator').test

before ->
  @reposlug = 'node-french-omelette' # prefix with node to test module name different from repo name
  @runGenerator = (responses, done) ->
    helpers.testDirectory path.join(__dirname, 'generated', @reposlug), (err) =>
      if err
        return done(err)

      options = {}
      options['skip-install'] = true
      options['quiet'] = true
      @app = helpers.createGenerator('hmlad:app', ['../../../generators/app/index.js'], [], options)

      helpers.mockPrompt @app, responses
      @app.run {pkgname: 'foo'}, ->
        done()
