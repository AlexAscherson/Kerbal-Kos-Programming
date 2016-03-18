// You start at point A, your target is somewhere along its orbit at point B and since you're using a Hohmann transfer your intercept point is at C. Your initial orbit has radius r1 = (6378.1 + 500) km = 6878.1 km, while the target's has radius r2 = (6378.1 + 700) km = 7078.1 km.

set currentorbitradius to body:radius+ altitude.
set targetorbitradius to body:radius + target:altitude.

//Transfer Time - Both Methods work

set transfertime to constant():pi * sqrt( (currentorbitradius+targetorbitradius)^3/(8*body:mu) ).  //Standard hoffman transfer.
Print "Transfer Time: "+ round(transfertime) + "s"+"/"+(transfertime/60)+" mins".
//mu = 3.986e5 km^3/s^2 (notice I'm using km for all distances; one must be careful that the units match), we get:

//Transfer Time via SMA
set sma_transfer to (currentorbitradius + targetorbitradius)/2.
set transfertime1 to 2 * constant():pi * sqrt(sma_transfer^3/body:mu).
print "T+" + round(missiontime) + " Hohmann apoapsis: " + round(targetorbitradius/1000) + "km, transfer time: " + (transfertime1/120) + "min".

// Now, the crucial part for the rendezvous to work is to start the transfer at the right time so that when you reach point C the target is also there. 
//We know that in time tH you travel 180Ã‚Â°, but how much (in terms of angle) does the target travel? Since the orbit is circular, this is easy to compute:

set theta to sqrt(body:mu/targetorbitradius^3) * transfertime. //
print "theta(degrees target will move during transfer): " +round(theta)+ " Rad".
print "theta (deg): " + round(theta*(180/constant():pi))+" deg".

// The correct phase angle for the rendezvous, phi, is then the difference between the angle you travel, 180Ã‚Â°, and the angle the target travels:

set phi to constant():pi - theta.
print "Phase angle needed for rendevous(phi) in rad: " + phi +" rad".
set phi0 to constant():pi * (1 - sqrt((1+currentorbitradius/targetorbitradius)^3 / 8) ).
print "Safety check: phi0: "+phi0.

print "Phase angle needed for rendevous(phi) in degrees: " + phi*(180/constant():pi) +" deg". // This means that the target must be phi degrees ahead of you when you start the transfer if you are to intercept it at C.

set phaseanglerateofchange to sqrt(body:mu/targetorbitradius^3) - sqrt(body:mu/currentorbitradius^3).
print "phase angle ro change: "+ phaseanglerateofchange+ " rad/s".
print "phase angle ro change: "+ (57.29577951308*phaseanglerateofchange)+ " deg/s?".

//Get current Angle on target
set Angle1 to obt:lan+obt:argumentofperiapsis+obt:trueanomaly. //the ships angle to universal reference direction.
set Angle2 to target:obt:lan+target:obt:argumentofperiapsis+target:obt:trueanomaly. //target angle
set Angle3 to Angle2 - Angle1.
set Angle3 to Angle3 - 360 * floor(Angle3/360).
Print "current angle to target: "+ angle3.


// current target angular position 
print "//////NEW BLOCK:///".
set positiontarget to target:position - body:position.
set positionlocal to V(0,0,0) - body:position.
set targetangularpostioncurrent to arctan2(positiontarget:x,positiontarget:z).
print "target angular position 1: "+targetangularpostioncurrent.
// target angular position after transfer
set target_sma to target:obt:semimajoraxis.                       // for circular orbits
set orbitalperiodtarget to 2 * constant():pi * sqrt(target_sma^3/body:mu).      // mun/minmus orbital period
set sma_ship to obt:semimajoraxis.                      
set orbitalperiodship to 2 * constant():pi * sqrt(sma_ship^3/body:mu).      // ship orbital period

set transferangle to (transfertime1/2) / orbitalperiodtarget * 360. 
Print "TRANSFER ANGLE V2: " +transferangle.           // mun/minmus angle for hohmann transfer
set das to (orbitalperiodship/2) / orbitalperiodtarget * 360.           // half a ship orbit to reduce max error to half orbital period

set at1 to targetangularpostioncurrent - das - transferangle.                // assume counterclockwise orbits

print "T+" + round(missiontime) + " " + target:name + ", orbital period: " + round(orbitalperiodtarget/60,1) + "min".
print "T+" + round(missiontime) + " | now: " + round(targetangularpostioncurrent) + "', xfer: " + round(transferangle) + "', rdvz: " + round(at1) + "'".



//number of angles thatneed to pass till we get to the right one
set angleslefts to angle3 - (phi*(180/constant():pi)).
print "ANGLES LEFT: " + round(angleslefts).

//Time till burn window
set tb to ((angle3-(phi*(180/constant():pi)))/(57.29577951308*phaseanglerateofchange)). //seconds till window
print tb + " seconds to burn window".

// eta to maneuver node
// current ship angular position 
set shipangularpostion_current to arctan2(positionlocal:x,positionlocal:z).
// ship angular position for maneuver
set shipangularpostion_manuever_temp to mod(at1 + 180, 360).
set shipangularpostion_manuever to shipangularpostion_manuever_temp.
until shipangularpostion_current > shipangularpostion_manuever { set shipangularpostion_manuever to shipangularpostion_manuever - 360. }
set etanode to (shipangularpostion_current - shipangularpostion_manuever) / 360 * orbitalperiodship.
print "Time till window2:" +etanode.

// Finally, the delta-v requirement is simply that of the Hohmann transfer:
set dv1 to sqrt(body:mu/currentorbitradius) * (sqrt( 2*targetorbitradius/(currentorbitradius+targetorbitradius) ) - 1).
print "Dv for transfer: "+ dv1 + " m/s".
set dv2 to sqrt(body:mu/targetorbitradius) * (1 - sqrt( 2*currentorbitradius/(currentorbitradius+targetorbitradius) )).
print "DV to match speed: "+ dv2 + "m/s".

//Ship obital period 
set positionlocal to V(0,0,0) - body:position.
set sma_ship to positionlocal:mag.                       
set orbitalperiodship to 2 * constant():pi * sqrt(sma_ship^3/body:mu).
print "orbitalperiodship"+orbitalperiodship/60 +" mins".



clearscreen.

print "".
Print "Transfer Time:   "+(transfertime/60)+" mins" + round(transfertime) + "s".
print "Transfer Time 2: " + (transfertime1/120) + "min".

print "theta1 (degrees target will move during transfer): " + theta*(180/constant():pi)+" deg".

print "Phi: - Phase angle needed for rendevous:  " + phi*(180/constant():pi) +" deg". 
Print "Phi2:- Phase angle needed for rendevous: " + transferangle. 

Print "current angle to target: "+ angle3.

print "Time till window1: "+tb + " seconds".
print "Time till window2: "+etanode.

//the time to burn is the current time + the time to the correct phase angle.  Travel time needs to be equal to the half of the targets period, - the travel time.
set nd to node(time:seconds + abs(tb), 0, 0, dv1).
add nd.

