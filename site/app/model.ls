B    = require \backbone
Api  = require \./api
Cons = require \../lib/model-constraints

B.Validation.configure labelFormatter:\label

Model = B.DeepModel.extend do
  toJSON-T: (opts) -> @toJSON opts

exports
  ..Evidence = Model.extend do
    urlRoot: Api.evidences
    labels :
      \url : 'Url'
    validation:
      \url : required:yes pattern:\url
  ..Edge = Model.extend do
    urlRoot: Api.edges
    labels :
      \a_node_id : 'Actor A'
      \b_node_id : 'Actor B'
      \year_from : 'Year From'
      \year_to   : 'Year To'
    validation:
      \a_node_id : required:yes
      \b_node_id : required:yes
      \a_is      : required:yes
      \how       :
        * required: no
        * pattern : Cons.edge.how.regex
          msg     : "How should be #{Cons.edge.how.info}"
      \year_from : range:[Cons.edge.year.min, Cons.edge.year.max] required:no
      \year_to   : range:[Cons.edge.year.min, Cons.edge.year.max] required:no
  ..Hive =
    Graph: new (Model.extend urlRoot:"#{Api.hive}/graph")!
  ..Node = Model.extend do
    urlRoot   : Api.nodes
    validation:
      \name :
        * required: yes
        * pattern : Cons.node.name.regex
          msg     : "Name should be #{Cons.node.name.info}"
  ..Note = Model.extend do
    urlRoot   : Api.notes
    validation:
      \text :
        * required: yes
        * pattern : Cons.note.regex
          msg     : "Note should be #{Cons.note.info}"
  ..Session = Model.extend do
    urlRoot   : Api.sessions
    validation:
      \login    : required:yes
      \password : required:yes
  ..Signup = Model.extend user-spec pwd-required:yes
  ..Sys    = new (Model.extend urlRoot: Api.sys)!
  ..User   = Model.extend user-spec pwd-required:no

function val-login
  return
    * required: yes
    * pattern : Cons.login.regex
      msg     : "Username should be #{Cons.login.info}"

function val-email
  return
    * required: yes
    * pattern : Cons.email.regex
      msg     : "Email should be #{Cons.email.info}"

function val-password opts
  return
    * required: opts.required
    * pattern : Cons.password.regex
      msg     : "Password should be #{Cons.password.info}"

function user-spec opts
  urlRoot: Api.users
  labels :
    \info     : 'Homepage'
    \passconf : 'Confirm Password'
  validation:
    \login    : val-login!
    \password : val-password required:opts.pwd-required
    \passconf : equalTo:\password
    \email    : val-email!
    \info     : pattern:\url required:no
