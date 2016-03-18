set done to false.
set mode to 1.

function updatevalues{
		set gConst to 6.67384*10^(0-11). // The Gravitational constant
		lock heregrav to gConst*body:Mass/((altitude+body:Radius)^2).
		set surfGrav to gConst*body:Mass/(body:Radius^2).
		set surfExtraAc to ( (maxthrust/(mass*surfGrav) ) - 1 ) * surfGrav.
		set a to (maxthrust/mass) - surfGrav.
		set a0 to (maxthrust/mass) - heregrav.
		set vi to verticalspeed.
		set t to (vi/a). //Burn time
		set h to (vi*t)-(0.5*(vi^2/a^2))*a.//Burn Alt1
		set h2 to (0.5*(vi^2)/a).//burn Alt2
		set tfE to 9999999. set tfN to 9999999. set tfU to 9999999. // east,north,up vector
		set absvsup to abs(tfU).
		// How much of my current aiming direction is vertical? (i.e. cosine of angle between steering and straight up):
		lock cossteerup to absvsup / ( (tfE^2+tfN^2+absvsup^2)^0.5 ).
		lock hovth to (ship:mass*heregrav) * (1/cossteerup) / maxthrust .
		// calculate gravitation neutral throttle setting (hover throttle)
		set maxa to maxthrust/mass.
		set hovth0 to heregrav/maxa.

	}
	function infoscreen{
		clearscreen.
		updatevalues().
		print "BURN TIME: "+round(t)+"/s".
		print "BURN ALT: 		 "+h +" metres".
		print "CURRENT:ALT:RADAR "+ alt:radar +" metres".
		print "Neutral throttle setting "+HOVTH+"%".
		print "Neutral throttle setting1"+ hovth0+"%".
		print "VERTICAL SPEED: "+verticalspeed +"mp/s".
		print "TrueGrav:    "+round(heregrav) +"mp/s".
		print "Surfacegrav: "+round(surfGrav)+"mp/s".
		print "Max acceleration surface:  "+ round(surfExtraAc)+"mp/s".
		print "Max acceleration surface2: " + round(a)+"mp/s".
		print "Max acceleration True:     " + round(a)+"mp/s".
		
	}	

until done = true{
	
	if mode = 1 {
		set sasmode to "RETROGRADE".
		wait 5.
		set sasmode to "STABILITYASSIST".
		UNTIL surfacespeed < 10 {
			print "MODE 1-PERFORMING DEORBIT BURN".
			infoscreen().
			lock steering to retrograde.
			lock throttle to 1.
		}
		UNTIL surfacespeed < 0.4{
			print "MODE 1-FINALIZING DEORBIT BURN.".
			infoscreen().
			lock throttle to (0.1*surfacespeed).
		} 
		set mode to 2.
		lock throttle to 0.
	}
	if mode = 2 {
		print "MODE 2- VERTICAL FREEFALL:BURN IN"+round(alt:radar - (h*1.2))+" Meters".
		set sasmode to "RETROGRADE".
		if alt:radar < (h*1.2) { //20% Saftey margin
			until verticalspeed > -3 {
				print "MODE 2- BURN ALT REACHED - SLOWING TO -3mps".
				infoscreen().
				lock throttle to 1.
			}
			set mode to 3.
			toggle gear.
		}
	}
	if mode = 3 {
		until alt:radar < 2.5 {
			if gear = False {
				set gear to True.
			}
			if verticalspeed > -3 {
				set throttle to 0.
				Print "Correcting th to 0.".
			}
			else {
				Print "MODE 3 - Locking speed to -3".
				lock throttle to hovth.
			}
			infoscreen().
		} 
		set mode to 4.
	}
	if mode = 4 {
		sas off.
		unlock steering.
		"Print MODE 4 - Touchdown - KILLING EVERYTHING".
		set sasmode to "STABILITYASSIST".
		lock throttle to 0.
		set done to true.
	}
infoscreen().
}