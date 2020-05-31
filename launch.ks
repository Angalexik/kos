@lazyGlobal off.

runOncePath("functions.ks").

function ascent {
    parameter tgtheight.
    wait until airspeed > 100.
    lock steering to heading(90, 88.963 - 1.03287 * alt:radar^0.409511).
    until ship:apoapsis > tgtheight {
        autostage().
    }
    print ship:apoapsis.
    print "correct apoapsis".
    lock throttle to 0.
}

function circ {
    parameter whereto.
    local whento is 0.
    local extreme is 0.
    if whereto = "apoapsis" { set whento to eta:apoapsis. set extreme to ship:apoapsis. }
    if whereto = "periapsis" { set whento to eta:periapsis. set extreme to ship:periapsis. }
    local µ is ship:body:mu.
    local r is extreme + ship:body:radius.
    local a is ship:orbit:semimajoraxis.
    local v1 is sqrt(µ*((2 / r) - (1 / a))).
    local v2 is sqrt(µ*((2 / r) - (1 / r))).
    local dv is v2 - v1.
    executemnv(time:seconds + whento, 0, 0, dv).
}

// Default launch configuration I use for most of my crafts
function launch {
    if ship:availablethrust <= 0 { safestage(). }
    lock throttle to 1.
    ascent(80000).
    wait until alt:radar >= 70000.
    ag10 on. // You totally set action group 10 to just fairings on all your crafts right?
    wait 0.1.
    panels on.
    circ("apoapsis").
}

// launch().
