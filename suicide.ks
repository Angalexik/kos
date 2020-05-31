@lazyGlobal off.

runOncePath("0:/functions.ks").
local ship_bounds is ship:bounds.

function deorbit {
    lock steering to retrograde.
    set kuniverse:timewarp:mode to "RAILS".
    set kuniverse:timewarp:rate to 50.
    wait until eta:periapsis <= 10.
    set kuniverse:timewarp:rate to 0.
    wait until kuniverse:timewarp:issettled.
    lock throttle to 1.
    wait until ship:groundspeed < 20.
    lock throttle to 0.
    wait 1.
    // I have no idea, why i have to stage twice
    safestage().
    safestage().
}

function suicide {
    parameter bias. // Bias is just by how much to increase the base throttle, in case it isnt agressive enough
    unlock steering.
    lights on.
    lock steering to srfRetrograde.
    lock grav to body:mu / (ship:altitude + body:radius)^2.
    lock maxdecel to (ship:availablethrust / ship:mass) - grav.
    lock stopdistance to ship:verticalspeed^2 / (2 * maxdecel).
    lock throttle to (stopdistance / ship_bounds:bottomaltradar) + bias.
    wait until ship_bounds:bottomaltradar < 200.
    gear on.
    wait until ship_bounds:bottomaltradar < 2.
    sas off.
    lock throttle to 0.
}

// deorbit().
// suicide(0.01).
