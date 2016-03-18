function setup_brake_log {
  set brake_log_columns to list().
  brake_log_columns:add( "Context:" + "Time:" 
                     + "True Alt:" + "Vertical Speed:" + "Groundspeed:"
                     + "Prediction Distance:" + "Horizontal Stop Distance:" + "Hoz Stop Time:" +
                     + "Predicted True Alt at Stop Distance:" + "predicted_fall:" + "Predicted Terrain hieght:"
                     + "time_to_change_speed(horizontal_stop):"
                     + "Vertical speed at stop point:" + "vertical stop time:"
                     + "Vertical stop distance after fall:"
                     + "local g:"
                     ).
  switch to 0.
  for item in brake_log_columns{
    log(item) to brake_log.csv.
  }
  switch to 1.

}
function run_brake_log{
  parameter context is "not set".
  set brake_log_items to list().
   
  brake_log_items:add( context + ":" + time:seconds + ":"
                     + round(alt_true(),2) + ":" + verticalspeed + ":" +Groundspeed + ":"
                     + round(prediction_distance,2) + ":" + distance_travelled_under_acceleration_over_time("horizontal_burn") + ":" + round(time_to_change_speed("horizontal_stop")) + ":" +
                     + round(predicted_true_alt_after_fall,2) + ":" + predicted_fall + ":" +terrain_position_at_stop_point:TERRAINHEIGHT + ":"
                     + time_to_change_speed("horizontal_stop") + ":"
                     + round(verticalspeed_after_fall,2) + ":" + round(time_to_change_speed("vertical_stop", 0, verticalspeed_after_fall),2) + ":"
                     + round(distance_travelled_under_acceleration_over_time("vertical_burn", time_to_change_speed("vertical_stop",0,verticalspeed_after_fall), verticalspeed_after_fall),2)+ ":"
                     + round(get_local_grav_acceleration(),2) + ":"). 

  switch to 0.
  for item in brake_log_items{
    log(item) to brake_log.csv.
  }
  switch to 1.
}