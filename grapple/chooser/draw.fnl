(local state (require :grapple.chooser.state))

(fn timer [x y]
  (love.graphics.print (string.format "COLOUR %.03f" state.time-left) x y))

{: timer}
