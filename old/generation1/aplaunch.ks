copy core_functions from 0.
run core_functions.
Launch_from_KSC().


function Launch_from_KSC{

  parameter target_alt is 75000.
  parameter ascent_mode is "ascent_profile".
 
  load_function(execute_node.ks).
  load_function(circ.ks).
  run execute_node.ks
  run circ.ks

  if ascent_mode = "ascent_profile"{

    SET ascent_profile to LIST(
      // Altitude,  Angle,  Thrust
      0,            85,    // 1,
      2500,         80,     //0.35,
      10000,        75,    // 0.35,
      15000,        70,    // 0.35,
      20000,        55,    // 0.35,
      25000,        45,    // 0.35,
      32000,        45,    // 0.35,
      45000,        45,    // 0.1,
      50000,        25,    // 0.1,
      60000,        0,     // 0.1,
      70000,        0,     // 1,
      target_alt,   0     // 0
    ).

    load_function(ascent_profile.ks).
    Run ascent_profile.ks

    IF ALT:RADAR < 100 {
       
      //// Ascent Profile ////
      LOCK THROTTLE TO 1. WAIT 1. STAGE.
      EXECUTE_ASCENT_PROFILE(90, ASCENT_PROFILE, target_alt).

      Circ_with_node().
      execute_node().

      // Enable Communitron and shutdown
      TOGGLE LIGHTS.
      LOCK THROTTLE TO 0.
      SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
    }
  }
  if ascent_mode = "dynamic"{
    //Write dyanimic ascent function here.
    // load_function(dynamic_ascent)
    // run dynamic_ascent.ks.
    // execute_dynamic_ascent().
  }

}