declare parameter tgtbody.
// setup a Hohmann transfer orbit
// prerequisite: ship in circular orbit
set done to False.
until done {
    // move origin to central body (i.e. Kerbin)
    set ps to V(0,0,0) - body:position.
    set pt to tgtbody:position - body:position.
    // Hohmann transfer orbit period
    set ra to rb + (periapsis+apoapsis)/2.  // average radius (burn angle not yet known)
    set vom to velocity:orbit:mag.          // actual velocity
    set r to rb + altitude.                 // actual distance to body
    set va to sqrt( vom^2 - 2*mu*(1/ra - 1/r) ). // average velocity 
    run soi(tgtbody).
    set apoh to pt:mag - soi/2.
    set smah to (ra + apoh)/2.
    set oph to 2 * pi * sqrt(smah^3/mu).
    print "T+" + round(missiontime) + " Hohmann apoapsis: " + round(apoh/1000) + "km, transfer time: " + round(oph/120) + "min".
    // current target angular position 
    set at0 to arctan2(pt:x,pt:z).
    // target angular position after transfer
    set smat to pt:mag.                       // mun/minmus have a circular orbit
    set opt to 2 * pi * sqrt(smat^3/mu).      // mun/minmus orbital period
    set smas to ps:mag.                       
    set ops to 2 * pi * sqrt(smas^3/mu).      // ship orbital period
    set da to (oph/2) / opt * 360.            // mun/minmus angle for hohmann transfer
    set das to (ops/2) / opt * 360.           // half a ship orbit to reduce max error to half orbital period
    set at1 to at0 - das - da.                // assume counterclockwise orbits
    print "T+" + round(missiontime) + " " + tgtbody:name + ", orbital period: " + round(opt/60,1) + "min".
    print "T+" + round(missiontime) + " | now: " + round(at0) + "', xfer: " + round(da) + "', rdvz: " + round(at1) + "'".
    // current ship angular position 
    set asnow to arctan2(ps:x,ps:z).
    // ship angular position for maneuver
    set as0 to mod(at1 + 180, 360).
    // eta to maneuver node
    set asm to as0.
    until asnow > asm { set asm to asm - 360. }
    set eta to (asnow - asm) / 360 * ops.
    if eta < 60 { 
        set eta to eta + ops.
        print "T+" + round(missiontime) + " too close for maneuver, waiting for one orbit, " + round(ops/60,1) + "m".
    }
    print "T+" + round(missiontime) + " ship, orbital period: " + round(ops/60,1) + "m".
    print "T+" + round(missiontime) + " | now: " + round(asnow) + "', maneuver: " + round(asm) + "' in " + round(eta/60,1) + "m".
    // hohmann orbit properties
    set vh to sqrt( va^2 - mu * (1/smah - 1/smas ) ).
    set dv to vh - va.
    print "T+" + round(missiontime) + " Hohmann burn: " + round(vom) + ", dv:" + round(dv) + " -> " + round(vh) + "m/s".
    // setup node 
    set nd to node(time:seconds + eta, 0, 0, dv).
    add nd.
    if encounter = tgtbody:name or encounter = "None" {
        set done to True.
    } else {
        print "T+" + round(missiontime) + " Trajectory intercepts " + encounter:body:name + ", wait for one orbit.".
        run warpfor(ops).
        remove nd.
        // recalculation of maneuver angle required (Minmus has moved to new location)
    }
}
if encounter = tgtbody:name {
    print "T+" + round(missiontime) + " Encounter: " + encounter + ", periapsis: " + round(encounter:periapsis/1000) + "km".
    print "T+" + round(missiontime) + " Node created.".
} else {
    print "T+" + round(missiontime) + " WARNING! No encounter found.".
    remove nd.
}