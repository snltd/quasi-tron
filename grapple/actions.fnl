(local defs (require :grapple.defs))
(local {: active? : dec : inc : nil? : pos? : state-cell-idx}
       (require :util.helpers))

(import-macros {: dec! : inc!} :util.macros)

(fn incoming [board-side row-num]
  "Returns the ID of the side which has the incoming signal, or 0 if there
   isn't one. So if you've fired through an inverter, you get the other side's
   ID"
  (let [connector-idx defs.board.cols]
    (if (active? connector-idx row-num board-side)
        (if (= :x (. (. board-side.paths row-num) connector-idx))
            (* -1 board-side.id)
            ;; passes through inverter, so invert the signal
            board-side.id)
        0)))

(fn update-box [incoming-l incoming-r]
  "Returns the colour a box should be, based on the left and right inputs, or
   nil if there are no inputs"
  (let [input-sum (+ incoming-l incoming-r)]
    (if (and (= 0 incoming-l) (= 0 incoming-r)) nil
        (= -2 input-sum) -1
        (= 2 input-sum) 1
        input-sum)))

(fn update-boxes [box-owners board]
  "Returns a new list of box owners"
  (local ret [])
  (for [row 1 (length board.left.paths)]
    (let [current-owner (. box-owners row)
          new-owner (update-box (incoming board.left row)
                                (incoming board.right row))]
      (if (and new-owner (not= current-owner new-owner))
          (table.insert ret new-owner)
          (table.insert ret current-owner))))
  ret)

;; fnlfmt: skip
(fn activate-cell [board x y ttl]
  (let [cell (. (. board.paths y) x)
        state-idx (state-cell-idx x y)]
    (if (not (active? x y board))
        (tset board.active-cells state-idx ttl))
    (if (= :─ cell) (activate-cell board (inc x) y ttl)
        (= :- cell) (activate-cell board (inc x) y ttl)
        (= :▶ cell)
          (do
            (tset board.active-cells state-idx math.huge)
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

(fn fire! [board-side]
  (when (and (pos? board-side.pips) (pos? board-side.pip-row))
    (let [adjacent (. (. board-side.paths board-side.pip-row) 3)]
      (when (and (pos? board-side.pip-row) (not= adjacent "◁")
                 (not= adjacent "▶"))
        (table.insert board-side.active-pips
                      {:owner 0 :ttl defs.pip-ttl :row board-side.pip-row})
        (tset (. board-side.paths board-side.pip-row) defs.firing-pip-col "▶")
        (dec! board-side.pips)
        (activate-cell board-side (inc defs.firing-pip-col) board-side.pip-row
                       defs.pip-ttl)
        (set board-side.pip-row 0)))))

(fn pip-up! [board rows]
  (if (< 1 board.pip-row)
      (dec! board.pip-row)
      (set board.pip-row rows)))

(fn pip-down! [board rows]
  (if (< board.pip-row rows)
      (inc! board.pip-row)
      (set board.pip-row 1)))

{: fire! : pip-down! : pip-up! : update-boxes : incoming : update-box}
