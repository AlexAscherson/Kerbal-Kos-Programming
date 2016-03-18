//Launch Sequence

Print "Counting Down:".
FROM {local countdown is 10.} UNTIL countdown = 0 STEP {set countdown to countdown-1.} Do {
	PRINT "..."+ countdown.
	WAIT 1. // Pauses script here for 1 second.
}

PRINT "Main throttle up. 2 seconds to stabilize it.".
LOCK THROTTLE TO 1.0. //1 IS MAX.
LOCK STEERING TO UP. //Lock steering 
WAIT 2. // Give throttle time to adjust

WHEN STAGE:LIQUIDFUEL < 0.001 THEN {
	PRINT "STAGE LIQUIDFUEL DEPLETED.  ATTEMPTING TO STAGE.".
	STAGE.
	PRESERVE.
}

//UNTIL SHIP:MAXTHRUST>0 {
//	WAIT 0.5. //PAUSE BETWEN STAGE ATTEMPTS
//	PRINT "Stage activated".
//	STAGE. // Like hitting the spacebar
//}

WAIT UNTIL SHIP:ALTITUDE > 70000. //WAIT UNTIL SHIUP IS HIGH UP

//Whenever you call the function HEADING(a,b), it makes a Direction oriented as follows on the navball:
//Point at the compass heading A.
//Pitch up a number of degrees from the horizon = to B.
//So for example, HEADING(45,10) would aim northeast, 10 degrees above the horizon. Combining this with the WHEN command from before, we get this section:

WHEN SHIP:ALTITUDE >10000 THEN {
	PRINT "STARTING TURN. AIMING EAST TO 45 DEGREE PITCH.".
	LOCK STEERING TO HEADING(90, 45). //eAST 45 DEGREES PITCH
}

WHEN SHIP:ALTITUDE > 40000 THEN {
	PRINT "ENDING GRAVITY TURN - BURNING TO HORIZON".
	LOCK STEERING TO HEADING(90, 0).
}