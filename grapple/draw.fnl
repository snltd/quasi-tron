(local state (require :grapple.state))
(local fonts (require :util.fonts))
(local defs (require :grapple.defs))
(local chooser (require :grapple.chooser))
(local {: pp : sum : inc : dec : half : active?} (require :util.helpers))

(local offset-x 130)
(local offset-y 180)
(local x-scale 25)
(local y-scale 28)
(local triangle-height 0.4)

; actually half the height
(local triangle-width 1)
(local vertical-width 1)
(local vertical-height 0.5)
(local ellipse-width 0.5)
(local ellipse-eccentricity 3)
(local line-width 7)
(local box-width 2)

;columns (* 2 x-scale)) ; pixels
(local edge-column-width 18)
(local dash-length 12)
(local gap-length 13)
(local march-speed 30)

(var side-colour nil)
(var other-colour nil)
(var parse-cell nil)

; to get around circular dependency

(fn sx [n] (+ offset-x (* n x-scale)))
(fn sy [n] (+ offset-y (* n y-scale)))

(fn gwrap [f]
  "convenience wrapper for temporarily changing colour, line-width etc"
  (love.graphics.push "all")
  (f)
  (love.graphics.pop))

(fn in-colour [col f]
  (gwrap (fn []
           (love.graphics.setColor (unpack col))
           (f))))

(fn continue-line [x y board]
  (for [i (inc x) (length (. board.paths 1))]
    (parse-cell i y (. (. board.paths y) i) board)))

(fn marching-line [x1 y1 x2 y2 dash gap speed]
  (let [dx (- x2 x1)
        dy (- y2 y1)
        len (math.sqrt (+ (* dx dx) (* dy dy)))
        ux (/ dx len)
        uy (/ dy len)
        cycle (+ dash gap)
        phase (% (* (love.timer.getTime) speed) cycle)]
    (var pos (- phase cycle))
    ;; start slightly before 0 so pattern enters cleanly
    (while (< pos len)
      (let [seg-start (math.max pos 0)
            seg-end (math.min (+ pos dash) len)]
        (when (< seg-start seg-end)
          (love.graphics.line (+ x1 (* ux seg-start)) (+ y1 (* uy seg-start))
                              (+ x1 (* ux seg-end)) (+ y1 (* uy seg-end)))))
      (set pos (+ pos cycle)))))

(fn _─ [colour x y board]
  (let [x-left (sx x)
        x-right (sx (inc x))
        y-px (sy y)]
    (if (active? x y board)
        (in-colour colour
                   (fn []
                     (marching-line x-left y-px x-right y-px dash-length
                                    gap-length march-speed)))
        (love.graphics.line x-left y-px x-right y-px))))

(fn ─ [x y board] (_─ side-colour x y board))
(fn ─invert [x y board] (_─ other-colour x y board))

(fn ◁ [x y board]
  (let [x-apex (sx x)
        x-base (sx (+ x triangle-width))
        y-apex (sy y)
        y-bottom (sy (+ y triangle-height))
        y-top (sy (- y triangle-height))]
    (─ x y board)
    (in-colour side-colour
               (fn []
                 (love.graphics.polygon :fill x-apex y-apex x-base y-top x-base
                                        y-bottom)))))

(fn ▶ [x y omit-line-segment board]
  (let [x-base (sx x)
        x-apex (sx (+ x triangle-width))
        y-apex (sy y)
        y-bottom (sy (+ y triangle-height))
        y-top (sy (- y triangle-height))]
    (if (not omit-line-segment)
        (if (= x defs.firing-pip-col) ; so there isn't a gap from the firing pip
            (in-colour side-colour (fn [] (─ x y board)))
            (─ x y board)))
    (in-colour side-colour
               (fn []
                 (love.graphics.polygon :fill x-apex y-apex x-base y-top x-base
                                        y-bottom)))))

(fn S [x y]
  (let [origin-x (sx (+ x ellipse-width))
        origin-y (sy y)]
    (in-colour other-colour
               (fn []
                 (love.graphics.ellipse :fill origin-x origin-y (half x-scale)
                                        (/ y-scale ellipse-eccentricity))))))

(fn │ [x y]
  (let [left (sx x)
        right (sx (+ x vertical-width))
        top (sy (- y vertical-height))
        bottom (sy (+ y vertical-height))]
    (in-colour side-colour
               (fn []
                 (love.graphics.polygon :fill left bottom left top right top
                                        right bottom)))))

