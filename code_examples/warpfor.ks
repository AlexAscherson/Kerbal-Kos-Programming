function warpfor{

    declare parameter dt.
    // warp    (0:1) (1:5) (2:10) (3:50) (4:100) (5:1000) (6:10000) (7:100000)
    // min alt        atmo   atmo   atmo    120k     240k      480k       600k
    // time:seconds also works before takeoff! Unlike missiontime.
    if ship:altitude > 9000 {
        set t1 to time:seconds + dt.
        if dt < 0 {
            print "T+" + round(missiontime) + " Warning: wait time " + round(dt) + " is in the past.".
        }
        set oldwp to 0.
        set oldwarp to warp.
        until time:seconds >= t1 {
            set rt to t1 - time:seconds.       // remaining time
            set wp to 0.
            if rt > 5      { set wp to 1. }
            if rt > 10     { set wp to 2. }
            if rt > 50     { set wp to 3. }
            if rt > 100    { set wp to 4. }
            if rt > 1000   { set wp to 5. }
            if rt > 10000  { set wp to 6. }
            if rt > 100000 { set wp to 7. }
            if wp <> oldwp or warp <> wp {
                set warp to wp.
                wait 0.1.
                if wp <> oldwp or warp <> oldwarp {
                    print "T+" + round(missiontime) + " Warp " + warp + "/" + wp + ", remaining wait " + round(rt) + "s".
                }
                set oldwp to wp.
                set oldwarp to warp.
            }
            wait 0.1.
        }
    }
}