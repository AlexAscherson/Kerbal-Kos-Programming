set targetLongitude to target:Longitude.
set targetAltitude to target:Altitude.

// transfer DVs
// courtesy of https://en.wikipedia.org/wiki/Hohmann_transfer_orbit
set r1 to ship:body:radius + ship:altitude.
set r2 to ship:body:radius + targetAltitude.
set dv1 to sqrt(ship:body:mu / r1) * (sqrt((2 * r2) / (r1 + r2)) - 1).
set dv2 to sqrt(ship:body:mu / r2) * (1 - sqrt((2 * r1) / (r1 + r2))).

print "DV1 = " + dv1.
print "DV2 = " + dv2.
print "Total = " + (dv1 + dv2).

set transitTime to constant():PI * sqrt((r1 + r2)^3 / (8 * ship:body:mu)).

print "Transit time = " + transitTime/60.

set bodyRotationSpeedInDegrees to 360 / ship:body:rotationPeriod.
set bodySiderealVelocity to ship:body:radius * bodyRotationSpeedInDegrees * constant():PI / 180.

print "Body rotation speed in degrees = " + bodyRotationSpeedInDegrees.
print "Body sidereal velocity = " + bodySiderealVelocity.

set bodyRotationInDegrees to bodyRotationSpeedInDegrees * transitTime.

print "Body will rotate " + bodyRotationInDegrees + " deg during the transit!".

set startBurnAngle to target:Longitude - bodyRotationInDegrees.
until startBurnAngle >= 0 {
  set startBurnAngle to startBurnAngle + 360.
}
set startBurnAngle to mod(startBurnAngle, 360).

print "Burn has to start at " + startBurnAngle + " deg!".

set vo to ship:velocity:orbit:mag.
set wo to (180 * vo) / (constant():PI * r1).
set shipLong to ship:longitude.
until shipLong < startBurnAngle {
  set shipLong to shipLong - 360.
}
set maneuverETA to (startBurnAngle - shipLong) / wo.

print "Vo = " + vo.
print "Wo = " + wo + " (deg)".
print "Ship longitude = " + shipLong.
print "ETA until maneuver = " + maneuverETA + " s".

set geoNode to node(time:seconds + maneuverETA, 0, 0, dv1).
add geoNode.