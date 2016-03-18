function lower_orbit_altitude {
	if body:name = "Mun" and periapsis > 7500 {		
		// run changeappe("p",6.2).
		// run executenode.
	}.
	if (apoapsis-periapsis) > 1500 and periapsis > 6000 {
		print "Circularising to low orbit.".
		run newcirc("p").
		run executenode.
	}.
}
function eliminate_horiztonal_speed{
	print "Eliminate horitontal speed. ".
	set surfacespeed0 to surfacespeed.
	lock steering to retrograde.
	wait 3.
	set runmode to 1.
	until runmode = 0 {
		if runmode = 1 and alt:radar < 6000 {
			print "Runmode 1 - Alt below 6k cutting speed 2/3 ".
			//lock steering to retrograde.
			wait 1.
			lock throttle to 0.5.
			WHEN surfacespeed < (surfacespeed0/3) THEN {
				set runmode to 2.
				lock throttle to 0.
			}
		}
		if runmode = 2 and alt:radar < 3000 {
			print "Alt below 2k cutting speed to 50 ".
			lock throttle to 0.5.
			WHEN surfacespeed < 50 THEN {
				set runmode to 3.
				lock throttle to 0.
			}
		}
		if runmode = 3 and alt:radar < 2000{
			print "Alt below 2k cutting speed to 0 ".
			lock throttle to 0.5.
			WHEN surfacespeed < 0.5 THEN {
				lock throttle to 0.
				set runmode to 0.
			}		
		}	
	}
}
function suicide_burn{
	set endburn to 0.
	until endburn = 1 {
		print "Starting Suicide burn ".
		set GM to ship:body:mu.
		set R to ship:body:radius. 
		set g0 to GM/(R^2).
		print "Gravatation acceleration at surface(mp/s): " + g0. 
		// a - Max acelleration
		set a to (maxthrust/mass)-g0.
		Print "Max acceleration: " + a.
		// Time to reduce velocity to 0 at full speed 
		set sbt to (SHIP:VERTICALSPEED/a).
		print "Time to reduce velocity at full speed: " + sbt.
		set SBT2 to (sbt*sbt).
		set SBT3 to (0.5*sbt2).
		// H - distance travelled ie altiude to start burn
		set h1 to (SHIP:VERTICALSPEED * sbt) - (sbt3*a).
		print "Current suicide burn height" + h1.
		print "radar alt "+ alt:radar.
		set timetoimpactv to (alt:radar/VERTICALSPEED).
		print "Raw Time to impact "+ timetoimpactv.

		//print "Impact time + grav acc" + (timetoimpactv*)
		clearscreen.
		// print "Running Suicide burn ".
		// run sb.
		set h to 1000.
		if alt:radar < h {
			print "below final 1k".
			set th to 0.2.
			until alt:radar < 5{
	    		lock steering to up.
	    		set landingspeed to 2.
	    		set a0 to SHIP:VERTICALSPEED*SHIP:VERTICALSPEED.
	    		set h4 to (0.5*((a0)/a)).
	    		print "suicide burn height? " + h4.
	    		if abs(VERTICALSPEED) > landingspeed {
	    			print "increasing speed".
	    			set th to (th+0.1).
	    			lock throttle to th.
	    		}
	    		if abs(VERTICALSPEED) < landingspeed {
	    			"match speed".
	    			lock throttle to (g0)/(maxThrust/mass).
	    		}
	    		if alt:radar < 5 {
	    			print "end burn".
	    			lock throttle to 0.
	    			lock steering to up.
	    			set endburn to 1.
	    		}
	    	}
   		 }
	}
}
set landingmode to 1.
until landingmode = 0 {
	if landingmode = 1{
		set landingmode to 2.
	}
	else if landingmode = 2 {
		lower_orbit_altitude().
		set landingmode to 3.
	}
	else if landingmode = 3 {
		eliminate_horiztonal_speed().
		set landingmode to 4.
	}
	else if landingmode = 4 {
		suicide_burn().
		set landingmode to 0.
	}
}