(fn ┌ [x y board]
  (let [left (sx x)
        right (sx (+ x vertical-width))
        top (- (sy y) line-width)
        bottom (sy (+ y vertical-height))]
    (─ x y board)
    (in-colour side-colour
               (fn []
                 (love.graphics.polygon :fill left bottom left top right top
                                        right bottom)))
    (continue-line x y board)))

(fn └ [x y board]
  (let [left (sx x)
        right (sx (+ x vertical-width))
        top (sy (- y vertical-height))
        bottom (+ line-width (sy y))]
    (─ x y board)
    (in-colour side-colour
               (fn []
                 (love.graphics.polygon :fill left bottom left top right top
                                        right bottom)))
    (continue-line x y board)))

(fn ┐ [x y board]
  (let [left (sx x)
        right (sx (+ x vertical-width))
        top (- (sy y) line-width)
        bottom (sy (+ y vertical-height))]
    (in-colour side-colour
               (fn []
                 (love.graphics.polygon :fill left bottom left top right top
                                        right bottom)))
    (parse-cell x (inc y) (. (. board.paths (inc y)) x) board)))

(fn ├ [x y board]
  (─ x y board)
  (│ x y)
  (continue-line x y board))

(fn ┘ [x y]
  ;; this doesn't need to be able to do anything: we always know how far it
  ;; is from the corresponding top
  (let [left (sx x)
        right (sx (+ x vertical-width))
        bottom (+ (sy y) line-width)
        top (sy (- y vertical-height))]
    (in-colour side-colour
               (fn []
                 (love.graphics.polygon :fill left bottom left top right top
                                        right bottom)))))

(fn ┤ [x y board]
  (│ x y)
  (let [adj-up (. (. board.paths (dec y)) x)
        adj-down (. (. board.paths (inc y)) x)]
    (if (= :┌ adj-up) (┌ x (dec y) board)
        (= :│ adj-up) (┤ x (dec y) board))
    (if (= :│ adj-down) (┤ (inc y) board)
        (= :└ adj-down) (└ x (inc y) board))))

(fn edge-column [x]
  (let [left (- x edge-column-width)
        right x
        top (- offset-y y-scale)
        bottom (+ offset-y (* (inc defs.board.rows) y-scale))]
    (in-colour side-colour
               (fn []
                 (love.graphics.polygon :fill left top right top right bottom
                                        left bottom)))
    (love.graphics.polygon :line left top right top right bottom left bottom) ; the home line for new pips. 
    (love.graphics.line (sx 1) (sy 0) (sx 2.5) (sy 0))))

(fn central-column-stub [x y flip]
  (let [x-apex (sx (if flip (inc x) x))
        x-base (sx (if flip x (inc x)))
        x-step (if flip -3 3)
        trunc (if flip -6 6)
        y-bottom (sy (+ y triangle-height))
        y-top (sy (- y triangle-height))]
    (love.graphics.push)
    (love.graphics.setLineWidth 2)
    (var y-step -6)
    (for [x (+ trunc x-apex) x-base x-step]
      (set y-step (+ 1 y-step))
      (love.graphics.line x (+ y-bottom y-step) x (- y-top y-step)))
    (love.graphics.pop)))

(fn box [x y]
  (central-column-stub (dec x) y false)
  (central-column-stub (+ box-width x) y true)
  (let [left (sx x)
        right (sx (+ x box-width))
        top (- (sy y) (half y-scale))
        bottom (+ top y-scale)
        owner (. state.box-owners y)
        colour (if (= -1 owner) defs.gcol.left
                   (= 1 owner) defs.gcol.right)]
    (in-colour colour
               (fn []
                 (love.graphics.polygon :fill left top right top right bottom
                                        left bottom)))
    (gwrap (fn []
             (love.graphics.setLineWidth 5)
             (love.graphics.polygon :line left top right top right bottom left
                                    bottom)))))

(fn who-is-winning? []
  "Returns the colour for the who-is-winning square"
  (let [score (sum state.box-owners)]
    (if (< score 0) defs.gcol.left
        (< 0 score) defs.gcol.right
        ;; we'll need some flashing thing here at some point
        [0 0 0])))

(fn who-is-winning-square [central-offset]
  "Draws the big square at the top of the cell column which shows the current
   state of the game."
  (let [left (sx central-offset)
        right (sx (+ central-offset box-width))
        bottom (+ offset-y (half y-scale))
        top (- bottom (* 1.8 y-scale))
        colour (who-is-winning?)]
    (in-colour colour
               (fn []
                 (love.graphics.polygon :fill left top right top right bottom
                                        left bottom)))
    (love.graphics.polygon :line left top right top right bottom left bottom)))

