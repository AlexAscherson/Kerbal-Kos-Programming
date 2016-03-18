


//Obtain the planetary phase angle, ejection angle and ejection velocity values according to your origin's obodyradiusit, your destination's obodyradiusit and your parking obodyradiusit information, as described above.
//Timewarp until the planetary alignment is right. For a positive phase angle, you want the destination to be ahead of you, and for a negative phase angle you want it behind you.
//Timewarp some more, until your ship is properly positioned for the transfer burn in the parking obodyradiusit. You need to put yourself at the ejection angle before your origin's prograde (for a higher destination obodyradiusit) or retrograde (for a lower destination) obodyradiusital heading, as shown in the right image.
//Once positioned, turn prograde and burn, until you reach ejection velocity.

// Check inclination is 0 and heading is 90 degrees

// We are going to make a Hoffman transfer up to the radius of the moons obodyradiusit.

// Place your ship in a circular, 0° inclination parking obodyradiusit around your planet/moon of origin. For optimal efficiency, make this obodyradiusit at a 90° heading.

// Calculate phase angle

function calcPhaseAngle {

	parameter destap.
	parameter destpe.

	// phaseangle = 1 / (2*sqrt (d^3 / h^3)).

	//s = your starting semi-major axis.  
	set startSMA to obt:semimajoraxis.

	//d = your destination semi-major axis.
	set destSMA to ((destap+destpe)/2).

	//h = your transfer semi-major axis. 
	set transferSMA to ((startSMA+destSMA)/2).

	set phaseangle to (1 / (2*sqrt((destSMA^3) / (transferSMA^3)))).
	return phaseangle.
}

// Calculate ejection angle

// Calculate ejection velocity

//  Timewarp to planetary alignment / Set node? / calc alignment
//  For a positive phase angle target is ahead, negative its behind 
// Timewarp some more, until your ship is properly positioned for the transfer burn in the parking obodyradiusit. 
// You need to put yourself at the ejection angle before your origin's prograde (for a higher destination obodyradiusit) or retrograde (for a lower destination) obodyradiusital heading


Transfer angle - This is the angle that the vessel travels between the departure and arrival point. In case of Hohmann transfer, the transfer angle is always 180 degrees. This means that whenever you plan a Hohmann transfer, the apoapsis of your trajectory should be exactly on the other side of Kebodyradiusol (the sun).

function hofftransv2 {
	parameter tgtbody.
	// move origin to central body (i.e. Kebodyradiusin)
   // use this later (ps) set positionlocal to V(0,0,0) - body:position.
    set positiontarget to tgtbody:position - body:position.
    // Hohmann transfer obodyradiusit period
    set bodyradius to body:radius.
    set altitudecurrent to bodyradius + altitude.                 // actual distance to body
    set altitudeaverage to bodyradius + (periapsis+apoapsis)/2.  // average radius (burn angle not yet known)

    set currentvelocity to velocity:orbit:mag.          // actual velocity
    set va to sqrt( currentvelocity^2 - 2*body:mu*(1/altitudeaverage - 1/altitudecurrent) ). // average velocity 

    set soi to (tgtbody:soiradius).
    set transferAp to positiontarget:mag - soi/2.
    //Transfer SMA
    set smah to (altitudeaverage + transferAp)/2.

    set transfertime to 2 * pi * sqrt(smah^3/body:mu).
    print "T+" + round(missiontime) + " Hohmann apoapsis: " + round(transferAp/1000) + "km, transfer time: " + round(transfertime/120) + "min".

}