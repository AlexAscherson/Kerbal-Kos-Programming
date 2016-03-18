// Descent

copy core_functions from 0.
run core_functions.

function Update_landing_Variables{
  // Local Graviational forces
  set gConst to 6.67384*10^(0-11). // The Gravitational constant
  set ship_gravity_acceleration_surface to gConst*body:Mass/(body:Radius^2). // Mp/s
  lock ship_gravity_acceleration_local to gConst*body:Mass/((altitude+body:Radius)^2). // Mp/s 
  // Can also be written as lock grav to ship:sensors:grav:mag.
  // Ship Properties
  lock ship_max_acceleration to maxthrust/mass.
  lock ship_max_acceleration_surface to (maxthrust/mass) - ship_gravity_acceleration_surface.  // Mp/s
  lock ship_max_acceleration_local to (maxthrust/mass) - ship_gravity_acceleration_local.
  lock ship_thrust_to_weight_ratio_local to maxthrust/(ship_gravity_acceleration_local*mass).
  // Hover throttle setting that would make ship rate of descent constant in vacuum:
  lock throttle_gravity_neutral_vacuum to 1/ship_thrust_to_weight_ratio_local. // Aim maintain twr at 1. Assuming equivlance between twr and max a 
  lock throttle_gravity_neutral_vacuum2 to ship_gravity_acceleration_local/ship_max_acceleration. //Another way of doing this
  // The acceleration I can do above and beyond what is needed to hover: 
  lock available_acceleration to (ship_thrust_to_weight_ratio_local - 1) * ship_gravity_acceleration_local.
}

function Descend_to_min_safe_orbit{

  set min_safe_orbit to get_safe_orbit().
  print "Running Min safe orbit".
  //200m is our safety threshold.
  if periapsis > (min_safe_orbit-200) { // If orbit above min safety threshold.
    if ship:orbit:hasnextpatch {
      notify("Descend to min safe orbit - We are Flying by - Establish Orbit").
      Establish_orbit().
    }
    if periapsis > (min_safe_orbit+200) {
      node_change_apsis("p",min_safe_orbit).
      notify("Descend to min safe orbit - PE = High -Lowering PE to minimum").
      execute_node().
    } 
    if periapsis < (min_safe_orbit+200) and apoapsis > (min_safe_orbit+200){  // periapsis is in safe zone - Circularise and deorbit
      circ_with_node("p").
      notify("Descend to min safe orbit - PE = OK, AP = High - Circularising").
      execute_node().
    }
  }
  if periapsis < (min_safe_orbit-200) and periapsis > 0 { // If orbit below min safety threshold.
    notify("Descend to min safe orbit - PE = LOW - Deorbiting").
    deorbit().
    return false.
  }
  if periapsis < 0 {
    notify("Descend to min safe orbit - Aborted - Sub orbital Trajectory Detected.").
  }

}

function Deorbit {
  
  set deorbit_setting to 0.
  set min_safe_orbit to get_safe_orbit().

  if periapsis < (min_safe_orbit-200) and periapsis > 0 {
    notify("Starting Deorbit - PE Low"). 
    set deorbit_setting to 1.
  }
  if periapsis > (min_safe_orbit-200) and periapsis < (min_safe_orbit+200) {
    notify("Starting Deorbit- PE Good -> Warping to PE").
    warpfor(eta:periapsis). 
    set deorbit_setting to 1.
  }
  if periapsis > (min_safe_orbit+200) {
    notify("Deorbit - Error: PE too High running Descend_to_min_safe_orbit ").
    Descend_to_min_safe_orbit().
    set deorbit_setting to 1.
  }

  if deorbit_setting = 1 {
    align_ship(retrograde).
    until periapsis < 1 {
      lock steering to retrograde.  
      lock throttle to 1.
    }
    lock throttle to 0.
  }
}

function alt_true{
  return altitude - ship:geoposition:terrainheight.
}

function get_verticalspeed_stopping_distance{
  //Update_Variables.
  lock t to (verticalspeed/ship_max_acceleration_surface).
  //Burn time
  lock h to (verticalspeed*t)-(0.5*(verticalspeed^2/ship_max_acceleration_surface^2))*ship_max_acceleration_surface.
  return h.
}

function get_verticalspeed_stopping_time{
  set vert_stopping_time to (2*get_verticalspeed_stopping_distance())*(0 + verticalspeed).  // 0  is final speed
}

function get_groundspeed_stopping_distance{
  //burn height.
  lock t to (groundspeed/total_acceleration()).
  //Burn Length
  lock height to (groundspeed*t)-(0.5*(groundspeed^2/total_acceleration()^2))*total_acceleration(). 
  lock stopping_distance to groundspeed^2/2*total_acceleration().
  lock stopping_distance2 to (groundspeed/2)*(groundspeed/total_acceleration()). //total_acceleration is looking at vertical so will be a bi inaccurate
  print "Stopping Distance returned 1:" + stopping_distance.
  print "Stopping Distance Debugger 2:" + stopping_distance2.
  print "Stopping Distance Debugger 3:" + height.
  return stopping_distance.
}

