
function transfer_node{
    parameter tgtbody.    

    if (apoapsis-periapsis) > 500 {
        notify("Circularising orbit for Transfer").
        copy circ from 0.
        run circ.
        circ_with_node().
        execute_node().
        delete circ.
    }

    set done to False.
    set delaynode to 0.

    until done {
        print "Running Hoffman calculation".
        CalcHoffmantransfer(tgtbody).
        print "Checking result".
        print tgtbody + "this is targetbody".

        if encounter = "none"{
            print "T+" + round(missiontime) + " WARNING! No encounter found.".
            remove nd.
            set done to True.
        } else {

            if encounter:body:name = tgtbody:name {
            set done to True.
             } else {
                print "T+" + round(missiontime) + " Trajectory intercepts " + encounter:body:name + ", wait for one orbit.".
                set delaynode to delaynode + orbitalperiodship.
                remove nd.
                // recalculation of maneuver angle required (Minmus has moved to new location)
            }
        }
    }
}

    //Calculate hoffman trnsfer logic. 
function CalcHoffmantransfer{
    parameter tgtbody.
	// move origin to central body (i.e. Kebodyradiusin)
    set positionlocal to V(0,0,0) - body:position.
    set positiontarget to tgtbody:position - body:position.

    // Hohmann transfer orbit period
    set bodyradius to body:radius.
    set altitudecurrent to bodyradius + altitude.                 // actual distance to body
    set altitudeaverage to bodyradius + (periapsis+apoapsis)/2.  // average radius (burn angle not yet known)
    set currentvelocity to velocity:orbit:mag.          // actual velocity
    set averagevelocity to sqrt( currentvelocity^2 - 2*body:mu*(1/altitudeaverage - 1/altitudecurrent) ). // average velocity 
    set soi to (tgtbody:soiradius).
    set transferAp to positiontarget:mag - soi/2.

    //Transfer SMA
    set sma_transfer to (altitudeaverage + transferAp)/2.
    set transfertime to 2 * constant():pi * sqrt(sma_transfer^3/body:mu).
    print "T+" + round(missiontime) + " Hohmann apoapsis: " + round(transferAp/1000) + "km, transfer time: " + round(transfertime/120) + "min".

    // current target angular position 
    set targetangularpostioncurrent to arctan2(positiontarget:x,positiontarget:z).
    // target angular position after transfer
    set target_sma to positiontarget:mag.                       // mun/minmus have a circular orbit
    set orbitalperiodtarget to 2 * constant():pi * sqrt(target_sma^3/body:mu).      // mun/minmus orbital period
    set sma_ship to positionlocal:mag.                       
    set orbitalperiodship to 2 * constant():pi * sqrt(sma_ship^3/body:mu).      // ship orbital period

    set transferangle to (transfertime/2) / orbitalperiodtarget * 360.            // mun/minmus angle for hohmann transfer
    set das to (orbitalperiodship/2) / orbitalperiodtarget * 360.           // half a ship orbit to reduce max error to half orbital period

    set at1 to targetangularpostioncurrent - das - transferangle.                // assume counterclockwise orbits

    print "T+" + round(missiontime) + " " + tgtbody:name + ", orbital period: " + round(orbitalperiodtarget/60,1) + "min".
    print "T+" + round(missiontime) + " | now: " + round(targetangularpostioncurrent) + "', xfer: " + round(transferangle) + "', rdvz: " + round(at1) + "'".
    
    // current ship angular position 
    set shipangularpostion_current to arctan2(positionlocal:x,positionlocal:z).
    
    // ship angular position for maneuver
    set shipangularpostion_manuever_temp to mod(at1 + 180, 360).

    // eta to maneuver node
    set shipangularpostion_manuever to shipangularpostion_manuever_temp.
    until shipangularpostion_current > shipangularpostion_manuever { set shipangularpostion_manuever to shipangularpostion_manuever - 360. }
    set etanode to (shipangularpostion_current - shipangularpostion_manuever) / 360 * orbitalperiodship.

    print "T+" + round(missiontime) + " ship, orbital period: " + round(orbitalperiodship/60,1) + "m".
    print "T+" + round(missiontime) + " | now: " + round(shipangularpostion_current) + "', maneuver: " + round(shipangularpostion_manuever) + "' in " + round(etanode/60,1) + "m".
    
    // hohmann orbit properties
    set transferdv to sqrt( averagevelocity^2 - body:mu * (1/sma_transfer - 1/sma_ship ) ).
    set dv to transferdv - averagevelocity.
    print "T+" + round(missiontime) + " Hohmann burn: " + round(currentvelocity) + ", dv:" + round(dv) + " -> " + round(transferdv) + "m/s".
    // setup node 
    if delaynode = 0 {
      set nd to node(time:seconds + etanode, 0, 0, dv).
    } else {
      set nd to node(time:seconds + (delaynode+ etanode), 0, 0, dv).
    }
    add nd.
    wait 1.
}