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
 :message-timer nil ; seconds
 :message-flash-show nil
 :message-flash-timer nil
 :enemy nil
 :enemy-id nil
 :enemy-side nil
 :enemy-move-timer nil
 :phase :chooser
 :player-side nil
 :final-score nil
 :time-left nil}
