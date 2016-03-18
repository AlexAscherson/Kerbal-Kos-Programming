
//Manifest.

copy get_safe_orbit from 0.
run get_safe_orbit.
copy circ from 0.
run circ.
copy time_warp from 0.
run time_warp.
copy execute_node from 0.
run execute_node.

copy establish_orbit from 0.
run establish_orbit.

function load_function{
 PARAMETER name.
  wait 1.
  COPY name FROM 0.
  wait 1.
}

FUNCTION NOTIFY {
  PARAMETER message.
  HUDTEXT("kOS: " + message, 5, 2, 50, WHITE, false).
  print "!!! ALERT !!!! "+message. 
}

// Manuever and Navigation

function alt_true{
  parameter at_altitude is altitude.
  parameter at_terrain_height is ship:geoposition:terrainheight.
  return at_altitude - at_terrain_height.
}

function align_ship{
  //Takes Steering as param
  sas off.
  parameter target_alignment.
  lock steering to target_alignment.  
  until abs(steering:pitch - facing:pitch) < 0.15 and abs(steering:yaw - facing:yaw) < 0.15{ //Started as wait untill in case of bugs..
    print "Aligning Craft.".
    lock steering to target_alignment.  
  }.
}

function node_change_apsis{
    parameter mode is "a". 
    parameter targetalt is 75000.
    //set targetalt to targetalt*1000.
    set rAp to APOAPSIS + body:radius.
    set rPe to PERIAPSIS + body:radius.
    set rTargetAp to APOAPSIS + body:radius.
      if mode = "a" {
        PRINT "We are changing Ap".
        set vPe to sqrt(body:mu * (2/rPE -1/obt:semimajoraxis)). 
        set rTargetAp to targetalt + body:radius.
        set sma_Target to (rTargetAp + (PERIAPSIS + body:radius))/2.
        set vTargetP to sqrt(body:mu * (2/(PERIAPSIS + body:radius) -1/sma_Target)).
        set dv to (vTargetP - vPe).
        PRINT dv + " DV needed to changet Ap to " + rTargetAp.
        set timetonode to (ETA:PERIAPSIS + time:seconds).
      }
      if mode = "p" {
        PRINT "We are raising Pe".
        set vAp to sqrt(body:mu * (2/rAp -1/obt:semimajoraxis)).
        //Set target AP and PE to Current AP 
        set rTargetPe to targetalt + body:radius.
        // Calulate SMA of target orbit
        set sma_Target to ((APOAPSIS + body:radius) + rTargetPe)/2.
        //Calculate new Velocity at Ap 
        set vTargetA to sqrt(body:mu * (2/(APOAPSIS + body:radius) -1/sma_Target)).
        //Delta v change between the two orbits.
        set dv to (vTargetA - vAp).
        PRINT dv + " DV needed to raise pe to " + rTargetpe.
        set timetonode to (ETA:APOAPSIS + time:seconds).
      }
      // Node
    SET mn TO NODE(timetonode, 0, 0, dv).
    ADD mn.
}