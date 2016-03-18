function get_safe_orbit{
	
	set safeorbit to lexicon().

	set safeorbit[Kerbin] to 70000.
	set safeorbit[Mun]    to 4000.
	set safeorbit[Minmus] to 6250.

	set safeorbit[Duna]   to 42000.
	set safeorbit[Ike]    to 13500.
	
	set safeorbit[Eve]    to 97500.
	set safeorbit[Ghilly] to 7500.

	set safeorbit[Dres]   to 6500.

	set safeorbit[Moho]   to 7500.

	set safeorbit[Eeloo]  to 4500.

	set safeorbit[Jool]   to 139500.
	set safeorbit[Bop]    to 23000.
	set safeorbit[Pol]    to 6000.
	set safeorbit[Laythe] to 56000.
	set safeorbit[Val]    to 9000.
	set safeorbit[Tylo]   to 13500.

  set current_safeorbit to safeorbit[body].
  return current_safeorbit.

}