function distance_travelled_under_acceleration_over_time{

  parameter acceleration_type is "vertical_burn".
  parameter time is 10.
  parameter velocity_start is verticalspeed. // Assume we want vertical 
  parameter fixed_a is "none".

  if acceleration_type = "vertical_burn"{
    print "max vertical a"+ get_max_acceleration("vertical").
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
  print "avg acceleration" + avg_acceleration.
  return abs(((velocity_start*time) + avg_acceleration)). // We are going to make this absolute otherwise will return negative numbers is decelerating.
}

print "verticalspeed:"+verticalspeed.
print "Distance travelled to stop:"+round(distance_travelled_under_acceleration_over_time("vertical_burn", time_to_change_speed("vertical_stop")),2).


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


function get_local_grav_acceleration{
  set gConst to 6.67384*10^(0-11). // The Gravitational constant
  //print "Local grav acceleration"+ gConst*body:Mass/((altitude+body:Radius)^2).
  return gConst*body:Mass/((altitude+body:Radius)^2).
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
  print "stop time "+speed_orientation+":"+round(time_needed,2).
  return abs(time_needed).
}