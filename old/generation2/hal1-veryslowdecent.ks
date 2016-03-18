//Hal mk1.
	//Guide
	//Set for static variables, lock indictes that if a dependent varaible changes the value should update.
  // Lock expressions to cut down on the number of statements in a loop:


set done to 0. 
set mode to 1.

until done = 1 {
 
  Update_Variables().
  Hover().
  clearscreen.
  Update_Gui().
}

function Update_Variables{
  // Local Graviational forces
  set gConst to 6.67384*10^(0-11). // The Gravitational constant
  set ship_gravity_acceleration_surface to gConst*body:Mass/(body:Radius^2). // Mp/s

  lock ship_gravity_acceleration_local to gConst*body:Mass/((altitude+body:Radius)^2). // Mp/s 
  // Can also be written as lock grav to ship:sensors:grav:mag.

  // Ship Properties
  lock ship_max_acceleration to maxthrust/mass.
  lock ship_max_acceleration_surface to (maxthrust/mass) - ship_gravity_acceleration_surface.  // Mp/s

  lock ship_thrust_to_weight_ratio_local to maxthrust/(ship_gravity_acceleration_local*mass).

  // Navigation
  set vector_east to 9999999. set vector_north to 9999999. set vector_up to 9999999. // east,north,up vector
  lock absspd to (vector_east^2 + vector_north^2 + vector_up^2) ^ 0.5 .  // Ship speed as a vector
  set petermv to 999999.
  set usepe to 999999.

  // Vertical Aiming Direction -i.e cosine of angle between steering and straight up: //Ship Heading as a vector?
  set absolute_vector_up to abs(vector_up).  
  lock cossteerup to absolute_vector_up / ( (vector_east^2+vector_north^2+absolute_vector_up^2)^0.5 ).
  lock sinsteerup to ((vector_east^2+vector_north^2)^0.5) / ( (vector_east^2+vector_north^2+absolute_vector_up^2)^0.5 ).

  // Hover throttle setting that would make ship rate of descent constant in vacuum:
  lock throttle_gravity_neutral_vacuum to 1/ship_thrust_to_weight_ratio_local. // Aim maintain twr at 1. Assuming equivlance between twr and max a 
  lock throttle_gravity_neutral_vacuum2 to ship_gravity_acceleration_local/ship_max_acceleration. //Another way of doing this

  // The acceleration I can do above and beyond what is needed to hover: 
  lock available_acceleration to (ship_thrust_to_weight_ratio_local - 1) * ship_gravity_acceleration_local.
}


function Update_Gui{
  Print "///// Orbit /////".
  print "ship_gravity_acceleration_local" + round(ship_gravity_acceleration_local, 2) + "Mp/s".
  print "ship_gravity_acceleration_surface" + round(ship_gravity_acceleration_surface, 2) + "Mp/s".

  Print "///// Steering //////".
  print "Vector Speed" + absspd.
  print "Vector Cosine between steering and up" + cossteerup.

  Print "///// Thrust /////".
  print "Gravity Neutral Throttle setting: " + round(throttle_gravity_neutral_vacuum, 2) + "%".
  print "Gravity Neutral Throttle setting v2: " + round(throttle_gravity_neutral_vacuum2, 2) + "%".

  print "Ship_Max_Acceleration: " + round(ship_max_acceleration, 2) + "Mp/s".
  print "Ship_Max_Acceleration_Surface: " + round(ship_max_acceleration_surface, 2) + "Mp/s". // Maybe should be max Vertical Acceleration
  
  print "Ship_thrust_to_weight_ratio_local: " + round(ship_thrust_to_weight_ratio_local, 2).
  
}

function Hover{
    set compensation_value to abs(Verticalspeed/ship_max_acceleration).
    if VerticalSpeed > 0.05 {
      Print "///// Hover-> Ascending - Waiting for negative vertical velocity".
      Set throttle_gravity_neutral_vacuum to throttle_gravity_neutral_vacuum - compensation_value*1.5.
    }
    else if VerticalSpeed < -0.1 {
      Print "///// Hover-> Descending - Adding Velocity to Throttle /////".
      Set throttle_gravity_neutral_vacuum to throttle_gravity_neutral_vacuum + compensation_value.
    }
    else {
      Print "///// Hover-> Neutral -  /////" + compensation_value.
    }
    lock throttle to throttle_gravity_neutral_vacuum.
}