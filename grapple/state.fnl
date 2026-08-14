;; anything nil is set by setup.launch, from defs
{:board {:left {;; yellow
                :active-cells {}
                :active-pips []
                :id -1
                :other-id 1
                :paths []
                :pip-row 0
                :pips 0}
         :right {;; blue
                 :active-cells {}
                 :active-pips []
                 :id 1
                 :other-id -1
                 :paths []
                 :pip-row 0
                 :pips 0}}
 :box-owners [] ; the ID of the owner
 :deadlock-timer nil ; seconds
 :enemy-side nil
 :enemy-move-timer nil
 :enemy-skills {
    ;; all probs are from 0 to 1
    :fire-prob 0.3; 0 never fires, 1 fires every cycle
    :move-prob 0.8; 0 never moves, 1 moves every cycle
    :dir-prob 0.3; from 0 to 1. 0 always moves up, 1 always moves down
    :smarts 1; the closer to 0, the more likely to fire down a ---< or at a box of its own colour
    :speed 0.08 ; interval between moves, in s. player is 0.1
  }
 :phase :chooser
 :player-side nil
 :time-left nil}
