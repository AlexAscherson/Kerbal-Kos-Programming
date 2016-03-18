SET motherstate to 1.

WHEN STAGE:SOLIDFUEL <0.1 THEN {
	Stage.
 }

SET thrott TO 1.
SET dthrott TO 0.
LOCK THROTTLE TO thrott.
LOCK STEERING TO R(0,0,-90) + HEADING(90,90).
STAGE.
Print "launching".
set launchmode to 1.

until launchmode = 0 {

  if maxthrust = 0 {
    stage.
  }
  SET numOut to 0.
  LIST ENGINES IN engines.
  FOR eng IN engines {
    print eng:FLAMEOUT.
    IF eng:FLAMEOUT
    {
      SET numOut TO numOut + 1.
    }
  }
  if numOut > 0 { stage. }.

  WHEN SHIP:ALTITUDE > 1000 THEN {
  	SET g TO KERBIN:MU / KERBIN:RADIUS^2.
  	LOCK accvec TO SHIP:SENSORS:ACC - SHIP:SENSORS:GRAV.
  	LOCK gforce TO accvec:MAG / g.
  	LOCK dthrott TO 0.05 * (1.2 - gforce).

  	WHEN SHIP:ALTITUDE > 10000 THEN {
  		LOCK dthrott TO 0.05 * (2.0 - gforce).

  		WHEN SHIP:ALTITUDE > 20000 THEN { 
  			LOCK dthrott TO 0.05 * (4.0 - gforce).
  			PRINT "STARTING TURN. AIMING EAST TO 45 DEGREE PITCH.".
  			LOCK STEERING TO HEADING(90, 45). //eAST 45 DEGREES PITCH

  			WHEN SHIP:ALTITUDE > 30000 THEN {
  			LOCK dthrott TO 0.05 * (5.0 - gforce).
  				WHEN SHIP:ALTITUDE > 40000 THEN {
  					PRINT "ENDING GRAVITY TURN - BURNING TO APOAPSIS".
  					LOCK STEERING TO HEADING(90, 0).
  					WHEN SHIP:APOAPSIS > 100000 THEN {
  						LOCK THROTTLE TO 0.
  						PRINT "Target APOAPSIS reached..Coasting to Circularisation burn".
  						SET time_to_ap to (round(eta:apoapsis/60, 2)).
  						PRINT "T-minus " + round(eta:apoapsis/60, 2) + "Mins to Apoapsis".
  						SET time_to_ap to (round(eta:apoapsis/60, 2)).
  						PRINT "Speed needed for orbit =" + velocity:orbit.
  						Print "Running Circularisation calculation + node creation".
              set launchmode to 0.
  					}
  				}
  			}
  		}
  	}
  }
}

RUN circ.
Print "Circ calc complete".
Print "program completed".

