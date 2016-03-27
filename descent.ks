// Descent

function Update_landing_Variables{
  // Local Graviational forces
  set gConst to 6.67384*10^(0-11). // The Gravitational constant
  set ship_gravity_acceleration_surface to gConst*body:Mass/(body:Radius^2). // Mp/s
  lock ship_gravity_acceleration_local to gConst*body:Mass/((altitude+body:Radius)^2). // Mp/s 
  // Ship Properties
  lock ship_max_acceleration to maxthrust/mass.
  lock ship_max_acceleration_surface to (maxthrust/mass) - ship_gravity_acceleration_surface.  // Mp/s
  lock ship_max_acceleration_local to (maxthrust/mass) - ship_gravity_acceleration_local.
  lock ship_thrust_to_weight_ratio_local to maxthrust/(ship_gravity_acceleration_local*mass).
  // Hover throttle setting that would make ship rate of descent constant in vacuum:
  lock throttle_gravity_neutral_vacuum to 1/ship_thrust_to_weight_ratio_local. // Aim maintain twr at 1. Assuming equivlance between twr and max a 
  // The acceleration I can do above and beyond what is needed to hover: 
  lock available_acceleration to (ship_thrust_to_weight_ratio_local - 1) * ship_gravity_acceleration_local.
}

function Descend_to_min_safe_orbit{

  parameter safety_margin is 2000.
  set min_safe_orbit to get_safe_orbit()+safety_margin.
  print "Running Min safe orbit".
  until false {
    if ((apoapsis+periapsis)/2) - min_safe_orbit > 300 {
      if ship:orbit:hasnextpatch {
        notify("Descend to min safe orbit - We are Flying by - Establish Orbit").
        Establish_orbit().
      }
      if periapsis > (min_safe_orbit+200) { // IF is to high
        notify("Descend to min safe orbit - PE = High -Lowering PE to minimum").
        node_change_apsis("p",min_safe_orbit).
        print "min safe orbit" + min_safe_orbit.
        execute_node().
        node_change_apsis("a", min_safe_orbit).
        execute_node().
      } else if periapsis < (min_safe_orbit+200) and periapsis > (min_safe_orbit-200) and (apoapsis-periapsis) > 500 {
        notify("PE - OK - Changing AP").
        node_change_apsis("a", min_safe_orbit).
        execute_node().
      } else if periapsis < (min_safe_orbit-200){
          notify("Danger - Periapsis is Low.").
          if eta:apoapsis < ETA:Periapsis {
            node_change_apsis("p",min_safe_orbit).
            execute_node.
          } else {
            notify("We have passed apoapsis - Emergency deorbit").
            return false.
          }
      } else {
        notify("Error Unknown state.").
      }
    } else {
      notify("Safe orbit established").
      return true.
    }
  }
}

function Deorbit {

  if Descend_to_min_safe_orbit() = true {
    notify("Starting Deorbit - From Min safe orbit-> Warping to PE").
    warpfor(eta:periapsis). 
  } else {
    notify("Starting Deorbit - PE Low"). 
  }

  align_ship(retrograde).

  until periapsis < 1 {
    lock steering to retrograde.  
    lock throttle to 1.
    if periapsis < 1 {break.}.
  }
  lock throttle to 0.
  
}

function wait_for_suicide_burn_point{
  parameter safety_margin is (1.1).
  align_ship(retrograde).
  until false {
    clearscreen.
    
    notify("Waiting for Impact warning").
    lock steering to retrograde.
    copy brake_warning from 0.
    run brake_warning.
    if groundspeed > 15 { 
      set impact_warning to get_brake_warning().
      if impact_warning {
        print "Predicted Impact Warning".
        Reduce_Groundspeed().
        lock steering to up.
      }
    }
    if groundspeed < 15 and groundspeed > 3{ 
      print "Going slow, correct to vertical drop".
      Reduce_Groundspeed().
      lock steering to up.
    }
    if groundspeed < 3 {
      break.  // Want to do a vertical sb.
    }     
  }
}

function Reduce_Groundspeed{

  parameter target_speed is 0.
  local manuver_done is 0.
  sas off.
  LOCK STEERING TO (-1) * SHIP:VELOCITY:SURFACE.
  notify("Killing groundspeed").

  until manuver_done = 1 {
    
    LOCK STEERING TO (-1) * SHIP:VELOCITY:SURFACE. 
    //if GroundSpeed > target_speed +20 {
      //get_brake_warning(). // For Degbugging/logging.
    //}     
    if GroundSpeed > target_speed +5 {  //  Print "Burning to Target Speed+5".
      lock throttle to 1.
    }
    if GroundSpeed < target_speed +5 { //  print "Slowing hoz burn to 10% Groundspeed".
      if (0.1*GroundSpeed) > 0.10 {
        lock throttle to (0.1*GroundSpeed).
      } else {
        lock throttle to 0.10.
      }
    } 
    if GroundSpeed < target_speed +0.5{ 
      lock throttle to 0.
      set manuver_done to 1.
    } 
  }
  notify("Ground speed manuever complete").
}

function touch_down{
  notify("Touching Down").
  lock throttle to 0.
  local landing_safety_margin is (0.75).

  lock steering to up.
  if legs = false {
    toggle legs.
    Print "Waiting for Legs".
    wait until legs = true. //
    Print "Legs Deployed". 
  } 

  until false {
    //print "est vstop alt:"+ distance_travelled_under_acceleration_over_time("vertical_burn", time_to_change_speed("vertical_stop")).
    set dont_interupt_burn to 0.
    if verticalspeed < -5 {
      
      if(landing_safety_margin* alt_true()) < distance_travelled_under_acceleration_over_time("vertical_burn", time_to_change_speed("vertical_stop")){
        lock throttle to 1.
        set dont_interupt_burn to 1.
        until verticalspeed >-5{
          wait 0.1.
        }
      }
    } 

    if alt_true < 10 and verticalspeed < 0 and verticalspeed >-4{
      lock throttle to 0.
      break.
    }

    if alt_true < 50 and dont_interupt_burn = 0 {
      if verticalspeed < -5 {
          set throttle_gravity_neutral_vacuum_faster to (throttle*1.10).
          lock throttle to throttle_gravity_neutral_vacuum_faster.
      }
      if verticalspeed > -5 and verticalspeed< -2 {
        set throttle_gravity_neutral_vacuum_slower to (throttle_gravity_neutral_vacuum *0.9).
        lock throttle to throttle_gravity_neutral_vacuum_slower.
      }
      if verticalspeed < -1 and verticalspeed > -5 {
        lock throttle to throttle_gravity_neutral_vacuum.
      }    
    } 

    if verticalspeed > -1{
      lock throttle to 0.
    }

  }

  unlock steering.
  sas on.
  set sasmode to "STABILITYASSIST".  
  lock throttle to 0.
  notify("Final Descent").
  until ship:status = "LANDED"{
    wait 5.
    UNSET checkpoint_marker. // Brake warning markers.
    UNSET halfway_marker.
  } 
  
}

function Descend_to_land{

  parameter decent_point is "At_PE".

  if ship:status = "Sub_Orbital"{ 
    notify("Sub Orbital Descent!").
    Update_landing_Variables().
    wait_for_suicide_burn_point().
    touch_down().
    return true.
  }

  Descend_to_min_safe_orbit(2000).
  if decent_point = "At_PE"{ 
    deorbit().  
    Update_landing_Variables().
    wait_for_suicide_burn_point().
    touch_down().
    return true.
  }
  if decent_point = "Custom_Decent"{
    // Calculate logic for a custom descent.
  } 
}

