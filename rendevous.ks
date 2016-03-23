function get_rendevous_nodes{
  // You start at point A, your target is somewhere along its orbit at point B and since you're using a Hohmann transfer your intercept point is at C. Your initial orbit has radius r1 = (6378.1 + 500) km = 6878.1 km, while the target's has radius r2 = (6378.1 + 700) km = 7078.1 km.
    until false{
        wait 0.1.
        clearscreen.
        set currentorbitradius to body:radius+ altitude.
        set targetorbitradius to body:radius + target:altitude.

        //Transfer Time - Both Methods work
        set transfertime to constant():pi * sqrt( (currentorbitradius+targetorbitradius)^3/(8*body:mu) ).  //Standard hoffman transfer.
        //Transfer Time via SMA
        set sma_transfer to (currentorbitradius + targetorbitradius)/2.
        set transfertime1 to 2 * constant():pi * sqrt(sma_transfer^3/body:mu).
     
        set theta to sqrt(body:mu/targetorbitradius^3) * transfertime. // theta(degrees target will move during transfer):
        
        // The correct phase angle for the rendezvous, phi, is then the difference between the angle you travel, 180Ã‚Â°, and the angle the target travels:
        set phi to constant():pi - theta.
        //print "Phase angle needed for rendevous(phi) in rad: " + phi +" rad".
        set phi0 to constant():pi * (1 - sqrt((1+currentorbitradius/targetorbitradius)^3 / 8) ).

        set phaseanglerateofchange to sqrt(body:mu/targetorbitradius^3) - sqrt(body:mu/currentorbitradius^3).

        //Get current Angle on target
        set Angle1 to obt:lan+obt:argumentofperiapsis+obt:trueanomaly. //the ships angle to universal reference direction.
        set Angle2 to target:obt:lan+target:obt:argumentofperiapsis+target:obt:trueanomaly. //target angle
        lock Angle3 to Angle2 - Angle1.
        lock Angle4 to Angle3 - 360 * floor(Angle3/360). 

        // current target angular position 
        set positiontarget to target:position - body:position.
        set positionlocal to V(0,0,0) - body:position.
        set targetangularpostioncurrent to arctan2(positiontarget:x,positiontarget:z).
        lock shipangularpostion_current to arctan2(positionlocal:x,positionlocal:z).

        //Time till burn window
        set tb to ((angle4-(phi*(180/constant():pi)))/(57.29577951308*phaseanglerateofchange)). //seconds till window
        
        // Finally, the delta-v requirement is simply that of the Hohmann transfer:
        set dv1 to sqrt(body:mu/currentorbitradius) * (sqrt( 2*targetorbitradius/(currentorbitradius+targetorbitradius) ) - 1). //  print "Dv for transfer: "+ dv1 + " m/s".
        set dv2 to sqrt(body:mu/targetorbitradius) * (1 - sqrt( 2*currentorbitradius/(currentorbitradius+targetorbitradius) )).//  print "DV to match speed: "+ dv2 + "m/s".   

        set intercept_angle to  phi*(180/constant():pi) - angle4.
        set angles_to_intercept to abs(abs(intercept_angle)- abs(shipangularpostion_current) ).

        print "theta1 (degrees target will move during transfer): " + theta*(180/constant():pi)+" deg".
        print "Phi: - Phase angle needed for rendevous:  " + phi*(180/constant():pi) +" deg". 
        Print "current angle to target: "+ angle4.
        //the time to burn is the current time + the time to the correct phase angle.  Travel time needs to be equal to the half of the targets period, - the travel time.
        print "This is our current angular position from PE" + shipangularpostion_current.
        //  This is 0 at pe, negative between pe and ae up to -180, becomes positive at ap and declines to 0 at pe.
        Print "This is the position we need to be when we calculate"+ (angle4-( phi*(180/constant():pi))).
        //set seconds_to_intercept_point to (abs(abs(shipangularpostion_current) - (angle4-( phi*(180/constant():pi))))) /angles_per_pecond.
        print "angles_to_intercept" + angles_to_intercept.
            
        if angles_to_intercept < 5  {
            PRINT "Close to calculation point, kill speed.".
            set warp to 0.
            if angles_to_intercept < 0.2 {  // changed this from 0.5
                print "condition true" + (abs(abs(shipangularpostion_current) - (angle4-( phi*(180/constant():pi))))).
                set warp to 0.
                break.
            }        
        } else {
            set warp to 4.
        }
    }
    set nd to node(time:seconds + abs(tb), 0, 0, dv1).
    add nd.
}

function establish_rendevous{
    copy rendevous_lib from 0.
    run rendevous_lib.

    notify("adjusting orbit for rendevous").
    node_change_apsis("p", target:periapsis*0.80).
    execute_node().
    node_change_apsis("a", target:apoapsis*0.80).
    execute_node().
    copy inc from 0.
    run inc.
    match_target_inclination_node(target).
    execute_node().
    notify("Orbit Now Suitable for rendevous").
    copy execute_node from 0.
    run execute_node.
    get_rendevous_nodes().
    execute_node().

    until target:distance < 500 {
        
        rdv_cancel(target).
        rdv_approach(target, 30).
        rdv_await_nearest(target, 500).
    }
    RDV_CANCEL_relative_velocity(target).

    rdv_await_nearest(target,500).
    red_cancel_relative_velocity(target).
}

