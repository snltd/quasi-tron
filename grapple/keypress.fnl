(local global-defs (require :global-defs))
(local state (require :grapple.state))
(local chooser (require :grapple.chooser))
(local actions (require :grapple.actions))

(fn handler [key]
  (let [side state.player-side
        board (. state.board side)]
    (match state.phase
      (where :grapple (= key global-defs.keys.fire)) (actions.fire! board)
      :chooser (chooser.keypress key))))

{: handler}
