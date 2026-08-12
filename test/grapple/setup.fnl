(local defs (require :grapple.defs))
(local t (require :faith))
(local s (require :grapple.setup))

(fn test-box-owners []
  (t.= [1 -1 1 -1 1] (s.box-owners 5)))

(fn test-board-paths []
  (for [rows 1 16]
    (let [board (s.board-paths rows)]
      (t.= rows (length board))
      (t.= defs.board.cols (length (. board 1))))))

{: test-box-owners : test-board-paths }
