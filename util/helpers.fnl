; (local fennel (require :lib.fennel))

;; Readability
; 
(fn inc [n]
  "Return n with 1 added to it"
  (+ 1 n))

(fn dec [n]
  "Return n with 1 subtracted from it"
  (- n 1))

(fn half [n]
  "Return half of the given number"
  (/ n 2))

;; Debugging

 (fn pp [x]
   "Analog to Janet's pp"
   ; (print (fennel.view x)))
   )

;; Data structure manipulation
; 
(fn flatten [nested]
  "return a flat array of the given nested arrays"
  (let [result []]
    (each [_ v (ipairs nested)]
      (if (= (type v) :table)
          (each [_ x (ipairs (flatten v))]
            (table.insert result x))
          (table.insert result v)))
    result))

(fn sum [tbl]
  "Return the sum of the given array"
  (var total 0)
  (each [_ v (ipairs tbl)]
    (set total (+ total v)))
  total)

{: pp : half : flatten : inc : dec : sum}


