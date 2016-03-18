


set aF to APOAPSIS + body:radius. // apo/peri/semimajor axis of final, circular orbit
set aI to obt:semimajoraxis. //semimajor axis of starting orbit
set PeI to 100000+body:radius.
set VPeI to sqrt(body:mu * (2/PeI-1/aI)).
set aT to (PeI+aF)/2. //semimajor axis of transfer orbit
set VPeT to sqrt(body:mu * (2/PeI-1/aT)).
set dvIT to VPeT+VPeI.

SET mn TO NODE(APOAPSIS, 0, 0, dvIT).
ADD mn.

print dvIT.
	

//We calculate our velocity at ap first
//  This is assuming that we the manuver is executed at apoapsis.  otherwise we should set r to altitude (radial not actual?)
//Remember ap and pe are just parts of r in the Vis a vis equation.

// Distance from centre - This is critical.  Use this to calculate velocity at any given point on the orbit (alt)
//set rNow to SHIP:ALTITUDE + body:radius.


// CALCULATING V FOR CURRENT ORBIT

//We can calculate r at different points along the orbit.
set r to SHIP:ALTITUDE + body:radius.
set rAp to APOAPSIS + body:radius.
set rPE to PERIAPSIS + body:radius.

// The SMA of our current orbit
set sma to obt:semimajoraxis.
// Body Gravatational parameter
set Gm to bodu:mu.

// Current Velocity
set v to sqrt(Gm( * (2/r -1/sma)).
// v at Apogee and Perigee
set vAp to sqrt(Gm( * (2/rAp -1/sma)).
set vPe to sqrt(Gm( * (2/rPE -1/sma)).	

// Calculating V for a Different orbit

//eg. Circularise to AP - Calc V at current ap, 

// 1. Set the ap and pe of the new orbit
set rTargetAp to rAp.
set rTargetPe to rAp.

// SMA of desired orbit
set smaTarget to (rTargetAp + rTargetPe)/2.

// V at AP in new orbit 
set vTargetAp to sqrt(Gm( * (2/rTargetAp -1/smaTarget)).
	
// V at pe in new orbit 
set vTargetPe to sqrt(Gm( * (2/rTargetPe -1/smaTarget)).

//Deltav change needed to raise Pe to Ap - Prograde at Ap

set dvCircAp to (vTargetAp - vAp).

//Deltav change needed to lower Ap to pe - Retro at Pe

set dvCircPe to (vPe - vTargetPe).

// Then we calculate the velocity of our desired orbit

set targetapoapsis to 100000 + body:radius.
set targetperiapsis to 100000 + body:radius.
// Target SMA 
set targetsma to (targetperiapsis/targetapoapsis)/2. 

set vTarget to sqrt(Gm( * 2/))
// Delta v (Velocity change) is reached by subtrating the two



