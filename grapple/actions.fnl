(local defs (require :grapple.defs))
(local state (require :grapple.state))
(local { : active? : dec : inc : nil? : pos? : state-cell-idx }
  (require :util.helpers))
(import-macros  {: dec! : inc! } :util.macros)

(fn activate-cell [board x y ttl]
  (let [cell (. (. board.paths y) x)
        state-idx (state-cell-idx x y)]
    (if (not (active? x y board))
        (tset board.active-cells state-idx ttl))
    (if (= :─ cell) (activate-cell board (inc x) y ttl)
        (= :- cell) (activate-cell board (inc x) y ttl)
        (= :◀ cell) (tset state.cells.owner y board.id)
        (= :x cell) (tset state.cells.owner y board.other-id)
        (= :▶ cell)
          (do
            (table.insert board.active-cells state-idx math.huge)
            (activate-cell board (inc x) y math.huge))
        (= :┤ cell)
          (do
            (activate-cell board (inc x) (inc y) ttl)
            (activate-cell board (inc x) (dec y) ttl))
        (= :S cell) (activate-cell board (inc x) y ttl)
        (= :┐ cell)
          (case (active? x (+ 2 y) board)
            value (activate-cell board (inc x) (inc y)
                                 (if (= value math.huge) ttl value)))
        (= :┘ cell)
          (case (active? x (- y 2) board)
            value (activate-cell board (inc x) (dec y)
                                 (if (= value math.huge) ttl value))))))

(fn fire-pip [board]
  (let [adjacent (. (. board.paths board.pip-row) 3)]
    (when (and (pos? board.pip-row) (not= adjacent :◁) (not= adjacent :▶))
      (table.insert board.active-pips
                    {:owner 0 :ttl defs.pip-ttl :row board.pip-row})
      (tset (. board.paths board.pip-row) defs.firing-pip-col :▶)
      (dec! board.pips)
      (activate-cell board
                     (inc defs.firing-pip-col)
                     board.pip-row defs.pip-ttl)
      (set board.pip-row 0))))

(fn fire []
  (let [board (. state.board state.player-side)]
  (if (and (pos? board.pips) (pos? board.pip-row))
    (fire-pip board))))

(fn pip-down [board]
  (if (< 1 board.pip-row)
      (dec! board.pip-row)
      (set board.pip-row defs.board.rows)))

(fn pip-up [board]
  (if (< board.pip-row defs.board.rows)
      (inc! board.pip-row)
      (set board.pip-row 1)))

{ : fire-pip : fire : pip-down : pip-up }
