_ = require \underscore

module.exports = (vg) ->
  vg.on \late-render ->
    function render-badge node, x, x-size
      const BADGE-Y-SIZE = 16
      badge = d3.select node .append \svg:g
        .attr \class \badge-bil
        .attr \transform -> "translate(#x,10)"
      badge.append \svg:rect
        .attr \height BADGE-Y-SIZE
        .attr \width x-size
        .attr \rx 5
        .attr \ry 5
      badge

    function render-badges-combined node, edges
      const BADGE-X-SIZE = 82
      render-badge node, (-BADGE-X-SIZE / 2), BADGE-X-SIZE
        .append \svg:text
          .attr \dx 2
          .attr \dy 13
          .text "#{edges.0.yyyy} - #{edges[*-1].yyyy}"

    function render-badges-separate node, edges
      const BADGE-X-GAP = 24
      const BADGE-X-SIZE = 20
      offset-x = - (BADGE-X-GAP * (edges.length - 1)) / 2
      for edge, i in edges
        evs = entevs.where entity_id:edge._id
        is-single = (n-evs = evs.length) is 1
        ev0 = evs.0?toJSON-T!
        x = offset-x + (i * BADGE-X-GAP) - (BADGE-X-SIZE / 2)
        render-badge node, x, BADGE-X-SIZE .append \svg:a
          .attr \target if is-single then \_blank else ''
          .attr \xlink:href if is-single then ev0.href else "#/edge/#{edge._id}"
          .attr \xlink:title if is-single then "Evidence at Bilderberg #{edge.yyyy}" else ''
          .append \svg:text
            .attr \dx 1
            .attr \dy 13
            .text edge.yy

    entevs = vg.map.get(\entities).evidences
    node <- @svg.selectAll \g.node .each
    edges = _.filter me.edges-attend, -> node._id is it.a_node_id or node._id is it.b_node_id
    edges = _.sortBy edges, -> it.yyyy
    (if edges.length <= 4 then render-badges-separate else render-badges-combined) this, edges

  vg.on \pre-render (ents) ->
    [conf-nodes, ents.nodes] = _.partition ents.nodes, me.is-conference-yyyy
    (_.find ents.nodes, me.is-annual-conference)?sub-nodes = conf-nodes

  me =
    is-annual-conference: -> 'Bilderberg Annual Conference' is it.name
    is-conference-yyyy  : -> /^Bilderberg Conference [0-9]{4}$/.test it.name
    is-steering         : -> 'Bilderberg Steering Committee' is it.name
