@lazyGlobal off.

// God this script is a mess

deletePath("pid.csv").

clearVecDraws().

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

lock steering to lookDirUp(-shipdock:portfacing:vector, up:forevector). // Ironically `up` in this case means sideways 



// I hope I never have to touch vectors ever again




// PID controller part

// PID controller for y axis
local ykp is 1.
local yki is 0.
local ykd is 0.75.

local ypid is pidLoop(ykp, yki, ykd, -1, 1).
set ypid:setpoint to 0.

// PID controller for x axis
local xkp is 1.
local xki is 0.
local xkd is 0.75.

local xpid is pidLoop(xkp, xki, xkd, -1, 1).
set xpid:setpoint to 0.

lock rotatedDock to shipdock:nodePosition * -ship:facing.

local dockVector is vecDraw(
    V(0,0,0),
    { return shipdock:nodePosition. },
    rgb(1,0,1),
    "Dock is this way",
    1.0,
    true,
    0.2,
    true,
    true
).

function pidreadouts {
    clearScreen.
    print "Node y position: " + rotatedDock:y.
    print "Node x position: " + rotatedDock:x.
    print "Node z position: " + rotatedDock:z.
    print "-------- y PID loop -------".
    print "y PID loop error: " + ypid:error.
    print "y PID loop output: " + ypid:output.

    print "y P: " + ypid:pterm.
    print "y I: " + ypid:iterm.
    print "y D: " + ypid:dterm.

    print "-------- x PID loop -------".
    print "x PID loop error: " + xpid:error.
    print "x PID loop output: " + xpid:output.

    print "x P: " + xpid:pterm.
    print "x I: " + xpid:iterm.
    print "x D: " + xpid:dterm.

    print "Sample: " + i.
}

function logpiddata {
    parameter pid.
    local elapsedtime is time:seconds - startime.
    log elapsedtime + "," + pid:input + "," + pid:output to pid.csv.
}

local i is 0.

local samplecount is 2000.
local startime is time:seconds.

until i = samplecount {
    if mydock:haspartner { break. }
    ypid:update(time:seconds, rotatedDock:y).
    xpid:update(time:seconds, rotatedDock:x).
    set ship:control:starboard to -xpid:output.
    set ship:control:top to -ypid:output.
    logpiddata(xpid).
    pidreadouts().
    
    // This massive if statement checks if the two ships are lined up and their difference in velocity is
    // less than 0.25 m/s
    if abs(rotatedDock:y) < 0.1 and
    abs(rotatedDock:x) < 0.1 and 
    abs(ship:velocity:orbit:mag - shipdock:ship:velocity:orbit:mag) < 0.25 {
        set ship:control:fore to 0.1. // I hope this wont cause any issues.
    }

    // set i to i + 1.
    wait 0.
}

set ship:control:starboard to 0.
set ship:control:top to 0.
set ship:control:fore to 0.
print "Done!".
clearVecDraws().
