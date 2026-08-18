(local defs (require :grapple.defs))
(local {: active?
        : sum
        : dec
        : inc
        : neg?
        : zero?
        : nil?
        : pos?
        : state-cell-idx} (require :util.helpers))

(import-macros {: dec! : inc!} :util.macros)

(fn winner [box-owners player-side]
  (let [raw-score (sum box-owners)
        player-multiplier (if (= player-side :left) -1 1)
        player-score (* raw-score player-multiplier)]
    (if (zero? player-score) :deadlock
        (pos? player-score) :player
        (neg? player-score) :enemy)))

(fn incoming [board-side row-num]
  "Returns the ID of the side which has the incoming signal, or 0 if there
   isn't one. So if you've fired through an inverter, you get the other side's
   ID"
  (let [connector-idx defs.board.cols]
    (if (active? connector-idx row-num board-side)
        (if (= :x (. (. board-side.paths row-num) connector-idx))
            (* -1 board-side.id) ; passes through inverter, so invert the signal
            board-side.id)
        0)))

(fn box-owner [incoming-l incoming-r]
  "Returns the colour a box should be, based on the left and right inputs, or
   nil if there are no inputs"
  (let [input-sum (+ incoming-l incoming-r)]
    (if (and (zero? incoming-l) (zero? incoming-r)) nil
        (zero? input-sum) (if (< 0.5 (math.random)) 1 -1)
        (= -2 input-sum) -1
        (= 2 input-sum) 1
        input-sum)))

(fn box-owners [owners board]
  "Returns a new list of box owners"
  (local ret [])
  (for [row 1 (length board.left.paths)]
    (let [current-owner (. owners row)
          new-owner (box-owner (incoming board.left row)
                               (incoming board.right row))]
      (if (and new-owner (not= current-owner new-owner))
          (table.insert ret new-owner)
          (table.insert ret current-owner))))
  ret)

(fn activate-cell! [board x y ttl]
  (let [cell (. (. board.paths y) x)
        state-idx (state-cell-idx x y)]
    (when (not (active? x y board))
      (tset board.active-cells state-idx ttl))
    (case cell
      (where (or "─" "-" :S)) (activate-cell! board (inc x) y ttl)
      "▶" (do
              (tset board.active-cells state-idx math.huge)
              (activate-cell! board (inc x) y math.huge))
      "┤" (do
              (activate-cell! board (inc x) (inc y) ttl)
              (activate-cell! board (inc x) (dec y) ttl))
      "┐" (let [value (active? x (+ 2 y) board)]
              (activate-cell! board (inc x) (inc y)
                              (if (= value math.huge) ttl value)))
      "┘" (let [value (active? x (- y 2) board)]
              (activate-cell! board (inc x) (dec y)
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
        (activate-cell! board-side (inc defs.firing-pip-col) board-side.pip-row
                        defs.pip-ttl)
        (set board-side.pip-row 0)))))

(fn pip-up! [board-side rows]
  (if (< 1 board-side.pip-row)
      (dec! board-side.pip-row)
      (set board-side.pip-row rows)))

(fn pip-down! [board-side rows]
  (if (< board-side.pip-row rows)
      (inc! board-side.pip-row)
      (set board-side.pip-row 1)))

{: fire! : pip-down! : pip-up! : box-owners : incoming : box-owner : winner}
