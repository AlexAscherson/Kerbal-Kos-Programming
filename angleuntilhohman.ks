//KOS angleUntilHohmann
// Return the angle (in degrees) of offset from now to when 
// the optimal Hohmann transfer point is to reach the given
// target body.  If it's negative that means "don't burn yet".
// If it's positive it means "too late".  Try to straddle the
// burn across the moment where this returns zero,
//
// Assumes target is in a circular orbit, so for some bodies
// it will have error.  Note if this is used on orbits that
// are not circular, it will use the semi-major axis of the
// orbits as if those were their circular radii.
//
// RETURNS two things:
//   1: haTime.  (Time from now when the Hohmann angle will be achieved.)
//   2: haDeltaV.  (How much deltaV it will probably take to do it).
// All variables here begin with 'ha' to help prevent name clashes.
// ("ha" for "Hohmann angle").

function angle_until_hohmann{
  declare parameter dest. // Destination of transfer.  Only bodies (not vessels) surrported currently.
  set br to target:Radius.

  // Semi-major axis of the destination orbit:
  set highSMA to br+ ( (dest:periapsis + dest:apoapsis) / 2 ).

  // Semi-major axis of my current orbit:
  set lowSMA to br+ ( (periapsis + apoapsis) / 2 ).

  set tfUnit to tfDirToUnitV(UP).
  // tfUnit is now my position direction as a unit vector.
  set lowPos to tfUnit * (br+lowSMA).
  print lowPos.
  // Dest position defaults to relative to ME.
  // Make it relative to the parent body instead:
  set highPos to dest:position + lowPos.

  // Dot product of the vector from origin to me and the vector from origin to the destination:
  set haDotProd to (lowPos:x * highPos:x) + (lowPos:y * highPos:y) + (lowPos:z * highPos:z) .
  // haPhi is the angle betwen me and the destination right now.
  set haPhi to arccos( haDotProd / (lowPos:mag * highPos:mag) ).

  set lowVel to dest:velocity:orbit.
  set sign to 1.
  // Up till now the code has been assuming I am the low
  // orbit and the destination is the high one.  But it might
  // be the other way around and I might be trying to go to a
  // closer-in orbit.
  // SWAP HIGH AND LOW VARIABLES IF I AM THE HIGH ORBIT:
  if highSMA < lowSMA {
    set lowVel to ship:velocity:orbit.
    set tmp to lowPos. set lowPos to highPos. set highPos to tmp.
    set tmp to lowSMA. set lowSMA to highSMA. set highSMA to tmp.
    set sign to -1.
  }.

  // Getting the angle from a dot product tends to hide the sign, and I need the sign.
  // (I need to know the difference between being 30 degrees ahead of the target vs
  // 30 degrees behind it.)
  // If my velocity is towards-ish the target then it's ahead of me.
  // if my velocity is away-ish from the target, then it's behind me.
  // I figure out which it is by looking at whether the dot product of my
  // velocity and the target position relative to me is postive:
  set chk to  (lowVel:x*(highPos:x-lowPos:x) ) + (lowVel:y*(highPos:y-lowPos:y) ) + (lowVel:z*(highPos:z-lowPos:z) ) .
  if chk < 0 {
    set haPhi to 360-haPhi.
  }.

  // Solution taken from:
  //   https://docs.google.com/document/d/1IX6ykVb0xifBrB4BRFDpqPO6kjYiLvOcEo3zwmZL0sQ/edit

  // haOrbits is the number of orbits the destination will make in the time it takes to get there.
  // NOTE: br is the radius of the current body being orbited, NOT the radius of the destination body.
  set haOrbits to 0.5 * (( (lowSMA + highSMA +  2*br) / (2*br+2*highSMA) )^1.5) .
  // haTheta is how much the destination's angle position will have moved after it performs haOrbits.
  set haTheta to 360 * mod( haOrbits, 1 ).
  // haRho is the angle I need to be behind the destination when I make the burn:
  set haRho to 180 - haTheta.
  if haRho < 0 { set haRho to haRho+360. }.

  // Report the difference between where I want to be (haRho) and where I am (haPhi):
  set haOffset to haPhi - haRho.
  if haOffset < 0 { set haOffset to haOffset + 360 . }.

  set lowP to 2*pi*sqrt(lowSMA^3/(target:Mass*gConst)).
  // Number of degrees per second I am rotating around body:
  set lowARate to 360/lowP.

  set highP to 2*pi*sqrt(highSMA^3/(target:Mass*gConst)).
  // Number of degrees per second my destination is rotating around body:
  set highARate to 360/highP.

  set haTime to haOffset/ abs(lowARate-highARate). 

  set haGM to gConst*target:Mass.
  set haR1 to br+lowSMA.
  set haR2 to br+highSMA.
  set haDeltaV to sign* sqrt(haGM/haR1 ) * ( sqrt( 2*haR2 / (haR1+haR2) ) - 1 ) .

}


// Given a Direction tuple like any of the examples
// below:
// Up. North. R(100,32,0), Q(1,0,0,30) HEADING 30 by 10
//
// Calculate what that direction would be if expressed
// as a unit vector instead.
// 
// This is accomplished by performing the matrix rotation
// on a vector that begins as V(1,0,0) and seeing what
// the result is.
//
// 
// Because you can't pass things out of a program,
// global variables must be used here for the output.
// INPUT:  1 parameter: the Direction vector.
// OUTPUT: tfUnit, a Vector containing the xyz coords of
// the output.
//
// All "local" variables begin with "tf" to help
// prevent them from clashing with the other
// variables you might have used in the global
// namespace of KOS.
function tfDirToUnitV{
  declare parameter tfDir.

  // Rotation angles for rotation matrix:
  set tfA to tfDir:yaw.
  set tfCosA to cos(tfA).
  set tfSinA to sin(tfA).

  set tfB to tfDir:pitch.
  set tfCosB to cos(tfB).
  set tfSinB to sin(tfB).

  set tfC to tfDir:roll.
  set tfCosC to cos(tfC).
  set tfSinC to sin(tfC).

  set tf11 to tfCosA*tfCosC + tfSinA*tfSinB*tfSinC .
  set tf21 to tfCosC*tfSinA*tfSinB - tfCosA*tfSinC .
  set tf31 to tfCosB*tfSinA .
  set tf12 to tfCosB*tfSinC .
  set tf22 to tfCosB*tfCosC .
  set tf32 to 0-tfSinB .
  set tf13 to tfCosA*tfSinB*tfSinC - tfCosC*tfSinA .
  set tf23 to tfSinA*tfSinC + tfCosA*tfCosC*tfSinB .
  set tf33 to tfCosA*tfCosB .
  set tfV to V( 0,0,1 ).

  set tfUnit to V(
    tf11*tfV:x + tf21*tfV:y + tf31*tfV:z ,
    tf12*tfV:x + tf22*tfV:y + tf32*tfV:z ,
    tf13*tfV:x + tf23*tfV:y + tf33*tfV:z ) .
  return tfUnit.
}