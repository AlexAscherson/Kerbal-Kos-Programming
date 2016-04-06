function ascend_from_moon {

  parameter target_alt is get_safe_orbit()+4000.
  //set target_inclination to (-1)*(90-target:orbit:inclination). if you want to go orbit westerly, normal is east./anticlockwise(?)
  parameter target_inclination is (90-target:orbit:inclination). // This will work so long as the orbit is crossign the position of the ship. (if you are matching a target)
  sas off.  // Changed aboveto plus because gave correct direction but opposite inclination.
  lock steering to up.
  set runmode to 1.

  print "Waiting for Launch Window".
  SET ANLongitude to target:orbit:LONGITUDEOFASCENDINGNODE.
  until floor(longitude + BODY:ROTATIONANGLE) = floor(ANLongitude - 180) OR floor(longitude + BODY:ROTATIONANGLE) = floor(ANLongitude + 180) OR floor(longitude + BODY:ROTATIONANGLE) = floor(ANLongitude){
    set warp to 4.
  }
  set warp to 0.
  print "Launch Window Reached".
  
  until false {

  	if runmode = 1 {
  		if ship:status = "landed" {
  			lock throttle to 1.
        wait 1.
        toggle legs.
        wait 2.
        if legs = true {
          toggle legs.
          Print "Retracting Legs".
          wait 1.
          gear off.
          wait 1.
          gear off.
          //wait until legs = false. //
          //Print "Legs Deployed". 
        } 
  			wait 4.
        if legs = true {
          toggle gear.
          Print "Error - Retracting legs again".
          //wait until legs = false. //
          //Print "Legs Deployed". 
        } 
  			set runmode to 2.
  		}
  	}
  	if runmode = 2 {
  		if altitude < target_alt*0.3{
  			lock steering to heading(target_inclination, 75).
  		} else if apoapsis < target_alt*0.5{
  			lock steering to heading(target_inclination, 45).
  		} else if apoapsis < target_alt*0.7 {
        lock steering to heading(target_inclination, 25).
      } else {
        lock steering to heading(target_inclination, 5).
      }
      if apoapsis > target_alt {
        set runmode to 3.
        lock throttle to 0.
      }
  	}
    if runmode = 3 {
      lock throttle to 0.
      wait 0.5.
      node_change_apsis("p", apoapsis).
      //copy execute_node from 0.
      //run execute_node.
      //copy time_warp from 0.
      //run time_warp.
      execute_node().
      break.
    }
  }
}
