(local state (require :select-grapple-side.state))

(fn timer []
  (love.graphics.print state.time-left))

{: timer}
