(local state (require :grapple.state))
(local {: gcol : number-of-cells } (require :grapple.defs))
(local {: sum : inc : dec : half : pp } (require :util.helpers))

(local offset-x 100)
(local offset-y 150)
(local x-scale 28)
(local y-scale 28)
(local triangle-height 0.4) ; actually half the height
(local triangle-width 0.8)
(local vertical-width 0.8)
(local vertical-height 0.5)
(local ellipse-width 0.5)
(local ellipse-eccentricity 3)
(local line-width 7)
(local central-cell-width (* 2 x-scale)) ; pixels
(local edge-column-width 18)

(var side-colour nil)
(var other-colour nil)
(var parse-cell nil) ; to get around circular dependency

(fn sx [n] (+ offset-x (* n x-scale)))
(fn sy [n] (+ offset-y (* n y-scale)))

(fn gwrap [f]
  "convenience wrapper for temporarily changing colour, line-width etc"
  (love.graphics.push "all")
  (f)
  (love.graphics.pop))

(fn in-colour [col f]
  (gwrap
    (fn []
      (love.graphics.setColor (unpack col))
      (f))))

(fn continue-line [x y board]
  (for [i (inc x) (length (. board 1))]
    (parse-cell i y (. (. board y) i) board)))

(fn ─ [x y]
  (let [x-left  (sx x)
        x-right (sx (inc x))
        y       (sy y)]
    (love.graphics.line x-left y x-right y)))

(fn ◁ [x y]
  (let [x-apex   (sx x)
        x-base   (sx (+ x triangle-width))
        y-apex   (sy y)
        y-bottom (sy (+ y triangle-height))
        y-top    (sy (- y triangle-height))]
    (in-colour side-colour
      (fn []
        (love.graphics.polygon :fill x-apex y-apex
                                     x-base y-top
                                     x-base y-bottom)))))

(fn ▶ [x y omit-line-segment]
  (let [x-base   (sx x)
        x-apex   (sx (+ x triangle-width))
        y-apex   (sy y)
        y-bottom (sy (+ y triangle-height))
        y-top    (sy (- y triangle-height))]
    (if (not omit-line-segment) (─ x y))
    (in-colour side-colour
      (fn [] (love.graphics.polygon :fill x-apex y-apex
                                          x-base y-top
                                          x-base y-bottom)))))

(fn S [x y]
  (let [origin-x (sx (+ x ellipse-width))
        origin-y (sy y)]
  (in-colour other-colour
    (fn []
      (love.graphics.ellipse :fill origin-x
                                   origin-y
                                   (half x-scale)
                                   (/ y-scale ellipse-eccentricity))))))

(fn │ [x y]
  (let [left   (sx x)
        right  (sx (+ x vertical-width))
        top    (sy (- y vertical-height))
        bottom (sy (+ y vertical-height))]
    (in-colour side-colour
      (fn []
        (love.graphics.polygon :fill left bottom
                                     left top
                                     right top
                                     right bottom)))))

(fn ┌ [x y board]
  (let [left   (sx x)
        right  (sx (+ x vertical-width))
        top    (- (sy y) line-width)
        bottom (sy (+ y vertical-height))]
    (─ x y)
    (in-colour side-colour
      (fn []
        (love.graphics.polygon :fill left bottom
                                     left top
                                     right top
                                     right bottom)))
    (continue-line x y board)))

(fn └ [x y board]
  (let [left   (sx x)
        right  (sx (+ x vertical-width))
        top    (sy (- y vertical-height))
        bottom (+ line-width (sy y))]
    (─ x y)
    (in-colour side-colour
      (fn []
        (love.graphics.polygon :fill left bottom
                                     left top
                                     right top
                                     right bottom)))
    (continue-line x y board)))

(fn ┐ [x y board]
  (let [left   (sx x)
        right  (sx (+ x vertical-width))
        top    (- (sy y) line-width)
        bottom (sy (+ y vertical-height))]
    (in-colour side-colour
      (fn []
        (love.graphics.polygon :fill left bottom
                                     left top
                                     right top
                                     right bottom)))
    (parse-cell x (inc y) (. (. board (inc y)) x) board)))

(fn ├ [x y board]
  (─ x y)
  (│ x y)
  (continue-line x y board))

(fn ┘ [x y]
  ;; this doesn't need to be able to do anything: we always know how far it
  ;; is from the corresponding top
  (let [left   (sx x)
        right  (sx (+ x vertical-width))
        bottom (+ (sy y) line-width)
        top    (sy (- y vertical-height))]
    (in-colour side-colour
      (fn []
        (love.graphics.polygon :fill left bottom
                                     left top
                                     right top
                                     right bottom)))))

