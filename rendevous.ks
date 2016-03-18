// You start at point A, your target is somewhere along its orbit at point B and since you're using a Hohmann transfer your intercept point is at C. Your initial orbit has radius r1 = (6378.1 + 500) km = 6878.1 km, while the target's has radius r2 = (6378.1 + 700) km = 7078.1 km.

set currentorbitradius to body:radius+ altitude.
set targetorbitradius to body:radius + target:altitude.
set transfertime to constant():pi * sqrt( (currentorbitradius+targetorbitradius)^3/(8*body:mu) ).  //Standard hoffman transfer.
Print "Transfer Time: "+ round(transfertime) + "s"+"/"+round(transfertime/60)" mins".
//mu = 3.986e5 km^3/s^2 (notice I'm using km for all distances; one must be careful that the units match), we get:

// Now, the crucial part for the rendezvous to work is to start the transfer at the right time so that when you reach point C the target is also there. 
//We know that in time tH you travel 180Ã‚Â°, but how much (in terms of angle) does the target travel? Since the orbit is circular, this is easy to compute:

// theta_target = omega_target * transfertime

// where omega_target is the angular speed of the target, which for a circular orbit is given by omega = sqrt(mu/r^3), with r the radius of the orbit. Thus:

//ALL THESE ARE EQUIVIALNT
set theta to sqrt(body:mu/targetorbitradius^3) * transfertime.
set theta0 to sqrt(body:mu/targetorbitradius^3) * constant():pi * sqrt( (currentorbitradius+targetorbitradius)^3/(8*body:mu) ).
set theta1 to constant():pi * sqrt( (currentorbitradius+targetorbitradius)^3/(8*targetorbitradius^3) ).
set theta2 to constant():pi * sqrt( (1+currentorbitradius/targetorbitradius)^3 / 8 ).

print "theta: " +theta+ " Rad".
print "theta0: " +theta0+ " Rad".
print "theta1: " +theta1+ " Rad".
print "theta2: " +theta2+ " Rad".

// theta = 3.07544 rad
//times rad by 180/pi to get the angle in degrees
// = 176.20 deg

// The correct phase angle for the rendezvous, phi, is then the difference between the angle you travel, 180Ã‚Â°, and the angle the target travels:

set phi to constant():pi - theta.
print "Phase angle needed for rendevous(phi) in rad: " + phi +" rad".
print "Phase angle needed for rendevous(phi) in degrees: " + phi*(180/constant():pi) +" deg".
// = pi - omega_target*tH
//set phi1 to constant():pi - constant():pi * sqrt( (1+currentorbitradius/targetorbitradius)^3 / 8 ).

set phi0 to constant():pi * (1 - sqrt((1+currentorbitradius/targetorbitradius)^3 / 8) ).
print "Safety check: phi0: "+phi0.
// In this case, we get:

// phi = 0.066293 rad

// = 3.8 deg

// This means that the target must be phi degrees ahead of you when you start the transfer if you are to intercept it at C.

// Finally, the delta-v requirement is simply that of the Hohmann transfer:

set dv1 to sqrt(body:mu/currentorbitradius) * (sqrt( 2*targetorbitradius/(currentorbitradius+targetorbitradius) ) - 1).

// = 0.054353 km/s

// = 54.35 m/s

print "Dv for transfer: "+ dv1 + " km/s".
print "Dv for transfer: "+ (dv1 *1000) + (" m/s").

// for the initial burn at A, and

set dv2 to sqrt(body:mu/targetorbitradius) * (1 - sqrt( 2*currentorbitradius/(currentorbitradius+targetorbitradius) )).
print "DV to match speed: "+ dv2 + "m/s".
// = 0.053965 km/s

// = 53.96 m/s

// for the circularization burn at C, which in this case is the burn to match speeds with the target. The total delta-v is thus about 100.8 m/s.

// If initially the target is not +3.8 degrees ahead of you, then you'll have to wait for the phase angle between you two to reach that value. If you're at 4 o'clock and the target is at 12 o'clock (and moving counter-clockwise), that means your current phase angle is +120Ã‚Â° (target 120Ã‚Â° ahead). Since you're in a lower orbit, you're moving faster and are catching up, and thus the phase angle is reducing with time. If you wait enough, it'll come down to +3.8Ã‚Â° at which point you should start the transfer.

// We can figure out how long that will take by computing the phase angle's rate of change, which is simply the difference between your target's angular speed and yours:

// d phi / dt = omega_target - omega_you

set phaseanglerateofchange to sqrt(body:mu/targetorbitradius^3) - sqrt(body:mu/currentorbitradius^3).
// = sqrt(mu/r2^3) - sqrt(mu/r1^3)
print "phase angle change: "+ phaseanglerateofchange+ " rad/s".
// = -4.6578e-05 rad/s
print "phase angle change: "+ ((180/constant():pi)*phaseanglerateofchange)+ " deg/h?".
// = -9.6073 deg/h