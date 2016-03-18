function run_gui{
  parameter flight_mode is "NONE".
  parameter status_message is "NONE".
  parameter parameter1 is 0.
  clearscreen.
  print "//////////////////////////////////////////".
  print "//   FLIGHT MODE: "+flight_mode +"       //".
  print "//   Status Message: "+status_message +"       //".

  if flight_mode = "DEORBIT" {
    print "Altitude-radar: "+alt:radar.
    print "Altitude_True: "+alt_true.
    print "GroundSpeed: "+ GroundSpeed.
  }
  if flight_mode = "LAND" {

  }
  if flight_mode = "Reduce_Groundspeed" {
    Print "//////REDUCING VELOCITY//////".
    print "Groundspeed: " + round(GroundSpeed, 3).
    print "Target Speed: " + round(parameter1, 3).
    print "Thottle:"+ round(throttle,2)+"%".
  }
}

function Reduce_Groundspeed{

  parameter target_speed is 0.
  set flight_mode to "Reduce_Groundspeed".
  set manuver_done to 0.
  sas off.
  LOCK STEERING TO (-1) * SHIP:VELOCITY:SURFACE.
  Print "ALIGN SHIP 2 SECONDS".
  wait 2.
  until manuver_done = 1 {
      
    LOCK STEERING TO (-1) * SHIP:VELOCITY:SURFACE.      
    if GroundSpeed > target_speed +5 {
      lock throttle to GroundSpeed/ship_max_acceleration.
      Set status_message to "Burning to Target Speed+5".
    }
    if GroundSpeed < target_speed +5 {
      if (0.1*GroundSpeed) > 0.10 {
        lock throttle to (0.1*GroundSpeed).
      } else {
        lock throttle to 0.10.
      }
       Set status_message to "Slowing hoz burn to 10% Groundspeed".
    } 
    if GroundSpeed < target_speed +0.5{
      Set status_message to "ENDING Manuever at Margin of 0.5".
      set throttle to 0.
      set manuver_done to 1.
    } 
    run_gui(flight_mode,status_message, target_speed).  
  }
}

function Hover{
    
  parameter hover_time is 5.
  sas off.

  set time_now to time:seconds.
  until time:seconds > time_now + hover_time {
    
    Lock STEERING to UP.
    set compensation_value to abs(Verticalspeed/ship_max_acceleration_local).
    set hover_throttle to throttle_gravity_neutral_vacuum.
    Print "///// Hover-> Compensation Value /////" + compensation_value.
    Print "///// Hover-> Throttle Value /////" + hover_throttle.
    if VerticalSpeed > 0.5 {
      Print "///// Hover-> Ascending - Waiting for negative vertical velocity".
      Set hover_throttle to 0.
    }
    if VerticalSpeed > 0.01 and VerticalSpeed < 0.5 {
      Print "///// Hover-> Ascending - Waiting for negative vertical velocity".
      Set hover_throttle to hover_throttle - compensation_value.
    }
    if VerticalSpeed < -0.02 {
      Print "///// Hover-> Descending - Adding Velocity to Throttle /////".
      Set hover_throttle to hover_throttle + compensation_value.
    }
    if VerticalSpeed > -0.02 and Verticalspeed < 0.02 {
      Print "///// Hover-> Holding".
    }
    lock throttle to hover_throttle.
  }
}

function align_ship{
  //Takes Steering as param
  sas off.
  parameter target_alignment.
  lock steering to target_alignment.  
  until abs(steering:pitch - facing:pitch) < 0.15 and abs(steering:yaw - facing:yaw) < 0.15{ //Started as wait untill in case of bugs..
    print "Aligning Craft.".
    lock steering to target_alignment.  
  }.
}

function alt_true{
  return altitude - ship:geoposition:terrainheight.
}

function Deorbit {
  
  parameter deorbit_type is "Now".
  set flight_mode to "Deorbit-"+deorbit_type.
  LOCAL alt_true is alt_true().
  set deorbit_mode to 0.     
  until deorbit_mode = 1 {

    if deorbit_type = "Now"{
      set status_message to "Waiting For Trigger Condition".
      if alt_true > 10000 {
        set status_message to "Altitude High-Slowing speed by 25%".
        Reduce_Groundspeed(Groundspeed*0.75).
        set deorbit_mode to 1.
      }
      if alt_true > 4000 and alt_true < 7000 { 
        Reduce_Groundspeed(Groundspeed*0.50).
        set status_message to "Altitude Medium-Slowing speed by 50%".
        set deorbit_mode to 1. 
      }
      if alt_true < 4000 { 
        Reduce_Groundspeed(Groundspeed*0.25).
        set status_message to "Altitude Low-Slowing speed by 75%".
        set deorbit_mode to 1. 
      }
    }
    if deorbit_type = "At_PE"{
      //code for /wait till PE later
      if ship:body = Mun OR ship:body = Minmus {
        if periapsis > 10000{
          node_change_apsis("p", 3500).
          execute_node().
          set deorbit_mode to 1.
        }
      }
    }
    run_gui(flight_mode, status_message).
  }
}

