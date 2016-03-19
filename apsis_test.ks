
function node_change_apsis{
    parameter mode is "a". 
    parameter targetalt is 75000.
    //set targetalt to targetalt*1000.
    set rAp to APOAPSIS + body:radius.
    set rPe to PERIAPSIS + body:radius.
    set rTargetAp to APOAPSIS + body:radius.
      if mode = "a" {
        PRINT "We are changing the Ap".
        set vPe to sqrt(body:mu * (2/rPE -1/obt:semimajoraxis)). 
        set rTargetAp to targetalt + body:radius.
        set sma_Target to (rTargetAp + (PERIAPSIS + body:radius))/2.
        set vTargetP to sqrt(body:mu * (2/(PERIAPSIS + body:radius) -1/sma_Target)).
        set dv to (vTargetP - vPe).
        PRINT dv + " DV needed to changet Ap to " + targetalt.
        set timetonode to (ETA:PERIAPSIS + time:seconds).
      }
      if mode = "p" {
        PRINT "We are changing the Pe".
        set vAp to sqrt(body:mu * (2/rAp -1/obt:semimajoraxis)).
        //Set target AP and PE to Current AP 
        set rTargetPe to targetalt + body:radius.
        // Calulate SMA of target orbit
        set sma_Target to ((APOAPSIS + body:radius) + rTargetPe)/2.
        //Calculate new Velocity at Ap 
        set vTargetA to sqrt(body:mu * (2/(APOAPSIS + body:radius) -1/sma_Target)).
        //Delta v change between the two orbits.
        set dv to (vTargetA - vAp).
        PRINT dv + " DV needed to raise pe to " + targetalt.
        set timetonode to (ETA:APOAPSIS + time:seconds).
      }
      // Node
      print "target Alt: " +targetalt.
    SET mn TO NODE(timetonode, 0, 0, dv).
    ADD mn.
}

node_change_apsis("a", 100004).