(fn ┤ [x y board]
  (│ x y)
  (let [adj-up   (. (. board (dec y)) x)
        adj-down (. (. board (inc y)) x)]
    (if (= :┌ adj-up)   (┌ x (dec y) board)
        (= :│ adj-up)   (┤ x (dec y) board))
    (if (= :│ adj-down) (┤ (inc y) board)
        (= :└ adj-down) (└ x (inc y) board))))


(fn edge-column [x]
  (let [left (- x edge-column-width)
        right x
        top (- offset-y y-scale)
        bottom (+ offset-y (* (inc number-of-cells) y-scale))]
  (in-colour side-colour
    (fn []
      (love.graphics.polygon :fill left top
                                   right top
                                   right bottom
                                   left bottom)))
  (love.graphics.polygon :line left top
                               right top
                               right bottom
                               left bottom)
  ; the home line for new pips. 
  (love.graphics.line (sx 1) (sy 0)  (sx 2.5) (sy 0))))

(fn central-column-stub [x y]
  (let [x-apex   (+ 5 (sx (+ x (- 1 triangle-width))))
        x-base   (sx (inc x))
        y-apex-t (- (sy y) 4)
        y-apex-b (+ 4 (sy y))
        y-bottom (sy (+ y triangle-height))
        y-top    (sy (- y triangle-height))]
    (love.graphics.polygon :fill x-apex y-apex-b
                                 x-apex y-apex-t
                                 x-base y-top
                                 x-base y-bottom)))

(fn central-cell [x y]
  (central-column-stub x y)
  (let [left   (sx (inc x))
        right  (+ left central-cell-width)
        top    (- (sy y) (half y-scale))
        bottom (+ top y-scale)
        colour (if (= 0 (. state.cell-owner y)) gcol.left gcol.right)]
    (in-colour colour
      (fn []
      (love.graphics.polygon :fill left top
                                   right top
                                   right bottom
                                   left bottom)))
    (gwrap
      (fn []
        (love.graphics.setLineWidth 5)
        (love.graphics.polygon :line left top
                                     right top
                                     right bottom
                                     left bottom)))))

(fn who-is-winning? []
  "Returns the colour for the who-is-winning square"
  (let [tie-score   (half number-of-cells)
        right-score (sum state.cell-owner)]
      (if (< right-score tie-score) gcol.left
          (> right-score tie-score) gcol.right
          ;; we'll need some flashing thing here at some point
          [0 0 0]))) 
        
(fn who-is-winning-square [central-offset]
  (let [left   (sx (inc central-offset))
        right  (+ left central-cell-width)
        bottom (+ offset-y (half y-scale))
        top    (- bottom (* 1.8 y-scale))
        colour (who-is-winning?)
        ]
      (in-colour colour
        (fn []
          (love.graphics.polygon :fill left top
                                       right top
                                       right bottom
                                       left bottom)))
      (love.graphics.polygon :line left top
                                   right top
                                   right bottom
                                   left bottom)
))

(fn central-column []
  (let [central-offset (length (. state.board 1))]
  
  (who-is-winning-square central-offset)
  (for [row-idx 1 (length state.board)]
    (central-cell central-offset row-idx))))

(fn pip-arsenal []
  (let [left-offset -2]
    (for [i 1 state.pips.player]
      (▶ left-offset i true))))

(fn player-pip []
  (if (< 0 state.pips.player)
    (▶ (+ 2 (- 1 triangle-width)) state.pip-row.player true)))

(fn active-pips []
  (each [_ pip (ipairs state.active-pips)]
  (▶ 3 pip.row))
)
  
(set parse-cell
  (fn [col-idx row-idx cell board]
    (if (= :─ cell) (─ col-idx row-idx)
        (= :▶ cell) (▶ col-idx row-idx)
        (= :┤ cell) (┤ col-idx row-idx board)
        (= :├ cell) (├ col-idx row-idx board)
        (= :S cell) (S col-idx row-idx)
        (= :┐ cell) (┐ col-idx row-idx board)
        (= :┘ cell) (┘ col-idx row-idx)
        (= :◁ cell) (◁ col-idx row-idx))))

(fn board []
  "Draw the grapple board. `board` is a vec of vecs, each cell being a unicode
   character."
  (love.graphics.setLineWidth line-width)
  (love.graphics.setColor gcol.lines)
  (set side-colour gcol.left)
  (set other-colour gcol.right)
  (each [row-idx row (ipairs state.board)]
    (each [col-idx cell (ipairs row) &until (= cell " ")]
      (parse-cell col-idx row-idx cell state.board)))
  (edge-column (+ offset-x x-scale))
  (central-column)
  (player-pip)
  (pip-arsenal))

{: board : active-pips}
