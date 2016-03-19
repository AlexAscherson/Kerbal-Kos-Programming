function decouple_port{
  parameter portname.
  for port in ship:dockingports{
  	if port:tag = portname{
  	print "port found by tag".
    print port.
  	}
    if port:title = portname{
      print "port found by title".
      print port.
      print 
      if port:state = "PreAttached"{
        print "should undock".
        port:GETMODULE("ModuleDockingNode"):doevent("decouple node").
      }
    }
  }
  check_staging().

}
// can also use SHIP:DOCKINGPORTS[0] structure."Clamp-O-Tron Docking Port"