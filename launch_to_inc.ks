function launch_to_inclination {
    PARAMETER targetAltitude.
    PARAMETER targetInclination.
     
    set launchLatitude to SHIP:LATITUDE.
     
    set targetFacing to Arcsin(Max(-1, Min(1, Cos(targetInclination)/Cos(launchLatitude)))).
    lock currentInclination to Ship:Obt:Inclination.
     
    set v_orbit to SQRT(BODY:MU / (SHIP:BODY:RADIUS + targetAltitude)).
    set v_orbit_x to COS(targetInclination)*v_orbit.
     
    set v_equatorial to (2*CONSTANT():PI*SHIP:BODY:RADIUS)/SHIP:BODY:ROTATIONPERIOD.
    set v_rot to COS(SHIP:LATITUDE)*v_equatorial.
     
    function getHorizontalSpeed {
            return cos(currentInclination)*Ship:groundspeed.
    }
     
    print "Preparing ascent...".
     
    if (v_orbit_x > v_rot) {
     
            lock error to targetInclination - currentInclination.                           // positive     [0, ~90]
            set maxError to error.
            lock transformedError to Log10(error + 1)/Log10(maxError + 1).
           
            set maxCorrection to 90-targetInclination.                                                      // positive
            lock correction to maxCorrection*transformedError.                                      // positive, aproaching zero as error aproaches zero.
           
            lock correctedFacing to targetFacing - correction.
     
    } else {
            // DOESNT WORK
     
            set error to targetInclination - currentInclination.                            // 89
            set maxError to error.                                                                                          // 89
            lock transformedError to Log10(error + 1)/Log10(maxError + 1).          // 1
     
            set maxCorrection to 180 - targetInclination.                                           // 91
            lock correction to maxCorrection*transformedError.                                                                     
     
            lock correctedFacing to targetFacing - correction.
    }
     
    print "Throttling...".
     
    set THROTTLEBUFFER to 1.
    lock THROTTLE to MAX(MIN(THROTTLEBUFFER, 1), 0).
     
    set runmode to 1.
    until (runmode = 0) {
     
            if (runmode = 1) {
                    lock STEERING to heading(correctedFacing, 80).
                    set THROTTLEBUFFER to 1.
                    if ship:status = "prelaunch" {
                        stage.
                    }
                    set runmode to 2.
            }
           
            else if (runmode = 2) {
                    lock STEERING to heading(correctedFacing, 45).
                   
                    if (SHIP:ALTITUDE > 2000) {
                            set runmode to 3.
                    }
            }
           
            else if (runmode = 3) {
                    lock STEERING to heading(correctedFacing, 90 * (1 - ALT:RADAR / get_min_safe_orbit())).
                    set THROTTLEBUFFER to 0.6.
                   
                    if (SHIP:APOAPSIS > 100000) {
                            set runmode to 4.
                    }
            }
           
            else {
                    print "Illegal runmode: " + runmode + "! Terminating.".
                    set runmode to 0.
            }      
           
            clearscreen.
            print "Error:                " + Round(error, 2) at (5,5).
            print "TransformedError: " + Round(transformedError, 2) at (5,6).
            print "Correction:       " + Round(correction, 2) at (5,7).
            print "Corrected:        " + Round(correctedFacing, 2) at (5,8).
            print "Speed:        " + Round(getHorizontalSpeed(), 2) at (5,9).
    }
}       

launch_to_inclination((target:ALTITUDE/10)-1000,target:orbit:Inclination).