Assert = require \assert
Shell  = require \shelljs
W4     = require \wait.for .for
Dir    = require \./constants .dir
G      = require \./growl

const AF-APPNAME = \whodotheyserve
const AF-RUNTIME = \node08

try
  cfg = (JSON.parse env.prod).appfog
  Assert uid = cfg.account.uid
  Assert pwd = cfg.account.pwd
catch

module.exports =
  is-cfg: -> cfg?

  login: ->
    try
      W4 exec, "af login --email #uid --passwd #pwd"
    catch e
      log e

  push: ->
    exec-then-logout ->
      W4 exec, "af push #AF-APPNAME --runtime #AF-RUNTIME"
      G.ok "pushed site to appfog PRODUCTION"

  send-env-vars: ->
    exec-then-logout ->
      for k, v in cfg.env
        W4 exec, "af env-add #AF-APPNAME #k=#v"
      G.ok "sent env-vars to appfog PRODUCTION"

  show-config: -> log cfg

  update: ->
    exec-then-logout ->
      # prevent node 0.8/0.10 bcrypt version mismatch
      # TODO: find a better solution
      W4 exec, 'npm shrinkwrap'
      test \-e \npm-shrinkwrap.json

      W4 exec, "af update #AF-APPNAME"
      G.ok "updated site to appfog PRODUCTION"

## helpers

function exec-then-logout fn
  try
    pushd Dir.site.STAGING
    fn!
  catch e
    log e
  finally
    popd!
    logout!

function logout
  try
    W4 exec, "af logout"
  catch e
    log e
