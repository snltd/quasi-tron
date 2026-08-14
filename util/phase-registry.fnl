(local registry {})

(fn register! [name phase-module]
  (tset registry name phase-module))

(fn get [name]
  (. registry name))

{: register! : get}
