(local action (require :grapple.actions))
(local defs (require :grapple.defs))
(local state (require :grapple.state))
(local { : pos? } (require :util.helpers))

(fn move [_dt]
  (let [rows defs.board.rows
        n (math.random 0 1000)
        board (. state.board state.enemy-side)]
    (if (< n 20)
          (action.pip-up! board rows)
        (< n 50)
          (action.pip-down! board rows)
        (and (< n 80) (pos? board.pips) (pos? board.pip-row))
          (action.fire! board))))

{: move}
