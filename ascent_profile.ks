FUNCTION EXECUTE_ASCENT_STEP {
  PARAMETER direction.
  PARAMETER target_alt.
  PARAMETER minAlt.
  PARAMETER newAngle.
  //PARAMETER newThrust.

  SET prevThrust TO MAXTHRUST.

  UNTIL FALSE {
    
    clearscreen.
    Print "Next Ascent step Altitude:" + minAlt.
    Print "Throttle:"+ throttle.

    IF MAXTHRUST < (prevThrust - 10) {
      SET currentThrottle TO THROTTLE.
      LOCK THROTTLE TO 0.
      WAIT 1. STAGE. WAIT 1.
      LOCK THROTTLE TO currentThrottle.
      SET prevThrust TO MAXTHRUST.
    }
    IF ALTITUDE > minAlt {
      LOCK STEERING TO HEADING(direction, newAngle).
     // LOCK THROTTLE TO newThrust.
      BREAK.
    }
    if apoapsis > target_alt and periapsis < (target_alt-500) {
      LOCK THROTTLE to 0.
      notify("Circularising at AP").
      Circ_with_node().
       set maxa to maxthrust/mass.
       set dob to nextnode:deltav:mag/maxa.     // incorrect: should use tsiolkovsky formula
       print "T+" + round(missiontime)+" Burn duration: " + round(dob) + "s".
       notify("Warping to 1 min before burn.").
       warpfor(nextnode:eta - dob/2 - 60).
      execute_node().
      BREAK.
    } 

    Calculate_ascent_throttle().
    WAIT 0.1.
  }
}

FUNCTION EXECUTE_ASCENT_PROFILE {
  PARAMETER direction.
  PARAMETER profile.
  PARAMETER target_alt.

  SET step TO 0.
  UNTIL step >= profile:length - 1 {
    EXECUTE_ASCENT_STEP(
      direction,
      target_alt,
      profile[step],
      profile[step+1]
      //profile[step+2]
     
    ).
    SET step TO step + 2. //Number of params - removing throttle
  }
}

FUNCTION Calculate_ascent_throttle{

  set speed_limit to 0.

  if ALT:RADAR < 1500 {
    LOCK THROTTLE to 1.
  }
  if ALT:RADAR >1500 and ALT:RADAR < 4000 {
    set speed_limit to 200.
  }
  if ALT:RADAR > 4000 and ALT:RADAR < 8000 {
    set speed_limit to 350.
  }
  if ALT:RADAR > 8000 and ALT:RADAR < 15000 {
    set speed_limit to 550.
  }
  if ALT:RADAR > 15000 and ALT:RADAR < 30000 {
    set speed_limit to 950.
  }
  if ALT:RADAR > 30000 {
    set speed_limit to 0.
  }
  
  print "Speed Limit"+speed_limit.
  if speed_limit >1 {
    if verticalspeed > speed_limit{
      set th to (throttle*0.9).
      if th > 0.01 {
        LOCK THROTTLE to th.
      }
    } else {
      set th to (throttle*1.1).
      if th > 1 {
        LOCK THROTTLE to 1.
      } else {
        LOCK THROTTLE to th.}
    }
    print "Throttle correction" + th.
    print "New current throttle" + THROTTLE.
  } 
}
