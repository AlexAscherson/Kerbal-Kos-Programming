// set timetoimpactv to (alt:radar/VERTICALSPEED).

set timetoimpactv to (1000/50)
print "Raw Time to impact "+ timetoimpactv.

set GM to ship:body:mu.
		set R to ship:body:radius. 
		set g0 to GM/(R^2).


set projectedspeed to VERTICALSPEED.
set projectedalt to alt:radar.
set calc to false.
set timetoimpactv0 to round(timetoimpactv).
set timetoimpactv1 to round(timetoimpactv).
print "Number of seconds to impact- RAW " + timetoimpactv0.
until calc {
	// How many seconds till impact?
	//wait 0.1.

	if projectedalt > 1 {
		//No impact yet - 
		print "starting impact time " + timetoimpactv0.
		set projectedspeed to projectedspeed + g0. // After one more second GU acc
		set projectedalt to (projectedalt-projectedspeed). // After 1 seconds desent

		if projectedalt < 0 {
			set calc to true.
			print "gravatationl increase p/s " + g0.
			print "its this loop and time to impact = "+ timetoimpactv0.
			print "difference "+ (timetoimpactv1-timetoimpactv0).
		}
		else{
			set timetoimpactv0 to (timetoimpactv0 - 1).
			print "alt still above 0 "+ timetoimpactv0 + "alt" + projectedalt.
		}
	}
}