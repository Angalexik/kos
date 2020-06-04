@lazyGlobal off.

deletePath("0:/pid.csv").

local bounds is ship:bounds.
local kp is 0.16943729271897004.
local ki is 1.5930344665755278.
local kd is 0.009010789397936987.

local pid is pidLoop(kp, ki, kd, 0, 1).
set pid:setpoint to 0.

local lastoutput is 0.
local lasttime is time:seconds.

local thrott is 0.
lock throttle to thrott.
lock steering to up.

function setup {
    stage.
    set thrott to 0.7.
    wait until bounds:bottomaltradar > 2.5.
    set thrott to 0.
    gear off.
}

function updatereadouts {
    clearScreen.
    // print pid:output. print lastoutput. print pid:lastsampletime. print time:seconds.
    // local changerate is (pid:output - lastoutput) / (time:seconds - lasttime).
    print "Vertical speed: " + verticalSpeed.
    print "Altitude: " + bounds:bottomaltradar.
    print "Current throttle value: " + pid:output.
    print "PID loop error: " + pid:error.
    // print "PID oscillation: " + changerate + " /s".
    print "P: " + pid:pterm.
    print "I: " + pid:iterm.
    print "D: " + pid:dterm.
    print "Sample: " + i.
    set lastoutput to pid:output.
    set lasttime to pid:lastsampletime.
}

setup().

local i is 0.

local startime is time:seconds.

function recordpiddata {
    local elapsedtime is time:seconds - startime.
    // log elapsedtime + "," + bounds:bottomaltradar + "," + (100) + "," + pid:output to pid.csv.
    log elapsedtime + "," + pid:input + "," + pid:output to pid.csv.
    // print "succesfully recorded data".
}


until i = 5000 {
    if ship:resources[1]:amount < 50 { gear on. }
    if ship:resources[1]:amount < 10 { break. }
    set thrott to pid:update(time:seconds, verticalSpeed).
    updatereadouts().
    recordpiddata().
    wait 0.
    // set i to i + 1.
}

clearScreen.
print "Done".
