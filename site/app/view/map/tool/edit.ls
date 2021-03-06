B  = require \backbone
C  = require \../../../collection
Hm = require \../../../model/hive .instance.Map
S  = require \../../../session
Vs = require \../../../view-activity/select

module.exports = (ve, vg) ->
  if S.is-signed-in! then init! else B.once \signin init

  ## helpers

  function alert-success msg
    ve.$ \.alert-success .text msg .toggle msg?

  function init
    C.Edges.on 'add remove' ->
      return unless node-ids = ve.v-nodes-sel?get-selected-ids!
      refresh-map node-ids if do
        _.contains node-ids, it.get \a_node_id and _.contains node-ids, it.get \b_node_id
    C.Nodes
      ..on \add ->
        node-ids = render-dropdown(it.id if add2map = it?get \__add-to-map)
        refresh-map node-ids if add2map
      ..on \remove ->
        node-ids = render-dropdown!
        refresh-map node-ids if _.contains node-ids, it.id
    ve
      ..on \rendered ->
        alert-success void
        init-dropdown!
        render-dropdown!
        refresh-deletable!
        init-error-alert!
        load-default-tab it.id
      ..on \saved (map, is-new) ->
        for i from 0 to 1
          save-default-tab i, map.id if ve.$el.find "\#default-id-#i" .prop \checked
        alert-success 'Successfully saved'
        init-error-alert!
      ..on \serialized ->
        # save all selected nodes -- some may have been filtered out of the map in
        # which case they'll be saved without (x, y)
        nodes = vg.get-nodes-xy!
        sel-node-ids = ve.v-nodes-sel.get-selected-ids!
        map-node-ids = _.map nodes, -> it._id
        for id in sel-node-ids then unless _.contains map-node-ids, id
          nodes.push _id:id # node is selected but filtered out of map
        it.set nodes:nodes, 'size.x':vg.get-size-x!, 'size.y':vg.get-size-y!
      ..show = ->
        alert-success void
        init-error-alert!
        @$el.show!
    vg
      ..on \pre-cool ->
        ve.$el.disable-buttons!
      ..on \cooled ->
        ve.$el.enable-buttons!
        refresh-deletable!

  function init-dropdown
    opts = filter:true maxHeight:500 width:370
    ve.v-nodes-sel = new Vs.MultiSelectView el:(ve.$ \#nodes), opts:opts
      ..on 'checkAll click uncheckAll' ->
        node-ids = @get-selected-ids!
        # checkAll also fires if all nodes are already selected and the dropdown is opened
        # even if the selection is unchanged, in which case bail
        return if node-ids.length is (vg.map.get \nodes)?length
        refresh-map node-ids

  function init-error-alert
    # show errors on this form rather than in base view
    $ \.alert-error .removeClass \active
    ve.$el.find \.alert-error .addClass \active .hide!

  function load-default-tab id
    for let i from 0 to 1 then ve.$el.find "\#default-id-#i"
      ..prop \checked id is Hm.default-ids[i]
      ..on \change -> ve.$el.find "\#default-id-#{1-i}" .prop \checked false

  function render-dropdown add-node-id
    return unless ve.v-nodes-sel?
    node-ids = if vg.map then _.pluck (vg.map.get \nodes), \_id else []
    node-ids.push add-node-id if add-node-id
    ve.v-nodes-sel.render C.Nodes, \name, node-ids
    node-ids

  function refresh-deletable
    is-deletable = (ve.v-nodes-sel?get-selected-ids! or []).length < 10
    ve.$el.find \.delete-ask
      ..toggle-button is-deletable
      ..attr \title if !is-deletable then 'To delete this map, first remove actors' else ''

  function refresh-map node-ids
    vg.refresh-entities node-ids .render is-slow-to-cool:true

  function save-default-tab tab-index, map-id
    default-ids = Hm.default-ids
    default-ids[tab-index] = map-id
    Hm.set-prop \default-ids default-ids
    Hm.save void do
      success: -> log 'saved default-ids' default-ids
      error  : -> log 'error saving default-ids' default-ids
