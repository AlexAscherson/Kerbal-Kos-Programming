/////////////////////////////////////////////////////////////////////////////
// Rendezvous with target
/////////////////////////////////////////////////////////////////////////////
// Maneuver close to another vessel orbiting the same body.
/////////////////////////////////////////////////////////////////////////////
    copy core_functions from 0.
    run core_functions.

    copy inc2 from 0.
    run inc2.
        
    //copy execute_node from 0.
    //run execute_node.

    copy hoffman_node from 0.
    run hoffman_node.

   // copy dock from 0.
   // run dock.
    copy dock_lib from 0.
    run dock_lib.

  //  copy approach from 0.
  //  run approach.
   

  function match_velocites_with_target{
  /////////////////////////////////////////////////////////////////////////////
  // Match velocity with target
  /////////////////////////////////////////////////////////////////////////////
  // Cancel most velocity with respect to target. Any residual speed will be
  // small (typically < 1 m/s) and pointed directly at the target.
  /////////////////////////////////////////////////////////////////////////////

  // Don't let unbalanced RCS mess with our velocity
  rcs off.
  sas off.

  // HACK: distinguish between currently-targeted vessel and port using mass > 2 tonnes
  local station is 0.
  //if target:mass < 2 {
 //   set station to target:ship.
  //} else {
    set station to target.
  //}

  local accel is AssertAccel().
  lock vel to (ship:velocity:orbit - station:velocity:orbit).
  rcs on.
  
  lock steering to lookdirup(-vel:normalized, ship:facing:upvector).
  wait until vdot(-vel:normalized, ship:facing:forevector) >= 0.99.
    rcs off.

  Print "Maneuver Braking burn".
  lock throttle to min(vel:mag / accel, 1.0).
  when vel:mag < 3 then {
    lock throttle to min(vel:mag / accel, 0.05).
  }
  wait until vel:mag <= 0.2 and vel:z <= 0.
  unlock throttle.
  set ship:control:pilotmainthrottle to 0.

  // TODO use RCS to cancel remaining dv

  unlock vel.

  lock steering to lookdirup(station:position, ship:facing:upvector).
  wait until vdot(station:position, ship:facing:forevector) >= 0.99.

  unlock steering.
  sas off.

}

function match_velocity_node{
/////////////////////////////////////////////////////////////////////////////
// Match velocities at closest approach.
/////////////////////////////////////////////////////////////////////////////
// Bring the ship to a stop when it meets up with the target. The accuracy
// of this program is limited; it'll get you into roughly the same orbit
// as the target, but fine-tuning will be required if you want to
// rendezvous.
/////////////////////////////////////////////////////////////////////////////
  // Figure out some basics
  local T is time_till_Closest_Approach(ship, target).
  local Vship is velocityat(ship, T):orbit.
  local Vtgt is velocityat(target, T):orbit.
  local Pship is positionat(ship, T) - body:position.
  local dv is Vtgt - Vship.

  // project dv onto the radial/normal/prograde direction vectors to convert it
  // from (X,Y,Z) into burn parameters. Estimate orbital directions by looking
  // at position and velocity of ship at T.
  local r is Pship:normalized.
  local p is Vship:normalized.
  local n is vcrs(r, p):normalized.
  local sr is vdot(dv, r).
  local sn is vdot(dv, n).
  local sp is vdot(dv, p).

  // figure out the ship's braking time
  local accel is AssertAccel().
  local dt is dv:mag / accel.

  // Time the burn so that we end thrusting just as we reach the point of closest
  // approach. Assumes the burn program will perform half of its burn before
  // T, half afterward
  add node(T, sr, sn, sp).
}

function AssertAccel{
  //parameter prefix.

  local accel is ship:availablethrust / ship:mass. // kN over tonnes; 1000s cancel

  if accel <= 0 {
    Print "ENGINE FAULT - RESUME CONTROL".
    //wait 5.
    //reboot.
  } else {
    return accel.
  }
}


