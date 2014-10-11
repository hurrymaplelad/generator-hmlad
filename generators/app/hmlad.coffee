fs = require 'fs'
path = require 'path'
yeoman = require 'yeoman-generator'
handlebarsEngine = require 'yeoman-handlebars-engine'
{underscored} = require 'underscore.string'
childProcess = require 'child_process'

quiet = false

bundleExec = (args..., done) ->
  args.unshift 'exec'
  env = Object.create process.env
  env.BUNDLE_GEMFILE = path.join __dirname, '../../Gemfile'
  child = childProcess.spawn 'bundle', args,
    stdio: quiet and 'ignore' or 'inherit'
    env: env
  child.on 'close', done

hub = (args...) -> bundleExec 'hub', args...

module.exports = class HmladNpmGenerator extends yeoman.generators.Base
  constructor: (args, options, config) ->
    options.engine = handlebarsEngine
    yeoman.generators.Base.apply this, arguments
    quiet = options.quiet
    @on 'end', ->
      @installDependencies
        skipInstall: options['skip-install']
        bower: false

    @sourceRoot path.join __dirname, '../templates'
    @pkg = require '../../package.json'

    @reposlug = path.basename process.cwd()

  askFor: ->
    cb = @async()

    prompts = [{
      type: 'input'
      name: 'pkgname'
      message: 'Name your NPM package'
      default: @reposlug
    }, {
      type: 'input'
      name: 'description'
      message: 'Describe your package'
      default: ''
    }, {
      type: 'input'
      name: 'keywords'
      message: 'Keywords?'
      default: ''
      filter: (input) ->
        input.split(',')
        .map((term) -> term.trim())
        .filter(Boolean)
    }, {
      type: 'list'
      name: 'coffee'
      message: 'Using coffeescript for this one?'
      default: false
      choices: [
        {name: 'js', value: false}
        {name: 'coffee', value: true}
      ]
    }]
    @prompt prompts, ({@pkgname, @description, @keywords, @coffee}) =>
      unless @keywords.length
        delete @keywords
      cb()

  gitUser: ->
    gitConfig = require 'git-config'
    done = @async()
    gitConfig (err, config) =>
      @user = config?.user
      done()

  defaultUser: ->
    @user ?=
      name: 'Adam Hull'
      email: 'adam@hmlad.com'

  author: ->
    @author = @user

  project: ->
    @copy '../../.editorconfig', '.editorconfig'
    @copy 'gitignore', '.gitignore'
    @copy 'travis.yml', '.travis.yml'
    @template '_README.md', 'README.md'

  packageJson: ->
    packageJson = require '../package_json'
    @write 'package.json', packageJson(@)

  sourceFile: ->
    filename = underscored @pkgname
    if @coffee
      @write "src/#{filename}.coffee", ''
    else
      @write "#{filename}.js", ''

  test: ->
    @copy '../../test/mocha.opts', 'test/mocha.opts'
    @copy 'test.coffee', "test/#{underscored @pkgname}.test.coffee"

  git: ->
    done = @async()
    hub 'init', done
