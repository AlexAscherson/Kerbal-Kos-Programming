
//A function for calculating time until surface impact (and bonus function you'll never need) (self.Kos)
//submitted 7 months ago * by only_to_downvote
//EDIT - Alternate method that should always find first impact time and not jump around is now posted in comments, see below
//I was inspired by Fez's post on suicide burns to write a function for "accurately" calculating impact times for any body:radius crossing orbit, not just mostly vertical ones.
//I originally though I would do this with some orbital mechanics (see below) but turns out that estimate wasn't all that great (it relied on estimating the terrain height at impact). /u/brekus pointed out that GEOPOSITIONOF and POSITIONAT could be used to find it with some iteration. Here's the function I came up with based on that:
FUNCTION coastImpactTime
{
    // Returns time in seconds until estimated time of impact with surface assuming no 
    //    external forces on the spacecraft or 0 if no impact
    // Usage: coastImpactTime(). 
    // NOTE: value can fluctuate if multiple solutions exist (e.g. shallow trajectory passing through 
    //    crater rim). For very shallow trajectories on bodies with relatively large terrain features, 
    //    value can have significant error
    // written by /u/only_to_downvote

    // return 0 if no impact
    IF SHIP:OBT:PERIAPSIS > 0
    {
        RETURN 0. 
    }.

    // tolerance (in seconds)
    LOCAL tol IS 0.1.

    // Set up initial two time points at periapsis and either apoapsis (if still ascending) or current time
    LOCAL timeOffsetT0 IS 0.
    IF ETA:APOAPSIS < ETA:PERIAPSIS SET timeOffsetT0 TO ETA:APOAPSIS + 1. // ensure altitude decreases with time
    LOCAL terrainHeightT0 IS SHIP:BODY:GEOPOSITIONOF(POSITIONAT(SHIP,TIME:SECONDS + timeOffsetT0)):TERRAINHEIGHT.
    LOCAL orbitAltT0 IS SHIP:BODY:ALTITUDEOF(POSITIONAT(SHIP,TIME:SECONDS + timeOffsetT0)).
    LOCAL errorT0 IS ABS(orbitAltT0 - terrainHeightT0).

    LOCAL timeOffsetT1 IS ETA:PERIAPSIS.
    LOCAL terrainHeightT1 IS SHIP:BODY:GEOPOSITIONOF(POSITIONAT(SHIP,TIME:SECONDS + timeOffsetT1)):TERRAINHEIGHT.
    LOCAL orbitAltT1 IS SHIP:BODY:ALTITUDEOF(POSITIONAT(SHIP,TIME:SECONDS + timeOffsetT1)).
    LOCAL errorT1 IS ABS(orbitAltT1 - terrainHeightT1).

    // Binary search to minimize (terrain height - orbital altitude) at specified time
    UNTIL False
    {
        LOCAL midPoint IS (timeOffsetT1 + timeOffsetT0)/2.
        IF ABS(timeOffsetT1 - timeOffsetT0) < tol RETURN midPoint.
        IF errorT0 < errorT1
        {
            SET timeOffsetT1 TO midPoint.
            SET terrainHeightT1 TO SHIP:BODY:GEOPOSITIONOF(POSITIONAT(SHIP,TIME:SECONDS + timeOffsetT1)):TERRAINHEIGHT.
            SET orbitAltT1 TO SHIP:BODY:ALTITUDEOF(POSITIONAT(SHIP,TIME:SECONDS + timeOffsetT1)).
            SET errorT1 TO ABS(orbitAltT1 - terrainHeightT1).
        }
        ELSE
        {
            SET timeOffsetT0 TO midPoint.
            SET terrainHeightT0 TO SHIP:BODY:GEOPOSITIONOF(POSITIONAT(SHIP,TIME:SECONDS + timeOffsetT0)):TERRAINHEIGHT.
            SET orbitAltT0 TO SHIP:BODY:ALTITUDEOF(POSITIONAT(SHIP,TIME:SECONDS + timeOffsetT0)).
            SET errorT0 TO ABS(orbitAltT0 - terrainHeightT0).
        }.
    }.
}.
//Anyone have suggestions for improvement or see any flaws that might cause errors I haven't found yet?
// Also, (although probably not all that useful) since I had already written most of it, I converted my other attempt into a function for calculating ETA to the next time you cross a specified altitude:
FUNCTION timeToAltitude
{
    // Returns time in seconds to the next time SHIP crosses the input altitude or 0 if 
    //    input altitude is never crossed
    // Usage: timeToAltitude(<altitude in meters>)
    // written by /u/only_to_downvote

    PARAMETER alt.

    // return 0 if never reach altitude
    IF alt < SHIP:PERIAPSIS OR alt > SHIP:APOAPSIS RETURN 0.

    // query constants
    LOCAL ecc IS SHIP:OBT:ECCENTRICITY.
    IF ecc = 0 SET ecc TO 0.00001. // ensure no divide by 0
    LOCAL sma IS SHIP:OBT:SEMIMAJORAXIS.
    LOCAL desiredRadius IS alt + SHIP:BODY:RADIUS.
    LOCAL currentRadius IS SHIP:ALTITUDE + SHIP:BODY:RADIUS.

    // Step 1: get true anomaly (bounds required for numerical errors near apsides)
    LOCAL desiredTrueAnomalyCos IS MAX(-1, MIN(1, ((sma * (1-ecc^2) / desiredRadius) - 1) / ecc)).
    LOCAL currentTrueAnomalyCos IS MAX(-1, MIN(1, ((sma * (1-ecc^2) / currentRadius) - 1) / ecc)).

    // Step 2: calculate eccentric anomaly  
    LOCAL desiredEccentricAnomaly IS ARCCOS((ecc+desiredTrueAnomalyCos) / (1 + ecc*desiredTrueAnomalyCos)).
    LOCAL currentEccentricAnomaly IS ARCCOS((ecc+currentTrueAnomalyCos) / (1 + ecc*currentTrueAnomalyCos)).

    // Step 3: calculate mean anomaly
    LOCAL desiredMeanAnomaly IS desiredEccentricAnomaly - ecc  * SIN(desiredEccentricAnomaly).
    LOCAL currentMeanAnomaly IS currentEccentricAnomaly - ecc  * SIN(currentEccentricAnomaly).
    IF ETA:APOAPSIS > ETA:PERIAPSIS
    {
        SET currentMeanAnomaly TO 360 - currentMeanAnomaly.
    }.
    IF alt < SHIP:ALTITUDE
    {
        SET desiredMeanAnomaly TO 360 - desiredMeanAnomaly.
    }
    ELSE IF alt > SHIP:ALTITUDE AND ETA:APOAPSIS > ETA:PERIAPSIS
    {
        SET desiredMeanAnomaly TO 360 + desiredMeanAnomaly.
    }.

    // Step 4: calculate time difference via mean motion
    LOCAL meanMotion IS 360 / SHIP:OBT:PERIOD. // in deg/s
    RETURN (desiredMeanAnomaly - currentMeanAnomaly) / meanMotion.
}.
//6 commentsshare
//sorted by: best
//[–]only_to_downvote[S] 3 points 7 months ago* 
//Here's an alternate method that doesn't jump around and, thanks to /u/brekus 's suggestion, should always find the first impact time (if multiple exist).
//But the tradeoff is it may take several seconds to initialize, it requires use of a global variable, and it uses the function timeToAltitude (from the main post). The global variable could be done away with if it were to pass in/out a list, but I preferred to have it just return a single number.
FUNCTION timeToImpact
{
    // Returns time in seconds until first time of impact with surface assuming no 
    //    external forces on the spacecraft (or 0 if no impact)
    // Usage: 
    //    requires initialization:   GLOBAL impactTimeList IS LIST(0,0).
    //    run with:   timeToImpact(). 
    // NOTE: requires GLOBAL variable impactTimeList to operate.
    //       requires function timeToAltitude
    // written by /u/only_to_downvote

    // return 0 if no impact
    IF SHIP:OBT:PERIAPSIS > 0
    {
        RETURN 0. 
    }.

    // tolerance (in seconds)
    LOCAL tol IS 0.1.

    // initialize variables
    LOCAL terrainHeight IS 0.
    LOCAL orbitAlt IS 1.
    LOCAL timeOffset IS 0.

    // one time setup if impact time not previously found (requires many iterations, slow)
    IF impactTimeList[0] = 0
    {
        HUDTEXT("Initializing, may take several seconds.",2,50,2,WHITE,FALSE).
        SET WARP TO 0.
        // start from time to altitude = 1/2 body's radius (worst case terrain height)
        IF ALTITUDE > (BODY:RADIUS / 2) SET timeOffset TO timeToAltitude(BODY:RADIUS / 2).  
        UNTIL orbitAlt < terrainHeight
        {
            SET terrainHeight TO SHIP:BODY:GEOPOSITIONOF(POSITIONAT(SHIP,TIME:SECONDS + timeOffset)):TERRAINHEIGHT.
            SET orbitAlt TO SHIP:BODY:ALTITUDEOF(POSITIONAT(SHIP,TIME:SECONDS + timeOffset)).
            SET timeOffset TO timeOffset + 2.
        }.
        SET timeOffset TO timeOffset - 20.
    }

    // Start from a bit before previously found impact time if exists to speed things up significantly
    ELSE SET timeOffset TO (impactTimeList[0] - 5*(TIME:SECONDS - impactTimeList[1])).

    // Loop to find impact time accurately
    UNTIL orbitAlt < terrainHeight
    {
        SET terrainHeight TO SHIP:BODY:GEOPOSITIONOF(POSITIONAT(SHIP,TIME:SECONDS + timeOffset)):TERRAINHEIGHT.
        SET orbitAlt TO SHIP:BODY:ALTITUDEOF(POSITIONAT(SHIP,TIME:SECONDS + timeOffset)).
        SET timeOffset TO timeOffset + tol.
    }.
    GLOBAL impactTimeList IS LIST(timeOffset - tol, TIME:SECONDS).
    RETURN impactTimeList[0].
}.
