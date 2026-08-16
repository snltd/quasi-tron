(local data (require :data))
(local global-defs (require :global-defs))
(local defs (require :select-components.defs))
(local state (require :select-components.state))
(local {: nil?} (require :util.helpers))
(import-macros {: dec! : inc!} :util.macros)

(local row-height 40)
(local left-margin 80)
(local name-margin 400)

(fn sy [row] (* row-height row))

(fn selector [row]
  (when (= row state.active-row)
    (love.graphics.print "[" 50 (sy row))
    (love.graphics.print "]" 260 (sy row))))

(fn centred [text row]
  (love.graphics.printf text 0 (sy row) global-defs.size.window.width :center))

(fn exit-option [row]
  (love.graphics.print "<< EXIT" left-margin (sy row))
  (selector row))

(fn component [component-type name row]
  (selector row)
  (love.graphics.print component-type left-margin (sy row))
  (love.graphics.print (if (nil? name) "<none>" name) name-margin (sy row)))

(fn component-list []
  (let [robot (. data.robots state.robot-id)]
    (centred "SELECT REQUIRED PARTS" 1)
    (centred (.. "UNIT.. " robot.name " " robot.desc) 2)
    (centred (.. "Security Class " robot.security-class) 3)
    (exit-option defs.exit-row)
    (each [component-type row (pairs defs.component-rows)]
      (component component-type (. state.components component-type) row))))

{: component-list}
