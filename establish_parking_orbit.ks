function establish_parking_orbit{
	
	if ship:status = "escaping"{
		establish_orbit().
    notify("Alert - Escaping - Establishing orbit before parking.").
	}
	if ship:status = "orbiting"{
  	set parking_orbit to get_safe_orbit()+10000.
    if ((apoapsis+periapsis)/2 - parking_orbit) > 300 or ((apoapsis+periapsis)/2 - parking_orbit) < -300{ 
      notify("Establishing parking orbit.").
    	node_change_apsis("a", parking_orbit).
    	execute_node().
    	circ_with_node("a").
      execute_node().
    }
    if ((apoapsis+periapsis)/2 - parking_orbit) > 300 or ((apoapsis+periapsis)/2 - parking_orbit) < -300{ 
      notify("Parking orbit established").
      return true.
    } else {
      notify("Error - Alt Error > 1000").
      return false.
    }
	} else {
    notify("Parking Orbit Error - Not in Orbit").
    return false.
  }
}