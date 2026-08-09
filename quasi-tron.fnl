;; The Quazatron grapple sub-game.
;; A central column of cells. Each player has a number of pips. Firing a pip
;; into a cell changes its colour. When the time reaches zero, whoever has the
;; most cells of their colour wins.
;;
;; Initial sketch for how it works:
;; To generate the game board we have a store of paths. Paths can be a straight
;; line to a single cell, or they can branch into multiple paths, some or all
;; of which may be dead-ends.

(local {: keys : size : gcol : number-of-cells : pip-ttl}
       (require :grapple.defs))

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
  (love.window.setMode size.window.width size.window.height {:resizable true})
  (love.graphics.setBackgroundColor (unpack gcol.background))
  (set state.pips.player 10)
  ;; TODO dynamically
  (set state.pips.enemy 5)
  ;; TODO dynamically
  (set state.cell-owner (init.cell-owners))
  (set state.board (init.board number-of-cells)))

(fn love.draw []
  (let [(win-w win-h) (love.graphics.getDimensions)
        scale (math.min (/ win-w size.window.width)
                        (/ win-h size.window.height))
        offset-x (/ (- win-w (* size.window.width scale)) 2)
        offset-y (/ (- win-h (* size.window.height scale)) 2)]
    (love.graphics.push)
    (love.graphics.translate offset-x offset-y)
    (love.graphics.scale scale scale)
    (draw.board)
    (love.graphics.pop)))

(fn love.update [dt]
  (each [idx ttl (pairs state.active-cells)]
    (local new-ttl (- ttl dt))
    (tset state.active-cells idx new-ttl)
    (when (< new-ttl 0)
      (tset state.active-cells idx nil)))
  (each [i pip (ipairs state.active-pips)]
    (dec! pip.ttl dt)
    (when (not (pos? pip.ttl))
      (tset (. state.board pip.row) 3 :─)
      (table.remove state.active-pips i)))
  ;; keyboard stuff
  (set key-timer (- key-timer dt))
  (let [held (or (love.keyboard.isDown keys.up)
                 (love.keyboard.isDown keys.down))]
    (if held
        (when (or (not key-held) (<= key-timer 0))
          (if (love.keyboard.isDown keys.down)
              (if (< state.pip-row.player number-of-cells)
                  (inc! state.pip-row.player)
                  (set state.pip-row.player 1))
              (love.keyboard.isDown keys.up)
              (if (< 1 state.pip-row.player)
                  (dec! state.pip-row.player)
                  (set state.pip-row.player number-of-cells)))
          (set key-timer (if key-held keys.repeat-rate keys.repeat-delay))
          (set key-held true))
        (set key-held false))))

(fn activate-cell [x y ttl]
  (let [cell (. (. state.board y) x)
        state-idx (state-cell-idx x y)]
    (if (not (active? x y))
      (tset state.active-cells state-idx ttl))
      
    (if (= :─ cell) (activate-cell (inc x) y ttl)
        (= :- cell) (activate-cell (inc x) y ttl)
        (= :◀ cell) (tset state.cell-owner y 0) ;; todo fix for sides
        (= :x cell) (tset state.cell-owner y 1) ;; todo fix for sides
        (= :▶ cell)
          (do
            (table.insert state.active-cells state-idx math.huge)
            (activate-cell (inc x) y math.huge))
        (= :┤ cell)
          (do
            (activate-cell (inc x) (inc y) ttl)
            (activate-cell (inc x) (dec y) ttl))
        (= :S cell) (activate-cell (inc x) y ttl)
        (= :┐ cell)
          (match (active? x (+ 2 y))
            value (activate-cell (inc x) (inc y)
                                 (if (= value math.huge) ttl value)))
        (= :┘ cell)
          (match (active? x (- y 2))
            value (activate-cell (inc x) (dec y)
                                 (if (= value math.huge) ttl value))))))

(fn fire []
  (let [row state.pip-row.player
        pip-col 3
        adjacent (. (. state.board row) 3)]
    (when (and (pos? row) (not= adjacent :◁) (not= adjacent :▶))
      (table.insert state.active-pips {:owner 0 :ttl pip-ttl :row row})
      (tset (. state.board row) pip-col :▶)
      (dec! state.pips.player)
      (activate-cell (inc pip-col) row pip-ttl)
      (set state.pip-row.player 0))))

(fn love.keypressed [key]
  ;; we don't need/want repeat on the fire
  (if (and (= key keys.fire) (pos? state.pips.player)
           (pos? state.pip-row.player))
      (fire)
      (= key "escape")
      (love.event.quit)))
