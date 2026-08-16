(local defs (require :grapple.chooser.defs))
(local state (require :grapple.chooser.state))

(fn launch [] (set state.time-left defs.time-to-choose))

{: launch}
