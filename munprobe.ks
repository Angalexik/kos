@lazyGlobal off.

runOncePath("0:/functions.ks").
runOncePath("0:/launch.ks").
runOncePath("0:/transfer.ks").
runOncePath("0:/suicide.ks").
local j10 is ship:partsdubbed("J-10")[0].
sas off.

function courseCorrection {
    parameter tgtalt.
    print "Starting course correction".
    lock steering to retrograde.
    add node(time:seconds + eta:transition / 4, 0, 0, 0).
    print nextNode.
    warptonode(nextNode).
    remove nextNode.
    lock throttle to 0.01.
    wait until ship:orbit:nextpatch:periapsis >= tgtalt.
    lock throttle to 0.
}

function tweakap {
    parameter tgtalt.
    lock steering to retrograde.
    lock throttle to 0.35.
    wait until periapsis <= tgtalt.
    lock throttle to 0.
    unlock steering.
}

function warptomun {
    wait 0.5.
    set kuniverse:timewarp:mode to "RAILS".
    set kuniverse:timewarp:rate to 1000.
    wait until ship:body:name = "Mun".
    set kuniverse:timewarp:rate to 0.
}

launch().
tranferpls(mun).
wait 1.
if ship:orbit:nextpatch:body:radius >= ship:orbit:nextpatch:periapsis { courseCorrection(35000). }
warptomun().
tweakap(20000).
set j10:thrustlimit to 30.
circ("periapsis").
wait 1.
deorbit().
suicide(0.015).
