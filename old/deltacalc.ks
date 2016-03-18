// CALCULATING V FOR CURRENT ORBIT

//r = Velocity
//We can calculate r at different points along the orbit.
set r to SHIP:ALTITUDE + body:radius.
set rAp to APOAPSIS + body:radius.
set rPE to PERIAPSIS + body:radius.
// The Semi Major Axis of our current orbit
set sma to obt:semimajoraxis.
// Local Body Gravatational parameter
set Gm to body:mu.

// Current Velocity
set v to sqrt(Gm * (2/r -1/sma)).
// v at Apogee and Perigee
set vAp to sqrt(Gm * (2/rAp -1/sma)).
set vPe to sqrt(Gm * (2/rPE -1/sma)).	

// Calculating V for a Different orbit

// Hoffman transer


//eg. Circularise

function Circularise {
  parameter rTargetA.
  parameter rTargetP.

  // SMA of desired orbit
  set sma_Target to (rTargetA + rTargetP)/2.
  // V at AP in new orbit 
  set vTargetA to sqrt(Gm * (2/rTargetAp -1/sma_Target)).	
  // V at pe in new orbit 
  set vTargetP to sqrt(Gm * (2/rTargetPe -1/sma_Target)).

  if rAp = rTargetA {
  	PRINT "We are raising Pe". 
  	set dvCircA to (vTargetAp - vAp).
 	  PRINT dvCircA + " DV needed to raise pe to " + rTargetP.
	}
  if rPE = rTargetP {
  	PRINT "We are lowering Ap".
  	set dvCircP to (vTargetP - vPe).
  	PRINT dvCircP + " DV needed to lower Ap to " + rTargetA.
    }
}

// 1. Circularize at ap
set rTargetAp to rAp.
set rTargetPe to rAp.
Circularise(rTargetAp, rTargetPe).

// 2. Circularize at pe
set rTargetAp to rPE.
set rTargetPe to rPE.
Circularise(rTargetAp, rTargetPe).




// SMA of desired orbit
//set smaTarget to (rTargetAp + rTargetPe)/2.
// V at AP in new orbit 
//set vTargetAp to sqrt(Gm * (2/rTargetAp -1/smaTarget)).	
// V at pe in new orbit 
//set vTargetPe to sqrt(Gm * (2/rTargetPe -1/smaTarget)).

//Deltav change needed to raise Pe to Ap - Prograde at Ap

//set dvCircAp to (vTargetAp - vAp).



//Deltav change needed to lower Ap to pe - Retro at Pe

//set dvCircPe to ( vTargetPe - vPe ).

//Print "v v at ap and v at pe".
//PRINT v.
//PRINT vAp.
//PRINT vPe.
//PRINT "DV change to Circularise at ap and at pe".
//PRINT dvCircAp.
//PRINT dvCircPe.
//PRINT dvCircAp + "DV change to Circularise at ap".