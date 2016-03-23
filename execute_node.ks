function calculate_mnv_time{
  parameter dv.
  set ens to list().
  ens:clear.
  set ens_thrust to 0.
  set ens_isp to 0.
  list engines in myengines.
  for en in myengines {
    if en:ignition = true and en:flameout = false {
      ens:add(en).
    }
  }
  for en in ens {
    set ens_thrust to ens_thrust + en:availablethrust.
    set ens_isp to ens_isp + en:isp.
  }
  if ens_thrust = 0 or ens_isp = 0 {
    notify("No engines available!").
    return 0.
  }
  else {
    local f is ens_thrust * 1000.  // engine thrust (kg * m/s²)
    local m is ship:mass * 1000.        // starting mass (kg)
    local e is constant():e.            // base of natural log
    local p is ens_isp/ens:length.               // engine isp (s) support to average different isp values
    local g is ship:orbit:body:mu/ship:obt:body:radius^2.    // gravitational acceleration constant (m/s²)
    return g * m * p * (1 - e^(-dv/(g*p))) / f.
  }
}

function execute_node{
    //we only need to lock throttle once to a certain variable in the beginning of the loop, and adjust only the variable itself inside it

    print "Executing Node".
    set nd to nextnode.

    if deltaVstage() < nd:deltav:mag{
        stage.
    }
    set tset to 0.
    lock throttle to tset.

    set maxa to maxthrust/mass.
    set dob to calculate_mnv_time(nd:deltav:mag).
    print "T+" + round(missiontime)+" Burn duration: " + round(dob) + "s".
    
    sas off.
    rcs off.
    set np to R(0,0,0) * nd:deltav.
    lock steering to nextnode.
    notify("Aligning Ship to burn vector").
    
    WAIT UNTIL VANG(SHIP:FACING:VECTOR, nd:BURNVECTOR) < 2.
    Print "Warp to burn".
    LOCAL startTime IS TIME:SECONDS + nd:ETA - calculate_MNV_TIME( nd:BURNVECTOR:MAG)/2.
    WARPTO(startTime - 30). 
    print "T+" + round(missiontime) + " Orbital burn start " + round(nd:eta) + "s before apoapsis.".
    WAIT UNTIL TIME:SECONDS >= startTime.
    set done to False.
    set dv0 to nd:deltav. //initial deltav
    until done
    {   
        lock steering to nextnode. 
        set max_acc to ship:maxthrust/ship:mass.  //recalculate current max_acceleration, as it changes while we burn through fuel

        set tset to min(nd:deltav:mag/max_acc, 1). //throttle is 100% until there is less than 1 second of time left to burn - when there is less than 1 second - decrease the throttle linearly

        if vdot(dv0, nd:deltav) < 0         //here's the tricky part, we need to cut the throttle as soon as our nd:deltav and initial deltav start facing opposite directions - this check is done via checking the dot product of those 2 vectors
        {
            print "End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
            lock throttle to 0.
            break.
        }
        if nd:deltav:mag < 0.1   //we have very little left to burn, less then 0.1m/s
        {
            print "Finalizing burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
            wait until vdot(dv0, nd:deltav) < 0.5. //we burn slowly until our node vector starts to drift significantly from initial vector this usually means we are on point
            lock throttle to 0.
            print "End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
            set done to True.
        }
    }
    unlock steering.
    unlock throttle.
    wait 1.
    remove nd. 
    SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.     //set throttle to 0 just in case.
}