if ship:body <> target:body {
  Print "Rendezvous Target outside of SoI".
  //wait 5.
  //reboot.
}

function rendevous_transfer_to_target{
  print "Rendezvous -transfer_to_target".
  local accel is AssertAccel().
  local approachT is time_till_Closest_Approach(ship, target).
  local approachX is (positionat(target, approachT) - positionat(ship, approachT)):mag.

  // Perform Hohmann transfer if necessary
  if target:position:mag > 25000 and approachX > 25000 {
    local ri is abs(obt:inclination - target:obt:inclination).

    // Align if necessary
    if ri > 0.1 {
      print "Rendezvous - Alignment burn".
      set_inc_lan(target:orbit:inclination, target:orbit:LAN).
      execute_node().
    }

    get_hoffman_node().

    if check_if_next_node() = false {
      print "Rendezvous, Transfer to phasing orbit".
      node_change_apsis("a",target:altitude * 1.666).
      execute_node().
      node_change_apsis("p",target:altitude * 1.666).
      execute_node().
      get_hoffman_node().
    }

    print "Rendezvous Transfer injection burn".
    execute_node().
  }

}

FUNCTION RDV_APPROACH {
  PARAMETER craft, speed.

  LOCK relativeVelocity TO craft:VELOCITY:ORBIT - SHIP:VELOCITY:ORBIT.
  RDV_STEER(craft:POSITION). LOCK STEERING TO craft:POSITION.

  LOCK maxAccel TO SHIP:MAXTHRUST / SHIP:MASS.
  LOCK THROTTLE TO MIN(1, ABS(speed - relativeVelocity:MAG) / maxAccel).

  WAIT UNTIL relativeVelocity:MAG > speed - 0.1.
  LOCK THROTTLE TO 0.
  LOCK STEERING TO relativeVelocity.
}

FUNCTION RDV_AWAIT_NEAREST {
  PARAMETER craft, minDistance.

  UNTIL 0 {
    if target:distance > 2000 {
        set warp to 4.
      } else {
        set warp to 0.
    }
    SET lastDistance TO craft:DISTANCE.
    WAIT 0.1.
    IF craft:distance > lastDistance OR craft:distance < minDistance { 
      set warp to 0.
      BREAK. }
  }
}

FUNCTION RDV_STEER {
  PARAMETER vector.

  LOCK STEERING TO vector.
  WAIT UNTIL VANG(SHIP:FACING:FOREVECTOR, vector) < 2.
}

function rendevous_approach{

  // Match velocity at closest approach
  // TODO make node_vel_tgt more accurate and use it here (currently only used for steering guidance)
  local accel is AssertAccel().
  set approachT to time_till_Closest_Approach(ship, target).
  local aprVship is velocityat(ship, approachT):orbit.
  local aprVtgt is velocityat(target, approachT):orbit.
  local brakingT is (aprVtgt - aprVship):mag / accel.
  sas off.
 // match_velocity_node().

  //lock steering to lookdirup(nextnode:deltav, ship:facing:topvector).
  //wait until vdot(nextnode:deltav:normalized, ship:facing:vector) > 0.99.
  //unlock steering.
 // remove nextnode.
  lock steering to retrograde.
  print "Warping Closer.".
 
  warpto(time:seconds+(ship:orbit:period/3)).  // This works?
  print "Awaiting Nearest Approach".
  RDV_AWAIT_NEAREST(target, 200).

  //sas on.
  match_velocites_with_target().
  print "Matching Velocities".
  if target:distance > 500 {
    print "Approaching".
    RDV_APPROACH(target,5).
    print "Waiting for Nearest".
    RDV_AWAIT_NEAREST(target, 200).
    print "Matching Velocities".
    match_velocites_with_target().
  }
  
  sas off.
 
  //approach_target().
 // wait until target:position:mag < 1000.
 // dock().

}