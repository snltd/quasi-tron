(local chooser-state (require :grapple.chooser.state))
(local grapple-state (require :grapple.state))

(fn update [dt]
  (let [new-time (- chooser-state.time-left dt)]
    (if (< new-time 0)
        (do
          (set chooser-state.time-left 0)
          (set grapple-state.phase :grapple))
        (set chooser-state.time-left new-time))))

{: update}
