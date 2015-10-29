# a javascript timer uses much less cpu than css animations
module.exports = (vg, cursor) ->
  var timer
  frame = 0
  toggle!

  cursor.on \hide -> clearInterval timer
  cursor.on \show -> timer := setInterval advance-frame, 500ms

  function advance-frame
    toggle!
    frame := ++frame % const N-FRAMES = 5
    toggle!

  function toggle
    vg.$el.toggleClass "frame-#frame"
