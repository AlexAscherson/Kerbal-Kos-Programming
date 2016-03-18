
//Manifest.

copy get_planet_data from 0.
run get_planet_data.

copy circ from 0.
run circ.

copy time_warp from 0.
run time_warp.

copy execute_node from 0.
run execute_node.

copy establish_orbit from 0.
run establish_orbit.


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
  }
}

function node_change_apsis{
  parameter mode is "a". 
  parameter targetalt is 75000.
  //local targetalt to targetalt*1000.
  local rAp is APOAPSIS + body:radius.
  local rPe is PERIAPSIS + body:radius.
  local rTargetAp is APOAPSIS + body:radius.
    if mode = "a" {
      PRINT "We are changing Ap".
      local vPe to sqrt(body:mu * (2/rPE -1/obt:semimajoraxis)). 
      local rTargetAp is targetalt + body:radius.
      local sma_Target is (rTargetAp + (PERIAPSIS + body:radius))/2.
      local vTargetP is sqrt(body:mu * (2/(PERIAPSIS + body:radius) -1/sma_Target)).
      local dv is (vTargetP - vPe).
      PRINT dv + " DV needed to changet Ap to " + rTargetAp.
      local timetonode is (ETA:PERIAPSIS + time:seconds).
    }
    if mode = "p" {
      PRINT "We are raising Pe".
      local vAp is sqrt(body:mu * (2/rAp -1/obt:semimajoraxis)).
      //local target AP and PE to Current AP 
      local rTargetPe is targetalt + body:radius.
      // Calulate SMA of target orbit
      local sma_Target is ((APOAPSIS + body:radius) + rTargetPe)/2.
      //Calculate new Velocity at Ap 
      local vTargetA is sqrt(body:mu * (2/(APOAPSIS + body:radius) -1/sma_Target)).
      //Delta v change between the two orbits.
      local dv is (vTargetA - vAp).
      PRINT dv + " DV needed to raise pe to " + rTargetpe.
      local timetonode is (ETA:APOAPSIS + time:seconds).
    }
    // Node
  set mn TO NODE(timetonode, 0, 0, dv).
  ADD mn.
}