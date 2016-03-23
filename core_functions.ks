
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
  print "Aligning Craft.". 
  until abs(steering:pitch - facing:pitch) < 0.15 and abs(steering:yaw - facing:yaw) < 0.15{ //Started as wait untill in case of bugs..
    
    lock steering to target_alignment.  
  }
}

function check_staging {
  UNTIL maxthrust > 0 {
    stage.
    wait 1.
  }
}

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
      PRINT dv + " DV needed to changet Ap to " + rTargetAp.
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
      PRINT dv + " DV needed to raise pe to " + rTargetpe.
      set timetonode to (ETA:APOAPSIS + time:seconds).
    }
    // Node
    print "target Alt: " +targetalt.
  SET mn TO NODE(timetonode, 0, 0, dv).
  ADD mn.
}

function decouple_port{
  parameter portname.
  for port in ship:dockingports{
    if port:tag = portname or port:title = portname{
      print "port found".
      print port.
      if port:state = "PreAttached"{
        print "should undock".
        port:GETMODULE("ModuleDockingNode"):doevent("decouple node").
      }
    }
  }
  check_staging().
}

FUNCTION deltaVstage{   
    // fuel name list
    LOCAL fuels IS list().
    fuels:ADD("LiquidFuel").
    fuels:ADD("Oxidizer").
    fuels:ADD("SolidFuel").
    fuels:ADD("MonoPropellant").

    // fuel density list (order must match name list)
    LOCAL fuelsDensity IS list().
    fuelsDensity:ADD(0.005).
    fuelsDensity:ADD(0.005).
    fuelsDensity:ADD(0.0075).
    fuelsDensity:ADD(0.004).

    // initialize fuel mass sums
    LOCAL fuelMass IS 0.

    // calculate total fuel mass
    FOR r IN STAGE:RESOURCES
    {
        LOCAL iter is 0.
        FOR f in fuels
        {
            IF f = r:NAME
            {
                SET fuelMass TO fuelMass + fuelsDensity[iter]*r:AMOUNT.
            }.
            SET iter TO iter+1.
        }.
    }.  

    // thrust weighted average isp
    LOCAL thrustTotal IS 0.
    LOCAL mDotTotal IS 0.
    LIST ENGINES IN engList. 
    FOR eng in engList
    {
        IF eng:IGNITION
        {
            LOCAL t IS eng:maxthrust*eng:thrustlimit/100. // if multi-engine with different thrust limiters
            SET thrustTotal TO thrustTotal + t.
            IF eng:ISP = 0 SET mDotTotal TO 1. // shouldn't be possible, but ensure avoiding divide by 0
            ELSE SET mDotTotal TO mDotTotal + t / eng:ISP.
        }.
    }.
    IF mDotTotal = 0 LOCAL avgIsp IS 0.
    ELSE LOCAL avgIsp IS thrustTotal/mDotTotal.

    // deltaV calculation as Isp*g0*ln(m0/m1).
    LOCAL deltaV IS avgIsp*9.81*ln(SHIP:MASS / (SHIP:MASS-fuelMass)).

    RETURN deltaV.
}

function target_nearest_craft{

  list targets in tlist.
  set minDist to 5. // don't pick something closer than 5 meters.
  set smallestDist to 999999999999.
  set nearestVessel to ship. // so at least it's something.
  for t in tlist {
      set thisDist to t:distance.
      if thisDist < smallestDist and thisDist > minDist {
          set smallestDist to thisDist.
          set nearestVessel to t.
      }.
  }. 

  if nearestVessel = ship {
      print "Nope, no other vessels exist".
  } else {
    set target to nearestVessel.
  }

}

function check_if_next_node {
  local sentinel is node(time:seconds + 9999999999, 0, 0, 0).
  add sentinel.
  local nn is nextnode.
  remove sentinel.
  if nn = sentinel {
    return false.
  } else {
    return true.
  }
}

function utilClosestApproach {
  parameter ship1.
  parameter ship2.

  local Tmin is time:seconds.
  local Tmax is Tmin + 2*ship1:obt:period.
  local T is 0.

  // Binary search for time of closest approach
  local N is 0.
  until N > 64 {
    local dt is (Tmax - Tmin) / 4.
    set T to  Tmin + (2*dt).
    local Tl is Tmin - dt.
    local Th is Tmax + dt.

    local Rl is (positionat(ship1, Tl)) - (positionat(ship2, Tl)).
    local Rh is (positionat(ship1, Th)) - (positionat(ship2, Th)).

    if Rh:mag < Rl:mag {
      set Tmin to T.
    } else {
      set Tmax to T.
    }

    set N to N + 1.
  }

  return T.
}