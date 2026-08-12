(local global-state (require :global-state))
(local action (require :grapple.actions))
(local chooser (require :grapple.chooser))
(local defs (require :grapple.defs))
(local enemy (require :grapple.enemy))
(local state (require :grapple.state))
(local {: pos?} (require :util.helpers))
(local {: keys} (require :global-defs))
(local {: nil?} (require :util.helpers))
(import-macros {: dec!} :util.macros)

(fn update [dt]
  (each [_side board (pairs state.board)]
    (each [idx ttl (pairs board.active-cells)]
      (local new-ttl (- ttl dt))
      (tset board.active-cells idx new-ttl)
      (when (< new-ttl 0)
        (tset board.active-cells idx nil)))
    (each [i pip (ipairs board.active-pips)]
      (dec! pip.ttl dt)
      (when (not (pos? pip.ttl))
        (tset (. board.paths pip.row) defs.firing-pip-col "─")
        (table.remove board.active-pips i))))
  ;; player 
  (if (= state.phase :grapple)
      (do
        (set global-state.key-timer (- global-state.key-timer dt))
        (let [held (or (love.keyboard.isDown keys.up)
                       (love.keyboard.isDown keys.down))
              board (. state.board state.player-side)]
          (if held
              (when (or (not global-state.key-held)
                        (<= global-state.key-timer 0))
                (if (love.keyboard.isDown keys.down) (action.pip-down board)
                    (love.keyboard.isDown keys.up) (action.pip-up board))
                (set global-state.key-timer
                     (if global-state.key-held keys.repeat-rate
                         keys.repeat-delay))
                (set global-state.key-held true))
              (set global-state.key-held false)))
        ;; enemy
        (action.update-boxes state.board)
        (enemy.move dt)))
  ;; state.phase is chooser
  (chooser.update dt))

{: update}
