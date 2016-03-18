set done to 0.
set mode to 1.
until done = 1{

	set gConst to 6.67384*10^(0-11). // The Gravitational constant
	lock heregrav to gConst*body:Mass/((altitude+body:Radius)^2).
	print "TrueGrav" +heregrav +"mp/s".
	set surfGrav to gConst*body:Mass/(body:Radius^2).
	print "Surfacegrav: "+surfGrav+"mp/s".
	set surfExtraAc to ( (maxthrust/(mass*surfGrav) ) - 1 ) * surfGrav.
	print "Max acceleration surface:  "+ round(surfExtraAc)+"mp/s".
	set a to (maxthrust/mass) - surfGrav.
	print "Max acceleration surface2: " + round(a)+"mp/s".
	set a0 to (maxthrust/mass) - heregrav.
	print "Max acceleration True:     " + a+"mp/s".
	set vi to verticalspeed.
	print "verticalspeed Mp/s? "+verticalspeed.

	set t to (vi/a).
	//Burn time
	set h to (vi*t)-(0.5*(vi^2/a^2))*a.
	//Burn Alt1
	set h2 to (0.5*(vi^2)/a).
	//burn Alt2

	set tfE to 9999999. set tfN to 9999999. set tfU to 9999999. // east,north,up vector
	set absvsup to abs(tfU).
	// How much of my current aiming direction is vertical? (i.e. cosine of angle between steering and straight up):
	lock cossteerup to absvsup / ( (tfE^2+tfN^2+absvsup^2)^0.5 ).
	lock hovth to (ship:mass*heregrav) * (1/cossteerup) / maxthrust .
	// calculate gravitation neutral throttle setting (hover throttle)
	set maxa to maxthrust/mass.
	set hovth0 to heregrav/maxa.
	

	function infoscreen{
		print "BURN TIME: "+t.
		print "BURN ALT: "+h.
		print "CURRENT:ALT:RADAR "+ alt:radar.
		print "Neutral throttle setting"+HOVTH+"%".
		print "Neutral throttle setting1"+ hovth0+"%".
	}	
	
	if mode = 1 {
		set sasmode to "RETROGRADE".
		wait 5.
		set sasmode to "STABILITYASSIST".
		until surfacespeed < 10 {
			print " correcting horizontal speed.".
			lock steering to retrograde.
			lock throttle to 1.
			set killhoz to 1.
		}
		until surfacespeed < 0.4{
			print "slowing hoz burn".
			lock throttle to (0.1*surfacespeed).
		} 
		set mode to 2.
		lock throttle to 0.
	}
	if mode = 2 {
		print "mode 2 waiting for sb alt.".
		set sasmode to "RETROGRADE".
		if alt:radar < (h*1.2) {
			until verticalspeed > -3 {
				print "SB ALT REACHED".
				lock throttle to 1.
				set burning to 1.
			}
			set mode to 3.
		}
	}
	if mode = 3 {
		
		until alt:radar < 2.5 {
			if verticalspeed > -3 {
				set throttle to 0.
			}
			else {
				Print "descending to touchdown".
				lock throttle to hovth.
				}
		} 
		set mode to 4.
		toggle gear.
		wait 1.
	}
	if mode = 4 {
		if gear = 0 {
			toggle gear.
			print "gear inst down toggling".
		}
		sas off.
		unlock steering.
		"Print Mode 4 - Touchdown".
		set sasmode to "STABILITYASSIST".
		lock throttle to 0.
	}
	// if burning = 1 and verticalspeed > -3 {
	// 	print "minimum speed reached ending burn.".
	// 	lock throttle to 0.
	// 	set burning to 0.
	// }
	
clearscreen.

}