
function get_terrain{
	declare parameter p1, b, d, radius. //(start point,bearing,distance,radius(planet/moon)).
	set resultLat to arcsin(sin(p1:lat)*cos((d*180)/(radius*constant():pi))+cos(p1:lat)*sin((d*180)/(radius*constant():pi))*cos(b)).
	if abs(resultLat) = 90 {
	 set resultLng to 0.
	}
	else {
	 set resultlng to p1:lng+arctan2(sin(b)*sin((d*180)/(radius*constant():pi))*cos(p1:lat),cos((d*180)/(radius*constant():pi))-sin(p1:lat)*sin(resultLat)).
	}.
	set result to latlng(resultLat,resultLng).
  return result.
}

// courtousy of KOS NAV TOOLS.
//eg. for 1km ahead.
// RUN gs_destination(ship:geoposition,(-1)*ship:bearing,1000,body:radius).