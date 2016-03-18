// CALCULATING V FOR CURRENT ORBIT
DECLARE PARAMETER circmode.
//ALTITUDE - Current, AP, PE
set r to SHIP:ALTITUDE + body:radius.
set rAp to APOAPSIS + body:radius.
set rPe to PERIAPSIS + body:radius.
// The Semi Major Axis of our current orbit
set sma to obt:semimajoraxis.
// Local Body Gravatational parameter
set Gm to body:mu.
// v at Apogee and Perigee
set vAp to sqrt(Gm * (2/rAp -1/sma)).
set vPe to sqrt(Gm * (2/rPE -1/sma)).	
// 1. Circularize at ap
if circmode = "a" {
  PRINT "We are raising Pe".
  //Set target AP and PE to Current AP 
  set rTargetAp to rAp.
  set rTargetPe to rAp. 
  // Calulate SMA of target orbit
  set sma_Target to (rTargetAp + rTargetPe)/2.
  //Calculate new Velocity at Ap 
  set vTargetA to sqrt(Gm * (2/rTargetAp -1/sma_Target)).
  //Delta v change between the two orbits.
  set dvCirc to (vTargetA - vAp).
  PRINT dvCirc + " DV needed to raise pe to " + rTargetAp.
  set timetonode to (ETA:APOAPSIS + time:seconds).
}
// 2. Circularize at pe
if circmode = "p" {
  PRINT "We are lowering Ap".
  set rTargetPe to rPe.
  set rTargetAp to rPe.
  set sma_Target to (rTargetAp + rTargetPe)/2.
  set vTargetP to sqrt(Gm * (2/rTargetPe -1/sma_Target)).
  set dvCirc to (vTargetP - vPe).
  PRINT dvCirc + " DV needed to lower Ap to " + rTargetPe.
  set timetonode to (ETA:PERIAPSIS + time:seconds).
}
// Node
SET mn TO NODE(timetonode, 0, 0, dvCirc).
ADD mn.