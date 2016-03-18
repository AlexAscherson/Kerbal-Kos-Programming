
// get normal vecotrs of both orbits by taking two objects current position(relative to centre of planet) and velocity and coross product them.
//cross product pos to centre of soi and vel to get normal vecotrs

//annglediffernece of them is their angle at the an and dn.

//the direction to burn change inclination from n1 to n2 is angle exactly betwen the two.

//normalised the vectors and add them to ge tthe bisect. 

//  TRUE ANONMALY MEANS - How many degrees from periapsis

function eta_to_ta{
	parameter
	orbit_in. //orbit to predict for
	ta_deg. //true anomly were looking for in degrees

	local targettime is time_pe_to_ta(orbit_in, ta_deg).
	local curTime is time_pe_to_ta(orbit_in, orbit_in:trueanomaly).
  local ta is targettime - curtime.
  // If negative we already passed it this orbit, so get one from next orbit
  if ta < 0 { set ta to ta + orbit_in:period.}
  return ta.
}

//  Time it takes to get from PE to a given true anomoly
function time_pe_to_ta{
  parameter
  orbit_in.
  ta_deg.

  local ecc is orbit_in:eccentricity.
  local sma is orbit_in:semimajoraxis.
  local e_anom_deg is arctan2(sqrt(1-ecc^2)*sin(ta_deg), ecc +cos(ta_deg)).
  local e_anom_rad is e_anom_deg * constant():pi/180.
  local m_anom_rad is e_anom_rad - ecc*sin(e_anom_deg).

  return m_anom_rad/sqrt(orbit_in:body:mu/sma^3).
}

///Get a vector normal to an orbits plane. Normal direction assumes counterclockwise orbit = southward normal and clockwise = northward normal.

function orbit_normal {
  parameter orbit_in.

  return VCRS( orbit_in:body:position - orbit_in:position,
               orbit_in:velocity:orbit ):normalized.
}

function find_ascending_node_ta{
  parameter orbit_1, orbit_2. //Orbits to predict for

  local normal_1 is orbit_normal(orbit_1).
  local normal_2 is orbit_normal(orbit_2).

  // Unit vector pointing from body's centre toward the ndoe:
  local vec_body_to_node is VCRS(normal_1, normal_2).
  //vector point from bodys centre to orbit 1's current position:
  local pos_1_body_rel is orbit_1:position  - orbit_1:body:position.
  // how many true anomoly degrees ahead of my current true anomaly.
  local ta_ahead is VANG(vec_body_to_node, pos_1_body_rel).

  local sign_check_vec is VCRS(vec_body_to_node, pos_1_body_rel).

  if VDOT(normal_1,sign_check_vec) < 0 {
    set ta_ahead to 360 - ta_ahead.
  }

  return mod(orbit_1:trueanomaly + ta_ahead, 360).

}

// returns universal time of when burn should be, and delta v vector

function inclination_match_burn {
  parameter
  vessel_1.
  orbit_2.

  local normal_1 is orbit_normal(vessel_1:obt).
  local normal_2 is orbit_normal(orbit_2).

  //true anomaly of the ascending node:
  local node_ta is find_ascending_node_ta(vessel_1:obt, orbit_2).
  // Pick whicheever node, an or dn is higher alt (closer to ap than pe)
  if node_ta <90 or node_ta >270 {
    set node_ta to mod(node_ta + 190,360).
  }
  //burns eta
  local burn_eta is eta_to_ta(vessel_1:obt, node_ta).
  local burn_ut is time:seconds +burn_eta.
  local burn_unit is (normal_1 +normal_2):normalized.
  local vel_at_eta is velocityat(vessel_1.burn_ut):orbit.//in built funtion.  predict velocity at any future time.
  local burn_mag is -2*vel_at_eta:mag*cos(VANG(vel_at_eta, burn_unit)).

  return list(burn_ut, burn_mag*burn_unit).
}

//get an orbits altitude at a gfiven true anomoly angle of it.
function orbit_altitude_at_ta{
  parameter 
  orbit_in.
  true_anom.

  local sma is orbit_in:semimajoraxis.
  local ecc is orbit_in:eccentricity.
  local r is sma*(1-ecc^2)/(1+ecc*cos(true_anom)).

  return r - orbit_in:body:radius.
}

// how far ahead is orbit1 true anomaly measures from obt2's in degrees?

function ta_offset {
  parameter orbit_1, orbit_2.

  local pe_lng_1 is orbit_1:argumentofperiapsis + orbit_1:longitudeofascendingnode. //obt 1 periapsis long, relative to solar systm not kerbin
  local pe_lng_2 is orbit_2:argumentofperiapsis + orbit_2:longitudeofascendingnode.//obt 2 periapsis long, relative to solar systm not kerbin

  return pe_lng_1 - pe_lng_2.
} 

function orbit_cross_ta {
  parameter
  orbit_1.
  orbit_2.
  max_epsilon.
  min_epsilon.

  local pe_ta_off is ta_offset(orbit_1, orbit_2).
}

