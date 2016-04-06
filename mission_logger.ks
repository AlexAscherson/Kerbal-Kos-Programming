function setup_mission_log{
  set mission_log to lexicon().
  set mission_log["Ship_name"] to ship:name.
  set mission_log["Status"] to "Prelaunch".
  
  //switch to 0.
  WRITEJSON(mission_log, "mission_log.json").
}

function read_mission_log{
  parameter log_field is "None".  
  SET local_mission_log TO READJSON("mission_log.json").
  if log_field = "None" {
    return local_mission_log.
  } else {
    return local_mission_log[log_field].
  }
}

function write_mission_log{
  parameter log_field is "None".  
  parameter log_content is "None".
  SET local_mission_log TO READJSON("mission_log.json").  
  if log_field = "None" or log_content = "None"{
    Print "Error - not eneough fields set". 
  } else {
    SET local_mission_log[log_field] TO log_content.
    delete mission_log.json.
    WRITEJSON(local_mission_log, "mission_log.json").
  }
}