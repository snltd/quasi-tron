;; The Quazatron grapple sub-game.
;; A central column of cells. Each player has a number of pips. Firing a pip
;; into a cell changes its colour. When the time reaches zero, whoever has the
;; most cells of their colour wins.
;;
;; Initial sketch for how it works:
;; To generate the game board we have a store of paths. Paths can be a straight
;; line to a single cell, or they can branch into multiple paths, some or all
;; of which may be dead-ends.

(local defs (require :grapple.defs))

(local draw (require :grapple.draw))
(local init (require :grapple.init))
(local state (require :grapple.state))
(local {: state-cell-idx : pos? : nil? : inc : dec : active? : pp}
       (require :util.helpers))

; (import-macros {: inc! : dec! } :util.macros)

(macro dec! [token opt-val]
  "Decrement token by 1, or by opt-val if given"
  `(set ,token (if (nil? ,opt-val) (- ,token 1) (- ,token ,opt-val))))

(macro inc! [token opt-val]
  "Increment token by 1, or by opt-val if given"
  `(set ,token (if (nil? ,opt-val) (+ ,token 1) (+ ,token ,opt-val))))

(var key-timer 0)
(var key-held false)

(fn love.load []
  (math.randomseed (os.time))
  (love.window.setTitle "Quasi-Tron")
  (love.window.setMode defs.size.window.width defs.size.window.height {:resizable true})
  (love.graphics.setBackgroundColor (unpack defs.gcol.background))
  (set state.pips.player 10)
  ;; TODO dynamically
  (set state.pips.enemy 5)
  ;; TODO dynamically
  (set state.cells.owner (init.cell-owners defs.board.rows))
  (set state.board.left.paths (init.board defs.board.rows))
  (set state.board.right.paths (init.board defs.board.rows)))

(fn love.draw []
  (let [(win-w win-h) (love.graphics.getDimensions)
        scale (math.min (/ win-w defs.size.window.width)
                        (/ win-h defs.size.window.height))
        offset-x (/ (- win-w (* defs.size.window.width scale)) 2)
        offset-y (/ (- win-h (* defs.size.window.height scale)) 2)]
    (love.graphics.push)
    (love.graphics.translate offset-x offset-y)
    (love.graphics.scale scale scale)
    (draw.board)
    (love.graphics.pop)))

(fn love.update [dt]
  (each [_side board (pairs state.board)]
    (each [idx ttl (pairs board.active-cells)]
      (local new-ttl (- ttl dt))
      (tset board.active-cells idx new-ttl)
      (when (< new-ttl 0)
        (tset board.active-cells idx nil)))
    (each [i pip (ipairs board.active-pips)]
      (dec! pip.ttl dt)
      (when (not (pos? pip.ttl))
        (tset (. board.paths pip.row) 3 :─)
        (table.remove board.active-pips i))))
  ;; keyboard stuff ; 
  (set key-timer (- key-timer dt))
  (let [keys defs.keys
        held (or (love.keyboard.isDown keys.up)
                 (love.keyboard.isDown keys.down))
        props state.board.left]
    (if held
        (when (or (not key-held) (<= key-timer 0))
          (if (love.keyboard.isDown keys.down)
              (if (< props.pip-row defs.board.rows)
                  (inc! props.pip-row)
                  (set props.pip-row 1))
              (love.keyboard.isDown keys.up)
              (if (< 1 props.pip-row)
                  (dec! props.pip-row)
                  (set props.pip-row defs.board.rows)))
          (set key-timer (if key-held keys.repeat-rate keys.repeat-delay))
          (set key-held true))
        (set key-held false))))

(fn activate-cell [board x y ttl]
  (let [cell (. (. board.paths y) x)
        state-idx (state-cell-idx x y)]
    (if (not (active? x y board))
        (tset board.active-cells state-idx ttl))
    (if (= :─ cell) (activate-cell board (inc x) y ttl)
        (= :- cell) (activate-cell board (inc x) y ttl)
        (= :◀ cell) (tset state.cells.owner y 0) ;; todo fix for sides
        (= :x cell) (tset state.cells.owner y 1)
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

(fn fire [side]
  (let [board (. state.board side)
        pip-col 3
        adjacent (. (. board.paths board.pip-row) 3)]
    (when (and (pos? board.pip-row) (not= adjacent :◁) (not= adjacent :▶))
      (table.insert board.active-pips
                    {:owner 0 :ttl defs.pip-ttl :row board.pip-row})
      (tset (. board.paths board.pip-row) pip-col :▶)
      (dec! state.pips.player)
      (activate-cell board (inc pip-col) board.pip-row defs.pip-ttl)
      (set board.pip-row 0))))

(fn love.keypressed [key]
  (let [side :left
        props (. state.board side)]
    ;; we don't need/want repeat on the fire
    (if (and (= key defs.keys.fire) (pos? state.pips.player) (pos? props.pip-row))
        (fire side)
        (= key "escape")
        (love.event.quit))))
