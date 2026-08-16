(local h (require :util.helpers))
(local t (require :faith))
(local s (require :grapple.actions))

(local active-line {104 5 105 5 106 5 107 5 108 5 109 5 110 5 111 5 112 5})
;; left has -1, right has 1
(local sample-boxes [-1 1])

; blue on top, yellow underneath
(local straight-paths
       [(h.utf8-chars "───────────◀")
        (h.utf8-chars "───────────◀")])

(local inverter-paths ;; left has -1, right has 1
       [(h.utf8-chars "───────S---x")
        (h.utf8-chars "───────S---x")])

(fn test-update-boxes!-no-inputs []
  (local board
         {:left {:paths straight-paths :id -1 :active-cells {}}
          :right {:paths straight-paths :id 1 :active-cells {}}})
  (t.= sample-boxes (s.update-boxes! sample-boxes board)))

(fn test-update-boxes!-both-shoot-own-colour []
  (local board
         {:left {:paths straight-paths :id -1 :active-cells {112 5}}
          :right {:paths straight-paths :id 1 :active-cells {212 5}}})
  (t.= sample-boxes (s.update-boxes! sample-boxes board)))

(fn test-update-boxes!-both-shoot-other-colour []
  (local board
         {:left {:paths straight-paths :id -1 :active-cells {212 5}}
          :right {:paths straight-paths :id 1 :active-cells {112 5}}})
  (t.= [1 -1] (s.update-boxes! sample-boxes board)))

;; This now uses randomness
; (fn test-update-boxes!-both-shoot-same-box []
;   (local board
;          {:left {:paths straight-paths :id -1 :active-cells {112 5}}
;           :right {:paths straight-paths :id 1 :active-cells {112 5}}})
;   (t.= [0 1] (s.update-boxes! sample-boxes board)))

(fn test-update-boxes!-left-through-inverters []
  (local board
         {:left {:paths inverter-paths :id -1 :active-cells {112 5 212 5}}
          :right {:paths straight-paths :id 1 :active-cells {}}})
  (t.= [1 1] (s.update-boxes! sample-boxes board)))

(fn test-update-boxes!-both-sending-same-signal []
  (local board
         {:left {:paths inverter-paths :id -1 :active-cells {112 5}}
          :right {:paths straight-paths :id 1 :active-cells {112 5}}})
  (t.= [1 1] (s.update-boxes! sample-boxes board)))

;; This now uses randomness
; (fn test-update-boxes!-both-sending-inverted-signal []
;   (local board
;          {:left {:paths inverter-paths :id -1 :active-cells {112 5}}
;           :right {:paths inverter-paths :id 1 :active-cells {112 5}}})
;   (t.= [0 1] (s.update-boxes! sample-boxes board)))

(fn test-update-box []
  (t.= nil (s.update-box! 0 0))
  (t.= -1 (s.update-box! -1 0))
  (t.= -1 (s.update-box! 0 -1))
  (t.= 1 (s.update-box! 0 1))
  (t.= 1 (s.update-box! 1 0)))
  ; (t.= 0 (s.update-box 1 -1))
  ; (t.= 0 (s.update-box -1 1)))

(fn test-incoming []
  ;; No input
  (local nothing-doing {:paths [(h.utf8-chars "───────────◀")]
                        :active-cells []})
  (t.= 0 (s.incoming nothing-doing 1))
  ;; No input
  (local nothing-doing-x {:paths [(h.utf8-chars "───────S───x")]
                          :active-cells []})
  (t.= 0 (s.incoming nothing-doing-x 1))
  ;; LHS, own colour
  (local lit-normal-left {:paths [(h.utf8-chars "───────────◀")]
                          :active-cells active-line
                          :id -1})
  (t.= -1 (s.incoming lit-normal-left 1))
  ;; RHS, own colour
  (local lit-normal-right {:paths [(h.utf8-chars "───────────◀")]
                           :active-cells active-line
                           :id 1})
  (t.= 1 (s.incoming lit-normal-right 1))
  ;; LHS, other player's colour via inverted
  (local lit-inverted-left {:paths [(h.utf8-chars "───────S───x")]
                            :active-cells active-line
                            :id -1})
  (t.= 1 (s.incoming lit-inverted-left 1))
  ;; RHS, other player's colour via inverted
  (local lit-inverted-right {:paths [(h.utf8-chars "───────S───x")]
                             :active-cells active-line
                             :id 1})
  (t.= -1 (s.incoming lit-inverted-right 1)))

;; The fire tests exercise activate-cell, which is the heart of the thing.
;;
(fn test-fire-empty-ammo-does-nothing []
  (local b {:paths [(h.utf8-chars "───────────◀")]
            :pip-row 1
            :pips 0
            :active-cells []
            :active-pips []})
  (local expected (h.deep-clone b))
  (s.fire! b)
  (t.= expected b))

(fn test-fire-in-row-0-does-nothing []
  (local b {:paths [(h.utf8-chars "───────────◀")]
            :pip-row 0
            :pips 4
            :active-cells []
            :active-pips []})
  (local expected (h.deep-clone b))
  (s.fire! b)
  (t.= expected b))

(fn test-fire-straight-path []
  (local b {:paths [(h.utf8-chars "───────────◀")]
            :pip-row 1
            :pips 3
            :active-cells []
            :active-pips []})
  (s.fire! b)
  (t.= {:active-cells active-line
        :active-pips [{:owner 0 :row 1 :ttl 5}]
        :paths [(h.utf8-chars "──▶────────◀")]
        :pip-row 0
        :pips 2} b))

