FUNCTION launchWindow {
    PARAMETER tgt. //In your case you won't have a target; I imagine you'll want params to be LAN and Inc of target orbit.
    LOCAL lat IS SHIP:LATITUDE.
    LOCAL eclipticNormal IS obtNrm(). //this gets a vector for the target's orbital plane; this is what you'll need to change.
        //You'll need to figure out the normal of your contract's orbit using it's given LAN and the SOLARPRIMEVECTOR.
        //I don't have a method for this laying in my back pocket, but I'm sure collectively we'll all come up with something.
    LOCAL planetNormal IS HEADING(0,lat):VECTOR.
    LOCAL bodyInc IS VANG(planetNormal, eclipticNormal).
    LOCAL beta IS ARCCOS(MAX(-1,MIN(1,COS(bodyInc) * SIN(lat) / SIN(bodyInc)))).
    LOCAL intersectdir IS VCRS(planetNormal, eclipticNormal):NORMALIZED.
    LOCAL intersectpos IS -VXCL(planetNormal, eclipticNormal):NORMALIZED.
    LOCAL launchtimedir IS (intersectdir * SIN(beta) + intersectpos * COS(beta)) * COS(lat) + SIN(lat) * planetNormal.
    LOCAL launchtime IS VANG(launchtimedir, SHIP:POSITION - BODY:POSITION) / 360 * BODY:ROTATIONPERIOD.
    if VCRS(launchtimedir, SHIP:POSITION - BODY:POSITION)*planetNormal < 0 {//Exclude this to only launch north
        SET launchtime TO BODY:ROTATIONPERIOD - launchtime.
    }
    RETURN TIME:SECONDS+launchtime.
}