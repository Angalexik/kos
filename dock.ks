@lazyGlobal off.
// TODO: Create some sort of PID controller to automate the approach
// Currently this script only makes you face the docking port, however I plan to implement the
// rest of the docking procedure

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

lock steering to lookDirUp(-shipdock:portfacing:vector, shipdock:portfacing:upvector).





// I hope I never have to touch vectors ever again




// PID controller part

// PID controller for y axis
local ykp is 1.
local yki is 0.
local ykd is 0.5.

local ypid is pidLoop(ykp, yki, ykd, -1, 1).
set ypid:setpoint to 0.

// PID controller for z axis
local zkp is 1.
local zki is 0.
local zkd is 0.5.

local zpid is pidLoop(zkp, zki, zkd, -1, 1).
set zpid:setpoint to 0.

// PID controller for x axis
local xkp is 1.
local xki is 0.
local xkd is 0.

local xpid is pidLoop(xkp, xki, xkd, -1, 1).
set xpid:setpoint to 0.

local dockvector is vecDraw(
    V(0,0,0),
    { return shipdock:position. },
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
    print "Node y position: " + shipdock:nodeposition:y.
    print "Node x position: " + shipdock:nodeposition:x.
    print "Node z position: " + shipdock:nodeposition:z.
    print "-------- y PID loop -------".
    print "y PID loop error: " + ypid:error.
    print "y PID loop output: " + ypid:output.

    print "y P: " + ypid:pterm.
    print "y I: " + ypid:iterm.
    print "y D: " + ypid:dterm.

    print "-------- z PID loop -------".
    print "z PID loop error: " + zpid:error.
    print "z PID loop output: " + zpid:output.

    print "z P: " + zpid:pterm.
    print "z I: " + zpid:iterm.
    print "z D: " + zpid:dterm.

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
    ypid:update(time:seconds, shipdock:nodeposition:y).
    xpid:update(time:seconds, shipdock:nodeposition:x).
    zpid:update(time:seconds, shipdock:nodeposition:z).
    // set ship:control:starboard to ypid:output.
    // set ship:control:top to zpid:output * -1.
    logpiddata(zpid).
    pidreadouts().
    set i to i + 1.
    wait 0.001.
}

set ship:control:starboard to 0.
set ship:control:top to 0.
set ship:control:fore to 0.
print "Done!".
clearVecDraws().