;; fnlfmt: skip
(fn test-fire-through-repeater []
  (local b {:paths [(h.utf8-chars "──────▶────◀")]
            :pip-row 1
            :pips 3
            :active-cells []
            :active-pips []})
  (s.fire! b)
  (t.= {:active-cells {104 5 105 5 106 5 107 .inf 108 .inf 109 .inf 110 .inf 111 .inf 112 .inf}
        :active-pips [{:owner 0 :row 1 :ttl 5}]
        :paths [(h.utf8-chars "──▶───▶────◀")]
        :pip-row 0
        :pips 2} b))

(fn test-fire-through-inverter []
  (local b {:paths [(h.utf8-chars "──────S----x")]
            :pip-row 1
            :pips 3
            :active-cells []
            :active-pips []})
  (s.fire! b)
  (t.= {:active-cells {104 5 105 5 106 5 107 5 108 5 109 5 110 5 111 5 112 5}
        :active-pips [{:owner 0 :row 1 :ttl 5}]
        :paths [(h.utf8-chars "──▶───S----x")]
        :pip-row 0
        :pips 2} b))

(fn test-fire-next-to-< []
  (local b {:paths [(h.utf8-chars "────┐       ")
                    (h.utf8-chars "──◁ ├──────◀")
                    (h.utf8-chars "────┘       ")]
            :pip-row 2
            :pips 3
            :active-cells []
            :active-pips []})
  (local expected (h.deep-clone b))
  (s.fire! b)
  (t.= expected b))

;; fnlfmt: skip
(fn test-fire-into-splitter []
  (local b {:paths [(h.utf8-chars "─────◁ ┌───◀")
                    (h.utf8-chars "───────┤    ")
                    (h.utf8-chars "─────◁ └─▶─◀")]
            :pip-row 2
            :pips 3
            :active-cells []
            :active-pips []})
  (s.fire! b)
  (t.= {:active-cells {109 5 110 5 111 5 112 5
                       204 5 205 5 206 5 207 5 208 5
                       309 5 310 .inf 311 .inf 312 .inf}
        :active-pips
        [{:owner 0 :row 2 :ttl 5}]
        :paths [["─" "─" "─" "─" "─" "◁" " " "┌" "─" "─" "─" "◀"]
                ["─" "─" "▶" "─" "─" "─" "─" "┤" " " " " " " " "]
                ["─" "─" "─" "─" "─" "◁" " " "└" "─" "▶" "─" "◀"]]
        :pip-row 0
        :pips 2} b))

;; fnlfmt: skip
(fn test-fires-into-joiner []
  (local b {:paths [(h.utf8-chars "────┐       ")
                    (h.utf8-chars "──◁ ├──────◀")
                    (h.utf8-chars "────┘       ")]
            :pip-row 1
            :pips 3
            :active-cells []
            :active-pips []})
  (s.fire! b)
  (t.= {:active-cells {104 5 105 5}
        :active-pips [{:owner 0 :row 1 :ttl 5}]
        :paths [["─" "─" "▶" "─" "┐" " " " " " " " " " " " " " "]
                ["─" "─" "◁" " " "├" "─" "─" "─" "─" "─" "─" "◀"]
                ["─" "─" "─" "─" "┘" " " " " " " " " " " " " " "]]
        :pip-row 0
        :pips 2} b)
  (s.pip-down! b 3) ; row 1: pip starts on row 0, wherever it was before
  (s.pip-down! b 3) ; row 2
  (s.pip-down! b 3) ; row 3
  (s.fire! b)
  (t.= {:active-cells {104 5 105 5
                       206 5 207 5 208 5 209 5 210 5 211 5 212 5
                       304 5 305 5}
        :active-pips [{:owner 0 :row 1 :ttl 5} {:owner 0 :row 3 :ttl 5}]
        :paths [["─" "─" "▶" "─" "┐" " " " " " " " " " " " " " "]
                ["─" "─" "◁" " " "├" "─" "─" "─" "─" "─" "─" "◀"]
                ["─" "─" "▶" "─" "┘" " " " " " " " " " " " " " "]]
        :pip-row 0
        :pips 1} b))

(fn test-pip-up-top []
  (local board {:pip-row 0})
  (s.pip-up! board 12)
  (t.= 12 board.pip-row))

(fn test-pip-up-middle []
  (local board {:pip-row 5})
  (s.pip-up! board 12)
  (t.= 4 board.pip-row))

(fn test-pip-down-bottom []
  (local board {:pip-row 12})
  (s.pip-down! board 12)
  (t.= 1 board.pip-row))

(fn test-pip-down-middle []
  (local board {:pip-row 5})
  (s.pip-down! board 12)
  (t.= 6 board.pip-row))

{: test-pip-up-middle
 : test-pip-up-top
 : test-pip-down-middle
 : test-pip-down-bottom
 : test-incoming
 : test-update-box
 : test-update-boxes!-no-inputs
 : test-update-boxes!-both-shoot-own-colour
 : test-update-boxes!-both-shoot-other-colour
 ;: test-update-boxes!-both-shoot-same-box
 : test-update-boxes!-left-through-inverters
 : test-update-boxes!-both-sending-same-signal
 ; : test-update-boxes!-both-sending-inverted-signal
 : test-fire-empty-ammo-does-nothing
 : test-fire-in-row-0-does-nothing
 : test-fire-next-to-<
 : test-fire-through-repeater
 : test-fire-through-inverter
 : test-fire-into-splitter
 : test-fires-into-joiner
 : test-fire-straight-path}
