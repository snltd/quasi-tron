(local { : paths } (require :grapple.paths))
(local {: flatten} (require :util.helpers))

(fn utf8-chars [s]
  "Breaks a unicode string down into an array of glyphs"
  (icollect [c (s:gmatch "[%z\001-\127\194-\244][\128-\191]*")]
    c))

(fn board [board-rows]
  "Returns a game board composed of paths from the paths file. The board is an
  array of arrays, so each char of the path is a separate element."
  (let [path-options (length paths)
        rows []]
    (var rows-to-add board-rows)
    (while (> rows-to-add 0)
      (let [random-index (math.random 1 path-options)
            candidate (. paths random-index )
            candidate-rows (length candidate)]
        (when (<= candidate-rows rows-to-add)
          (set rows-to-add (- rows-to-add candidate-rows))
          (table.insert rows candidate))))
    (icollect [_ row (ipairs (flatten rows))]
      (utf8-chars row))))

(fn cell-owners [board-rows]
  "Alternate colours for the initial state of the central column"
  (fcollect [i 1 board-rows] (% i 2)))

{: board : cell-owners}
