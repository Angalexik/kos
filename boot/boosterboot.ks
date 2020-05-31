core:part:getmodule("kOSProcessor"):doevent("Open Terminal").
clearScreen.
switch to 0.

wait until ship:unpacked.

if alt:radar < 10 { runOncePath("0:/boostback.ks"). }
