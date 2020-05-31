core:part:getmodule("kOSProcessor"):doevent("Open Terminal").

if exists("1:/functions.ks") { donothing. } else { copyPath("0:/functions.ks", "1:/"). }
if exists("1:/launch.ks") { donothing. } else { copyPath("0:/launch.ks", "1:/"). }
runOncePath("launch.ks").

local upperstage is ship:partsdubbed("upperstage")[0].
local oldshipname is ship:shipName.

if apoapsis > 70000 { circ("apoapsis"). }

until false {
    if upperstage:ship:shipName = oldshipname {
        clearScreen.
        print "Waiting for seperation".
    } else {
        clearScreen.
        break.
    }
}

unlock throttle.
unlock steering.

print "Booster seperated, pod CPU taking over".

launch().
