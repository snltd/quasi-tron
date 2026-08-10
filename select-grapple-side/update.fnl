(local global-state (require :global-state))
(local state (require :select-grapple-side.state))

(fn update [dt]
  (if (< 0 state.time-left)
      (set state.time-left (- state.time-left dt))
      (set global-state.phase :grapple)))

{: update}
