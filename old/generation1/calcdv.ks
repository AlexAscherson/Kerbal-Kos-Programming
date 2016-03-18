


set aF to APOAPSIS + body:radius. // apo/peri/semimajor axis of final, circular orbit
set aI to obt:semimajoraxis. //semimajor axis of starting orbit
set PeI to 100000+body:radius.
set VPeI to sqrt(body:mu * (2/PeI-1/aI)).
set aT to (PeI+aF)/2. //semimajor axis of transfer orbit
set VPeT to sqrt(body:mu * (2/PeI-1/aT)).
set dvIT to VPeT+VPeI.

SET mn TO NODE(APOAPSIS, 0, 0, dvIT).
ADD mn.

print dvIT.
	
