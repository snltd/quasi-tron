(local state (require :select-grapple-side.state))

(fn update [dt]
  (when (< 0 state.time-left)
    (set state.time-left (- state.time-left dt))))

{ : update }
