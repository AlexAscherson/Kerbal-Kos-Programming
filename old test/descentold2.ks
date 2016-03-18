// Descent

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


//not used?
function Time_To_Impact{ 
  PARAMETER margin is 0. //This is a bit redundant with burn alt having time as well.
  //From Gisikw on github.
  LOCAL d IS (alt_true() - margin).
  LOCAL v IS -SHIP:VERTICALSPEED.
  LOCAL g IS SHIP:BODY:MU / SHIP:BODY:RADIUS^2.
  RETURN (SQRT(v^2 + 2 * g * d) - v) / g.
}
//not used?
function velocity_at_impact {
  // v = v0 + at
  local v0 is -ship:verticalspeed + abs(ship:groundspeed).
  local a is total_acceleration().
  local t is time_to_impact().
  print "Vel Impact - Time to time_to_impact:" + time_to_impact().
  return v0 + a*t.
}

function alt_true{
  return altitude - ship:geoposition:terrainheight.
}

function local_gravity_acceleration{
  set gConst to 6.67384*10^(0-11). // The Gravitational constant
  lock ship_gravity_acceleration_local to gConst*body:Mass/((alt_true()+body:Radius)^2). // Mp/s 
  return ship_gravity_acceleration_local.
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
  parameter speed_to_reduce is verticalspeed.
  if travel_direction = "V"{
    set burn_time_v to time_to_kill_speed(verticalspeed, throttle_setting).
    return distance_travelled_under_constant_acceleration(burn_time_v, get_acceleration()). //Relying on defaults alot here 
  }
  if travel_direction = "H" {
    set burn_time_h to time_to_kill_speed(groundspeed, throttle_setting).
    return distance_travelled_under_constant_acceleration(burn_time_h, get_acceleration(groundspeed, throttle_setting), groundspeed). //Relying on defaults alot here
  }
}

function get_acceleration{
  parameter thrust_vector is verticalspeed.
  parameter throttle_setting is 1. // Assume you want the max acceleration.

  local a_thrust is ship:maxthrust / ship:mass.
  local a_thrust is a_thrust*throttle_setting.
  local grav is local_gravity_acceleration().

  if thrust_vector = verticalspeed{  //By default returns acceleration - gravity so dont need to worry about during height calcs?
    return a_thrust - grav.
    Print "Get acceleration returning for verticalspeed".
  } else {
    return a_thrust.
    Print "Get acceleration returning for horiztonalspeed.".
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
  }
  set result to latlng(resultLat,resultLng).
  return result.
}

function get_impact_warning_at_distance{
  // Need a condition to handle being activeblow the safe burn altitude, to either wait to see if terrain falls or burn up for a bit?
  // By Default we are going to check that our suicide burn alt is above the terrain at the point after we cut groundspeed.
  parameter checkpoint is get_stopping_distance("H").
  set safety_margin to (1.1).

  lock terrain_position_at_check_point to check_terrain_height(ship:geoposition,(-1)*ship:bearing,checkpoint,body:radius). 
  lock terrain_height_at_check_point to terrain_position_at_check_point:terrainheight.

  lock descent_during_hoz_burn to distance_travelled_under_constant_acceleration(time_to_kill_speed(groundspeed)). //This will be a bit high?
  set extra_vertical_speed_after_hoz_burn to local_gravity_acceleration()*time_to_kill_speed(groundspeed).
  lock alt_at_checkpoint to (ship:altitude-descent_during_hoz_burn).
  lock vertical_stopping_dist_after_hoz_burn to get_stopping_distance("V", (verticalspeed+extra_vertical_speed_after_hoz_burn)).
  lock true_alt_at_checkpoint to alt_true(alt_at_checkpoint, terrain_height_at_check_point).

  if (terrain_height_at_check_point*safety_margin) > (true_alt_at_checkpoint - vertical_stopping_dist_after_hoz_burn){
    // The terrain height at the checkpoint is above the alt we will need to cut vertical speed.
    return true.
  }
  print "TERRAIN CHECK".
  Print "Checkpoint Distance" + checkpoint. 
  print "Checkpoint Alt+safety:"+ (terrain_height_at_check_point*safety_margin).
  print "terrain_height_at_check_point" + terrain_height_at_check_point.
  print "True Alt at checkpoint:"+ true_alt_at_checkpoint.
  print "true height at check - vstop " + (true_alt_at_checkpoint - vertical_stopping_dist_after_hoz_burn).
  print "V stop distance after burn:" + vertical_stopping_dist_after_hoz_burn.

}

