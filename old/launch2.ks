// Created by: Devon Connor // On: 4/6/2015
// This file will launch a rocket to the desired altitude
// please turn down thrust before beginning script so that when // it is finished the engines remain shutdown
// to run the file type "run launch(OrbitHeight)." // where OrbitHeight is the final circular height in km.
// mode 1 launches the rocket from the pad // mode 2 takes the rocket to 9km // mode 3 begins the gravity turn until apoapsis is the target height // mode 4 coasts until rocket is within 60s of apoapsis // mode 5 circularizes the orbit // mode 6 deploys solar panels and reliquishes control to the user
// /////////// SETUP //////////// 

DECLARE PARAMETER orb. 
set orb to orb*1000.
 SAS off.
  RCS on. 
  lights on. 
  lock throttle to 0. 
  gear off.
   clearscreen. 
   lock TTW to (maxthrust+0.1)/mass.
    // ///////////////////////////////////
set mode to 2.
if ALT:RADAR < 50 { set mode to 1. }
if periapsis > 70000 { set mode to 4. }

until mode = 0 { if mode = 1 { // launch
    print "T-MINUS 10 seconds". lock steering to up. wait 1.
    print "T-MINUS  9 seconds".
    lock throttle to 1.
    wait 1.

    print "T-MINUS  8 seconds".
    wait 1.

    print "T-MINUS  7 seco...".
    stage.
    wait 1.

    print "......and here we GO, i guess".
    wait 2.

    clearscreen.
    set mode to 2.
}

else if mode = 2 { // fly up to 9km
    lock steering to up.
    if (ship:altitude > 9000){
        set mode to 3.
    }
}
else if mode = 3{ // gravity turn
    set targetPitch to max( 8, 90 * (1 - ALT:RADAR / 70000)). 
    lock steering to heading (90, targetPitch).

    if SHIP:APOAPSIS > orb{
        set mode to 4.
        }
    if TTW > 20{
        lock throttle to 20*mass/(maxthrust+0.1).
    }

}
else if mode = 4{ // coast to orbit
    lock throttle to 0.
    if (SHIP:ALTITUDE > 70000) and (ETA:APOAPSIS > 60) and (VERTICALSPEED > 0) {
        if WARP = 0 {        
            wait 1.        
            SET WARP TO 3. 
            }
        }
    else if ETA:APOAPSIS < 70 {
        SET WARP to 0.
        lock steering to heading(90,0).
        wait 2.
        set mode to 5.
        }

    if (periapsis > 70000) and mode = 4{
     if WARP = 0 {        
            wait 1.         
            SET WARP TO 3. 
      }
    }

}

else if mode = 5 {
    if ETA:APOAPSIS < 15 or VERTICALSPEED < 0 {
        lock throttle to 1.
        }

    if (ETA:APOAPSIS > 90) and (apoapsis > orb) { set mode to 4. }

    if ship:periapsis > orb {
        lock throttle to 0.
        set mode to 6.
    }
}

else if mode = 6 {
    lock throttle to 0.
    panels on.     //Deploy solar panels
    lights on.
    unlock steering.
    //set mode to 0.
    print "WELCOME TO A STABE SPACE ORBIT!".
    wait 2.
}

// this is the staging code to work with all rockets //

if stage:number > 0 {
    if maxthrust = 0 {
        stage.
    }
    SET numOut to 0.
    LIST ENGINES IN engines. 
    FOR eng IN engines 
    {
        IF eng:FLAMEOUT 
        {
            SET numOut TO numOut + 1.
        }
    }
    if numOut > 0 { stage. }.
}

// HERE is the code for the control pannel //

clearscreen.
print "LAUNCH PLAN STAGE " + mode.
print " ".
print "Periapsis height: " + round(periapsis, 2) + " m".
print " Apoapsis height: " + round(apoapsis, 2) + " m".
print " ETA to Apoapsis: " + round(ETA:APOAPSIS) + " s".
print "   Orbital speed: " + round(velocity:orbit:MAG, 2)+ " m/s".
print "        altitude: " + round(altitude, 2) + " m".
print "thrust to weight: " + round((throttle*maxthrust)/mass).
print " ".
print "Currently on Stage: " + stage:number.
wait 0.2.
}