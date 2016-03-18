DECLARE PARAMETER orb. 
set orb to orb*1000.
lock TTW to (maxthrust+0.1)/mass.
if ALT:RADAR < 50 { set mode to 1. }
if periapsis > 70000 { set mode to 4. }
	
until mode = 0 { 
	// Else if check onverything else.
	if mode = 1 { // launch
		if orb < 68000 {
			set orb to 75000.
			print "Setting Orb to default 75km".
		}
		lock throttle to 1.
		SET motherstatus TO "Initial Ascent".
	    print "T-MINUS 10 seconds". 
	    lock steering to up. wait 1.
	    print "T-MINUS  9 seconds".
	    wait 1.
	    
	    print "T-MINUS  8 seconds".
	    wait 1.

	    print "T-MINUS  7 seco...".
	    stage.
	    wait 1.

	    print "......and here we GO, i guess".
	    wait 2.

	    clearscreen.
	    set mode to 2.
	}

	else if mode = 2 { // fly up to 9km
		SET motherstatus TO "Flying up to 9km".
	    lock steering to up.

	    WHEN SHIP:ALTITUDE > 1000 THEN {
			SET g TO KERBIN:MU / KERBIN:RADIUS^2.
			LOCK accvec TO SHIP:SENSORS:ACC - SHIP:SENSORS:GRAV.
		}
		// ACCELLERATION VELOCITY? IS EQUAL TO ACCELLERATION - GRAVITY?
		LOCK gforce TO accvec:MAG / g.
		LOCK dthrott TO 0.05 * (1.2 - gforce).

	    if (ship:altitude > 11000){
	        set mode to 3.
	    }
	}

	else if mode = 3{ // gravity turn
		SET motherstatus TO "Gravity Turn".
	    set targetPitch to max( 8, 90 * (1 - ALT:RADAR / 70000)). 
	    lock steering to heading (90, targetPitch).

	    if SHIP:APOAPSIS > orb{
	        set mode to 4.
	        }
	    if TTW > 20{
	        lock throttle to 20*mass/(maxthrust+0.1).
	    }
	    WHEN SHIP:ALTITUDE > 10000 THEN {
			LOCK dthrott TO 0.05 * (2.0 - gforce).

			WHEN SHIP:ALTITUDE > 20000 THEN { 
				LOCK dthrott TO 0.05 * (4.0 - gforce).
				SET motherstatus TO "STARTING TURN. AIMING EAST TO 45 DEGREE PITCH.".
				LOCK STEERING TO HEADING(90, 45). //eAST 45 DEGREES PITCH

				WHEN SHIP:ALTITUDE > 30000 THEN {
					LOCK dthrott TO 0.05 * (5.0 - gforce).
				}
			}
		}

	}
	else if mode = 4{ // coast to orbit
		SET motherstatus TO "Coasting to orbit".
	    lock throttle to 0.
	    if (SHIP:ALTITUDE > 70000) and (ETA:APOAPSIS > 60) and (VERTICALSPEED > 0) {
	        if WARP = 0 {        
	            wait 1.        
	            SET WARP TO 3. 
	            }
	        }
	    else if ETA:APOAPSIS < 70 {
	        SET WARP to 0.
	        lock steering to heading(90,0).
	        wait 2.
	        set mode to 5.
	        }

	    if (periapsis > 70000) and mode = 4{
	     if WARP = 0 {        
	            wait 1.         
	            SET WARP TO 3. 
	      }
	    }

	}

	else if mode = 5 {
	    if ETA:APOAPSIS < 30 or VERTICALSPEED < 0 {
	        lock throttle to 1.
	        }

	    if (ETA:APOAPSIS > 90) and (apoapsis > orb) { set mode to 4. }

	    if ship:periapsis > orb {
	        lock throttle to 0.
	        set mode to 6.
	    }
	}

	else if mode = 6 {
	    lock throttle to 0.
	    panels on.     //Deploy solar panels
	    lights on.
	    unlock steering.
	    //set mode to 0.
	    print "WELCOME TO A STABE SPACE ORBIT!".
	    wait 2.
	}

	//Display code
	clearscreen.
	print "Mother Status:" + motherstatus.
	print "Status:" + status.
	print "LAUNCH PLAN STAGE " + mode.
	print " ".
	print "Periapsis height: " + round(periapsis, 2) + " m".
	print " Apoapsis height: " + round(apoapsis, 2) + " m".
	print " ETA to Apoapsis: " + round(ETA:APOAPSIS) + " s".
	print "   Orbital speed: " + round(velocity:orbit:MAG, 2)+ " m/s".
	print "        altitude: " + round(altitude, 2) + " m".
	print "thrust to weight: " + round((throttle*maxthrust)/mass).
	print " ".
	print "Currently on Stage: " + stage:number.
	wait 0.2.

	//Staging
	if stage:number > 0 {
	    if maxthrust = 0 {
	        stage.
	    }
	    if stage:number = 4 {
	        WHEN STAGE:SOLIDFUEL <0.1 THEN {
				Stage.
		  }
	    }
	    if stage:number = 3 {
	        WHEN STAGE:SOLIDFUEL <0.1 THEN {
				Stage.
		  }
	    }
	    SET numOut to 0.
	    LIST ENGINES IN engines. 
	    FOR eng IN engines 
	    {
	        IF eng:FLAMEOUT 
	        {
	            SET numOut TO numOut + 1.
	        }
	    }
	    if numOut > 0 { stage. }.
	}
}