function wait_for_suicide_burn_point{
  parameter safety_margin is (1.1).
  align_ship(retrograde).
  until false {
    clearscreen.
    //lock steering to retrograde.
    Print "Waiting for Impact Warning".
    print "Groundspeed"+ groundspeed.
    print "Verticalspeed"+ verticalspeed.
    if groundspeed > 15 { // we are going fast, look for the stopping distance
      set impact_warning to get_impact_warning_at_distance().
      if impact_warning {
        print "Predicted Impact Warning".
        Reduce_Groundspeed().
        lock steering to up.
      }
    }
    if groundspeed < 15 and groundspeed > 3{ 
      print "Going slow, correct to vertical drop".
      Reduce_Groundspeed().
      lock steering to up.
    }
    if groundspeed < 3 and alt_true() < get_stopping_distance("V") {
      until verticalspeed > -3 {
        lock STEERING to up.
        lock throttle to 1.
      }
      break. 
      // Want to do a vertical sb.
    }     
  }
}

function Reduce_speed{

  parameter speed_type is groundspeed.
  parameter target_speed is 0.
  parameter burn_direction is ((-1) * SHIP:VELOCITY:SURFACE).
  
  set manuver_done to 0.
  sas off.
  LOCK STEERING TO burn_direction.
  Print "ALIGN SHIP 2 SECONDS".
  wait 1.
  until manuver_done = 1 {
    LOCK STEERING TO burn_direction.      
    if speed_type > target_speed +20 {
      lock throttle to 1.
    }
    if groundspeed < target_speed +20 {
      if (0.1*speed_type) > 0.10 {
        lock throttle to (0.1*speed_type).
      } else {
        lock throttle to 0.10.
      }
    } 
    if speed_type < target_speed +0.5{
      set throttle to 0.
      set manuver_done to 1.
      Print "Reduce Speed Complete".
    } 
  }
}

function Reduce_Groundspeed{

  parameter target_speed is 0.
  
  set manuver_done to 0.
  sas off.
  LOCK STEERING TO (-1) * SHIP:VELOCITY:SURFACE.
  Print "ALIGN SHIP 2 SECONDS".
  wait 2.
  until manuver_done = 1 {
      
    LOCK STEERING TO (-1) * SHIP:VELOCITY:SURFACE.      
    if GroundSpeed > target_speed +5 {
      lock throttle to GroundSpeed/get_acceleration(groundspeed).
      Print "Burning to Target Speed+5".
    }
    if GroundSpeed < target_speed +5 {
      if (0.1*GroundSpeed) > 0.10 {
        lock throttle to (0.1*GroundSpeed).
      } else {
        lock throttle to 0.10.
      }
       print "Slowing hoz burn to 10% Groundspeed".
    } 
    if GroundSpeed < target_speed +0.5{
      print "ENDING Manuever at Margin of 0.5".
      set throttle to 0.
      set manuver_done to 1.
    } 
   
  }
}

function touch_down{
  notify("Touching Down").
  lock throttle to 0.
  Update_landing_Variables().
  lock steering to up.
  if legs = false {
    toggle legs.
    Print "Waiting for Legs".
    wait until legs = true.
    Print "Legs Deployed". 
  } 
  lock throttle to 0.  
  until alt_true() < 5 {
    // ship falling at contant accelleration(time of the stopping distance) > 
    if alt_true() < (get_stopping_distance("v")+12) and verticalspeed < -5 {
      until false {
        lock throttle to 1.
        print "touch down burn".
        if verticalspeed > -5{
          lock throttle to 0.
          break.
        }
      }
    }
    if alt_true() < 100 {
      lock throttle to 0.
    }
    if alt_true() < 50 {
      lock throttle to throttle_gravity_neutral_vacuum.
    }
    if alt_true() < 50 and verticalspeed < -5 {
      set throttle_gravity_neutral_vacuum_faster to (throttle_gravity_neutral_vacuum *1.15).
      lock throttle to throttle_gravity_neutral_vacuum_faster.
    }
    if alt_true() < 50 and verticalspeed > -5 {
      set throttle_gravity_neutral_vacuum_slower to (throttle_gravity_neutral_vacuum *0.9).
      lock throttle to throttle_gravity_neutral_vacuum_slower.
    }
    if alt_true() < 50 and verticalspeed < -1 and verticalspeed > -5 {
      lock throttle to throttle_gravity_neutral_vacuum.
    }
    if alt_true < 10 {
      lock throttle to 0.
      break.
    }

  }
  unlock steering.
  sas on.
  set sasmode to "STABILITYASSIST".  
  lock throttle to 0.
  notify("Touching Down").
  wait 10. 
  set touched_down to 1.
}

function Descend_to_land{

  parameter decent_point is "At_PE".
  //If there is a high orbit 
  Update_landing_Variables().
  if decent_point = "At_PE"{

    Descend_to_min_safe_orbit().
    deorbit().  
    Update_landing_Variables().
    wait_for_suicide_burn_point().
    touch_down().
  }
  if decent_point = "Custom_Decent"{
    // Calculate logic for a custom descent.
  } 
}

