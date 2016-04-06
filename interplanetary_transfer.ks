run core_functions.

function interplanetary_transfer{
	parameter target_p is Duna.

  set target to target_p.

  //if target:orbit:apoapsis < orbit:apoapsis{
  //  copy hoffman_node from 0.
  //  run hoffman_node.
  //  get_hoffman_node().
  //  set incriment to -1.
  //} else {
    copy hoffman_transfer from 0.
    run hoffman_transfer.
    set incriment to 1.
    transfer_node(target, false).
  //}

  local counter is 0.
  local count_limit is 500.
  set backup_node to nextnode.
  set reset_already to 0.

  until false {
    wait 0.1.
    if encounter = "none" or encounter:body:name <> target:name {
      if counter < count_limit{
        set old_node to nextnode.
        set old_node:prograde to old_node:prograde + incriment.
        remove nextnode.
        add old_node.
        set counter to counter+1.
      } else if reset_already = 0 {
        Print "reset counter and reversing incriment".
        print backup_node.
        set nextnode:prograde to nextnode:prograde - (counter*incriment).
        set reset_already to 1.
        set counter to 0.
       // remove nextnode.
       // add backup_node.
        if incriment = -1 {
          set incriment to 1.
        } else {
          set incriment to -1.
        }
      } else {
        Print "Tried twice with DV. - Restoring backup_node and trying time".
        set nextnode:prograde to nextnode:prograde - (counter*incriment).
        //remove nextnode.
        //add backup_node.
        increment_node_date().
        raised_ap_search().
        break.
      }
    } else {
      Print "Encounter Found!".
      print encounter:body:name.
      break.
    }

  } 
  
  refine_approach().
  
}

function raised_ap_search{

  if encounter = "none" or encounter:name <> target:name{
      Print "Encounter Failed - Trying again with higher ap".
      remove nextnode.
      transfer_node(target, false).
      
      // if going up raise ap, if down lower pe.
      if nextnode:prograde > 0 {
        //We are going up
        //set incrementer to 1.
        if nextnode:orbit:apoapsis < target:orbit:apoapsis {
          until false {
            set nextnode:prograde to nextnode:prograde+1.
            if nextnode:orbit:apoapsis > target:orbit:apoapsis{
              Print "AP Now Above target pe".
              break.
            }
          }
        }

      } else {
        //We are going down.
        //set incrementer to -1.
        if nextnode:orbit:periapsis > target:orbit:periapsis {
          until false {
            set nextnode:prograde to nextnode:prograde-1.
            if nextnode:orbit:periapsis < target:orbit:periapsis{
              Print "PE Now below target pe".
              break.
            }
          }
        }
      }
      if encounter = "none" or encounter:name <> target:name{ // unlikely we will have encounter but who knows.
        Print "INcrimeting by day.".
        increment_node_date().
      }
  }
}

function increment_node_date{
  parameter time_incriment is (6*(60*60)).  // one day
  set time_counter to 0.
  set time_counter_limit to 500.
  set time_reset_already to 0.

  until false {
    wait 0.1.
    if encounter = "none" {
      if time_counter < time_counter_limit and nextnode:eta > 0{
        set old_node to nextnode.
        set old_node:eta to old_node:eta + time_incriment.
        remove nextnode.
        add old_node.
        set time_counter to time_counter+1.
      } else if time_reset_already = 0 {
        Print "reset counter and reversing incriment".
        print backup_node.
        set time_reset_already to 1.
        set nextnode:eta to nextnode:eta - (time_counter*time_incriment).
        set time_counter to 0.
        //remove nextnode.
        //add backup_node.
        set time_incriment to time_incriment * -1.
       
      } else {
        Print "Tried twice with Time incriment. - Restoring backup_node".
        remove nextnode.
        add backup_node.
        break.
      }
    } else {
      Print "Encounter Found!".
      print encounter:body:name.
      break.
    }
  }
}

function refine_approach{

  set backup_node to nextnode.
  set original_pe to encounter:periapsis.

  if target:orbit:apoapsis < orbit:apoapsis{
    set incriment to -1.
  } else {
    set incriment to 1.
  }

  until false {
    
    if encounter <> "none" {

      if encounter:body:name = target:name and encounter:periapsis < target:soiradius*0.20 {
        Print "We have reached target encounter periapsis.".
        break.
      } else if encounter:body:name <> target:name {
        Print "Another body In the way - Press on.-"+encounter:body:name.
      }

      print "encounter pe:"+ encounter:periapsis.
      print "encounter body:" + encounter:body. 

      set old_node to nextnode.
      set new_node to nextnode.
      set old_pe to encounter:periapsis.

      set new_node:prograde to nextnode:prograde + incriment.
      remove nextnode.
      add new_node.
      Print "Periapsis Refined".
      wait 0.1.
      if encounter <> "None"{
        if encounter:Body:name = target:name and encounter:periapsis < old_pe {
          print "Success - New Pe is lower than old pe.".
        } else if encounter:Body:name = target:name and encounter:periapsis > old_pe { 
          print "Error - New Pe is Higher than old pe.".
          if incriment < 1 {
            set incriment to 1.
          } else {
            set incriment to -1.
          }
          remove nextnode.
          add old_node.
          //break.
        }
      } else { 
        Print "We lost the encounter1 - Restoring previous node".
        set new_node:prograde to nextnode:prograde - incriment.
        remove nextnode.
        add new_node.
        if encounter = "None" {
          Print "Restore failed - Reverting to backup".
          remove nextnode.
          add backup_node.
        }
        break.
      }
    } else { 
      Print "We lost the encounter2 - Restoring previous node".
      set new_node:prograde to nextnode:prograde - incriment.
      remove nextnode.
      add new_node.

      if encounter = "None" {
        Print "Restore failed - Reverting to backup".
        remove nextnode.
        add backup_node.
      }
      break.
    }
  }

}
interplanetary_transfer(Target).