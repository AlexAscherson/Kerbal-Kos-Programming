//KOS
// Find the transfer node to use, assuming the
// orbit of either me or the target isn't
// circular enough for a Hohmann transfer to work.
// Works by brute force guesses, starting with
// the location of a Hohmann transfer and then
// adjusting from there until it finds a spot
// that works.
//
// returns:
//    bestGuess:  An encounter node set up as a guess for transfer.
//

function brute_force_transfer{
  declare parameter dest. // destination body.
  copy angleuntilhohman from 0.
  run angleuntilhohman.
  set gConst to 6.67384*10^(0-11). // The Gravitational constant
  set pi to 3.14159265359 .
  set e to 2.718281828459 .
  set atmToPres to 1.2230948554874 . // presure at 1.0 Atm's.
  set target to dest:name. // just to help the viewer see what's going on.

  //run bodydata(body). // the body I and my target are orbiting.


  set Nope to "None". // Used to work around a KOS bug with literal strings.

  // Not only is the position of the transfer
  // node unknown, but also the exact delta-V
  // is too, becuase the intercept could be
  // high or low on the target's orbit.

  // These are the upper and lower bounds
  // for possible apoapsis altitudes
  // of my tansfer orbit:
  set dPeAlt to dest:periapsis.
  set dApAlt to dest:apoapsis.

  // This is the girst guess of a transfer
  // orbit, and I'll adjust up and down from
  // here until I find the one that hits:
  angle_Until_Hohmann(dest).


  // Starting interval to iterate over in time
  // between guesses (if a solution is not found
  // using a node at time T, then try a node
  // at time T +/- this much as the next guess.)
  // This amount will become smaller once an encounter
  // is found and it's time to fine tune it.
  set orbPeriod to 2*pi*sqrt( ((target:Radius+((periapsis+apoapsis)/2) )^3)/(target:Mass*gConst) ).

  // The altitude at that position

  set tGuessInc to orbPeriod/120. // 3 degree increments.

  // Starting interval to iterate over in delta-V
  // between guesses:
  set dVGuessInc to haDeltaV/200.

  set origSign to 1.
  if haDeltaV < 0 { set origSign to -1. }.

  set tGuess to haTime.

  set dvGuess to haDeltaV.

  // Iterate over the guesses in time:
  set encFound to 0.
  set bestEnc to 999999999.
  set bestGuess to NODE(0,0,0,0).

  set tGuessOff to 0.

  clearscreen.
  print "".
  print "This my take some time.  Be patient".
  print "Watch the map view.".
  print "".
  print "If the orbits were circular, the optimal burn ".
  print "would start at T+" + round(haTime,0) + " seconds.".

  // Push the cursor below the stuff I'll be over-writing on the screen:
  set x to 0. until x > 15 { print "". set x to x + 1. }.

  print "Looking for an encounter burn at: " at (0,13).
  print "Best Enc so far is" at (0,15).
  print "NONE" at (4,16).

  set wiggle to 1000. // bit of wiggle room so it doesn't give false positives on "better" values.
  lock escapevel to 0.9 *sqrt(2*gConst*target:Mass / (altitude+target:Radius)).

  until tGuessOff > orbPeriod {
    // Try all 4 guesses, using +/- for both
    // varying things (time and dv):
    // was this:
    set tSign to -1.
    // Will try for -1, then +1:
    until tSign > 1 {

      // Have to make a new node because node:eta is read-only in KOS 9.92 and I
      // can't change it.  I hope this gets fixed later:
      set tryETA to tGuess + tSign*tGuessOff.
      set guess to NODE( time:seconds + tryETA, 0, 0, dvGuess ).
      print "                                   " at (4,14).
      print "T + " + round(haTime,0) at (4,14).
      print "plus " at (18,14).
      if tSign < 0 { print "minus" at (18,14).  }.
      print round(abs(haTime-tryETA),0) at (24,14).
      if guess:ETA > 0 { // No sense in working out a time before now.
        add guess.
        // Will try for -1, then +1:
        set dVSign to -1.
        until dVSign > 1 {
  	set tooHigh to 0.
  	set tooLow to 0.
  	// Iterate over the guesses in dv at that time:
  	set dVGuessOff to 0.
  	until 0 {
            set gettingBetter to 0.
  	  set guess:PROGRADE to dvGuess + dVSign*dVGuessOff.
  	  if encounter = dest:name {
  	    set encFound to 1.
  	    // Because the value keeps wiggling, I need to get its average value
  	    // or I get false positives about it being "better" than it was before:
  	    set per to encounter:periapsis.
  	    set per to per + encounter:periapsis.
  	    set per to per + encounter:periapsis.
  	    set per to per + encounter:periapsis.
  	    set per to per / 4.0 .
  	    if (per+wiggle) < bestEnc {
  	      set bestEnc to per.
  	      set bestGuess to guess. 
  	      set gettingBetter to 1.
  	      print "T +" + round(bestGuess:ETA,0) + "s, deltaV of " + round(bestGuess:DELTAV:Mag,2) + "m/s      " at(4,16).
  	      // For now as soon as an encounter of any kind is found I'll quit.  I'm more interested
  	      // in the timing than the delta-V as I'll watch the delta V as I burn, and the
  	      // rest of the delta-V seeking code here is dodgy.
  	      break.
  	    }.
  	  }.
  	  if encFound = 0 {
  	    set relevantAlt to guess:orbit:apoapsis.

  	    // Special check because in KOS 0.9.2 when there is no apopasis because you're
  	    // on an escape path, instead of returning a sentinel bogus value for apoapsis,
  	    // that you can check for, KOS returns a seemingly valid, but bogus, number.
  	    if relevantAlt < 0 {
  	      set relevantAlt to 999999999999999.
  	    }.

  	    if origSign < 0 {
  	      set relevantAlt to guess:orbit:periapsis.
  	    }.

  	    if relevantAlt > (dApAlt*1.02) and dVSign = origSign { set tooHigh to 1. }.
  	    if relevantAlt < (dPeAlt*0.98) and dVSign = (-1)*origSign { set tooLow to 1. }.
  	  }.
  	  if encFound = 1 {
  	    if gettingBetter = 0 {
  	      break. // Not improving, this is as good as it gets, stop.
  	    }.
  	  }.
  	  if encFound = 0 {
  	    // The pos and neg variations give answers out of range:
  	    // Then get out of the loop and try a different delta Time:
  	    if tooHigh = 1 or tooLow = 1 {
  	      break.
  	    }.
  	  }.
  	  if gettingBetter = 1 {
  	    // re-center the search HERE and start deviating from this point.
  	    set dvGuess to bestGuess:PROGRADE.
  	    set dvGuessOff to 0.
  	    set tGuess to bestGuess:ETA.
  	    set tGuessOff to 0.
  	    // Slow down the rate of dV guessing:
  	    set dVGuessInc to dVGuessInc/2.
  	    // Never change timing guess again - leave it here now.
  	    set tGuessInc to 0.
  	  }.
  	  set dVGuessOff to dVGuessOff + dVGuessInc.
  	}.
  	set dVSign to dVSign + 2.
  	// For now as soon as an encounter of any kind is found I'll quit.  I'm more interested
  	// in the timing than the delta-V as I'll watch the delta V as I burn, and the
  	// rest of the delta-V seeking code here is dodgy.
  	if encFound { break. }.
        }.
        remove guess.
      }.
      set tSign to tSign + 2.
      // For now as soon as an encounter of any kind is found I'll quit.  I'm more interested
      // in the timing than the delta-V as I'll watch the delta V as I burn, and the
      // rest of the delta-V seeking code here is dodgy.
      if encFound { break. }.
    }.
    set tGuessOff to tGuessOff + tGuessInc.

    wait 0.2. // Seems to help KOS a bit to do this once in a while.

    // For now as soon as an encounter of any kind is found I'll quit.  I'm more interested
    // in the timing than the delta-V as I'll watch the delta V as I burn, and the
    // rest of the delta-V seeking code here is dodgy.
    if encFound { break. }.
  }.

  // Caller can get the result in the encounter called bestGuess.
}

run hoffman_node.
get_hoffman_node().
wait 10.
brute_force_transfer(duna).