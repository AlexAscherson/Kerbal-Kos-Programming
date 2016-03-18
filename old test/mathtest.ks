//
// Calculate distance travelled while accellerating

function alt_true{
  return altitude - ship:geoposition:terrainheight.
}

function local_gravity_acceleration{
  set gConst to 6.67384*10^(0-11). // The Gravitational constant
  lock ship_gravity_acceleration_local to gConst*body:Mass/((alt_true()+body:Radius)^2). // Mp/s 
  return ship_gravity_acceleration_local.
}

function fall_calculator{
  //defaults assume vertical

  set distance_travelled to verticalspeed*duration_of_fall.


}


function distance_travelled_under_constant_acceleration{
  //Defaults are for falling vertically for 1 min for 1 min with 0 throttle.
  parameter time_travelled is 60.
  parameter acceleration is local_gravity_acceleration().
  parameter initial_speed is verticalspeed.

  lock total to (initial_speed*time_travelled)-(0.5*(initial_speed^2/acceleration^2))*acceleration.

  return abs(total).
}

function time_to_kill_speed {
  parameter speed is verticalspeed. // Assume you want vertical speed.
  parameter throttle_setting is 1. // We assume you want result full speed unless you give it something else
  
  lock stop_time to (speed/get_acceleration(speed, throttle_setting)).
  return abs(stop_time).
}

function get_stopping_distance{
  parameter travel_direction is "V".
  parameter throttle_setting is 1. //Assume we want stopping dist at max throttle
  if travel_direction = "V"{
    set burn_time_v to time_to_kill_speed(verticalspeed, throttle_setting).
    return distance_travelled_under_constant_acceleration(burn_time_v, get_acceleration()). //Relying on defaults alot here 
  }
  if travel_direction = "H" {
    set burn_time_h to time_to_kill_speed(groundspeed, throttle_setting).
    return distance_travelled_under_constant_acceleration(burn_time_h, get_acceleration("H", throttle_setting), groundspeed). //Relying on defaults alot here
  }
}

function get_acceleration{
  parameter thrust_vector is "V".
  parameter throttle_setting is 1. // Assume you want the max acceleration.

  local a_thrust is ship:maxthrust / ship:mass.
  local a_thrust is a_thrust*throttle_setting.
  local grav is local_gravity_acceleration().

  if thrust_vector = "V"{  //By default returns acceleration - gravity so dont need to worry about during height calcs?
    return a_thrust - grav.
  } else {
    return a_thrust.
  }
}


function check_terrain_height{
  declare parameter p1, b, d, radius. //(start point,bearing,distance,radius(planet/moon)).
  set resultLat to arcsin(sin(p1:lat)*cos((d*180)/(radius*constant():pi))+cos(p1:lat)*sin((d*180)/(radius*constant():pi))*cos(b)).
  if abs(resultLat) = 90 {
   set resultLng to 0.
  }
  else {
   set resultlng to p1:lng+arctan2(sin(b)*sin((d*180)/(radius*constant():pi))*cos(p1:lat),cos((d*180)/(radius*constant():pi))-sin(p1:lat)*sin(resultLat)).
  }.
  set result to latlng(resultLat,resultLng).
  return result.
}

function get_impact_warning{

  // Get the terrain at the point where ship would stop after reducing hoz speed to 0.  Maybe needs ship to be facing retro?.
  parameter checkpoint is "HSTOP".
  if checkpoint = "HSTOP"{
    lock checkpoint to get_stopping_distance("H").
  } else if checkpoint ="Now"{
    if alt_true < get_stopping_distance("V"). {
      Print "Alt Now below V stopping distance".
      return true.
    } else {
      Print "Alt Now Above stopping distance".
      return False.
    }
  }
  lock terrain_position_at_check_point to check_terrain_height(ship:geoposition,(-1)*ship:bearing,checkpoint,body:radius). 
  lock terrain_height_at_check_point to terrain_position_at_check_point:terrainheight).
  lock terrain_difference to ship:geoposition:terrainheight - terrain_position_at_check_point.
 
  if terrain_difference > 1 {
    Print "Alt At checkpoint below current height".
    return false.
  }
  if terrain_difference < 1 {
    Print "Warning - Alt checkpoint Above current height".
    lock vertical_stop_distance to get_stopping_distance("V").
    set descent_during_hoz_burn to distance_travelled_under_constant_acceleration(time_to_kill_speed("H")).
    if (alt_true()-descent_during_hoz_burn) < vertical_stop_distance. {
      print "Warning Altitude at checkpoint is higher than Vertical Stop Distance".
      return true.
    }
  }

}

function execute_suicide_burn{
  //align_ship(retrograde). In case it causes delays test later.
  notify("Suicide Burn - Retrograde.").
  until verticalspeed > -3 {
    lock steering to retrograde.
    lock throttle to 1.
  }
  lock throttle to 0.
  notify("suicide burn complete").
}

function detect_suicide_burn_point{
  parameter safety_margin is (1.1).

  alignship(retrograde).

  set Impact_detected to false.
  until Impact_detected = true {
    lock steering to retrograde.
    Print "Waiting for Impact Warning".
    if get_impact_warning("now"){break}.
    if get_impact_warning("HSTOP"){break}.
    clearscreen.
  }
  execute_suicide_burn().

}