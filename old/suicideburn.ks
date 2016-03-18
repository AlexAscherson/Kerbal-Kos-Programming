// g0-Accelleration of gravity at surface of body
set GM to ship:body:mu.
set R to ship:body:radius. 
set g0 to GM/(R^2).
print "Gravatation acceleration at surface(mp/s): " + g0. 
// a - Max acelleration
set a to (maxthrust/mass)-g0.
Print "Max acceleration: " + a.
// set vi to SHIP:VERTICALSPEED.
// Time to reduce velocity to 0 at full speed 
set sbt to (SHIP:VERTICALSPEED/a).
print "Time to reduce velocity at full speed: " + sbt.
set SBT2 to (sbt*sbt).
set SBT3 to (0.5*sbt2).
// H - distance travelled ie altiude to start burn
set h1 to (SHIP:VERTICALSPEED * sbt) - (sbt3*a).
print h1.

set a0 to SHIP:VERTICALSPEED*SHIP:VERTICALSPEED.
set h2 to ((SHIP:VERTICALSPEED*(SHIP:VERTICALSPEED/a))-(0.5*(a0/(a*a)))*a).
set h4 to (0.5*((a0)/a)).

print h2.
print h4.

//Change Periapsis to lowest safe

if body:name = "Kerbin" {set maxAlt to 6700.}.
if body:name = "Mun" {set maxAlt to 6200.}.
if body:name = "Minmus" {set maxAlt to 5725.}.

// LOCK STEERING TO (-1) * SHIP:VELOCITY:SURFACE.

// height from which to constant descend, and desired velocity.
set hLanding to 40.
set vLanding to -3.

set g to 5.
set maxAlt to 0.

set maxRocketA to maxThrust/mass.
set a to maxRocketA - g.
 
lock pro to velocity:surface.
lock retro to V(0-pro:x, 0-pro:y, 0-pro:z).
lock steering to retro.
        
lock throttle to 0.
print "Under useful radar altitude, using radar altimeter.".
set h to hLanding.
set vFinal to vLanding.
       
wait until 0-((vFinal+verticalspeed)/2)*((vFinal-verticalspeed)/a) > alt:radar-h.
 
set v0 to verticalspeed.
set x0 to 0-((vFinal+verticalspeed)/2)*((vFinal-verticalspeed)/a).
 
set pT to missiontime.
set pV to v0.
set pErr to 0.
set errInt to 0.
 
set desiredSpeed to 0-sqrt(V0^2+2*a*(alt:radar-h-x0)).
 
lock throttle to 1.
 
set land to "LANDED".
set splash to "SPLASHED".


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
    set dT to missiontime - pT.
    set pT to missiontime.
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
set nd to node(time:seconds + sbt, 0, 0, 0).
add nd.
