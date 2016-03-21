execute_mission_profile().

function execute_mission_profile{

  print "STARTING".

  copy core_functions from 0.
  run core_functions.

  set mission_profile to lexicon().
  set mission_profile["Target_Body"]    to Minmus.
  set mission_profile["Mission"]        to "Land".
  set mission_profile["Mission_target"] to "None".

  Mission_stage_launch(mission_profile).
  Mission_stage_transfer(mission_profile).
  Mission_stage_land(mission_profile).

}

  //Launch and circ
  
function Mission_stage_launch{
  parameter mission_profile.
  if alt:radar < 100 and ship:body:name = "kerbin" {  // Landed At KSC -> Launch
    copy ascent from 0.
    run ascent.
    notify("Running Ascent Program.").
    Launch_from_KSC(80000).
    notify("Ascent Program Complete.").
    //delete ascent.
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
    transfer_node(mission_profile["Target_Body"]).
    notify("Executing Transfer Program").
    execute_node(). // Maybe copy into core functions...
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

  copy establish_parking_orbit from 0.
  run establish_parking_orbit.

  if establish_orbit(mission_profile["Target_Body"]) = true {
    establish_parking_orbit().
    if establish_parking_orbit() = true {
      decouple_port("transfer_engine_port").
      decouple_port("transfer_engine").     
    }

  } else {
    print "establish orbit return false.  Not in traget body and no patch coming up.".
  }

  if ship:body = mission_profile["Target_Body"] and ship:status = "ORBITING" {
    establish_parking_orbit().
  }


}


function Mission_stage_land{
  parameter mission_profile.
      
  if ship:body = mission_profile["Target_Body"] {
    if mission_profile["Mission"] = "Land"{ 
        if ship:status <> "LANDED" { 
          
          establish_parking_orbit(). 
            
          copy descent from 0.
          run descent.
          descend_to_land().
          notify("Landing Mission Complete").
      } else {
        notify("landed on target body - Mission Complete").
        return true.
      }
    }
  } else {
    notify ("Conditions Incorrect to execute mission stage 3").
    return false.
  }
}