$.fn.disable-buttons = ->
  @find \.btn .prop \disabled true .addClass \disabled

$.fn.enable-buttons = ->
  @find \.btn .prop \disabled false .removeClass \disabled

_hide = $.fn.hide
$.fn.hide = (speed, cb) ->
  $ this .trigger \hide
  _hide.apply this, arguments

_toggle = $.fn.dropdown.Constructor.prototype.toggle
$.fn.dropdown.Constructor.prototype.toggle = ->
  r = _toggle.apply this, arguments
  $ this .trigger \toggled
  r

# http://stackoverflow.com/questions/1184624/convert-form-data-to-js-object-with-jquery
$.fn.serializeObject = ->
  function set name, val, to-array = true
    const IGNORE-NAME = /^select(Item|Allnodes)/ # jquery.multi.select
    return if IGNORE-NAME.test name
    path = name.split \. # name can be 'foo.bar.baz'
    o = if path.length is 1 then res else path[til -1].reduce ((r, k) -> r[k] or r[k] = {}), res
    k = path[*-1]
    v = if typeof val is \boolean then val else val or ''
    if to-array and o[k]?
      o[k] = [o[k]] unless o[k].push
      o[k].push v
    else
      o[k] = v
  res = {}
  for {name, value} in @serializeArray! then set name, value
  # http://stackoverflow.com/questions/3029870/jquery-serialize-does-not-register-checkboxes
  for c in @find 'input[type=checkbox]:visible' then set c.name, c.checked, false
  res
