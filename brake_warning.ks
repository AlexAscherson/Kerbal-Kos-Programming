copy brake_warning_debug from 0.
run brake_warning_debug.

function get_terrain{
  declare parameter p1, b, d, radius. //(start point,bearing,distance,radius(planet/moon)).
  set resultLat to arcsin(sin(p1:lat)*cos((d*180)/(radius*constant():pi))+cos(p1:lat)*sin((d*180)/(radius*constant():pi))*cos(b)).
  if abs(resultLat) = 90 {
   set resultLng to 0.
  }
  else {
   set resultlng to p1:lng+arctan2(sin(b)*sin((d*180)/(radius*constant():pi))*cos(p1:lat),cos((d*180)/(radius*constant():pi))-sin(p1:lat)*sin(resultLat)).
  }
  set result to latlng(resultLat,resultLng).
  return result.
}

function get_local_grav_acceleration{
  set gConst to 6.67384*10^(0-11). // The Gravitational constant
  //print "Local grav acceleration"+ gConst*body:Mass/((altitude+body:Radius)^2).
  return gConst*body:Mass/((altitude+body:Radius)^2).
}

function get_max_acceleration{
  parameter ship_orientation is "vertical".
  if ship_orientation = "vertical"{
    // print "Max acceleration - grav"+ ((maxthrust/ship:mass)-get_local_grav_acceleration()).
    return (maxthrust/ship:mass)-get_local_grav_acceleration().
  } else {
    // print "Max acceleration - Horizontal"+ (maxthrust/ship:mass).
    return (maxthrust/ship:mass).
  }
}

function distance_travelled_under_acceleration_over_time{

  parameter acceleration_type is "vertical_burn".
  parameter time is 10.
  parameter velocity_start is verticalspeed. // Assume we want vertical 
  parameter fixed_a is "none".

  if acceleration_type = "vertical_burn"{
    set ship_acceleration to get_max_acceleration("vertical").
  }
  if acceleration_type = "horizontal_burn"{
    set ship_acceleration to (-1)*get_max_acceleration("horizontal").
    set velocity_start to groundspeed.
  } 
  if acceleration_type = "Gravity"{
    set ship_acceleration to get_local_grav_acceleration().
  }
  if fixed_a <> "none" {
    set ship_acceleration to fixed_a.
  }
  set avg_acceleration to (0.5*(ship_acceleration*time^2)).
 //print "avg acceleration" + avg_acceleration.
  return abs(((velocity_start*time) + avg_acceleration)). // We are going to make this absolute otherwise will return negative numbers is decelerating.
}

function time_to_change_speed{
  parameter speed_orientation is "vertical_stop".
  parameter target_speed is 0.
  parameter start_speed is "none".
  parameter max_a is "none".

  if speed_orientation = "vertical_stop"{
    if start_speed = "none"{
      set start_speed to verticalspeed.
    }
    set time_needed to (abs(start_speed)/get_max_acceleration("vertical")). 

  } else if speed_orientation = "horizontal_stop" {
   
    if start_speed = "none" { // Check if we got a parameter or not
      set start_speed to groundspeed.
    }
    set time_needed to (abs(start_speed)/get_max_acceleration("horizontal")). 
  } else if speed_orientation = "custom"{ 
     set time_needed to (abs(start_speed)/max_a).  // This mode is for testing or custom calcs
  }
  return abs(time_needed).
}
function get_impact_time {

  parameter ship_alt IS (altitude-ship:geoposition:terrainheight).
  parameter ship_vertical_speed IS -SHIP:VERTICALSPEED.
  parameter grav_parameter IS get_local_grav_acceleration().
  RETURN (SQRT(ship_vertical_speed^2 + 2 * grav_parameter * ship_alt) - ship_vertical_speed) / grav_parameter.
}

function get_impact_time2 {

  parameter height IS (altitude-ship:geoposition:terrainheight). // didnt have alt true n fiel..
  parameter existing_speed IS -SHIP:VERTICALSPEED.

  set time_to_impact to SQRT((2*(get_local_grav_acceleration()*height)+ existing_speed^2)).
  return time_to_impact.
}

function get_impact_distance{
  return distance_travelled_under_acceleration_over_time("horizontal_burn", get_impact_time(), groundspeed, 0).
}

function get_brake_warning{
  // The max distance we can start breaking is the amount that it would take to stop our horizontal speed.
  set safetymarginalt to 1.15.
  lock prediction_distance to distance_travelled_under_acceleration_over_time("horizontal_burn", time_to_change_speed("horizontal_stop")). 

  // Impact point is trajectory where our predicted alt falls below the terain hight. // Two minuses make a positive.
  lock terrain_position_at_stop_point to get_terrain(ship:geoposition,ship:bearing,prediction_distance,body:radius).
  // We step forward ^
  lock predicted_fall to distance_travelled_under_acceleration_over_time("Gravity", time_to_change_speed("horizontal_stop")).
  lock predicted_alt_after_fall to (altitude - predicted_fall).
  lock verticalspeed_after_fall to (verticalspeed-abs(get_local_grav_acceleration()*time_to_change_speed("horizontal_stop"))).
  
  // We step down ^
  lock predicted_true_alt_after_fall to (predicted_alt_after_fall - terrain_position_at_stop_point:terrainheight)*safetymarginalt.//
  lock predicted_time_to_impact to get_impact_time(predicted_true_alt_after_fall,(verticalspeed_after_fall)).
  // We get the distance from the ground after falling during the horizontal stop.
  if predicted_true_alt_after_fall < distance_travelled_under_acceleration_over_time("vertical_burn", time_to_change_speed("vertical_stop",0,verticalspeed_after_fall),verticalspeed_after_fall){
    print "!!!Impact Alert!!! - Predicted Alt < Vertical Stopping Distance".
    run_brake_log("!!! Ran Brake Warning- Impact !!!").
    return true.
  } else {
    print "!!! Ran Brake Warning: SAFE !!!".
    run_brake_log("!!! Ran Brake Warning- SAFE !!!").
    SET VD TO VECDRAWARGS(
      terrain_position_at_stop_point:ALTITUDEPOSITION(terrain_position_at_stop_point:TERRAINHEIGHT+100),
      terrain_position_at_stop_point:POSITION - terrain_position_at_stop_point:ALTITUDEPOSITION(terrain_position_at_stop_point:TERRAINHEIGHT+100),
      red, "Checking here.", 1, true, 2).
    set terrain_position_at_stop_point to get_terrain(ship:geoposition,ship:bearing,(prediction_distance*0.5),body:radius).

    SET V2 TO VECDRAWARGS(
      terrain_position_at_stop_point:ALTITUDEPOSITION(terrain_position_at_stop_point:TERRAINHEIGHT+100),
      terrain_position_at_stop_point:POSITION - terrain_position_at_stop_point:ALTITUDEPOSITION(terrain_position_at_stop_point:TERRAINHEIGHT+100),
      blue, "50%", 1, true, 2).

    Return False.
  }
}