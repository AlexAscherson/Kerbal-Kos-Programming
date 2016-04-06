function decouple_port{
  parameter portname.
  for port in ship:dockingports{
    if port:tag = portname or port:title = portname{
      print "port found".
      print port.
      if port:state = "PreAttached"{
        print "should undock".
        // if port::GETMODULE("ModuleDockingNode"):allevents //to get events array.
        port:GETMODULE("ModuleDockingNode"):doevent("decouple node").
        wait 5.
      }
    }
  }
  check_staging().
}
// can also use SHIP:DOCKINGPORTS[0] structure."Clamp-O-Tron Docking Port"