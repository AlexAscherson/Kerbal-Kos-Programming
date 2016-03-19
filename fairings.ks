//fairings

   // if SHIP:ALTITUDE > 40000  {

      // Iterates over a list of all parts with the stock fairings module
      FOR module IN SHIP:MODULESNAMED("ModuleProceduralFairing") { // Stock and KW Fairings
          if module:allevents:length = 0 {
            "Fairings already deployed.".
          } else {
            module:DOEVENT("deploy").  // and deploys them
            HUDTEXT("Fairing Utility: Aproaching edge of atmosphere; Deploying Fairings", 3, 2, 30, YELLOW, FALSE).
            PRINT "Deploying Fairings". 
          }                
      }
   // }
