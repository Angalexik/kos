@lazyGlobal off.

function safestage {
    wait until stage:ready.
    stage.
}

function autostage {
    if not(defined oldthrust) {
        global oldthrust is ship:availablethrust.
    }
    if ship:availableThrust < oldthrust {
        safestage().
        wait 1.
        set oldthrust to ship:availablethrust.
    }
}

function burntime {
    parameter mnv.
    set oldthrust to ship:availableThrust.
    local a0 is maxThrust / mass.
    local eIsp is 0.
    local ship_engines is list().
    list engines in ship_engines.
    for eng in ship_engines {
        set eIsp to eIsp + eng:maxThrust / maxThrust * eng:isp.
    }
    local Ve to eIsp * constant():g0.
    local drymass is mass * constant():e^(-1 * mnv:deltav:mag/Ve).
    local a1 to maxThrust / drymass.
    local t is mnv:deltav:mag / ((a0 + a1) / 2).
    return t.
}

function executemnv {
    parameter utime, radial, normal, porgrade.
    local mnv is node(utime, radial, normal, porgrade).
    add mnv.
    lock steering to mnv:deltav.
    wait until vAng(ship:facing:vector, mnv:deltav) < 5.
    wait until mnv:eta < burntime(mnv) / 2.
    lock throttle to 1.
    until vAng(ship:facing:vector, mnv:deltav) >= 90 {
        autostage().
    }
    lock throttle to 0.
    remove mnv.
    unlock steering.
    unlock throttle.
}

function warptonode {
    // There has to be a better to do this, I just know it
    parameter mnv.
    set kuniverse:timewarp:mode to "RAILS".
    set kuniverse:timewarp:warp to 6.
    wait until mnv:eta + burntime(mnv) < 30 * 60.
    set kuniverse:timewarp:warp to 4.
    wait until mnv:eta + burntime(mnv) < 10 * 60.
    set kuniverse:timewarp:warp to 3.
    wait until mnv:eta + burntime(mnv) <= 25.
    set kuniverse:timewarp:warp to 0.
    wait until kuniverse:timewarp:issettled.
    wait 0.5. // Just in case
}
