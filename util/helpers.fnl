(local fennel (require :fennel))

;; Quality-of-life functions you might expect to find in a Lisp.

;; Readability
; 
(fn inc [n]
  "Return n with 1 added to it. Use inc! to modify in-place"
  (+ 1 n))

(fn dec [n]
  "Return n with 1 subtracted from it. Use dec! to modify in-place"
  (- n 1))

(fn half [n]
  "Return half of the given number"
  (/ n 2))

(fn zero? [val]
  "Is val zero?"
  (= 0 val))

(fn pos? [val]
  "Is val a positive number?"
  (< 0 val))

(fn not-pos? [val]
  "Is val less than or equal to zero?"
  (<= val 0))

(fn neg? [val]
  "Is val a negative number?"
  (< val 0))

(fn not-neg? [val]
  "Is val zero or greater?"
  (<= 0 val))

(fn nil? [val]
  "Is val nil?"
  (= nil val))

(fn not-nil? [val]
  "Is val nil?"
  (not= nil val))

; (fn string-contains? [s char]
;   "does string s contain char c?"
;   (not= nil (string.find s char true)))

(fn array-contains? [tbl e]
  (var found false)
  (each [_ v (ipairs tbl)]
    (when (= v e)
      (set found true)))
  found)

;; Debugging

(fn pp [x]
  "Analog to Janet's pp"
  (print (fennel.view x)))

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

(fn state-cell-idx [x y]
  ;; Used to access state.active-cells
  (+ x (* 100 y)))

(fn utf8-chars [s]
  "Breaks a unicode string down into an array of glyphs"
  (icollect [c (s:gmatch "[%z\001-\127\194-\244][\128-\191]*")]
    c))

(fn deep-clone [t]
  (if (= (type t) :table)
      (let [result {}]
        (each [k v (pairs t)]
          (tset result k (deep-clone v)))
        result)
      t))

;; State things
; 
(fn active? [x y board]
  (. board.active-cells (state-cell-idx x y)))

{: active?
 : array-contains?
 : dec
 : deep-clone
 : flatten
 : half
 : inc
 : nil?
 : not-nil?
 : pos?
 : not-pos?
 : neg?
 : not-neg?
 : pp
 : state-cell-idx
 : sum
 : utf8-chars
 : zero?}