(fn central-column []
  "Draws the column of boxes the players compete to control"
  (let [central-offset (+ 1 defs.board.cols)]
    (who-is-winning-square central-offset)
    (for [row-idx 1 defs.board.rows]
      (box central-offset row-idx))))

(fn pip-arsenal [board]
  "Draws the column of pips the player or enemy has in reserve"
  (let [left-offset -2]
    (for [i 1 board.pips]
      (▶ left-offset i true))))

(fn player-pip [side]
  "Draws the pip the player is controlling, wherever the state says it should
   be. The paths are designed such that every row is always a valid position."
  (let [board (. state.board side)]
    (if (< 0 board.pips)
        (▶ (+ 2 (- 1 triangle-width)) board.pip-row true))))

(set parse-cell
     (fn [col-idx row-idx cell board]
       (if (= :─ cell) (─ col-idx row-idx board)
           (= :- cell) (─invert col-idx row-idx board)
           (= :◀ cell) (─ col-idx row-idx board)
           (= :x cell) (─invert col-idx row-idx board)
           (= :▶ cell) (▶ col-idx row-idx false board)
           (= :┤ cell) (┤ col-idx row-idx board)
           (= :├ cell) (├ col-idx row-idx board)
           (= :S cell) (S col-idx row-idx)
           (= :┐ cell) (┐ col-idx row-idx board)
           (= :┘ cell) (┘ col-idx row-idx)
           (= :◁ cell) (◁ col-idx row-idx board))))

(fn side-icon [x y]
  (love.graphics.circle :line x y 20))

(fn side-icons []
  (let [left-x (sx 0)
        player-col [100 100 100]
        enemy-col [0 0 0]
        right-x (sx (+ 4 (* 2 defs.board.cols)))
        y (sy -3)]
    (if (= state.player-side :left)
        (do
          (in-colour player-col (fn [] (side-icon left-x y)))
          (in-colour enemy-col (fn [] (side-icon right-x y))))
        (do
          (in-colour enemy-col (fn [] (side-icon left-x y)))
          (in-colour player-col (fn [] (side-icon right-x y)))))))

(fn timer [label value]
  (let [left (sx 1)
        top (sy (+ 3 defs.board.rows))
        value (string.format "%.02f" value)
        value-offset 130]
  (love.graphics.print label left top)
  (love.graphics.printf value (+ value-offset left) top 140 :right)))

(fn draw-deadlock []
  (gwrap (fn []
           (love.graphics.setFont fonts.big-font)
           (if (= 0 (% (math.floor (love.timer.getTime)) 2 ))
               (love.graphics.print " * D E A D L O C K *" 60 600) ; (love.graphics.setColor 1 1 1 1)))
               ))))

(fn board []
  "Draws the grapple board and its trimmings"
  (love.graphics.setBackgroundColor (unpack defs.gcol.background))
  (love.graphics.setLineWidth line-width)
  (love.graphics.setColor defs.gcol.lines)
  (let [board (. state.board :left)]
    (set side-colour (. defs.gcol :left))
    (set other-colour (. defs.gcol :right))
    (each [row-idx row (ipairs board.paths)]
      (each [col-idx cell (ipairs row) &until (= cell " ")]
        (parse-cell col-idx row-idx cell board)))
    (edge-column (+ offset-x x-scale))
    (player-pip :left)
    (pip-arsenal board))
  (love.graphics.push)
  (love.graphics.translate (+ offset-x (* 2 (sx defs.board.cols))) 0)
  (love.graphics.scale -1 1)
  (let [board (. state.board :right)]
    (set side-colour (. defs.gcol :right))
    (set other-colour (. defs.gcol :left))
    (each [row-idx row (ipairs board.paths)]
      (each [col-idx cell (ipairs row) &until (= cell " ")]
        (parse-cell col-idx row-idx cell board)))
    (edge-column (+ offset-x x-scale))
    (player-pip :right)
    (pip-arsenal board))
  (love.graphics.pop)
  (side-icons)
  (central-column)
  (if (= state.phase :chooser) (timer "COLOUR" chooser.state.time-left)
      (= state.phase :grapple) (timer "TIME" state.time-left)
      (= state.phase :deadlock) (draw-deadlock)))

{: board}
