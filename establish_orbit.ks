function establish_orbit{

  parameter target_body is ship:body.

  if ship:orbit:hasnextpatch {

    if ship:orbit:transition = "Encounter" {
      if target_body:name = ship:orbit:nextpatch:body:name {
        warpfor(eta:transition+60).
      } else {
        notify("we are intecepting the wrong planet").
      }
    }

    if ship:orbit:transition = "Escape" and ship:body = target_body {

      set altitude_check to ship:altitude.
      wait 1.
      if altitude_check < ship:altitude { 
        notify("We have passed the pe, Burning Now.").
      } else { 
        notify( "We are still in front of the PE. establish_orbit there.").
        warpfor(eta:periapsis-30).
      }
      align_ship(retrograde).
      until ship:orbit:hasnextpatch = false{
        lock steering to retrograde.
        lock throttle to 1.
      }
      wait 0.5. // Safety margin delay.
      lock throttle to 0.
      
    } else {
      notify("On escape orbit but no encounter for target orbit - either mistake or target not in local system").
    }
    
  } else {
     notify("No Patch Detected.").
  }
} 
