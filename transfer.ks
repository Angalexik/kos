@lazyGlobal off.

runOncePath("0:/functions.ks").
sas off.

function getdv {
    // Nothing worked, so i resorted to hill climbing :(
    parameter tgtbody.
    local stepsize is 0.7.
    local mnvdata is list(time:seconds + 10, 0, 0, 0).
    until false {
        local mnv is node( mnvdata[0], mnvdata[1], mnvdata[2], mnvdata[3] ).
        add mnv.
        if mnv:orbit:apoapsis < tgtbody:orbit:periapsis {
            set mnvdata[3] to mnvdata[3] + stepsize.
        } else {
            remove mnv.
            return mnvdata[3].
        }
        remove mnv.
    }
}

function gettransferangle {
    parameter tgtbody.
    local transfer is node(time:seconds + 10, 0, 0, getdv(tgtbody)).
    add transfer.
    local transferangle is 180 - (360 * ((1 / 2 * transfer:orbit:period)/(tgtbody:orbit:period))).
    remove transfer.
    return transferangle.
}

function getphaseangle {
    parameter tgtbody.
    local phaseangle is vAng(ship:position - body:position, tgtbody:position - body:position).
    // print "The current phase angle is: " + phaseangle + "°".
    return phaseangle.
}

function aheadorbehind {
    parameter tgtbody.
    local bodytoshipvec is (ship:position - body:position):normalized.
    local obtnrm is vCrs(bodytoshipvec, ship:velocity:orbit:normalized):normalized.
    local bodytotarvec is vxcl(obtnrm, (tgtbody:position - body:position):normalized):normalized.
    local signvec is vCrs(obtnrm, bodytoshipvec).
    local phasesign is bodytotarvec * signvec. // Mulitplication is the same as the vdot function
    if phasesign > 0 {
        // print "The ship is ahead".
        return true.
    } else {
        // print "The ship is behind".
        return false.
    }
}

function tranferpls {
    parameter tgtbody.
    local dv is getdv(tgtbody).
    local transferangle is gettransferangle(tgtbody).
    local phaseangle is getphaseangle(tgtbody).
    set kuniverse:timewarp:mode to "RAILS".
    set kuniverse:timewarp:warp to 4.
    until transferangle - phaseangle < 0.5 and transferangle - phaseangle > -0.5 and aheadorbehind(tgtbody) {
        set phaseangle to getphaseangle(tgtbody).
    }
    set kuniverse:timewarp:warp to 0.
    wait until kuniverse:timewarp:issettled.
    local transfer is node(time:seconds, 0, 0, dv).
    add transfer.
    local transfertime is time:seconds + burntime(transfer).
    remove transfer.
    executemnv(transfertime, 0, 0, dv).
}
// tranferpls(mun).
