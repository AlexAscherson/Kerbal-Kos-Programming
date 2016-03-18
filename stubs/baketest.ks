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

print distance_travelled_under_acceleration_over_time("vertical_burn", 20, -20, 1.4 )