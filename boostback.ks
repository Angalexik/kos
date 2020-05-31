@lazyGlobal off.
runOncePath("0:/functions.ks").
runOncePath("0:/suicide.ks").

// check if trajectories exists
if not(addons:tr:available) {
    print "You need trajectories installed".
    local crashcreator is 1 / 0.
}
local boostertanks is ship:partsdubbed("boostertank").
local ksc is latlng(-0.096911, -74.610568).

function stagewithsomefuelleftover { // I shouldnt be allowed to name functions anymore
    parameter fuelamount.

    local fuelleft is 0.

    for tank in boostertanks {
        set fuelleft to fuelleft + tank:resources[0]:amount. // Increase fuelleft by the amount of liquid fuel left in the tank
    }

    if fuelleft <= fuelamount {
        safestage().
        set decoupled to true.
    }
}

function ascent {
    parameter tgtheight.
    lock steering to heading(90,90).
    wait until airspeed > 100.
    lock steering to heading(90, 88.963 - 1.03287 * alt:radar^0.409511).
    if not(defined decoupled) {
        global decoupled is false.
    }
    until decoupled or apoapsis > tgtheight {
        stagewithsomefuelleftover(1056). // Change back to 1056 when done testing
        wait 0.1.
    }
    clearScreen.
}

function boostback {
    parameter margin, tgtspot.

    lock throttle to 0.
    rcs on.
    lock predspot to addons:tr:impactpos.
    lock distancetotgt to (tgtspot:position - predspot:position):mag.
    local tgtheading is heading(270, 1).
    lock steering to tgtheading.
    wait until vAng(ship:facing:vector, tgtheading:vector) < 5.
    lock steering to heading(270 + tgtspot:bearing, 1).
    lock throttle to 1.
    wait until distancetotgt < margin.
    unlock predspot. // Prevent a crash when switching vessels
    wait 2. // Compensate for different drag when facing retrograde
    lock throttle to 0.
    lock steering to srfRetrograde.
    brakes on.
    wait until ship:geoposition:terrainheight > 0. // Ensure you dont land in the ocean
    suicide(0.05).
}

lock throttle to 1.
safestage().
ascent(75000).
boostback(3400, ksc).
