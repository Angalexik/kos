runPath("0:/boot/boot.ks").

wait until ship:loaded.
wait until ship:unpacked.

runPath("hover.ks").
