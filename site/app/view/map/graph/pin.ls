_ = require \underscore

module.exports = (vg) ->
  vg.on \late-render ->
    return unless @map.get-is-editable!

    const PIN-IN  = 'translate(-7,7)'
    const PIN-OUT = 'translate(-7,-7) rotate(90)'
    const SIZE    = 20

    pin = @svg.selectAll \g.node
      .append \g
        .attr \class \pin
        .attr \transform "translate(-0, #SIZE)" # position under node
    pin.append \g # for some reason, rotation doesn't work on text so we'll do it on a parent group
      .attr \transform -> if it.fixed then PIN-IN else PIN-OUT
      .append \text
        .attr \class \fe
        .attr \font-family \fontello
        .attr \font-size SIZE
        .text \\ue81e
    # include this path to show bounding box for debugging pin rotation
    #pin.append \svg:path .attr \d "M -#{l = SIZE / 2} -#l L #l -#l L #l #l L -#l #l L -#l -#l"

    @$el.off  \click \.pin .on  \click \.pin ->
      c = $ this .parent!attr \class
      id = (c.match /id_([-\|\w]+)/).1 # some ids include a pipe | but short-id shouldn't do this !?
      pin = vg.svg.select "g.node.id_#id .pin g"
      t = pin.attr \transform
      pin.attr \transform if t is PIN-IN then p = PIN-OUT else p = PIN-IN
      d3n = _.findWhere vg.d3f.nodes!, _id:id
      d3n.fixed = p is PIN-IN
