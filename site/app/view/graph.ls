B  = require \backbone
F  = require \fs
_  = require \underscore
V  = require \../view
E  = require \./graph/edge
EG = require \./graph/edge-glyph
FZ = require \./graph/freezer
N  = require \./graph/node
O  = require \./graph/overlay
OB = require \./graph/overlay/bil
OS = require \./graph/overlay/slit
P  = require \./graph/persister

T = F.readFileSync __dirname + \/graph.html

const SIZE = 3000

overlays = [ OB, O.Ac, O.Bis, O.Cfr ]

module.exports = B.View.extend do
  init: ->
    return unless @el # might be undefined for seo
    refresh @el, f = d3.layout.force!
    V.graph-toolbar
      ..render!
      ..on \save-layout, -> P.save-layout f
  render: ->
    @scroll = @scroll or x:0, y:0
    $window = $ window
    B.once \route-before, ~>
      @scroll.x = $window.scrollLeft!
      @scroll.y = $window.scrollTop!
    @$el.show!
    _.defer ~> $window .scrollTop(@scroll.y) .scrollLeft(@scroll.x)

function refresh el, f then
  $ el .empty!
  svg = d3.select el .append \svg:svg
    .attr \width , SIZE
    .attr \height, SIZE

  nodes = N.data!
  edges = E.data nodes

  # prevent D3 error "Cannot read property 'length'" when nodes or edges
  # is empty, typically at start of app integration tests
  return unless nodes?length and edges?length

  edges = (OB.filter-edges >> O.Ac.filter-edges >> O.Bis.filter-edges >> O.Cfr.filter-edges) edges
  nodes = (OB.filter-nodes >> P.apply-layout >> FZ.fix-unless-admin) nodes

  f.nodes nodes
   .links edges
   .charge -2000
   .friction 0.95
   .linkDistance 100
   .linkStrength E.get-strength
   .size [SIZE, SIZE]
   .start!

  if P.is-persisted! then f.alpha 0.01 # settle immediately (must invoke after start)

  # order matters: svg uses painter's algo
  E .init svg, f
  N .init svg, f
  OS.init svg, f
  EG.init svg, f
  _.each overlays, -> it.init svg, f

  FZ.make-draggable-if-admin svg, f
  OS.align svg, f

  n-tick = 0
  f.on \end  , -> _.each overlays, -> it.render!
  f.on \start, -> _.each overlays, -> it.render-clear!
  f.on \tick, ->
    if n-tick++ % 4 is 0 then
      N .on-tick!
      E .on-tick!
      EG.on-tick!
