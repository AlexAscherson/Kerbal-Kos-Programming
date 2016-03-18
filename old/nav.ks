


//To select a direction that is 20 degrees off from straight up::

LOCK STEERING TO Up + R(20,0,0).
//Changing will rotate craft around N/S navball line 360 degrees turning south first from north. i.e down the 180 deg lat line not . 
// Can accept numbers > 360 and negative numbers. 
LOCK STEERING TO Up + R(0,20,0).

//Changing will rotate craft around N/S navball line 360 degrees turning East to West. i.e down the 180 deg lat line not . 
// Can accept numbers > 360 and negative numbers. 

LOCK STEERING TO Up + R(0,20,0).  // rotate with N at 12'oclock. Positive = Anticlockwise 



function east_for {
  parameter ves.
  return vcrs(ves:up:vector, ves:north:vector).
}

function compass_for {
  parameter ves.
  parameter compass_mode is 1.
  if compass_mode = 1{ 
    set pointing to ves:facing:forevector.
  }
  if compass_mode <> 1{ 
    set pointing to compass_mode.
  }

  local east is east_for(ves).
  local trig_x is vdot(ves:north:vector, pointing).
  local trig_y is vdot(east, pointing).

  local result is arctan2(trig_y, trig_x).

  if result < 0 { 
    return 360 + result.
  } else {
    return result.
  }
}

function pitch_for {
  parameter ves.

  return 90 - vang(ves:up:vector, ves:facing:forevector).
}

function roll_for {
  parameter ves.
  
  if vang(ship:facing:vector,ship:up:vector) < 0.2 { //this is the dead zone for roll when the ship is vertical
    return 0.
  } else {
    local raw is vang(vxcl(ship:facing:vector,ship:up:vector), ves:facing:starvector).
    if vang(ves:up:vector, ves:facing:topvector) > 90 {
      if raw > 90 {
        return 270 - raw.
      } else {
        return -90 - raw.
      }
    } else {
      return raw - 90.
    }
  } 
}.

//Nav comp

function align_ship{

  parameter target_alignment.
  lock steering to target_alignment.

  until abs(target_alignment:pitch - facing:pitch) < 0.15 and abs(target_alignment:yaw - facing:yaw) < 0.15{
    lock steering to target_alignment.
    //Started as wait untill in case of bugs..
  }.
}

function direction_horizon{
  set bearing_temp to ship:BEARING.
  local heading_temp is HEADING(-1*bearing_temp, 0).
  print "ship bearing" + bearing_temp. 
  print "pitch to horizon"+ heading_temp.
  return heading_temp.
}
//set pro_heading to compass_for(SHIP, PROGRADE).
//print pro_heading.
// align_ship(PROGRADE).
print "align ended.".

align_ship(retrograde).
set horizon to direction_horizon().
align_ship (horizon).
wait 5.
//alignmentcheck(PROGRADE).



  
  print "Steering: "+STEERING.
 // print "UP:"+up.
 // print "Direction - Facing: "+ ship:facing. // As a direction

 // print "Steering - facing: "+ (STEERING-ship:facing).
  //print "UP - facing: "+ (UP-ship:facing).
  
  Print "//////////////////////////////".
//  print "Absolute Heading: "+ ship:heading. // absolute heading scaler deg
//  print "Relative Bearing: "+ ship:bearing. // relative heading scaler deg
//  print "Angular Momentum - Vector: "+ ship:ANGULARMOMENTUM. //
//  print "Angular Velocity - Vector: "+ ship:ANGULARVEL. //

  print "///////".
 // print "East For SHIPel"+ east_for(SHIP).
// print "Compass For SHIPel"+ Compass_for(SHIP).
//  print "PITCH For SHIPel"+ pitch_for(SHIP).
 // print "East For SHIPel"+ roll_for(SHIP).

  print "/////////".
  //if ship:ANGULARVEL > V(0.5,0.5,0.5){
    //print "SHIP HAS ANGULAR MOMENTUM".
  //}
  //clearscreen.
