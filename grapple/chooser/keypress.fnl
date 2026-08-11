(local {: keys} (require :global-defs))
(local state (require :grapple.state))

(fn handler [key]
  (let [l-pips state.board.left.pips
        r-pips state.board.right.pips]
    (if (and (or (= key keys.left) (= key keys.up))
             (not= state.player-side :left))
        (do
          (set state.board.left.pips r-pips)
          (set state.board.right.pips l-pips)
          (set state.player-side :left)
          (set state.enemy-side :right))
        (and (or (= key keys.right) (= key keys.down))
             (not= state.player-side :right))
        (do
          (set state.board.left.pips r-pips)
          (set state.board.right.pips l-pips)
          (set state.player-side :right)
          (set state.enemy-side :left))
        (= key keys.fire)
        (set state.phase :grapple))))

{: handler}
