set mission_profile to lexicon().
  set mission_profile["Target_Body"]    to Mun.
  set mission_profile["Mission"]        to "Land".
  set mission_profile["Mission_target"] to "None".


  if ship:body = mission_profile["Target_Body"] {
    if ship:hasorbit{
      if mission_profile["Mission"] = "Land"{
        copy hal2.ks from 0.
        run hal2.
      }
    } else {
      circ_with_node("p").
      execute_node().
    }
  }