function suicide_burn_alt{
  //Update_Variables.
  lock t to (verticalspeed/ship_max_acceleration_surface).
  //Burn time
  lock h to (verticalspeed*t)-(0.5*(verticalspeed^2/ship_max_acceleration_surface^2))*ship_max_acceleration_surface.
  return h.
}

function Time_To_Impact{
  PARAMETER margin is 0.
  //From Gisikw on github.
  LOCAL d IS ALT:RADAR - margin.
  LOCAL v IS -SHIP:VERTICALSPEED.
  LOCAL g IS SHIP:BODY:MU / SHIP:BODY:RADIUS^2.
  RETURN (SQRT(v^2 + 2 * g * d) - v) / g.
}

function Landing {
  if alt:radar > 5 {
    set landed to 0.
  }
  toggle gear.
  until landed = 1 {
    local alt_true is alt_true().
    print "Altitude-radar: "+alt:radar.
    print "Altitude_True: "+alt_true.
    print "GroundSpeed: "+ GroundSpeed.
    Print "sb alt:"+ suicide_burn_alt().
    Print "Time to Time_To_Impact"+ round(Time_To_Impact(),2).

    if alt:radar < (suicide_burn_alt()*1.1) {
      Print "Suicide Burn".
      until verticalspeed > -3 {
        lock steering to up.
        lock throttle to 1.
      }
    }

    if alt_true < 4000 and alt_true > 1000 { // and Time_To_Impact - burn time is > than 10 seconds
      Print "4000-1000m -> Checking GroundSpeed - Normal High Gate at 2k".
      if Groundspeed > 200 {
        Print "High Gate -4k -Emergency Approach".
        Reduce_Groundspeed().
      }
      if Groundspeed > 100 and Groundspeed < 200 {
        Print "High Gate -4k -Fast Approach".
        Reduce_Groundspeed().
      } 
      if Groundspeed < 100 and Groundspeed > 5 and altitude < 2000 {
        Print "High Gate -2k -Normal Approach".
        Reduce_Groundspeed().
      } 
    }
    
    if alt_true < 1000 {

      if Groundspeed > 5 {
        print "Low Gate - 1k". 
        Reduce_Groundspeed().
      }      
      if alt_true < 100 and alt:radar > 10 {
        print "Final Approach 100-10 Metres - Checking Vertical Speed.".
        if gear = 0 {
          toggle gear.
          Print "Waiting for Gear".
          wait until gear = 1. 
        }   
        if verticalspeed > 1 {
          print "ERROR CRAFT ASCENDING". 
          hover().
          Reduce_Groundspeed().
          lock steering to UP.
          lock throttle to throttle_gravity_neutral_vacuum.
        }
        if verticalspeed < -0.5 and verticalspeed > -5 {  
          print "Vertical Speed Nominal Checking Groundspeed". 
          lock throttle to throttle_gravity_neutral_vacuum.
          if GroundSpeed < 3 {
            print "Good touchdown Profile". 
            sas off.
            lock steering to UP.
          }
          if GroundSpeed > 3 and GroundSpeed < 10 {
            print "Correcting Groundspeed - Locking Retro". 
            unlock steering.
            sas on.
            set sasmode to "RETROGRADE".
            until GroundSpeed < 3 {
              Lock throttle to (throttle_gravity_neutral_vacuum*1.2).
            }
          }
          if GroundSpeed > 3 and GroundSpeed > 10 {
            print "ERROR - Extreme Hoz". 
            hover().
            Reduce_Groundspeed().
            lock steering to UP.
          }
        }
        if verticalspeed < -5 and verticalspeed > -10 { 
          print "Vertical Speed High - Slowing".
          lock steering to up.
          set throttle_gravity_neutral_vacuum to throttle_gravity_neutral_vacuum *1.15.
        }
        if verticalspeed < -10 { 
          print "Extreme Vertical Speed -Checking for Impact".
          lock steering to up.
          set throttle to throttle_gravity_neutral_vacuum *1.15.
          if alt:radar < (suicide_burn_alt()*1.1) {
            Print "!!!Emergency Suicide Burn!!!".
            until verticalspeed > -3 {
              lock steering to up.
              lock throttle to 1.
            }
          }
        }
      }
      if alt:radar < 5 {
        unlock steering.
        sas on.
        set sasmode to "STABILITYASSIST".
        set landed to 1.
        until alt:radar < 5 {
          set throttle to throttle_gravity_neutral_vacuum.
        }
        set throttle to 0.
        Print "Landing Done".
      }  
    }    
    clearscreen. 
  }
}

//Program code
Print "Program loaded".
set end_test to 0. 
until end_test = 1 {
  Update_Variables().
  Print "Variables updated".
  Deorbit().
  Landing().
  Print "Deorbit ended".
  set end_test to 1.
  clearscreen.
  //Update_Gui().
}