(local {: keys} (require :global-defs))
(local global-state (require :global-state))
(local state (require :grapple.state))

;; TODO set these from the game
(local player-pips 5)
(local enemy-pips 10)

(fn handler [key]
  (if (or (= key keys.left) (= key keys.up))
      (do
        (set state.board.left.pips player-pips)
        (set state.board.right.pips enemy-pips)
        (set state.player-side :left)
        (set state.enemy-side :right))
      (or (= key keys.right) (= key keys.down))
      (do
        (set state.board.left.pips enemy-pips)
        (set state.board.right.pips player-pips)
        (set state.player-side :right)
        (set state.enemy-side :left))
      (= key keys.fire)
      (set global-state.phase :grapple)))

{: handler}
