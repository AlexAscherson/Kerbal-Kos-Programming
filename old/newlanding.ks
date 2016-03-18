// Some lock expressions I will be using to cut down on
// number of statements in the loop:
// ====================================================

// Non body constants
set gConst to 6.67384*10^(0-11). // The Gravitational constant


set done to 0.
until done = 1 {
      
      lock heregrav to gConst*body:Mass/((altitude+body:Radius)^2).

      lock twr to maxthrust/(heregrav*mass).
      set tfE to 9999999. set tfN to 9999999. set tfU to 9999999. // east,north,up vector
      lock absspd to (tfE^2 + tfN^2 + tfU^2) ^ 0.5 .
      set petermv to 999999.
      set usepe to 999999.

      //throttle
      set myTh to 0.0 .
      //chaning from myth
      //lock throttle to hovth.

      set absvsup to abs(tfU).
      // How much of my current aiming direction is vertical?
      // (i.e. cosine of angle between steering and straight up):
      lock cossteerup to absvsup / ( (tfE^2+tfN^2+absvsup^2)^0.5 ).
      lock sinsteerup to ((tfE^2+tfN^2)^0.5) / ( (tfE^2+tfN^2+absvsup^2)^0.5 ).

      // Non body constants
      set gConst to 6.67384*10^(0-11). // The Gravitational constant
      //Drag Setting
      set fdrag to 0. // hack cause drag is 0
      set airbrakeMult to 1. // hack caue nto aerobraking

      // Current grav
      lock heregrav to gConst*body:Mass/((altitude+body:Radius)^2).
      lock twr to maxthrust/(heregrav*mass).
      // Surface grav
      set surfGrav to gConst*body:Mass/(body:Radius^2).
      set surfExtraAc to ( (maxthrust/(mass*surfGrav) ) - 1 ) * surfGrav .

      
      lock hovth to ((ship:mass*heregrav)-fdrag) * (1/cossteerup) / maxthrust .
      print "hover throttle setting that would make my rate of descent constant:"+HOVTH.
      lock throttle to hovth.
      lock extraac to (twr - 1) * heregrav.
      print "The acceleration I can do above and beyond what is needed to hover:"+ extraac.
      // My current stopping distance I need at that accelleration, with a 1.2x fudge
      // factor for a safety margin:

   //   if body:name = "Mun" {
            set descendBotSpeed to 6.0.
            set descendBot to 80. 
     // }
      lock stopdist to 1.2 * ( (absvsup-descendBotSpeed)^2)/(2*extraac).
      print "Stop Distance: " + stopdist.

      //current speed to descend assuming landing alt is the same
      set h to alt:radar.
      if H < 0  { set H to 0.  } // if dipping negative, don't allow sqrt to give NAN result.
      set pDesSpd to sqrt( 1.8 * surfExtraAc * H ) + descendBotSpeed.

      print "What current burn speed should be: " +( round( pDesSpd * 100 ) /  100 ) + " m/s" at (22,9).

          

            set pTime to (missiontime+ 0.001).
            set spd to absspd.
            
            set dTime to missiontime - pTime.
            set pTime to missiontime.
            set altAGL to alt:radar.

            if verticalspeed > 0.0 { set spd to 0 - absspd. }.
        
            // How far to offset the throttle depends on relatively how far
            // off we are from the desired speed, and how good the craft is at
            // thrusting, and how slowly this loop is running.
            // The goal being seeked is to use a setting that would achive the
            // desired speed in 1 iteration:
            set thOff to ( ( spd - pDesSpd ) / dTime ) / (maxthrust/mass).
        
            // Make the throttle less gentle when too close to the ground and going down
            // fast - go ahead and throttle highly if in that scenario:
            if altAGL < (descendBot*3) and spd > (pDesSpd*2) {
              set thOff to 1.5*thOff.
            }.
            
            set newTh to ( hovth + thOff ) * airbrakeMult .
            if newTh < 0.0 { set newTh to 0.0 . }.
            if newTh > 1.0 { set newTh to 1.0 . }.
        
            print "new throttle setting" + ( round( myTh * 1000 ) / 10 ) + " %"  at (22,4).
        clearscreen.
        }