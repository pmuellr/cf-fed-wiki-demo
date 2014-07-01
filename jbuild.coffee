# Licensed under the Apache License. See footer for details.

#-------------------------------------------------------------------------------
# use this file with jbuild: https://www.npmjs.org/package/jbuild
# install jbuild with:
#    linux/mac: sudo npm -g install jbuild
#    windows:        npm -g install jbuild
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
tasks = defineTasks exports,
  watch: "watch for source file changes, then run build, and server"
  serve: "run the server stand-alone"
  build: "build the server"

WatchSpec = """
  server.js
  tmp/cf-fed-wiki.updated.txt
  """

PidFile = "tmp/server.pid"

#-------------------------------------------------------------------------------
mkdir "-p", "tmp"

#-------------------------------------------------------------------------------
touchDemo = ->
  msg = "last updated at #{new Date()}"
  msg.to "tmp/cf-fed-wiki.updated.txt"

#-------------------------------------------------------------------------------
touchDemo()

#-------------------------------------------------------------------------------
tasks.build = ->
  log "running build"

  unless test "-d", "node_modules"
    exec "npm install"

    log ""
    log "---------------------------------------"
    log "exiting jbuild because of `npm install`"
    log "---------------------------------------"

    process.exit 1

  log "copying cf-fed-wiki module from ../cf-fed-wiki"

  rm "-rf",                    "node_modules/cf-fed-wiki"
  cp "-R", "../cf-fed-wiki/*", "node_modules/cf-fed-wiki"

#-------------------------------------------------------------------------------
tasks.watch = ->
  watchIter()

  watch
    files: WatchSpec.split /\s+/
    run:   watchIter

  watchFiles "jbuild.coffee" :->
    log "jbuild file changed; exiting"
    process.exit 0

#-------------------------------------------------------------------------------
tasks.serve = ->
  log "running server"

  args = "server --verbose"
  args = args.split(/\s+/)

  server.start PidFile, "node", args

#-------------------------------------------------------------------------------
tasks.test = ->
  log "running tests"

  tests = "tests/test-*.coffee"

  options =
    ui:         "bdd"
    reporter:   "spec"
    slow:       300
    compilers:  "coffee:coffee-script"
    require:    "coffee-script/register"

  options = for key, val of options
    "--#{key} #{val}"

  options = options.join " "

  mocha "#{options} #{tests}", silent:true, (code, output) ->
    console.log "test results:\n#{output}"

#-------------------------------------------------------------------------------
watchIter = ->
  setTimeout watchIterDelayed, 500

#-------------------------------------------------------------------------------
watchIterDelayed = ->
  tasks.build()
  tasks.serve()

#-------------------------------------------------------------------------------
cleanDir = (dir) ->
  mkdir "-p", dir
  rm "-rf", "#{dir}/*"

#-------------------------------------------------------------------------------
# Copyright IBM Corp. 2014
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#-------------------------------------------------------------------------------
