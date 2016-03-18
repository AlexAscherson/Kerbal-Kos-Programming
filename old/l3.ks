set tVal to 1.

lock throttle to tVal.
lock steering to up + R(0,0,180).
stage.
print "Launch!".

until altitude > 10000
{
  if verticalspeed > 210
  {
    set tVal to tVal – 0.02.
  }.
}.

lock steering to up + R(0,0,180) + R(0,-60,0).
print "Beginning gravity turn.".

wait 5.

until throttle = 1
{
  set tVal to tVal + 0.02.
  if tVal > 1 { set tVal to 1. }.
}.
// Program proceeds with staging and reaching orbit from here.