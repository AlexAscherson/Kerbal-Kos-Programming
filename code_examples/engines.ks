
 // if stage:number > 0 {
    if maxthrust = 0 {
      stage.
    }
    SET numOut to 0.
    LIST ENGINES IN engines.
    FOR eng IN engines {
      print eng:FLAMEOUT.
      IF eng:FLAMEOUT
      {
        SET numOut TO numOut + 1.
      }
    }
    if numOut > 0 { stage. }.
  

//}