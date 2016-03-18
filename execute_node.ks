function execute_node{
    //we only need to lock throttle once to a certain variable in the beginning of the loop, and adjust only the variable itself inside it

    print "Executing Node".
    set nd to nextnode.
    set tset to 0.
    lock throttle to tset.

    set maxa to maxthrust/mass.
    set dob to nd:deltav:mag/maxa.     // incorrect: should use tsiolkovsky formula
    print "T+" + round(missiontime)+" Burn duration: " + round(dob) + "s".
    notify("Warping to 1 min before burn.").
    if ((nd:eta - dob/2)-60)<60{
      warpfor((nd:eta - dob/2)-60).
    }
    sas off.
    rcs off.
    set np to R(0,0,0) * nd:deltav.
    lock steering to nextnode.
    notify("Aligning Ship to burn vector").
    wait until abs(np:direction:pitch - facing:pitch) < 1.5 and abs(np:direction:yaw - facing:yaw) < 0.5.
    Print "warp to burn".
    warpfor(nd:eta - dob/2).
    print "T+" + round(missiontime) + " Orbital burn start " + round(nd:eta) + "s before apoapsis.".

    set done to False.
    //initial deltav
    set dv0 to nd:deltav.
    until done
    {   
        lock steering to nextnode.
        //recalculate current max_acceleration, as it changes while we burn through fuel
        set max_acc to ship:maxthrust/ship:mass.

        //throttle is 100% until there is less than 1 second of time left to burn - when there is less than 1 second - decrease the throttle linearly
        set tset to min(nd:deltav:mag/max_acc, 1).

        //here's the tricky part, we need to cut the throttle as soon as our nd:deltav and initial deltav start facing opposite directions - this check is done via checking the dot product of those 2 vectors
        if vdot(dv0, nd:deltav) < 0
        {
            print "End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
            lock throttle to 0.
            break.
        }

        //we have very little left to burn, less then 0.1m/s
        if nd:deltav:mag < 0.1
        {
            print "Finalizing burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
            //we burn slowly until our node vector starts to drift significantly from initial vector
            //this usually means we are on point
            wait until vdot(dv0, nd:deltav) < 0.5.

            lock throttle to 0.
            print "End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
            set done to True.
        }
    }
    unlock steering.
    unlock throttle.
    wait 1.
    remove nd. //we no longer need the maneuver node
    //set throttle to 0 just in case.
    SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
}