mission_log.

function main_mission_log_init{

  set active_missions to lexicon().
  switch to 0. 
  delete active_missions.csv.
  log active_missions to active_missions.csv.
}

function get_mission_log{}

function write_to_mission_log{
	// Mission log is going to be a lexicon.  We are going to write it to a file, then read it from a file and change it if we need to.
 

}