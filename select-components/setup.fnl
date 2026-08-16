(local data (require :data))
(local state (require :select-components.state))
(local {: deep-clone} (require :util.helpers))

(fn launch [{: robot-id : grapple-score}]
  (love.graphics.setBackgroundColor 0 0 0)
  (love.graphics.setColor 1 0.75 0)
  (set state.components (deep-clone (. (. data.robots robot-id) :components)))
  (set state.robot-id robot-id)
  (set state.grapple-score grapple-score))

{: launch}