function get_groundspeed_stopping_time{
  set stopping_time to (2*get_groundspeed_stopping_distance())*(0 + groundspeed).
  return stopping_time.
}

function Time_To_Impact{ 
  PARAMETER margin is 0. //This is a bit redundant with burn alt having time as well.
  //From Gisikw on github.
  LOCAL d IS (alt_true() - margin).
  LOCAL v IS -SHIP:VERTICALSPEED.
  LOCAL g IS SHIP:BODY:MU / SHIP:BODY:RADIUS^2.
  RETURN (SQRT(v^2 + 2 * g * d) - v) / g.
}

function total_acceleration {
  local a_grav is body:mu / ((ship:altitude + body:radius)^2).
  local a_thrust is ship:maxthrust / ship:mass.
  return a_grav - a_thrust.
}

function velocity_at_impact {
  // v = v0 + at
  local v0 is -ship:verticalspeed + abs(ship:groundspeed).
  local a is total_acceleration().
  local t is time_to_impact().
  print "Vel Impact - Time to time_to_impact:" + time_to_impact().
  return v0 + a*t.
}

function touch_down{
  
    lock steering to up.
    until alt:radar < 5 {
      set throttle to throttle_gravity_neutral_vacuum.
    }
    unlock steering.
    sas on.
    set sasmode to "STABILITYASSIST".  
    lock throttle to 0.
    notfiy("Touching Down").
    wait 10. 
    set touched_down to 1.
}

function execute_suicide_burn{
  //align_ship(retrograde). In case it causes delays test later.
  notify("Suicide Burn - Retrograde.").
  align_ship(retrograde).
  until verticalspeed > -3 {
    lock steering to retrograde.
    lock throttle to 1.
  }
  lock throttle to 0.
  notify("suicide burn complete").

}

function get_ship_alt_at_check_distance(){
  set terrain_position_at_check_point to check_terrain_height(ship:geoposition,(-1)*ship:bearing,horizontal_stop_distance,body:radius).

  set terrain_difference to alt_true() - terrain_position_at_check_point:terrainheight.
  set terrain_difference_after_decent- 
  // if its positive the ground is lower.
  //if its negative the ground is higher by that amount.  
  // If its higher that the burn alt, or if its higher than burn alt - the amount we will descend we need to break.

  // can use : ship_gravity_acceleration_local
  Set difference_between_altitude_now_and_target to 1.
  set time_till_checkpoint to get_horizontal_stopping_distance()/groundspeed. 

  set alt_at_checkpoint to alt_true()-(verticalspeed*time_till_checkpoint).
  return alt_at_checkpoint.
}

function descent_safety_check { 
  
  PARAMETER check_mode is "active".
  if check_mode = "active"{
    lock steering to retrograde.
    set descent_safety_margin to (1.1).
    lock vertical_stop_distance to get_verticalspeed_stopping_distance().
    lock horizontal_stop_distance to get_groundspeed_stopping_distance().
    set terrain_position_at_check_point to check_terrain_height(ship:geoposition,(-1)*ship:bearing,horizontal_stop_distance,body:radius). //check number of seconds travelling horizontally ahead that it would take to reduce the hoz speed to 0.
    //set terrain_height_at_check_point to (alt_true() - terrain_position_at_check_point:terrainheight).
    if alt_true() < (vertical_stop_distance*descent_safety_margin) or terrain_position_at_check_point:terrainheight < (vertical_stop_distance*descent_safety_margin) {
      execute_suicide_burn().
      lock throttle to 0.
      touch_down().
    } else {
      print "OK Current Margin:   " + (alt_true()-get_verticalspeed_stopping_distance()).
      Print "OK Predicted margin: " + (get_verticalspeed_stopping_distance()- terrain_height_at_check_point).
      Print "Burn Height:         " + vertical_stop_distance.
      Print "Horizintal Stop Dist:" + horizontal_stop_distance.
    }
  } else {
    //Predictivemode code here.
  }
}

function Final_Descent_Controller{
  copy check_terrain_height from 0.
  run check_terrain_height.

  Update_landing_variables().
  set touched_down to 0.
  until touched_down = 1 {
    descent_safety_check().
  }
}

function Descend_to_land{

  parameter decent_point is "At_PE".
  //If there is a high orbit 
 
  if decent_point = "At_PE"{
    Descend_to_min_safe_orbit().
    deorbit().  
    Final_Descent_Controller().
  }
  if decent_point = "Custom_Decent"{
    // Calculate logic for a custom descent.
  } 
}

