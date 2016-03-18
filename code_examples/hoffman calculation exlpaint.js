// You start at point A, your target is somewhere along its orbit at point B and since you're using a Hohmann transfer your intercept point is at C. Your initial orbit has radius r1 = (6378.1 + 500) km = 6878.1 km, while the target's has radius r2 = (6378.1 + 700) km = 7078.1 km.

set currentorbitradius to  6878.1*10.
set targetorbitradius to 7078.1*10.
set bodymu to 

 3.986*10^5 e5 km^3/s^2

set transfertime to constant():pi * sqrt( (currentorbitradius+targetorbitradius)^3/(8*bodymy) ).  //Standard hoffman transfer.
Print "Transfer Time: "+ round(transfertime) + "s"+"/"+round(transfertime/60)+" mins".
//mu = 3.986e5 km^3/s^2 (notice I'm using km for all distances; one must be careful that the units match), we get:

// Now, the crucial part for the rendezvous to work is to start the transfer at the right time so that when you reach point C the target is also there. 
//We know that in time tH you travel 180Ã‚Â°, but how much (in terms of angle) does the target travel? Since the orbit is circular, this is easy to compute:

set theta to sqrt(bodymy/targetorbitradius^3) * transfertime. //
print "theta(degrees target will move during transfer): " +round(theta)+ " Rad".
print "theta (deg): " + round(theta*(180/constant():pi))+" deg".

// The correct phase angle for the rendezvous, phi, is then the difference between the angle you travel, 180Ã‚Â°, and the angle the target travels:

set phi to constant():pi - theta.
print "Phase angle needed for rendevous(phi) in rad: " + phi +" rad".
set phi0 to constant():pi * (1 - sqrt((1+currentorbitradius/targetorbitradius)^3 / 8) ).
print "Safety check: phi0: "+phi0.

print "Phase angle needed for rendevous(phi) in degrees: " + phi*(180/constant():pi) +" deg". // This means that the target must be phi degrees ahead of you when you start the transfer if you are to intercept it at C.

set phaseanglerateofchange to sqrt(bodymy/targetorbitradius^3) - sqrt(bodymy/currentorbitradius^3).
print "phase angle ro change: "+ phaseanglerateofchange+ " rad/s".
print "phase angle ro change: "+ (57.29577951308*phaseanglerateofchange)+ " deg/s?".

//Get current Angle on target
set Angle1 to obt:lan+obt:argumentofperiapsis+obt:trueanomaly. //the ships angle to universal reference direction.
set Angle2 to target:obt:lan+target:obt:argumentofperiapsis+target:obt:trueanomaly. //target angle
set Angle3 to Angle2 - Angle1.
set Angle3 to Angle3 - 360 * floor(Angle3/360).
Print "current angle to target: "+ angle3.

//number of angles thatneed to pass till we get to the right one
set angleslefts to angle3 - (phi*(180/constant():pi)).
print "ANGLES LEFT: " + round(angleslefts).

//Time till burn window
set tb to ((angle3-(phi*(180/constant():pi)))/(57.29577951308*phaseanglerateofchange)). //seconds till window
print tb + " seconds to burn window".

// Finally, the delta-v requirement is simply that of the Hohmann transfer:
set dv1 to sqrt(bodymy/currentorbitradius) * (sqrt( 2*targetorbitradius/(currentorbitradius+targetorbitradius) ) - 1).
print "Dv for transfer: "+ dv1 + " m/s".
set dv2 to sqrt(bodymy/targetorbitradius) * (1 - sqrt( 2*currentorbitradius/(currentorbitradius+targetorbitradius) )).
print "DV to match speed: "+ dv2 + "m/s".

//Ship obital period 
set positionlocal to V(0,0,0) - body:position.
set sma_ship to positionlocal:mag.                       
set orbitalperiodship to 2 * constant():pi * sqrt(sma_ship^3/bodymy).
print "orbitalperiodship"+orbitalperiodship/60 +" mins".


//the time to burn is the current time + the time to the correct phase angle.  Travel time needs to be equal to the half of the targets period, - the travel time.
set nd to node(time:seconds + abs(tb), 0, 0, dv1).
add nd.