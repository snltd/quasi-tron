(local t (require :faith))
(local h (require :util.helpers))

(fn test-inc []
  (t.= 6 (h.inc 5)))

(fn test-dec []
  (t.= 4 (h.dec 5)))

(fn test-half []
  (t.= 2 (h.half 4))
  (t.= 2.5 (h.half 5)))

(fn test-zero? []
  (t.= true (h.zero? 0))
  (t.= false (h.zero? -1))
  (t.= false (h.zero? 1)))

(fn test-pos? []
  (t.= true (h.pos? 1))
  (t.= false (h.pos? 0))
  (t.= false (h.pos? -1)))

(fn test-neg? []
  (t.= true (h.neg? -1))
  (t.= false (h.neg? 1))
  (t.= false (h.neg? 0)))

(fn test-not-pos? []
  (t.= true (h.not-pos? -1))
  (t.= true (h.not-pos? 0))
  (t.= false (h.not-pos? 1)))

(fn test-not-neg? []
  (t.= false (h.not-neg? -1))
  (t.= true (h.not-neg? 1))
  (t.= true (h.not-neg? 0)))

(fn test-nil? []
  (t.= true (h.nil? nil))
  (t.= false (h.nil? false))
  (t.= false (h.nil? h.nil?)))

(fn test-not-nil? []
  (t.= false (h.not-nil? nil))
  (t.= true (h.not-nil? false))
  (t.= true (h.not-nil? h.nil?)))

(fn test-flatten []
  (t.= [1 2 3 4] (h.flatten [1 2 3 4]))
  (t.= [1 2 3 4] (h.flatten [1 [2 3] 4]))
  (t.= [1 2 3 4] (h.flatten [1 [2 3] [[[4]]]])))

(fn test-sum []
  (t.= 10 (h.sum [1 2 3 4]))
  (t.= 0 (h.sum [])))

(fn test-active? []
  (local board {:active-cells {106 5 105 5 104 5}})
  (t.= nil (h.active? 1 1 board))
  (t.= 5 (h.active? 6 1 board)))

{: test-inc
 : test-dec
 : test-half
 : test-zero?
 : test-pos?
 : test-nil?
 : test-not-nil?
 : test-neg?
 : test-not-neg?
 : test-not-pos?
 : test-active?
 : test-flatten
 : test-sum}
