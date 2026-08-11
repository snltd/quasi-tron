(local defs (require :grapple.defs))
(local {: paths} (require :grapple.paths))
(local state (require :grapple.state))
(local {: utf8-chars : flatten} (require :util.helpers))

(fn board [board-rows]
  "Returns a game board composed of paths from the paths file. The board is an
  array of arrays, so each char of the path is a separate element."
  (let [path-options (length paths)
        rows []]
    (var rows-to-add board-rows)
    (while (> rows-to-add 0)
      (let [random-index (math.random 1 path-options)
            candidate (. paths random-index)
            candidate-rows (length candidate)]
        (when (<= candidate-rows rows-to-add)
          (set rows-to-add (- rows-to-add candidate-rows))
          (table.insert rows candidate))))
    (icollect [_ row (ipairs (flatten rows))]
      (utf8-chars row))))

(fn cell-owners [board-rows]
  "Alternate colours for the initial state of the central column"
  (fcollect [i 1 board-rows] (% i 2)))

(fn launch [params]
  (love.graphics.setBackgroundColor (unpack defs.gcol.background))
  (set state.phase :chooser)
  (set state.board.left.pips params.player-pips)
  (set state.board.right.pips params.enemy-pips)
  (set state.player-side :left)
  (set state.enemy-side :right)
  (set state.cells.owner (cell-owners defs.board.rows))
  (set state.board.left.paths (board defs.board.rows))
  (set state.board.right.paths (board defs.board.rows)))

{: launch : board : cell-owners}
