// maths vs2

//Ship gravity accelleration 



function get_local_grav_acceleration{
  set gConst to 6.67384*10^(0-11). // The Gravitational constant
  print "Local grav acceleration"+ gConst*body:Mass/((altitude+body:Radius)^2).
  return gConst*body:Mass/((altitude+body:Radius)^2).
}

function get_max_acceleration{
  parameter ship_orientation is "vertical".
  if ship_orientation = "vertical"{
     print "Max acceleration - grav"+ ((maxthrust/ship:mass)-get_local_grav_acceleration()).
    return (maxthrust/ship:mass)-get_local_grav_acceleration().
  } else {
     print "Max acceleration - Horizontal"+ (maxthrust/ship:mass).
    return (maxthrust/ship:mass).
  }
}

//Distance travelled under accelleration

function velocity_change_under_acceleration_over_time { // this all can go?
  parameter burn_type is "vertical". 
  parameter time is 60.
  lock starting_vel to verticalspeed.
  //  
  if burn_type = "vertical_burn" {
    set ship_acceleration to (maxthrust/ship:mass)-get_local_grav_acceleration().
  } else if burn_type = "horizontal" {
    lock ship_acceleration to maxthrust/ship:mass.
    lock starting_vel to groundspeed.
  } else { // We assume we want the answer for a vertical freefall without a burn.
    set ship_acceleration to get_local_grav_acceleration(). 
  }
  set final_velocity to starting_vel + (ship_acceleration*time).
  return final_velocity.
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
    set ship_acceleration to get_max_acceleration("horizontal").
    set velocity_start to groundspeed.
  } 
  if acceleration_type = "Gravity"{
    set ship_acceleration to get_local_grav_acceleration().
  }
  if fixed_a <> "none" {
    set ship_acceleration to fixed_a.
  }
  set avg_acceleration to (0.5*(ship_acceleration*time^2)).
  return abs(((velocity_start*time) + avg_acceleration)). // We are going to make this absolute otherwise will return negative numbers is decelerating.
  //if this is negative it means we passed the 0 speed point and are now moving forward in opposite direction.
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
clearscreen.
Print "/////////////// Test 1 /////////". // no grav, accelerating
set initial_speed to 100.
set max_a to 10.
set target_speed to 0.
print "initial_speed: " + initial_speed.
print "max_a: " + max_a.
print "taget_speed: " + target_speed.

Print "/////////////// Results 1 /////////".
print "time to change speed"+time_to_change_speed("custom", target_speed, initial_speed, max_a). // This is the time to kill speed.
print "distance travelled under constant a:"+ distance_travelled_under_acceleration_over_time("horizontal", time_to_change_speed("custom", target_speed, initial_speed,max_a), initial_speed, max_a).

Print "/////////////// Test 2 /////////". // no grav, deccelerating
set initial_speed to -100.
set max_a to 10.
set target_speed to 0.
print "initial_speed: " + initial_speed.
print "max_a: " + max_a.
print "target_speed: " + target_speed.

Print "/////////////// Results 2 /////////".
print "time to change speed"+time_to_change_speed("custom", target_speed, initial_speed, max_a). // This is the time to kill speed.
print "distance travelled under constant a:"+ distance_travelled_under_acceleration_over_time("horizontal", time_to_change_speed("custom", target_speed, initial_speed,max_a), initial_speed, max_a).

Print "/////////////// Test 3 /////////". // no grav, accelerating
set initial_speed to -1000.
set max_a to 17.5.
set target_speed to 0.
print "initial_speed: " + initial_speed.
print "max_a: " + max_a.
print "target_speed: " + target_speed.

Print "/////////////// Results 3 /////////".
print "time to change speed"+time_to_change_speed("custom", target_speed, initial_speed, max_a). // This is the time to kill speed.
print "distance travelled under constant a:"+ distance_travelled_under_acceleration_over_time("horizontal", time_to_change_speed("custom", target_speed, initial_speed,max_a), initial_speed, max_a).

print "//////////////////////////////////////////////// With grav".

print "time to Vertical Stop at max a:"+time_to_change_speed("vertical_stop"). // This is the time to kill speed.
print "distance to Vertical Stop at max a:"+ distance_travelled_under_acceleration_over_time("vertical", time_to_change_speed("vertical_stop")).

