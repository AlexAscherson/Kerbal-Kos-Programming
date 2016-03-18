function Calc_circ_burn {
  parameter rTargetA.
  parameter rTargetP.

  // SMA of desired orbit
  set sma_Target to (rTargetA + rTargetP)/2.
  // V at AP in new orbit 
  set vTargetA to sqrt(Gm * (2/rTargetAp -1/sma_Target)).	
  // V at pe in new orbit 
  set vTargetP to sqrt(Gm * (2/rTargetPe -1/sma_Target)).

  if distance_from_centre_Ap = rTargetA {
  	PRINT "We are raising Pe". 
  	set dvCircA to (vTargetA - vAp).
 	  PRINT dvCircA + " DV needed to raise pe to " + rTargetP.
	}
  if distance_from_centre_Pe = rTargetP {
  	PRINT "We are lowering Ap".
  	set dvCircP to (vTargetP - vPe).
  	PRINT dvCircP + " DV needed to lower Ap to " + rTargetA.
  }
}

function Circ_with_node{

  // Returns node with 
  PARAMETER circmode is "a".
  //We can calculate r at different points along the orbit.
  set distance_from_centre to SHIP:ALTITUDE + body:radius.
  //Or at certain points.
  set distance_from_centre_Ap to APOAPSIS + body:radius.
  set distance_from_centre_Pe to PERIAPSIS + body:radius.
  // The Semi Major Axis of our current orbit
  set sma to obt:semimajoraxis.
  // Local Body Gravatational parameter
  set Gm to body:mu.
  // v at Apogee and Perigee
  set vAp to sqrt(Gm * (2/distance_from_centre_Ap -1/sma)).
  set vPe to sqrt(Gm * (2/distance_from_centre_Pe -1/sma)). 

  // Calculating V for a Different orbit

  // 1. Circularize at ap
  if circmode = "a" {
    set rTargetAp to distance_from_centre_Ap.
    set rTargetPe to distance_from_centre_Ap.
    Calc_circ_burn(rTargetAp, rTargetPe).
    set burn_eta to (ETA:APOAPSIS+ time:seconds).
    set burn_dv to dvCircA.
  }
  // 2. Circularize at pe
  if circmode = "p" {
    set rTargetAp to distance_from_centre_Pe.
    set rTargetPe to distance_from_centre_Pe.
    Calc_circ_burn(rTargetAp, rTargetPe).
    set burn_eta to (ETA:PERIAPSIS+ time:seconds).
    set burn_dv to dvCircP.
  }

  SET mn TO NODE(burn_eta, 0, 0, burn_dv).
  ADD mn.

}