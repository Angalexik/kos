@lazyGlobal off.
// TODO: Create some sort of PID controller to automate the approach
// Currently this script only makes you face the docking port, however I plan to implement the
// rest of the docking procedure

local mydock is ship:dockingports[0].
local shipdock is 0.

function finddock {
    parameter ports.
    for port in ports {
        if port:nodetype = mydock:nodetype
        and not(port:haspartner) {
            return port.
        }
    }
    return 0.
}

if target:istype("Part") {
    set shipdock to target.
} else {
    set shipdock to finddock(target:dockingports).
}

print "My docks name is: " + mydock:name.
print "The ships dock name is: " + shipdock:name.

mydock:controlfrom().

lock steering to lookDirUp(-shipdock:portfacing:vector, shipdock:portfacing:upvector).

wait until false.
