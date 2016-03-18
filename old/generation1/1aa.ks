
FUNCTION NOTIFY {
  PARAMETER message.
  HUDTEXT("kOS: " + message, 5, 2, 50, WHITE, false).
}

function hello{
	notify("hello World").
}

set mylist to list().
mylist:add(5).
mylist:add(hello()).