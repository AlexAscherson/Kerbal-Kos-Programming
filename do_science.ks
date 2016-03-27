// Find a list of all science parts and store it in a variable
clearscreen.

SET LIST_ALL_PARTS TO SHIP:PARTS.
SET LIST_SCIENCE_PART_MODULES TO LIST().
SET LIST_SCIENCE_PARTS_RERUNNABLE TO LIST().

FOR myPart in LIST_ALL_PARTS {
	FOR myPart_MODULENAME in myPart:MODULES {
		//print myPart_MODULENAME.
		if myPart_MODULENAME = "ModuleScienceExperiment" {
			SET SCIENCE_PART_MODULE TO myPart:GETMODULE(myPart_MODULENAME).
			//PRINT SCIENCE_PART_MODULE.
			LIST_SCIENCE_PART_MODULES:ADD(SCIENCE_PART_MODULE).
		}
	}
}

FOR SCIENCE_MODULE in LIST_SCIENCE_PART_MODULES {
	if SCIENCE_MODULE:rerunnable {
		LIST_SCIENCE_PARTS_RERUNNABLE:ADD(SCIENCE_MODULE).
	}
}

// Now we have all Science parts stored in our lists




function performExperiment {
	parameter experiment.
	
	if experiment:HASDATA {
		experiment:DUMP().
	}
	
	
	if not experiment:DEPLOYED {
		experiment:DEPLOY().
		WAIT UNTIL experiment:HASDATA.
	}
	
	if (experiment:DATA[0]:TRANSMITVALUE > 0.5) {
		print experiment:DATA[0].
		print experiment:DATA[0]:TRANSMITVALUE.
		
		experiment:TRANSMIT().
		print "Transmitting " + experiment:DATA[0]:TRANSMITVALUE + " Science!".
	} else {
		print "".
		print "".
	}
	
	experiment:DUMP().
	experiment:RESET().
}



UNTIL FALSE {
	clearscreen.
	FOR experiment in LIST_SCIENCE_PARTS_RERUNNABLE {
		performExperiment(experiment).
	}
	wait 10.
}