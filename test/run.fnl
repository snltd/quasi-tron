(local t (require :faith))
(local test-modules [:test.helpers-test
                     :test.grapple.actions
                     :test.grapple.setup])

(t.run test-modules)
