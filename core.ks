execute_mission_profile().

function execute_mission_profile{

  print "STARTING".

  copy core_functions from 0.
  run core_functions.

  set mission_profile to lexicon().
  set mission_profile["Target_Body"]    to Minmus.
  set mission_profile["Mission"]        to "Land".
  set mission_profile["Mission_target"] to "None".
  //set mission_status

  Mission_stage_launch(mission_profile).
  Mission_stage_transfer(mission_profile).
  Mission_stage_establish_orbit(mission_profile).
  Mission_stage_land(mission_profile).
  mission_stage_return_to_orbit(mission_profile).
  mission_stage_rendevous(mission_profile).
  Mission_stage_dock(mission_profile).

}

  //Launch and circ
  
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
    establish_orbit(mission_profile["Target_Body"]).

  } else if ship:body = kerbin and ship:orbit:hasnextpatch {
    //Transfer to Mun
    establish_orbit(mission_profile["Target_Body"]).

  } else {
    notify ("Conditions Incorrect to execute mission stage 2").
    return false.
  }
}

function Mission_stage_establish_orbit{
  parameter mission_profile.
  copy establish_parking_orbit from 0.
  run establish_parking_orbit.
  if ship:status <> "LANDED" and ship:status <> "SUB_ORBITAL"{ 
    if establish_orbit(mission_profile["Target_Body"]) = true {
      establish_parking_orbit().
      if establish_parking_orbit() = true {
        decouple_port("transfer_engine_port").
        decouple_port("transfer_engine").  
        target_nearest_craft().
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
          notify("Landing Mission Complete").
          wait 5.
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
    }
  }
}

function mission_stage_rendevous{
  parameter mission_profile.    
  if ship:body = mission_profile["Target_Body"] {
    if ship:status = "ORBITING" { 
      notify("Executing Rendevous Program").
      if has_file("ascent_lunar.ks",1) delete ascent_lunar.ks.
      if has_file("establish_orbit.ks",1) delete establish_orbit.ks.
      if has_file("establish_parking_orbit.ks",1) delete establish_parking_orbit.ks.
      copy rendevous from 0.
      run rendevous.
      rendevous_transfer_to_target(). 
      sas off.  
      rendevous_approach().
      notify("Rendevous Program Complete").
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

}