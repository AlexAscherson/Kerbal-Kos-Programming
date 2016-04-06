// Tranfer to orbit around sun.
function establish_solar_orbit{
print "Transferring to Sun.".
  until false {

    if body:name = "Sun" {
      print "Solar Orbit Acheived".
      break.
    }

    if ship:orbit:hasnextpatch {
      print "Patching".
      warpfor(eta:transition+60).
    }

    if body:name <> "Sun" and ship:status = "ORBITING"{
      warpfor(eta:periapsis-30).
      align_ship(prograde).
      print "Raising ap to patch.".
      until ship:orbit:hasnextpatch = true{
        lock steering to prograde.
        lock throttle to 1.
      }
      wait 0.5. // Safety margin delay.
      lock throttle to 0.
    }
  }
}