declare parameter hLanding.
// height from which to constant descend, and desired velocity.
set hLanding to 1000.
set vLanding to -3.
set g to 5.
set maxAlt to 0.
set maxRocketA to maxThrust/mass.
set a to maxRocketA - g.
set h to hLanding.
set vFinal to vLanding.
set v0 to verticalspeed.
set x0 to 0-((vFinal+verticalspeed)/2)*((vFinal-verticalspeed)/a).
set pT to missiontime.
set pV to v0.
set pErr to 0.
set errInt to 0.
set desiredSpeed to 0-sqrt(V0^2+2*a*(alt:radar-h-x0)).
set status to 1.
until status = 0{
	// PID control parameters.
	set P to -5.
	set I to -0.0001.
	set D to -0.3.
    set pro to velocity:surface.
    lock retro to V(0-pro:x, 0-pro:y, 0-pro:z).
    set steering to retro.
    set desiredSpeed to vFinal.
    if alt:radar > h
    {
            set desiredSpeed to 0-sqrt(V0^2+2*a*(alt:radar-h-x0)).
    }.
    // if desiredSpeed is greater, that means it's going up too much. we want to go down no slower than vFinal.
    if desiredSpeed > vFinal{ set desiredSpeed to vFinal.}.
    print desiredSpeed.
    set err to verticalSpeed - desiredSpeed.
    wait 0.01.
    set dT to missiontime - pT.
    set pT to missiontime.
    print "dT " + dT.
    set dErr to (err-pErr)/dT.
    set errInt to errInt + err*dT.
    set controlA to P*err + I*errInt + D*dErr.
    if alt:radar > h{ set controlA to controlA + a.}.
   
    set th to (controlA+g)/(maxThrust/mass).
    if th > 1
    {
            set th to 1.
            set errInt to errInt - err*dT.
    }.
    if th < 0
    {
            set th to 0.
            set errInt to errInt - err*dT.
    }.
   lock throttle to th.
}.