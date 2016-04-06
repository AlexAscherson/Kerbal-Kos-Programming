execute_mission_profile().

function execute_mission_profile{

  print "STARTING".

  copy core_functions from 0.
  run core_functions.

  if HAS_FILE(mission_log.json, 1) {
    // dont setup.
  } else {
    notify("Setting up mission log").
    setup_mission_log().
  }

  set mission_profile to lexicon().
  set mission_profile["Target_Body"]    to Minmus.
  set mission_profile["Mission"]        to "Land".
  set mission_profile["Mission_target"] to "None".
  //set mission_status

  if read_mission_log("Status") = "Prelaunch"{
    Mission_stage_launch(mission_profile).
  }
  if read_mission_log("Status") = "Orbiting_after_launch"{
    Mission_stage_transfer(mission_profile).
  }
  if read_mission_log("Status") = "Transfer_complete"{
    Mission_stage_establish_park_orbit_and_decouple(mission_profile).
  }
  if read_mission_log("Status") = "Decoupled"{
    Mission_stage_land(mission_profile).
  }
  if read_mission_log("Status") = "Landed"{
    mission_stage_return_to_orbit(mission_profile).
  }
  if read_mission_log("Status") = "Orbiting_after_landing"{
    mission_stage_rendevous(mission_profile).
  }
  if read_mission_log("Status") = "Pre_dock" {
    Mission_stage_dock(mission_profile).
  }
  if read_mission_log("Status") = "Docked" { 
    Mission_stage_transfer_to_sun(mission_profile).
  }
  if read_mission_log("Status") = "Sol_orbit" { 
    Mission_stage_transfer_planet(mission_profile, Duna).
  }

}

  
function Mission_stage_launch{
  parameter mission_profile.
  if alt:radar < 100 and ship:body:name = "kerbin" {  // Landed At KSC -> Launch
    copy ascent from 0.
    run ascent.
    notify("Running Ascent Program.").
    Launch_from_KSC(100000).
    notify("Ascent Program Complete.").
    delete ascent.
    delete ascent_profile.ks.
    write_mission_log("Status","Orbiting_after_launch").
  } else {
    notify ("Conditions Incorrect to execute mission stage 1").
    return false.
  }
}
  
function Mission_stage_transfer{
  parameter mission_profile.

  copy establish_orbit from 0.
  run establish_orbit.
  if ship:body = kerbin and ship:orbit:hasnextpatch = false {
    //Transfer to Mun
    copy hoffman_transfer from 0.
    run hoffman_transfer.
    notify("Executing Transfer Program").
    transfer_node(mission_profile["Target_Body"]).
  
    if check_if_next_node(){
      execute_node(). // Maybe copy into core functions...
    } else {
      notify("Error - No node found - Waiting 2 orbits and trying again.").
      warpto(time:seconds+(2*ship:orbit:period)).
      transfer_node(mission_profile["Target_Body"]).
    }

    delete hoffman_transfer.
    notify ("Establishing Orbit Around Target.").
    establish_orbit(mission_profile["Target_Body"]).
    write_mission_log("Status","Transfer_complete").

  } else if ship:body = kerbin and ship:orbit:hasnextpatch {
    //Transfer to Mun
    notify("Transfer Error - Ship has next patch.").

  } else {
    notify ("Conditions Incorrect to execute mission stage 2").
    return false.
  }
}

function Mission_stage_establish_park_orbit_and_decouple{
  parameter mission_profile.
  copy establish_orbit from 0.
  run establish_orbit.
  copy establish_parking_orbit from 0.
  run establish_parking_orbit.
  if ship:status <> "LANDED" and ship:status <> "SUB_ORBITAL"{ 
    if establish_orbit(mission_profile["Target_Body"]) = true {
      establish_parking_orbit().
      if establish_parking_orbit() = true {
        decouple_port("transfer_engine_port").
        decouple_port("transfer_engine").  
        target_nearest_craft().
        write_mission_log("Status","Decoupled").
        return true.   
      }
    } else {
      print "establish orbit return false.  Not in target body SOI and no patch coming up.".
    }

    if ship:body = mission_profile["Target_Body"] and ship:status = "ORBITING" {
      establish_parking_orbit().
    }
  } else {
    notify("Skipping Mission stage Establish Orbit.").
  }
}


