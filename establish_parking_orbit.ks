function establish_parking_orbit{
	
	if ship:status = "escaping"{
		establish_orbit().
    notify("Alert - Escaping - Establishing orbit before parking.").
	}
	if ship:status = "orbiting"{
  	set parking_orbit to get_safe_orbit()+10000.
  	node_change_apsis("a", parking_orbit).
  	execute_node().
  	circ_with_node("p").
    execute_node().
    if ((apoapsis+periapsis)/2 - parking_orbit) < 1000{
      notify("Parking orbit established").
      return true.
    } else {
      notify("Error - Alt Error > 1000").
      return false.
    }
	}
}