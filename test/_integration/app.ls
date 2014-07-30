W        = require \wait.for
R        = require \./helper .run
B        = require \./app/_browser
Edge     = require \./app/edge
Evidence = require \./app/evidence
Node     = require \./app/node
Note     = require \./app/note
Session  = require \./app/session
User     = require \./app/user

unless \tester is env = process.env.NODE_ENV
  throw new Error "unexpected environment #env"

function test spec then it spec.info, spec.fn

(...) <- describe 'app'
@timeout 15000

before R ->
  B.init!

after R ->
  B.go \__coverage # https://github.com/gotwarlost/istanbul-middleware

it 'click About', R ->
  B.click \About
  B.wait-for \About, \h3

it 'click Latest', R ->
  B.click \Latest
  B.wait-for 'Latest Updates', \legend

it '---admin signup users'
test User.list.is0
test User.admin.create.ok
test User.list.is1
test User.admin.create.bad
test User.login.min.create.bad
test Session.admin.signin.password.a.ok
test User.a.create.ok
test User.a.email.new.update.ok
test User.a.create.bad
test User.b.create.ok
test User.list.is3
it '---userA create entities'
test Session.signout.ok
test Session.a.signin.bad.login
test Session.a.signin.bad.password
test Session.a.signin.password.a.ok
it 'maint'
test User.a.password.b.update.ok
test Session.signout.ok
test Session.a.signin.password.a.bad
test Session.a.signin.password.b.ok
it 'node'
test Node.list.is0
test Node.a.create.ok
test Node.a.name.max.update.ok
test Node.a.name.max-gt.update.bad
test Node.a.name.update.ok
test Node.a.name.dup.update.bad
test Node.b.create.bad # prior node missing evidence
test Evidence.a.list.is0
test Evidence.a0.create.ok
test Evidence.a0.create.bad
test Evidence.a0.update.ok
test Evidence.a1.create.ok
test Evidence.a.list.is2
test Evidence.a1.update.ok
test Node.b.create.ok
test Evidence.b0.create.ok
it 'edge'
test Edge.list.is0
test Edge.ab.create.ok
test Edge.list.is1
test Edge.ab.create.bad # dup
test Edge.ab.is.eq.update.ok
test Evidence.ab0.create.ok
it 'note'
test Note.a.list.is0
test Note.a.create.ok
test Note.a.text.jotld.update.ok
test Note.a.list.is1
it '---userB'
test Session.signout.ok
test Session.b.signin.password.a.ok
it 'note'
test Note.a.create.ok
test Note.a.text.max.update.ok
test Note.a.list.is2
test Note.a.remove.ok
test Note.a.list.is1

#it 'map', R ->
#  B.refresh!
#  B.click \Graph
#  B.wait-for-visible sel:'.view>.graph'
#  B.assert.count 2, sel:'.graph g.node'
# TODO: why does B.assert.count think line is not displayed ?
# B.assert.count 1, sel:'.graph line.edge'

# TODO
# create map
# update/delete node ref'd by map -> fail
# update map
# delete map

## teardown
it '---userA remove entities'
test Session.signout.ok
test Session.a.signin.password.b.ok
test Edge.ab.remove.bad # still has evidence
test Evidence.ab0.remove.ok
test Edge.ab.remove.ok
test Node.a.remove.bad
test Note.a.remove.ok
test Note.a.list.is0
test Evidence.a0.remove.ok
test Evidence.a1.remove.ok
test Evidence.a.list.is0
test Node.a.remove.ok
test Evidence.b0.remove.ok
test Node.b.remove.ok
it '---admin remove users'
test Session.signout.ok
test Session.admin.signin.password.a.ok
test User.b.remove.ok
test User.a.remove.ok
test User.list.is1