function Mission_stage_land{
  parameter mission_profile.
      
  if ship:body = mission_profile["Target_Body"] {
    if mission_profile["Mission"] = "Land"{ 
        if ship:status <> "LANDED" { 
          //if establish_parking_orbit() <> true {
            //establish_parking_orbit(). 
          //}
          if has_file("rendevous.ks",1) delete rendevous.ks.
          if has_file("hoffman_node.ks",1) delete hoffman_node.ks.
          if has_file("dock_lib.ks",1) delete dock_lib.ks.
          copy descent from 0.
          run descent.
          descend_to_land().
          notify("Landing Complete.").
          wait 5.
          write_mission_log("Status","Landed").
      } else {
        notify("landed on target body - Mission Complete").

        wait 5.
        return true.
      }
    }
  } else {
    notify ("Conditions Incorrect to execute Landing").
    return false.
  }
}

function mission_stage_return_to_orbit{
  parameter mission_profile.
  if ship:body = mission_profile["Target_Body"] {
    if ship:status = "LANDED" { 
      notify("Running Ascent Program").
      wait 5.
        if has_file("descent.ks",1) delete descent.ks.
        if has_file("brake_warning.ks",1) delete brake_warning.ks.
      copy ascent_lunar from 0.
      run ascent_lunar.
      ascend_from_moon().   
      notify("Ascent Program Complete").
      write_mission_log("Status","Orbiting_after_landing").
    }
  }
}

function mission_stage_rendevous{
  parameter mission_profile.    
  if ship:body = mission_profile["Target_Body"] {
    if ship:status = "ORBITING" { 
      notify("Executing Rendevous Program").
      if has_file("ascent_lunar.ks",1) delete ascent_lunar.ks.
      if has_file("establish_orbit.ks",1) delete establish_orbit.
      if has_file("establish_parking_orbit.ks",1) delete establish_parking_orbit.ks.
      copy rendevous from 0.
      run rendevous.
      set_inc_lan(target:orbit:inclination, target:orbit:LAN).
      execute_node().
      rendevous_transfer_to_target(). 
      sas off.  
      rendevous_approach().
      notify("Rendevous Program Complete").
      write_mission_log("Status","Pre_dock").
    }
  }
}

function Mission_stage_dock{
  parameter mission_profile.
  notify("Begining Docking Sequence").
  ship:dockingports[0]:controlfrom().
  wait 1.
  copy dock_lib from 0.
  run dock_lib.
  dok_dock(ship:dockingports[0]:tag, target:name).
  notify("Docking Complete").
  write_mission_log("Status","Docked").
  delete dock_lib.
}

function Mission_stage_transfer_to_sun{
  parameter mission_profile.
  copy establish_sol_orbit from 0.
  run establish_sol_orbit.
  establish_solar_orbit().
  write_mission_log("Status","Sol_orbit").
  wait 1.
  delete establish_sol_orbit.

}

function Mission_stage_transfer_planet{
  parameter mission_profile.
  parameter target_p is Duna.
  set target to target_p. 

  if ship:orbit:ECCENTRICITY > 0.05 {
    circ_with_node("a").
    execute_node().
  }
  
  local ri is abs(obt:inclination - target:obt:inclination).
 // Align if necessary
  if ri > 0.1 {
    copy inc2 from 0.
    run inc2.
    set_inc_lan(target:orbit:inclination, target:orbit:LAN).
    execute_node().
    delete inc2.
  }
  //copy hoffman_transfer from 0.
  //run hoffman_transfer.
  //notify("Executing Transfer Program").
  //transfer_node(target_p).

  //copy hoffman_node from 0.
  //run hoffman_node.

  //get_hoffman_node().
  //if check_if_next_node() = false {
  //  print "Rendezvous, Transfer to phasing orbit".
 //   node_change_apsis("a",target:altitude * 1.666).
 //   execute_node().
 //  node_change_apsis("p",target:altitude * 1.666).
  //  execute_node().
  //  get_hoffman_node().
 // }

// copy interplanetary_transfer from 0.
// run interplanetary_transfer.

  //print "Rendezvous Transfer injection burn".
  //execute_node().
}