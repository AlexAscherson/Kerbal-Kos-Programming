function touch_down{
  notify("Touching Down").
  lock throttle to 0.
  Update_landing_Variables().
  lock steering to up.
  if legs = false {
    toggle legs.
    Print "Waiting for Legs".
    wait until legs = true.
    Print "Legs Deployed". 
  } 
  lock throttle to 0.  
  until false {
    print "est vstop alt:"+ distance_travelled_under_acceleration_over_time("vertical_burn", time_to_change_speed("vertical_stop")).
    if verticalspeed < -5 {
      if(1.2* alt_true()) < distance_travelled_under_acceleration_over_time("vertical_burn", time_to_change_speed("vertical_stop")){
        lock throttle to 1.
      }
    } else {
      if alt_true < 10 and verticalspeed < 0 and verticalspeed >-4{
        lock throttle to 0.
        break.
      }
      if alt_true() < 50 {
            
        if alt_true() < 20 {
          lock throttle to throttle_gravity_neutral_vacuum.
        }
        if alt_true() < 50 and verticalspeed < -5 {
          set throttle_gravity_neutral_vacuum_faster to (throttle_gravity_neutral_vacuum *1.10).
          lock throttle to throttle_gravity_neutral_vacuum_faster.
        }
        if alt_true() < 50 and verticalspeed > -5 and verticalspeed< -2 {
          set throttle_gravity_neutral_vacuum_slower to (throttle_gravity_neutral_vacuum *0.9).
          lock throttle to throttle_gravity_neutral_vacuum_slower.
        }
        if alt_true() < 50 and verticalspeed < -1 and verticalspeed > -5 {
          lock throttle to throttle_gravity_neutral_vacuum.
        }
      }  
    }
    
  }