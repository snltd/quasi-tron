(local defs (require :city.defs))
(local {: half } (require :util.helpers))

(fn grid->screen [col row]
  [(+ defs.origin.x (* (- col row) (half defs.tile.width)))
  (+ defs.origin.y (* (+ col row) (half defs.tile.height)))])

; screen_x = origin_x + (col - row) * (tile_width / 2)
; screen_y = origin_y + (col + row) * (tile_height / 2)
;

{: grid->screen }
