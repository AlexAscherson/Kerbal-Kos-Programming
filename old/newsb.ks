set done to 0.
	until done = 1 {
	set gConst to 6.67384*10^(0-11). // The Gravitational constant
	lock heregrav to gConst*body:Mass/((altitude+body:Radius)^2).

	// Surface grav
	set surfGrav to gConst*body:Mass/(body:Radius^2).
	set surfExtraAc to ( (maxthrust/(mass*surfGrav) ) - 1 ) * surfGrav.

	set g to surfgrav.

	// h = radar height
	set h to alt:radar.

	// v0 Vertial Velocity at any moment(?)

	set v0 to verticalspeed.
	print "This should be vertical velocity" + v0.

	// Vertical dv (presumably != Vertical speed?)

	set vertdv to sqrt(2*g*h+v0^2).
	print "This should be vertical dv" + vertdv.

	// Altitude fraction

	set altFraction to (vertdv^2)/(2*1000*maxthrust).

	// burn alt

	set burnAlt to (altFraction *mass).

	print "This should be burnAlt" + burnalt.
	set burnalt to burnalt*1000.
	print "radar alt: " +alt:radar.
	if (alt:radar - burnalt) < 0.1 {
		until verticalspeed > 0 {
			print "below burn alt ".
			lock throttle to 1.
		}
		lock throttle to 0.
	}
	clearscreen.
}	

