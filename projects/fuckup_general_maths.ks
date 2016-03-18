//Hal mk1.

	//Guide
	//Set for static variables, lock indictes that if a dependent varaible changes the value should update.
    // Lock expressions to cut down on the number of statements in a loop:
    
// Local Graviational forces
set gConst to 6.67384*10^(0-11). // The Gravitational constant
set ship_gravity_acceleration_at_surface to gConst*body:Mass/(body:Radius^2). // Mp/s

lock ship_local_gravity_acceleration to gConst*body:Mass/((altitude+body:Radius)^2). // Mp/s 
// Can also be written as lock grav to ship:sensors:grav:mag.


// Ship Properties
lock ship_max_acceleration to maxthrust/mass.
lock ship_max_acceleration_surface to (maxthrust/mass) - ship_gravity_acceleration_at_surface.  // Mp/s

lock ship_local_thrust_to_weight_ratio to maxthrust/(ship_local_gravity_acceleration*mass).


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
lock hovth to ((mass*ship_local_gravity)) * (1/cossteerup) / maxthrust .
set hovth0 to ship_local_gravity_acceleration/ship_max_acceleration.  //How can this be right?

// Set the max throttle as a percentage,

//With drag..
//lock hovth to ((mass*ship_local_gravity)-fdrag) * (1/cossteerup) / maxthrust .

// The acceleration I can do above and beyond what is needed to hover:
lock available_acceleration to (ship_local_thrust_to_weight_ratio - 1) * ship_local_gravity_acceleration.


set done to 0. 
set mode to 1.
until done = 0 {


  print "Hover Throttle setting:" + hovth.
  print "Hover Throttle setting:" + hovth.
  



}