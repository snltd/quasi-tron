(local paths (require :grapple.paths))
(local {: number-of-cells} (require :grapple.defs))
(local {: flatten} (require :util.helpers))

(fn utf8-chars [s]
  (icollect [c (s:gmatch "[%z\001-\127\194-\244][\128-\191]*")]
    c))

(fn board [number-of-rows]
  "Returns a game board composed of paths from the paths file. The board is an
  array of arrays, so each char of the path is a separate element."
  (let [path-options (length paths.paths)
        rows []]
    (var rows-to-add number-of-rows)
    (while (> rows-to-add 0)
      (let [candidate (. paths.paths (math.random 1 path-options))
            candidate-length (length candidate)]
        (when (<= candidate-length rows-to-add)
          (set rows-to-add (- rows-to-add candidate-length))
          (table.insert rows candidate))))
    (icollect [_ row (ipairs (flatten rows))]
      (utf8-chars row))))

(fn cell-owners []
  (fcollect [i 1 number-of-cells] (% i 2)))

{: board : cell-owners}
