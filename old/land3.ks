// Landing v3

// Usefull things about landing:

// emulate retrograde:surface - NEEDS TESTING
lock steering to R(0,0,0) * (-1 * velocity:surface:normalized) + R(0,0,90).


//  Ways of calculating gravitational inputs.

//main library version
set ga to body:mu/(body:Radius + altitude)^2.
print "main library vrsion"+ga.

//Vrison 2

set gConst to 6.67384*10^(0-11). // The Gravitational constant
lock heregrav to gConst*body:Mass/((altitude+body:Radius)^2).
print "v3 - heregrav**" +heregrav.
// Surface grav
set surfGrav to gConst*body:Mass/(body:Radius^2).
print "v2-Surfgrav: "+surfGrav.
set surfExtraAc to ( (maxthrust/(mass*surfGrav) ) - 1 ) * surfGrav.
print "v2-Surfextraac: "+ surfExtraAc.