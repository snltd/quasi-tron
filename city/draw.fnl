(local {: grid->screen} (require :city.maths))
(local levels (require :data.levels))
(local defs (require :city.defs))
(local state (require :city.state))
; (local global-state (require :global-state))
(local {: pp : half} (require :util.helpers))
(local player-png (love.graphics.newImage :assets/player.png))

(fn player [row col]
  (let [[x y] (grid->screen col row)]
    (love.graphics.draw player-png x y))
)

(fn plain-tile [row col str]
  (let [[x y] (grid->screen col row)
        y-t y
        y-m (+ y (half defs.tile.height))
        y-b (+ y defs.tile.height)
        x-l x
        x-m (+ x (half defs.tile.width))
        x-r (+ x defs.tile.width)]
    ;; x y are top corner of bounding rectangle
    (love.graphics.polygon str x-l y-m x-m y-t x-r y-m x-m y-b)))

(fn level []
  (each [y row (ipairs (. levels state.map-key ))]
    (each [x cell (ipairs row)]
      (plain-tile x y (if (= cell 1) :line :fill))))
  (player state.player-x state.player-y)

      )

{: level}
