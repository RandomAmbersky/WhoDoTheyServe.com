M      = require \mongoose
_      = require \underscore
Cons   = require \../../lib/model-constraints
Crud   = require \../crud
H      = require \../helper
P-Meta = require \./plugin-meta

spec =
  a_node_id : type:M.Schema.ObjectId, required:yes
  b_node_id : type:M.Schema.ObjectId, required:yes, index:yes
  a_is      : type:String, required:yes, enum:<[eq lt]>
  how       : type:String, required:no , match:Cons.edge.how.regex
  year_from : type:Number, required:no , min:Cons.edge.year.min, max:Cons.edge.year.max
  year_to   : type:Number, required:no , min:Cons.edge.year.min, max:Cons.edge.year.max

schema = new M.Schema spec
  ..index { a_node_id:1, b_node_id:1 }, {+unique}
  ..plugin P-Meta
  ..pre \validate, (next) ->
    if @year_from and @year_to and @year_from > @year_to then
      @invalidate \year_from, 'Invalid range'
    if @a_node_id.equals @b_node_id then
      @invalidate \a_node_id, 'Nodes A and B must differ'
    next!
  ..pre \save, (next) ->
    err, edge <~ M-Edges.findById @_id
    return next err if err
    # If update then allow inversion a--b to b--a
    return next! if edge?a_node_id.equals @b_node_id and edge?b_node_id.equals @a_node_id
    err, obj <~ M-Edges.findOne $and:
      * a_node_id:@b_node_id
      * b_node_id:@a_node_id
    return next err if err
    return next new H.ApiError 'Reciprocal duplicate detected' if obj
    next!

module.exports = M-Edges = Crud.set-fns M.model(\edges, schema) #,
