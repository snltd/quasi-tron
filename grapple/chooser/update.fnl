(local chooser-state (require :grapple.chooser.state))
(local grapple-state (require :grapple.state))

(fn update [dt]
  (if (< 0 chooser-state.time-left)
      (set chooser-state.time-left (- chooser-state.time-left dt))
      (set grapple-state.phase :grapple)))

{: update}
