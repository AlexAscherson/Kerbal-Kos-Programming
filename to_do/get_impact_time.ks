function get_impact_time {

  parameter ship_alt IS (altitude-ship:geoposition:terrainheight).
  parameter ship_vertical_speed IS -SHIP:VERTICALSPEED.
  parameter grav_parameter IS get_local_grav_acceleration().
  RETURN (SQRT(ship_vertical_speed^2 + 2 * grav_parameter * ship_alt) - ship_vertical_speed) / grav_parameter.
}

function get_impact_time2 {

  parameter height IS (altitude-ship:geoposition:terrainheight). // didnt have alt true n fiel..
  parameter existing_speed IS -SHIP:VERTICALSPEED.

  set time_to_impact to SQRT((2*(get_local_grav_acceleration()*height)+ existing_speed^2)).
  return time_to_impact.
}