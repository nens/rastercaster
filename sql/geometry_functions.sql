----------------------------------------------------------------
--- CLEAN MULTI POLYGON MINIMUM AREA
--- Input: multi_polygon and minimum area of smallest polygon
--- Output: merge multi polygon based on minimum polygon area
----------------------------------------------------------------

CREATE OR REPLACE FUNCTION clean_multipolygon_minimum_area(geom geometry, area double precision default 1.0)
RETURNS geometry AS
$$
    DECLARE
	shorts int;
    BEGIN
	shorts = 1;
	WHILE shorts > 0
	LOOP
		WITH 
		polygons_dump AS (
			SELECT (ST_Dump($1)).geom geom
		), link AS (
			SELECT DISTINCT ON (s.geom) s.geom as s_geom, l.geom as l_geom 
			FROM polygons_dump l
			LEFT JOIN polygons_dump s
				ON ST_Overlaps(ST_exteriorring(s.geom),ST_Exteriorring(l.geom))
				AND ST_area(l.geom) > ST_Area(s.geom)
			WHERE ST_AREA(s.geom) < $2
			ORDER BY s.geom, ST_Area(l.geom) DESC, ST_Distance(s.geom,ST_Centroid(l.geom))
		), count_links AS (
			SELECT count(*) as shorts FROM link
		), new_geoms AS (
			SELECT ST_Buffer(ST_Collect(ST_Collect(s_geom),l_geom),0) geom
			FROM link
			WHERE l_geom NOT IN (SELECT s_geom FROM link)
			GROUP BY l_geom
			UNION
			SELECT b.geom
			FROM polygons_dump b
			WHERE b.geom NOT IN (SELECT l_geom FROM link)
				AND b.geom NOT IN (SELECT s_geom FROM link)
			UNION
			SELECT s_geom
			FROM link
			WHERE l_geom IN (SELECT s_geom FROM link)
		)
		SELECT ST_Collect(c.geom), max(d.shorts) into geom, shorts FROM new_geoms c, count_links d;
		--RAISE NOTICE 'shorts solved: %', shorts;
	END loop;
	RETURN geom;
    END;
$$ LANGUAGE plpgsql;

---- VOORBEELD HOE DEZE FUNCTIE TE GEBRUIKEN: -----
-- 	DROP TABLE IF EXISTS tmp.voronoi_koppelkaart_cleaned;
-- 	CREATE TABLE tmp.voronoi_koppelkaart_cleaned AS
-- 	WITH clean_polygons AS (
-- 		SELECT id, clean_multipolygon_minimum_area(ST_Collect(the_geom),10) the_geom
-- 		FROM tmp.combined_voronoi_bgt 
-- 		--WHERE id = 43418
-- 		GROUP BY id
-- 	)
-- 	SELECT nextval('ids') as koppel_voronoi_id, a.id as bgt_id, (ST_Dump(a.the_geom)).geom as the_geom, b.*
-- 	FROM clean_polygons a JOIN src.koppelkaart b ON a.id = b.id;DROP FUNCTION IF EXISTS ST_AddAsVertices(geometry, geometry, double precision);
CREATE OR REPLACE FUNCTION ST_AddAsVertices (
	inputlijn geometry,
	inputpoints geometry,
	tolerance double precision,
	snap boolean DEFAULT true
)
RETURNS
	geometry
AS
$BODY$
	DECLARE 
		is_ring boolean;
		zm_flag integer;
		resultaat geometry;
	BEGIN

		IF ST_GeometryType(inputlijn) NOT IN ('ST_LineString')
		THEN RAISE EXCEPTION 'Input line is not a Linestring';
		END IF;

		IF ST_GeometryType(inputpoints) NOT IN ('ST_Point', 'ST_MultiPoint')
		THEN RAISE EXCEPTION 'Input points are not of type ST_Point or ST_MultiPoint';
		END IF;

		is_ring := ST_IsRing(inputlijn);
		zm_flag := ST_ZMFlag(inputlijn);
		
		

        WITH ori_vertices_dump AS (
            SELECT * FROM ST_DumpPoints(inputlijn)  
        ),
        inputpoints_dump AS (
            SELECT (ST_DumpPoints(inputpoints)).geom
        ), 
        snapped AS (
            SELECT 	geom AS geom_no_snap, 
			ST_ClosestPoint(inputlijn, geom) AS geom_snap 
	    FROM 	inputpoints_dump 
	    WHERE 	ST_DWithin(inputlijn, geom, tolerance) 
        ),
        new_vertices AS ( 
		-- voeg de nieuwe en de oorspronkelijke vertices samen
		-- gedrag van deze query gedifferentieerd op twee mogelijkheden:
		-- snap = true: de gesnapte geometrie van de nieuwe punten wordt gebruikt voor de X en Y coordinaten van het betreffende punt
		-- inputlijn heeft z-coordinaat: het Z-coordinaat van de oorspronkelijke geometrie wordt toegevoegd aan het betreffende punt
	    SELECT * FROM (
		    SELECT ST_LineLocatePoint(inputlijn, geom_snap) AS fraction, geom_no_snap AS geom FROM snapped WHERE NOT snap
		    UNION
		    SELECT ST_LineLocatePoint(inputlijn, geom_snap) AS fraction, ST_SetSRID(ST_MakePoint(ST_X(geom_snap), ST_Y(geom_snap), ST_Z(geom_no_snap)),ST_SRID(inputpoints)) AS geom FROM snapped WHERE snap
	    ) AS case_2d_line WHERE zm_flag >= 2 --als de inputlijn een z-coordinaat heeft (zm_flag: 0=2d, 1=3dm, 2=3dz, 3=4d)
	    UNION
	    SELECT * FROM (
		    SELECT ST_LineLocatePoint(inputlijn, geom_snap) AS fraction, geom_snap AS geom FROM snapped WHERE snap
		    UNION
		    SELECT ST_LineLocatePoint(inputlijn, geom_snap) AS fraction, geom_no_snap AS geom FROM snapped WHERE NOT snap
	    ) AS case_3d_line WHERE zm_flag < 2 --als de inputlijn geen z-coordinaat heeft (zm_flag: 0=2d, 1=3dm, 2=3dz, 3=4d)
            UNION
            SELECT ST_LineLocatePoint(inputlijn, geom) AS fraction, geom FROM ori_vertices_dump
            UNION
            SELECT 1 AS fraction, geom FROM ori_vertices_dump WHERE is_ring AND path[1] = ST_NumPoints(inputlijn)
        )
        SELECT ST_SetSRID(ST_MakeLine(geom ORDER BY fraction), 28992) FROM new_vertices INTO resultaat;
        
		RETURN resultaat;
	END;
$BODY$ LANGUAGE plpgsql;


--- TESTEN
/* 
DROP TABLE IF EXISTS ST_AddAsVertices_test CASCADE;
CREATE TABLE ST_AddAsVertices_test AS
WITH punten AS (
	SELECT ST_Collect(geom) AS geom FROM testpunt
)
SELECT ST_AddAsVertices(lijn.geom, punten.geom, 2.0, false)
FROM	testlijn AS lijn,
	punten
WHERE	lijn.id = 6
;
*//*

DESCRIPTION: 
Return a single linestring that is a part of a closed linestring, following the shortest (default) or longest route along the closed linestring

INPUTS:
- closed_linestring geometry: a closed linestring geometry
- startpoint geometry: the starting point of the resulting linestring
- endpoint geometry: the end point of the resulting linestring
- [OPTIONAL] shortest boolean: find the shortest route from start point to end point? DEFAULTs to TRUE.

OUTPUTS: 
- A single linestring

DEPENDENCIES:
- What functions does this function depend on that are not available in postgresql, postgis or pg3Di ?

REMARKS: 
- Anything the user should be aware of 

EXAMPLE(S):
- SQL snippet(s) demonstrating how to use the function

*/


CREATE OR REPLACE FUNCTION ST_ClosedLineSubstring (
	closed_linestring geometry,
	startpoint geometry,
	endpoint geometry,
	shortest boolean DEFAULT TRUE
)
RETURNS
	geometry
AS
$BODY$
	DECLARE 
		fraction_startpoint double precision;
		fraction_endpoint double precision;
	    smallest_fraction double precision;
		largest_fraction double precision;
		route_1 geometry;
		route_2 geometry;
	BEGIN
		IF NOT ST_IsClosed(closed_linestring) 
		THEN RAISE EXCEPTION 'First argument is not a closed linestring';
		END IF;
		
		-- Determine fractions for start and end points
		fraction_startpoint := ST_LineLocatePoint(closed_linestring, startpoint);
		fraction_endpoint := ST_LineLocatePoint(closed_linestring, endpoint);
		
		smallest_fraction := least(fraction_startpoint, fraction_endpoint);
		largest_fraction := greatest(fraction_startpoint, fraction_endpoint);
		-- Connect start and end point along both routes (CW and CCW)
		-- Option 1: connect start and end points not passing the first/last vertex of the closed_linestring
		SELECT ST_LineSubString(closed_linestring, smallest_fraction, largest_fraction) INTO route_1;

		-- Option 2: connect start and end points passing the first/last vertex of the closed_linestring
		WITH subs AS (
			SELECT ST_LineSubString(closed_linestring, largest_fraction, 1) AS geom
			UNION
			SELECT ST_LineSubString(closed_linestring, 0, smallest_fraction) AS geom
		)
		SELECT ST_LineMerge(ST_Union(geom)) FROM subs
		INTO route_2;		

		-- Determine which route is shortest and return the required linestring
		IF (ST_Length(route_1) < ST_Length(route_2)) = shortest 
		THEN 
			IF fraction_startpoint = smallest_fraction 
			THEN RETURN route_1;
			ELSE RETURN ST_Reverse(route_1);
			END IF;
		ELSE 
			IF fraction_startpoint = smallest_fraction 
			THEN RETURN ST_Reverse(route_2);
			ELSE RETURN route_2;
			END IF;
		END IF;
		
	END;
$BODY$ LANGUAGE plpgsql;


/* Testen

CREATE TABLE closedls_test_poly (id serial primary key, geom geometry(Polygon,28992));
CREATE TABLE closedls_test_points  (id serial primary key, geom geometry(Point,28992));

DROP TABLE IF EXISTS closedls_test_result;
CREATE TABLE closedls_test_result AS 
SELECT ST_ClosedLineSubstring(ST_ExteriorRing(poly.geom), s.geom, e.geom)
FROM	closedls_test_poly AS poly
JOIN	closedls_test_points AS s
ON 		s.id = 1
JOIN	closedls_test_points AS e
ON 		e.id = 2
;


;

*/DROP FUNCTION IF EXISTS ST_ClosestPoint(geometry, geometry(Point), double precision, double precision);
CREATE OR REPLACE FUNCTION ST_ClosestPoint(
	on_geom geometry,
	from_point geometry(Point),
	azimuth double precision ,
	max_dist double precision
	)
RETURNS 
	geometry 
AS $$
DECLARE
	to_point geometry;
	zoeklijn geometry;
	intersection geometry;
BEGIN
	to_point := ST_Transform(ST_Project(Geography(ST_Transform(from_point, 4326)), max_dist, azimuth)::geometry, ST_SRID(from_point));
	zoeklijn := ST_SetSRID(ST_MakeLine(from_point, to_point), ST_SRID(from_point));
	intersection := ST_Intersection(zoeklijn, on_geom);
	RETURN ST_ClosestPoint(intersection, from_point);	
END;
$$ LANGUAGE plpgsql;
--- Werkt op een vergelijkbare manier als ST_ClosestPoint, maar ipv de geometrie op het closestpoint de z-waarde op die plek
--- Als de inputgeometrie uit een multi is en op de ClosestPoint 2 geometrieën bevat, wordt er random een gekozen om de z-waarde van te bepalen, hierbij wordt de voorkeur gegeven aan linestrings of polygonen boven punten.
--- Functie heeft een precisie van 0.1 mm

--- The function has to variants that both use __ST_ClosestZ under the hood
--- ST_ClosestZ(geom_to_find geometry, geom_to_search_from geometry): works similar to the PostGIS default function ST_ClosestPoint
--- ST_ClosestZ(geom_to_find geometry, geom_to_search_from geometry, azimuth double precision, max_dist double precision)


CREATE OR REPLACE FUNCTION __ST_ClosestZ(
	geom_to_find geometry,
	closest_point geometry
)
RETURNS
	double precision
AS
$BODY$
	DECLARE 
		geom_to_find_single geometry;
		resultaat double precision;
	BEGIN
		-- Verhaksel de inputgeometrie tot alleen single linestrings overblijven
		WITH geoms_to_find_single AS (
			SELECT (ST_Dump(geom_to_find)).geom 
				-- Dit resulteert in Points, Linestrings, Polygons
				-- Points worden 
		), 
		linestrings AS (
			SELECT geom FROM geoms_to_find_single WHERE ST_GeometryType(geom) = 'ST_LineString'
			UNION
			SELECT ST_ExteriorRing((ST_DumpRings(geom)).geom) FROM geoms_to_find_single WHERE ST_GeometryType(geom) = 'ST_Polygon'
		), 
		points AS ( 
			SELECT geom FROM geoms_to_find_single WHERE ST_GeometryType(geom) = 'ST_Point'
		)
		SELECT 	geom FROM linestrings WHERE ST_DWithin(closest_point, geom, 0.0001)
		UNION
		SELECT 	geom FROM points WHERE ST_DWithin(closest_point, geom, 0.0001)
		LIMIT 1
		INTO geom_to_find_single
		;

		-- Bepaal de z-waarde op de gevonden plek
		IF 	ST_GeometryType(geom_to_find_single) = 'ST_Point' 
		THEN 	RETURN ST_Z(geom_to_find_single);
		ELSE	RETURN ST_Z(
				ST_LineInterpolatePoint(
					geom_to_find_single, 
					ST_LineLocatePoint(geom_to_find_single, closest_point)
				)
			);
		END IF; 

	END;
$BODY$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ST_ClosestZ(
	geom_to_find geometry,
	geom_to_search_from geometry
)
RETURNS
	double precision
AS
$BODY$
	DECLARE 
		closest_point geometry;
	BEGIN
		SELECT 	ST_ClosestPoint(geom_to_find, geom_to_search_from) INTO closest_point;
		RETURN __ST_ClosestZ(geom_to_find, closest_point);
	END;
$BODY$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ST_ClosestZ(
	geom_to_find geometry,
	geom_to_search_from geometry,
	azimuth double precision,
	max_dist double precision
)
RETURNS
	double precision
AS
$BODY$
	DECLARE 
		closest_point geometry;
	BEGIN
		SELECT 	ST_ClosestPoint(geom_to_find, geom_to_search_from, azimuth, max_dist) INTO closest_point;
		RETURN __ST_ClosestZ(geom_to_find, closest_point);
	END;
$BODY$ LANGUAGE plpgsql;



/* Testen

DROP TABLE IF EXISTS testlijn;
CREATE TABLE testlijn AS SELECT 1 AS id, ST_SetSRID(ST_MakeLine(ST_MakePoint(0, 0, 0), ST_MakePoint(5, 5, 5)), 28992) AS geom;
					
CREATE TABLE IF NOT EXISTS testpunt (id serial primary key, geom geometry(Point, 28992));
INSERT INTO testpunt (geom) SELECT ST_SetSRID(ST_MakePoint(5, 0),28992);

DROP TABLE IF EXISTS test_closestz_met_richting;
CREATE TABLE test_closestz_met_richting AS
SELECT 	ST_ClosestPoint(l.geom, p.geom, radians(330), 20),
		ST_ClosestZ(l.geom, p.geom, radians(330), 20) 
FROM 	testlijn AS l, testpunt AS p;
					
SELECT ST_ClosestZ(lijn.geom, punt.geom) FROM testlijn_z AS lijn, testpunt AS punt;

WITH multi AS (SELECT ST_Collect(geom) AS geom FROM testlijn_z)
SELECT ST_ClosestZ(lijn.geom, punt.geom) FROM multi AS lijn, testpunt AS punt;

WITH multi AS (SELECT ST_Collect(geom) AS geom FROM testlijn_z)
SELECT ST_GeometryType(lijn.geom) FROM multi AS lijn;

ALTER TABLE test_poly DROP COLUMN IF EXISTS geom_z;
ALTER TABLE test_poly ADD COLUMN geom_z geometry;
UPDATE test_poly SET geom_z = ST_Force3D(geom);

SELECT ST_ClosestZ(poly.geom_z, punt.geom) FROM test_poly AS poly, testpunt AS punt;

SELECT ST_AsEWKT(ST_ExteriorRing((ST_DumpRings((ST_Dump(geom_z)).geom)).geom)) FROM test_poly;



*/	-- ST_Densimplify takes a PolygonZ and changes the density of vertices, 
	-- 3d-simplifying with the tolerance specified in the second argument 
	-- and at the same time 
	-- densifying the vertices of interriorrings so that the distance between vertices is never greater than the distance to the exteriorring or other interriorrings
    -- Used in ST_PolygonZAsRaster 
	DROP FUNCTION IF EXISTS ST_Densimplify(geometry(PolygonZ), double precision);
	CREATE OR REPLACE FUNCTION ST_Densimplify(
		inputgeom geometry(PolygonZ),
		simplify double precision,
		min_segmentize_dist double precision
	)
	RETURNS	geometry
	AS
	$BODY$
		DECLARE 
			inputgeom_simplified geometry;
			processed_ring geometry;
			processed_exteriorring geometry;
			processed_rings geometry[];
			result geometry;
		BEGIN
			IF min_segmentize_dist <= 0 THEN
				RAISE EXCEPTION 'Invalid min_segmentize_dist, must be > 0';
			END IF;
		
			IF ST_GeometryType(inputgeom_simplified) != 'ST_Polygon' OR (NOT ST_IsValid(inputgeom_simplified)) THEN
				RAISE EXCEPTION 'Input geometry is not a valid Polygon';
			END IF;
			
			-- Simplify the input geometry
			inputgeom_simplified := ST_SimplifyVW(inputgeom, simplify);
			IF ST_GeometryType(inputgeom_simplified) != 'ST_Polygon' OR (NOT ST_IsValid(inputgeom_simplified)) THEN
				RAISE EXCEPTION 'Input geometry was simplified to a geometry that is not a valid Polygon';
			END IF;

-- 			RAISE NOTICE 'ST_Densimplify simplified the input geometry to %', ST_AsEWKT(inputgeom_simplified);
			
			
			-- Dump the exterior ring and densify it as needed
			WITH segments AS (
				SELECT (ST_DumpSegments(ST_ExteriorRing(inputgeom_simplified))).*
			)
			, dist_seg_own_ring AS (
				SELECT 	DISTINCT ON (s1.path)
					s1.path, s1.geom, ST_Distance(ST_Centroid(s1.geom), s2.geom) AS distance
				FROM	segments AS s1
				JOIN	segments AS s2
				ON	s1.path != s2.path
				ORDER BY s1.path, ST_Distance(ST_Centroid(s1.geom), s2.geom)
			)
			, segmentized AS (
				SELECT 	ST_Segmentize(geom, greatest(distance/2.0, simplify)) AS geom
				FROM 	dist_seg_own_ring
			)
			SELECT ST_LineMerge(ST_Collect(geom)) AS geom FROM segmentized INTO processed_exteriorring
			;

			
			-- Check if input has interiorrings and if so, process each of them separately	
			IF ST_NumInteriorRings(inputgeom_simplified) = 0 THEN
				RETURN ST_MakePolygon(processed_exteriorring);
			ELSE
			
				FOR n IN 1..ST_NumInteriorRings(inputgeom_simplified) LOOP
					WITH rings_dump AS (
						SELECT ST_DumpRings(inputgeom_simplified) AS dr
					)
					, int_ringn_segdump AS (
						SELECT 	(dr).path AS ring_nr,
							ST_DumpSegments(ST_ExteriorRing((dr).geom)) AS ds
						FROM rings_dump
						WHERE	(dr).path[1] = n	
					)
					, int_ringn_segments AS (
						SELECT ring_nr, (ds).path AS segm_nr, (ds).geom AS geom 
						FROM int_ringn_segdump

					)
					, other_rings AS (
						SELECT ST_Collect(ST_ExteriorRing((dr).geom)) AS geom 
						FROM rings_dump
						WHERE	
							(dr).path[1] != n
					)
					, dist_seg_other_rings AS (
						SELECT 	seg.ring_nr,
							seg.segm_nr,
							ST_Distance(seg.geom, other.geom) AS distance,
							seg.geom
						FROM	int_ringn_segments AS seg,
							other_rings AS other
					)
					, dist_seg_own_ring AS (
						SELECT 	DISTINCT ON (s1.ring_nr, s1.segm_nr)
							s1.ring_nr, s1.segm_nr, s1.geom, ST_Distance(ST_Centroid(s1.geom), s2.geom) AS distance
						FROM	int_ringn_segments AS s1
						JOIN	int_ringn_segments AS s2
						ON	s1.ring_nr = s2.ring_nr
							AND
							s1.segm_nr != s2.segm_nr
						ORDER BY s1.ring_nr, s1.segm_nr, ST_Distance(ST_Centroid(s1.geom), s2.geom)
					)
					, segmentized AS (
						SELECT 	ST_Segmentize(own.geom, greatest( least(own.distance, other.distance)/2.0, simplify)) AS geom
						FROM 	dist_seg_own_ring AS own
						JOIN 	dist_seg_other_rings AS other
						ON  	own.ring_nr = other.ring_nr
							AND
							own.segm_nr = other.segm_nr
					)
					SELECT ST_LineMerge(ST_Collect(geom)) AS geom FROM segmentized INTO processed_ring
					;
					processed_rings = array_append(processed_rings, processed_ring);
				END LOOP;

				RETURN ST_MakePolygon(processed_exteriorring, processed_rings);
			END IF;

		END;
	$BODY$ LANGUAGE plpgsql;


/* Test 
	DROP TABLE IF EXISTS test_st_densimplify CASCADE;
	CREATE TABLE test_st_densimplify AS
	WITH points AS (
		SELECT ST_Collect(geom_3d) AS geom FROM rc.elevation_point
	)
	,
	poly_3d AS (
		SELECT ST_InterpolateZFromPoints(s.geom, p.geom, 0.1) AS geom
		FROM rc.surface AS s, points AS p 
		WHERE s.id = 1
	)
	SELECT ST_Densimplify(geom, 0.1) FROM poly_3d;

	DROP TABLE IF EXISTS test_st_densimplify CASCADE;
	CREATE TABLE test_st_densimplify AS
	WITH points AS (
		SELECT ST_Collect(geom_3d) AS geom FROM rc.elevation_point
	)
	,
	poly_3d AS (
		SELECT ST_InterpolateZFromPoints(s.geom, p.geom, 0.1) AS geom
		FROM rc.surface AS s, points AS p 
		WHERE s.id = 1
	)
 	, rings_dump AS (
		SELECT ST_DumpRings(geom) AS dr FROM poly_3d
	)
   	, int_ringn_segdump AS (
		SELECT 	(dr).path AS ring_nr,
			ST_DumpSegments(ST_ExteriorRing((dr).geom)) AS ds
		FROM rings_dump
 		WHERE	(dr).path[1] = 1	
  	)
  	, int_ringn_segments AS (
		SELECT ring_nr, (ds).path AS segm_nr, (ds).geom AS geom 
		FROM int_ringn_segdump

  	)
    	, other_rings AS (
 		SELECT ST_Collect(ST_ExteriorRing((dr).geom)) AS geom 
 		FROM rings_dump
 		WHERE	
 			(dr).path[1] != 1
 	)
  	, dist_seg_other_rings AS (
		SELECT 	seg.ring_nr,
			seg.segm_nr,
			ST_Distance(seg.geom, other.geom) AS distance,
			seg.geom
		FROM	int_ringn_segments AS seg,
			other_rings AS other
  	)
   	, segmentized AS (
		SELECT ring_nr, segm_nr, distance, ST_Segmentize(geom, distance/2.0) AS geom
		FROM dist_seg_other_rings
   	)
   	SELECT ST_MakePolygon(ST_LineMerge(ST_Collect(geom))) AS geom FROM segmentized
	;

	SELECT ST_NumInteriorRings(geom)
	FROM rc.surface AS s
	WHERE s.id = 1
*/    CREATE OR REPLACE FUNCTION ST_DumpSegments (
        geometry
    )
    RETURNS
        SETOF geometry_dump
    AS
    $BODY$
        DECLARE 
            i geometry_dump % rowtype;
        BEGIN
            FOR i IN 
                WITH dump AS (
                    SELECT ST_DumpPoints($1) AS vertex
                ),
                punten AS (
                    SELECT (vertex).geom, (vertex).path  FROM dump
                ),
                met_volgende AS (
                    SELECT path, geom, lead(geom) over() AS volgende FROM punten ORDER BY path
                )
                SELECT	path, ST_SetSRID(ST_MakeLine(geom, volgende), ST_SRID($1)) FROM met_volgende WHERE path[1] < ST_NumPoints($1) ORDER BY path
            LOOP
                RETURN NEXT i;
            END LOOP;
        END;
    $BODY$ LANGUAGE plpgsql;
----------------------------------------------------------------
--- versie: 20180330
CREATE OR REPLACE FUNCTION ST_ExtrapolateLine(
	inputlijn geometry, 
	verlenging double precision,
	n integer DEFAULT 1 -- extrapolatie wordt gebaseerd op eerste en n'de punt
	)
RETURNS 
	geometry 
AS $$
DECLARE
	azimuth_start double precision;
	azimuth_eind double precision;
	nieuw_startpunt geometry;
	nieuw_eindpunt geometry;
	resultaat geometry;
BEGIN
	
	IF 	ST_GeometryType(inputlijn) != 'ST_LineString' 
	THEN 	RAISE EXCEPTION 'ST_GeometryType van de inputlijn is niet ST_LineString'; 
	END IF;
	
	IF 	n < 1 
	THEN 	RAISE EXCEPTION 'n moet groter zijn dan 0'; 
	END IF;
	
	IF n > ST_NumPoints(inputlijn) THEN 
 		RAISE NOTICE 'n is groter dan het aantal vertices van de inputlijn (%), wordt automatisch naar % gesnapt', ST_NumPoints(inputlijn), ST_NumPoints(inputlijn);
		n := greatest(n, ST_NumPoints(inputlijn));
	END IF;

	azimuth_start 	:= ST_Azimuth(ST_PointN(inputlijn, 1+n), ST_STARTPOINT(inputlijn));
	azimuth_eind 	:= ST_AZIMUTH(ST_PointN(inputlijn, ST_NPoints(inputlijn)-n), ST_ENDPOINT(inputlijn));
	nieuw_startpunt := ST_Transform(ST_Project(Geography(ST_Transform(ST_PointN(inputlijn, 1), 4326)), verlenging, azimuth_start)::geometry,28992); 
	nieuw_eindpunt 	:= ST_Transform(ST_Project(Geography(ST_Transform(ST_PointN(inputlijn, ST_NumPoints(inputlijn)), 4326)), verlenging, azimuth_eind)::geometry,28992);		

	WITH nieuwe_punten AS (
		SELECT	0 AS path, nieuw_startpunt AS geom
		UNION
		SELECT (dp).path[1], (dp).geom FROM ST_DumpPoints(inputlijn) AS dp
		UNION
		SELECT ST_NumPoints(inputlijn) + 1 AS path, nieuw_eindpunt
	)
	SELECT 	ST_MakeLine(geom ORDER BY path)
	FROM	nieuwe_punten
	INTO	resultaat
	;

	RETURN resultaat;
	
END;
$$ LANGUAGE plpgsql;
/*
Adds z-values to a inputgeometry based on a point or multipoint with Z-dimension. 
Inputgeom can be LineString or Polygon. 
Only points within the tolerance from the inputgeom are taken into account.
At least one of the input points must be within the tolerance from the inputgeom
If the inputgeom is a polygon, at least one of the input points must be within the tolerance from the inputgeom's exteriorring. Default treatment of interior rings that find no input points within the tolerance is to not return them in the output and issue a warning. To raise an error instead specify strict_on_interiorrings = True
*/

--
DROP FUNCTION IF EXISTS ST_InterpolateZFromPoints (geometry, geometry, double precision);
DROP FUNCTION IF EXISTS ST_InterpolateZFromPoints (geometry, geometry, double precision, boolean);
CREATE OR REPLACE FUNCTION ST_InterpolateZFromPoints (
	inputgeom geometry,
	inputpoints geometry,
	tolerance double precision,
	strict_on_linestrings boolean default true,
	strict_on_exterior_ring boolean default true,
	strict_on_interior_rings boolean default false
)
RETURNS
	geometry
AS
$BODY$
	DECLARE 
		ext_ring geometry;
        interiorrings_z geometry[];
		result geometry;
	BEGIN
		IF (ST_GeometryType(inputpoints) NOT IN ('ST_Point', 'ST_MultiPoint'))
		THEN RAISE EXCEPTION 'Second argument is not a Point or MultiPoint';
		END IF;
		
		IF (ST_ZMFlag(inputpoints) < 2 )
		THEN RAISE EXCEPTION 'Second argument has no Z dimension';
		END IF;

		IF 	ST_GeometryType(inputgeom) = 'ST_LineString'
	-- routine for linestring
		THEN 	RETURN _InterpolateZFromPoints_Linestring (inputgeom, inputpoints, tolerance, strict_on_linestrings); 
		ELSIF 	ST_GeometryType(inputgeom) = 'ST_Polygon'
	-- routine for polygon ..
		THEN	
            ext_ring := _InterpolateZFromPoints_Linestring (ST_ExteriorRing(inputgeom), inputpoints, tolerance, strict_on_exterior_ring);
            WITH ring_dump AS (
                SELECT ST_DumpRings(inputgeom) AS geomdump
            ),
            interiorrings AS (
                SELECT 	_InterpolateZFromPoints_Linestring(ST_ExteriorRing((geomdump).geom), inputpoints, tolerance, strict_on_interior_rings) AS geom
                FROM 	ring_dump
                WHERE	(geomdump).path[1] > 0 -- Want 0 = ExteriorRing
            )
            SELECT  array_agg(geom)
            FROM	interiorrings
            WHERE 	geom IS NOT NULL AND ST_GeometryType(geom) = 'ST_LineString'
            INTO    interiorrings_z
            ;
                    
            IF 	interiorrings_z IS NULL
-- .. without interior rings
            THEN	RETURN ST_MakePolygon(ext_ring);

-- .. with interior rings
            ELSE    RETURN ST_MakePolygon(ext_ring, interiorrings_z);
            END IF;
		ELSE	RAISE EXCEPTION 'First argument is not a LineString or Polygon';
		END IF;

	END;
$BODY$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS _InterpolateZFromPoints_Linestring(geometry, geometry, double precision);
CREATE OR REPLACE FUNCTION _InterpolateZFromPoints_Linestring (
	inputlijn geometry,
	inputpoints geometry,
	tolerance double precision,
	be_strict boolean DEFAULT FALSE
)
RETURNS
	geometry(LinestringZ)
AS
$BODY$
	DECLARE 
		inputlijn_z_nodata geometry(LinestringZ);
		inputlijn_points_added geometry(LinestringZ);
	BEGIN

		IF 	NOT ST_DWithin(inputlijn, inputpoints, tolerance)
		THEN	IF 	be_strict
			THEN	RAISE EXCEPTION 'No input PointZ found within tolerance from inputline';
			ELSE	RETURN NULL;
			END IF;
		END IF;
		
		-- maak een linestringZ van de inputlijn, waarbij alle z-waarden -9999 zijn
		WITH vertices_3d AS (
			SELECT ST_DumpPoints(inputlijn) AS dp
		)
		SELECT ST_SetSRID(ST_MakeLine(ST_MakePoint(ST_X((dp).geom),ST_Y((dp).geom),-9999) ORDER BY (dp).path), ST_SRID(inputlijn)) 
		FROM vertices_3d
		INTO inputlijn_z_nodata 
		;

-- 		RAISE NOTICE 'inputlijn: %', ST_AsEWKT(inputlijn);
-- 		RAISE NOTICE 'inputlijn_z_nodata: %', ST_AsEWKT(inputlijn_z_nodata);
-- 		
		-- voeg de inputpoints toe met ST_AddAsVertices
		inputlijn_points_added := ST_AddAsVertices (inputlijn_z_nodata, inputpoints, tolerance);
-- 		RAISE NOTICE 'inputpoints: %', ST_AsEWKT(inputpoints);
-- 		RAISE NOTICE 'inputlijn_points_added: %', ST_AsEWKT(inputlijn_points_added);
		
		-- in het geval er puntnen zijn die qua XY dubbel zijn, maar met verschillende z-waarden: gooi -9999 punten weg. Als er nog steeds dubbele zijn, geef een error.
		
		-- interpoleer alle punten die geen z-waarde hebben
		RETURN ST_InterpolateZInLinestring (
			inputlijn_points_added
		);
		RETURN inputlijn_points_added ;

	END;
$BODY$ LANGUAGE plpgsql;


--- TESTEN
/* 

ALTER TABLE testpunt ADD COLUMN IF NOT EXISTS geom_z geometry(PointZ, 28992);
UPDATE testpunt SET geom_z = ST_SetSRID(ST_MakePoint(ST_X(geom), ST_Y(geom), z), ST_SRID(geom))
SELECT ST_AsEWKT(geom_z) FROM testpunt;

ALTER TABLE testpunt ADD COLUMN z double precision;
UPDATE testpunt SET z = ST_Z(geom);


DROP TABLE IF EXISTS ST_InterpolateZFromPoints_test CASCADE;
CREATE TABLE ST_InterpolateZFromPoints_test AS
WITH punten AS (
	SELECT ST_Collect(geom) AS geom FROM testpunt
)
SELECT ST_InterpolateZFromPoints (lijn.geom, punten.geom, 2.0) AS geom
FROM	testlijn AS lijn,
	punten
WHERE	lijn.id = 6
;

DROP TABLE IF EXISTS ST_InterpolateZFromPoints_test_vertices CASCADE;
CREATE TABLE ST_InterpolateZFromPoints_test_vertices AS
SELECT 	(ST_DumpPoints(geom)).path,
	ST_Z((ST_DumpPoints(geom)).geom) AS z,
	(ST_DumpPoints(geom)).geom
FROM	ST_InterpolateZFromPoints_test 
;

SELECT * FROM ST_InterpolateZFromPoints_test_vertices



/*

	SELECT ST_IsRing(geom) FROM testlijn WHERE id =7
	ALTER TABLE testpunt ADD COLUMN geom_z geometry(PointZ, 28992);
	UPDATE testpunt SET geom_z = ST_SetSRID(ST_MakePoint(ST_X(geom), ST_Y(geom), z), 28992);

	UPDATE testlijn AS p
	SET geom_z = ST_InterpolateZFromPoints (p.geom, mp.geom, 2.0)
	FROM	( SELECT ST_Collect(geom_z) AS geom FROM testpunt) AS mp
	WHERE id = 7
	;
-- 
-- 	SELECT ST_AsEWKT(ST_Collect(geom_z)) AS geom FROM testpunt
-- 	SELECT ST_AsEWKT(geom_z) AS geom FROM testpunt
-- 	SELECT ST_AsEWKT(geom) AS geom FROM testpunt
-- 	SELECT ST_AsEWKT(geom) AS geom FROM testlijn

	DROP TABLE IF EXISTS testlijn_vertices CASCADE;
	CREATE TABLE testlijn_vertices  AS
	SELECT 	(ST_DumpPoints(geom_z)).path,
		ST_Z((ST_DumpPoints(geom_z)).geom) AS z,
		(ST_DumpPoints(geom_z)).geom
	FROM	testlijn
	;

	ALTER TABLE test_make_polygon_interiorrings ADD COLUMN IF NOT EXISTS geom_z geometry(PolygonZ, 28992);
	UPDATE test_make_polygon_interiorrings AS p
	SET geom_z = ST_InterpolateZFromPoints (p.geom, mp.geom, 10.0)
	FROM	( SELECT ST_Collect(geom_z) AS geom FROM testpunt) AS mp
	;

	SELECT ST_AsEWkT(geom_z) FROM test_make_polygon_interiorrings;

	DROP TABLE IF EXISTS test_make_polygon_interiorrings_vertices CASCADE;
	CREATE TABLE test_make_polygon_interiorrings_vertices  AS
	SELECT 	(ST_DumpPoints(geom_z)).path,
		ST_Z((ST_DumpPoints(geom_z)).geom) AS z,
		(ST_DumpPoints(geom_z)).geom
	FROM	test_make_polygon_interiorrings
	;

	CREATE TABLE test_donut (
		id serial,
		geom geometry(Polygon, 28992),
		geom_z geometry(PolygonZ, 28992)
	);
	ALTER TABLE test_donut ADD PRIMARY KEY (id);

	CREATE TABLE test_elevation_point (
		id serial,
		geom geometry(Point, 28992),
		geom_z geometry(PointZ, 28992)
	);
	
	ALTER TABLE test_elevation_point ADD PRIMARY KEY (id);
	ALTER TABLE test_elevation_point ADD COLUMN z double precision;
	UPDATE test_elevation_point SET geom_z = ST_SetSRID(ST_MakePoint(ST_X(geom), ST_Y(geom), z), 28992) ;

	UPDATE test_donut AS p
	SET geom_z = ST_InterpolateZFromPoints (p.geom, mp.geom, 2.0)
	FROM	( SELECT ST_Collect(geom_z) AS geom FROM test_elevation_point) AS mp
	;

	ALTER TABLE test_donut ADD COLUMN rast raster;

	UPDATE test_donut AS p
	SET rast = ST_PolygonZAsRaster ( ST_InterpolateZFromPoints (p.geom, mp.geom, 2.0), 2, 2, -9999 )
 	FROM	( SELECT ST_Collect(geom_z) AS geom FROM test_elevation_point) AS mp
	;

	SELECT (ST_SummaryStats(rast)).* FROM test_donut;

	DROP TABLE IF EXISTS test_donut_vertices CASCADE;
	CREATE TABLE test_donut_vertices  AS
	SELECT 	(ST_DumpPoints(geom_z)).path,
		ST_Z((ST_DumpPoints(geom_z)).geom) AS z,
		(ST_DumpPoints(geom_z)).geom
	FROM	test_donut
	;

	SELECT ST_AsEWKT(geom_z) FROM test_donut;

	CREATE TABLE ring6 AS SELECT ST_ExteriorRing((dr).geom) FROM (SELECT ST_DumpRings(geom) AS dr FROM test_make_polygon_interiorrings) AS x WHERE (dr).path[1] = 6

)
	
	
*/






*/--- Input: LinestringZ, waarvan de Z-waarden een NODATAVALUE mogen hebben
--- Output: LineStringZ waarvan de vertices met Z-waarde NULL zijn geïnterpoleerd

--- first / last aggregate to make interpolation of n NULL values possible
--- source: https://wiki.postgresql.org/wiki/First/last_(aggregate)
	-- Create a function that always returns the first non-NULL item
	CREATE OR REPLACE FUNCTION public.first_agg ( anyelement, anyelement )
	RETURNS anyelement LANGUAGE SQL IMMUTABLE STRICT AS $$
		SELECT $1;
	$$;
	 
	-- And then wrap an aggregate around it
	DROP AGGREGATE IF EXISTS public.FIRST(anyelement);
	CREATE AGGREGATE public.FIRST (
		sfunc    = public.first_agg,
		basetype = anyelement,
		stype    = anyelement
	);
	 
	-- Create a function that always returns the last non-NULL item
	CREATE OR REPLACE FUNCTION public.last_agg ( anyelement, anyelement )
	RETURNS anyelement LANGUAGE SQL IMMUTABLE STRICT AS $$
		SELECT $2;
	$$;
	 
	-- And then wrap an aggregate around it
	DROP AGGREGATE IF EXISTS public.LAST(anyelement);
	CREATE AGGREGATE public.LAST (
		sfunc    = public.last_agg,
		basetype = anyelement,
		stype    = anyelement
	);


CREATE OR REPLACE FUNCTION ST_InterpolateZInLinestring (
	inputlijn geometry(LinestringZ),
	nodatavalue double precision DEFAULT -9999
)
RETURNS
	geometry(LinestringZ)
AS
$BODY$
	DECLARE 
		is_ring boolean;
		result geometry(LinestringZ);
	BEGIN

		is_ring := ST_IsRing(ST_Force2D(inputlijn));

		RAISE NOTICE 'inputlijn: %', ST_AsEWKT(inputlijn);
		RAISE NOTICE 'ST_Force2D(inputlijn): %', ST_AsEWKT(ST_Force2D(inputlijn));
		RAISE NOTICE 'is_ring? %', is_ring; 

	
		WITH old_vertices AS (
			SELECT ST_DumpPoints(inputlijn) as dp 
		),
		coords AS (		-- lijstje met path, x, y, z, point_2d per vertex. Z kan NULL zijn
			SELECT 	(dp).path,
				ST_X((dp).geom) AS x, 
				ST_Y((dp).geom) AS y, 
				CASE WHEN ST_Z((dp).geom) = nodatavalue THEN NULL ELSE ST_Z((dp).geom) END AS z,
				(dp).geom AS vertex_2d
			FROM 	old_vertices AS dp
		),
		with_fractions AS (
			SELECT	*,
				ST_LineLocatePoint(inputlijn, vertex_2d) AS fraction
			FROM	coords
		),
		fractions_of_non_null_zs AS (
			-- fraction wordt NULL als z NULL is;
			-- bij een closed linestring worden alle vertices er aan de voor en achterkant nog een keer aangeplakt om 'rond' te kunnen interpoleren
			SELECT 	path, x, y, z, vertex_2d, -1 + fraction AS fraction, -1 + fraction * CASE WHEN z IS NULL THEN NULL ELSE 1 END AS fraction_non_null_z FROM with_fractions WHERE is_ring
			UNION
			SELECT 	path, x, y, z, vertex_2d, 0 + fraction AS fraction, 0 + fraction * CASE WHEN z IS NULL THEN NULL ELSE 1 END AS fraction_non_null_z FROM with_fractions
			UNION
			SELECT 	path, x, y, z, vertex_2d, 1 + fraction AS fraction, 1 + fraction * CASE WHEN z IS NULL THEN NULL ELSE 1 END AS fraction_non_null_z FROM with_fractions WHERE is_ring
		),
		next_and_previous_values AS (
			SELECT 	*,
				COALESCE(	first(z) over next_w,
						last(z) over prev_w
				) AS next_non_null_z,
				COALESCE(	last(z) over prev_w,
						first(z) over next_w
				) AS previous_non_null_z,
				first(fraction_non_null_z) over next_w AS next_fraction,
				last(fraction_non_null_z) over prev_w  AS previous_fraction
			FROM fractions_of_non_null_zs
			WINDOW  next_w AS (order by fraction rows between current row and unbounded following),
				prev_w AS (order by fraction rows between unbounded preceding and current row)
		), 
		interpolated AS (	
			SELECT 	*,  
				COALESCE(	z, -- als z niet NULL is, moet z gewoon behouden blijven, zoniet dan linear interpoleren met y = a*x+b
						((next_non_null_z - previous_non_null_z)/(COALESCE(next_fraction, previous_fraction+1) - COALESCE(previous_fraction, next_fraction-1))) -- a = dy/dx; dy = (next_non_null_z - previous_non_null_z); dx = (next_fraction - previous_fraction), waarbij de coalesce-truc is bedoeld om dx 1 te laten worden als of next_fraction NULL is of previous_fraction NULL is, wat optreedt als het begin of eind van de lijn 1 of meer NULL waarden bevat; allebei kan niet, want dan valt er niks te interpoleren.
						* 
						(fraction - COALESCE(previous_fraction, 0)) -- x, tellend vanaf de previous_fraction, zijnde 0 als er geen previous_fraction is, want dan zijn alle z-waarden tot aan het begin waarde NULL 
						+ 
						previous_non_null_z -- b
				) AS interpolated_z
			FROM next_and_previous_values
			WHERE fraction BETWEEN 0 AND 1
		)
		SELECT 	ST_SetSRID(ST_MakeLine(ST_MakePoint(x, y, interpolated_z) ORDER BY path), ST_SRID(inputlijn)) AS geom
		FROM 	interpolated
		INTO result
		;

		RETURN ST_RemoveRepeatedPoints(result);
	END;
$BODY$ LANGUAGE plpgsql;
-- Triangle3DParameters returns parameters a, b, and c that describe the elevation in a triangular plane according to 
--	z = ax + by + c
-- Input is a triangular polygon with XYZ coordinates
CREATE OR REPLACE FUNCTION Triangle3DParameters (
	tri geometry(PolygonZ)
)
RETURNS
	double precision[]
AS
$BODY$
	DECLARE 
		tri_ring geometry;
		
		x1 double precision;
		x2 double precision;
		x3 double precision;
		
		y1 double precision;
		y2 double precision;
		y3 double precision;
		
		z1 double precision;
		z2 double precision;
		z3 double precision;
		
		k double precision;
		l double precision;
		m double precision;
		
		c double precision;
		b double precision;
		a double precision;
	BEGIN
		IF (NOT ST_IsValid(tri)) OR ST_GeometryType(tri) != 'ST_Polygon' THEN RAISE EXCEPTION 'Input geometry is not a valid Polygon'; END IF;
		tri_ring := ST_ExteriorRing(tri);
	
		x1 := ST_X(ST_PointN(tri_ring, 1));
		x2 := ST_X(ST_PointN(tri_ring, 2));
		x3 := ST_X(ST_PointN(tri_ring, 3));

		y1 := ST_Y(ST_PointN(tri_ring, 1));
		y2 := ST_Y(ST_PointN(tri_ring, 2));
		y3 := ST_Y(ST_PointN(tri_ring, 3));

		z1 := ST_Z(ST_PointN(tri_ring, 1));
		z2 := ST_Z(ST_PointN(tri_ring, 2));
		z3 := ST_Z(ST_PointN(tri_ring, 3));

		k := x2/x1;
		l := x3/x1;

-- 		IF y2-k*y1 = 0 THEN RAISE NOTICE 'm berekenen gaat mis: x1=%, x2=%, x3=%, y1=%; y2=%; y3=%; z1=%; z2=%; z3=%;', x1, x2, x3, y1, y2, y3, z1, z2, z3; END IF;
        	m := (y3-l*y1)/(y2-k*y1);

-- 		IF ((1-l)-m*(1-k)) = 0 THEN RAISE NOTICE 'c berekenen dit gaat mis: x1=%, x2=%, x3=%, y1=%; y2=%; y3=%; z1=%; z2=%; z3=%;', x1, x2, x3, y1, y2, y3, z1, z2, z3; END IF;
		c := ((z3-l*z1)-m*(z2-k*z1)) / ((1-l)-m*(1-k));
	
-- 		IF (y2-k*y1) = 0 THEN RAISE NOTICE 'b berekenen dit gaat mis: x1=%, x2=%, x3=%, y1=%; y2=%; y3=%; z1=%; z2=%; z3=%;', x1, x2, x3, y1, y2, y3, z1, z2, z3; END IF;
        	b := ((z2-k*z1)-(1-k)*c)/(y2-k*y1);

-- 		IF x1 = 0 THEN RAISE NOTICE 'a berekenen dit gaat mis: x1=%, x2=%, x3=%, y1=%; y2=%; y3=%; z1=%; z2=%; z3=%;', x1, x2, x3, y1, y2, y3, z1, z2, z3; END IF;
        	a := (z1-1*c-y1*b)/x1;

--         IF a IS NULL OR b IS NULL OR c IS NULL or a = -9999 OR b = -9999 OR c = -9999
--         THEN 
-- 		RAISE NOTICE 'Warning: these parameters will result in a NULL raster! PolygonZ = %, a = %, b = %, c = %', tri, a, b, c; 
-- 	END IF;
        
		RETURN ARRAY[a, b, c];
	END;
$BODY$ LANGUAGE plpgsql;

/* Testen
WITH points AS (
	SELECT 1 AS path, ST_MakePoint(4, 40, 250) AS geom
	UNION
	SELECT 2, ST_MakePoint(2, 10, 800)
	UNION
	SELECT 3, ST_MakePoint(10, 0, 1050)
	UNION
	SELECT 4 AS path, ST_MakePoint(4, 40, 250) AS geom
	
), ring AS (
	SELECT ST_MakeLine(geom ORDER BY path) AS geom FROM points
), poly AS (
	SELECT ST_MakePolygon(geom) AS geom
	FROM ring
), 
params AS (
	SELECT Triangle3DParameters(geom) AS abc FROM poly
)
SELECT abc[1] AS a, abc[2] AS b, abc[3] AS c, abc[1]*6 + abc[2]*20 + abc[3] AS z FROM params
;
*//*

---- NAME
ST_LineSubstrings - Cut up a linestring into smaller segments, the result covering the whole input linestring

---- SYNOPSIS
setof geometry_dump	ST_LineSubStrings(geometry inputlijn, double precicion[] knipfracties)
setof geometry_dump	ST_LineSubStrings(geometry inputlijn, double precicion max_length)

---- DESCRIPTION
The first variant takes a single Linestring and cuts it up at each fraction passed to the function in the second argument (an array of double precisions between 0 an 1)
The second variant takes a single Linestring and cuts it up into equal parts of length max_length, except the last segment that will in most cases be smaller than max_length

This is a set returning function, returning a set of geometry_dump (path[], geometry) rows. Use (your_result_column).path and (your_result_column).geom to access its contents.

*/


DROP FUNCTION IF EXISTS ST_LineSubstrings(geometry, double precision[]);
CREATE OR REPLACE FUNCTION ST_LineSubstrings(
	inputlijn geometry,
    knipfracties double precision[],
	tolerance double precision DEFAULT 0
)
RETURNS
    SETOF geometry_dump

AS
$$
DECLARE
	inputlijn_straight geometry;
	frac_factor double precision;
	kf_arr double PRECISION[];
	i geometry_dump % rowtype;
BEGIN
	IF tolerance < 0
	THEN RAISE EXCEPTION 'Tolerance must be larger than 0.';
	ELSIF 	tolerance = 0 THEN 	kf_arr := knipfracties;
	ELSIF 	tolerance > 0 THEN 	
		-- Round frac factors to account for tolerance (rounding takes into account the length of the geom)
		inputlijn_straight := ST_MakeLine(ST_MakePoint(0,0), ST_MakePoint(ST_Length(inputlijn),0));
		WITH knipfracties_points_filtered AS (
			SELECT 	(ST_DumpPoints(ST_RemoveRepeatedPoints(ST_Collect(ST_LineInterpolatePoint(inputlijn_straight, kf)), tolerance))).geom AS geom 
			FROM 	unnest(knipfracties) AS kf
		)
		SELECT array_agg(ST_LineLocatePoint(inputlijn_straight, geom))
		FROM knipfracties_points_filtered
		INTO kf_arr;
	END IF;

	-- Voeg 0 en 1 toe als knipfractie om altijd aan het begin van de lijn te beginnen en aan het eind te eindigen
	kf_arr := array_cat(kf_arr, ARRAY[0, 1]::double precision[]);
	
	FOR i IN 
		WITH knipfracties AS (
			SELECT unnest(kf_arr) AS kf
		),
		knipfracties_uniek_gesorteerd AS (
			SELECT DISTINCT ON (kf) * FROM knipfracties ORDER BY kf
		),
		fracties_van_tot AS	(
			SELECT  kf AS fractie_van,
					lead(kf) over() AS fractie_tot
			FROM	knipfracties_uniek_gesorteerd
			),
		fracties_van_tot_opgeschoond AS	(
			SELECT	*
			FROM	fracties_van_tot
			WHERE	fractie_van IS NOT NULL
					AND
					fractie_tot IS NOT NULL
		)
		SELECT	ARRAY[row_number() over()] AS path, 
				ST_LineSubString(inputlijn, fractie_van, fractie_tot) AS geom
		FROM	fracties_van_tot_opgeschoond
	LOOP
		RETURN NEXT i;
	END LOOP;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS ST_LineSubstrings(geometry, double precision);
CREATE OR REPLACE FUNCTION ST_LineSubstrings(
	inputlijn geometry,
    max_length double precision,
	tolerance double precision DEFAULT 0
)
RETURNS
    SETOF geometry_dump
AS
$$
DECLARE
	step numeric;
	cut_fractions double precision[];
	i geometry_dump % rowtype;
BEGIN
	-- calculate step (fraction corresponding to max length)
	step := max_length / ST_Length(inputlijn);

	-- generate array of cut_fractions
	WITH ser AS (select generate_series(0::integer, ceil(1/step)::integer, step) AS ies) SELECT array_agg(ser.ies) FROM ser WHERE ser.ies BETWEEN 0 AND 1 INTO cut_fractions;

	-- call the other version of ST_LineSubstrings with the calculated parameters
	FOR i IN 
		SELECT (ST_LineSubstrings(inputlijn, cut_fractions, tolerance)).*
	LOOP
		RETURN NEXT i;
	END LOOP;
END;
$$ LANGUAGE plpgsql;

					  
					  
/* ---
TESTING

CREATE TABLE werk.test_linesubstrings (id serial, geom geometry(Linestring, 28992));
ALTER TABLE werk.test_linesubstrings ADD PRIMARY KEY (id);

DROP TABLE IF EXISTS werk.test_linesubstrings_output CASCADE;
CREATE TABLE werk.test_linesubstrings_output AS SELECT (ST_LineSubstrings(geom, ARRAY[0.2, 0.4, 0.56])).* FROM werk.test_linesubstrings;

DROP TABLE IF EXISTS werk.test_linesubstrings_output CASCADE;
CREATE TABLE werk.test_linesubstrings_output AS SELECT (ST_LineSubstrings(geom, 1)).* FROM werk.test_linesubstrings;
SELECT generate_series (0, 100, 0.234::double precision)
*/
					  
					  
					  
					  
					  
					  -- Dependencies: ST_ClosestPoint met richting.sql
CREATE EXTENSION IF NOT EXISTS postgis_sfcgal;

CREATE OR REPLACE FUNCTION ST_MainAxis(
	inputgeom geometry(Polygon)
	)
RETURNS 
	geometry 
AS $$
DECLARE
	resultaat geometry;
BEGIN
	WITH axisdump AS (
		SELECT	(ST_Dump(ST_LineMerge(ST_ApproximateMedialAxis(inputgeom)))).geom AS geom
	), 
	langste_axis AS (
		SELECT	geom
		FROM	axisdump
		ORDER BY ST_Length(geom) DESC
		LIMIT 1
	), 
	nieuwe_vertices AS (
		SELECT -1 AS path, ST_ClosestPoint(ST_ExteriorRing(inputgeom), ST_StartPoint(geom), ST_Azimuth(ST_PointN(geom, 2), ST_StartPoint(geom)), ST_Length(ST_LongestLine(geom, geom))) AS geom
		FROM	langste_axis
		UNION
		SELECT (ST_DumpPoints(geom)).path[1] AS path, (ST_DumpPoints(geom)).geom
		FROM	langste_axis AS la
		UNION
		SELECT ST_NumPoints(geom) + 1 AS path, ST_ClosestPoint(ST_ExteriorRing(inputgeom), ST_EndPoint(geom), ST_Azimuth(ST_PointN(geom, ST_NumPoints(geom) - 1), ST_EndPoint(geom)), ST_Length(ST_LongestLine(geom, geom))) AS geom
		FROM	langste_axis AS la
	)
	SELECT ST_MakeLine(geom ORDER BY path)
	FROM nieuwe_vertices
	INTO resultaat
	;

	RETURN resultaat;
END;
$$ LANGUAGE plpgsql;
-- Handig icm ST_AddMeasure om Z-waarden toe te kennen aan een lijn.
-- ST_MToZ(ST_AddMeasure(geom, 0.9, 1.5)) kent Z-waarden toe aan een Linestring, beginnend met 0.9, eindigend met 1.5, lineair interpolerend daartussen.


CREATE OR REPLACE FUNCTION ST_MToZ(
	inputlijn geometry
)
RETURNS
	geometry
AS
$BODY$
	DECLARE 
		resultaat geometry;
	BEGIN
		WITH old_vertices AS (SELECT ST_DumpPoints(inputlijn) AS dp ),
		new_vertices AS (
			SELECT (dp).path, 
				ST_MakePoint(ST_X((dp).geom),ST_Y((dp).geom),ST_M((dp).geom)) AS vertex
			FROM old_vertices
		)
		SELECT ST_SetSRID(ST_Force3DZ(ST_MakeLine(vertex ORDER BY path)),28992) FROM new_vertices INTO resultaat;
		

		RETURN resultaat;
	END;
$BODY$ LANGUAGE plpgsql;


/* Testen

CREATE TABLE IF NOT EXISTS testlijn (id serial primary key, geom geometry(Linestring, 28992));

INSERT INTO testlijn (geom) 
SELECT ST_SetSRID(ST_MakeLine(geom), 28992)
FROM (
	SELECT ST_MakePoint(0,0) AS geom
	UNION
	SELECT ST_MakePoint(1,1)
	UNION
	SELECT ST_MakePoint(2,2)
) AS x;

INSERT INTO testlijn (geom) 
SELECT ST_SetSRID(ST_MakeLine(geom), 28992)
FROM (
	SELECT ST_MakePoint(0,0) AS geom
	UNION
	SELECT ST_MakePoint(1,1)
	UNION
	SELECT ST_MakePoint(2,2)
	UNION
	SELECT ST_MakePoint(4,2)
	UNION
	SELECT ST_MakePoint(6,2)
	UNION
	SELECT ST_MakePoint(8,2)
) AS x;

SELECT ST_AsEWKT(ST_MToZ(ST_AddMeasure(geom, 0.9, 1.5))) FROM testlijn;

DROP TABLE IF EXISTS ST_mtoz_test;
CREATE TABLE ST_mtoz_test AS 
SELECT id, ST_MToZ(ST_AddMeasure(geom, 0.9, 1.5)) AS geom FROM testlijn;
SELECT Populate_Geometry_Columns('ST_mtoz_test'::regclass::oid);

ALTER TABLE ST_mtoz_test ADD PRIMARY KEY (id);

DROP TABLE IF EXISTS ST_mtoz_test_merged ;
CREATE TABLE ST_mtoz_test_merged AS SELECT (ST_Dump(ST_LineMerge(ST_Collect(geom)))).geom FROM ST_mtoz_test;

ALTER TABLE ST_mtoz_test_merged ADD COLUMN id serial;
ALTER TABLE ST_mtoz_test_merged ADD PRIMARY KEY (id);




*/-- ST_NextPoint(geom geometry(Linestring), leadby)
-- Dump points (ST_DumpPoints)
-- Add input point, path = -1
-- Calculate fraction (ST_LineLocatePoint)
-- Order by fraction
-- Select lead(geom, leadby) over(ORDER BY fraction)



CREATE OR REPLACE FUNCTION ST_NextPoint(geom geometry(Linestring), fraction double precision, leadby integer DEFAULT 1)
RETURNS
	geometry_dump
AS
$BODY$
	DECLARE 
 		result geometry_dump % rowtype;
	BEGIN
		WITH dump AS ( SELECT ST_DumpPoints(geom) as geom_dump ),
		dump_with_fractions AS (
			SELECT 	geom_dump,
				ST_LineLocatePoint(geom, (geom_dump).geom) AS frac
			FROM dump
			UNION
			SELECT (ARRAY[NULL], NULL::geometry)::geometry_dump AS geom_dump, fraction
		),
		answer AS (
			SELECT 	(geom_dump).path[1] AS label, 
				lead(geom_dump, leadby) over(ORDER BY frac) AS geom_dump
			FROM dump_with_fractions
		)
		SELECT (geom_dump).path, (geom_dump).geom FROM answer WHERE label IS NULL
		INTO result
		;

		RETURN result;
	END;
$BODY$ LANGUAGE plpgsql;

-- Azimuth berekenen tussen maken van vorige en volgende vertex (ST_Azimuth((ST_NextPoint(geom, 0.3, -1)).geom, (ST_NextPoint(geom, 0.3, 1)).geom)
-- Lijntje maken van 0,0 naar 0,lengte
-- Lijntje verplaatsen naar het punt op de lijn die door de fractie wordt bepaald
-- Lijntje draaien obv Azimuth + 90 graden



DROP FUNCTION IF EXISTS ST_Perpendicular(geometry(Linestring), double precision, double precision);
CREATE OR REPLACE FUNCTION ST_Perpendicular (
	geom geometry(Linestring),
	lengte	double precision,
	fractie double precision DEFAULT 0.5,
	links boolean DEFAULT TRUE,
	rechts boolean DEFAULT TRUE
)
RETURNS
	geometry(Linestring)
AS
$BODY$
	DECLARE 
		azimuth double precision;
		fractiepunt geometry(Point);
		x double precision;
		y double precision;
		noordlijntje geometry(Linestring);
		linkerresultaat geometry(Linestring);
		rechterresultaat geometry(Linestring);
		resultaat geometry(Linestring);
	BEGIN

	IF NOT rechts AND NOT links THEN RETURN NULL; END IF;
	
	IF fractie = 1
	THEN azimuth = ST_Azimuth(ST_PointN(geom, ST_NumPoints(geom)-1), ST_PointN(geom, ST_NumPoints(geom)));
	ELSIF fractie = 0
	THEN azimuth = ST_Azimuth(ST_PointN(geom, 1), ST_PointN(geom, 2));
	ELSE azimuth := ST_Azimuth(
				COALESCE((ST_NextPoint(geom, fractie, -1)).geom, ST_PointN(geom, 1)), 
				COALESCE((ST_NextPoint(geom, fractie, 1)).geom, ST_PointN(geom, ST_NumPoints(geom)))
			);
	END IF;

	fractiepunt := ST_LineInterpolatePoint(geom, fractie);
	x := ST_X(fractiepunt);
	y := ST_Y(fractiepunt);
	noordlijntje := ST_MakeLine(ST_Point(x,y), ST_Point(x,y+(lengte/2.0)));	--lijntje dat precies naar Noord wijst met begin op het fractiepunt

	IF 	links 
	THEN 	linkerresultaat := ST_SetSRID(ST_Rotate(noordlijntje, -azimuth + radians(90), fractiepunt), ST_SRID(geom));
	END IF;
	
	IF 	rechts 
	THEN 	rechterresultaat := ST_SetSRID(ST_Rotate(noordlijntje, -azimuth - radians(90), fractiepunt), ST_SRID(geom));
	END IF;

	IF links AND NOT rechts THEN RETURN linkerresultaat; END IF;
	IF rechts AND NOT links THEN RETURN rechterresultaat; END IF;
 	IF rechts AND links THEN RETURN ST_MakeLine(ST_EndPoint(linkerresultaat), ST_EndPoint(rechterresultaat)); END IF;

	END;
$BODY$ LANGUAGE plpgsql;
-- TESTEN
/*
DROP TABLE IF EXISTS test_maakraai CASCADE;
CREATE TABLE test_maakraai AS 
SELECT ST_Perpendicular(geom, 10, 0.4, TRUE, FALSE) AS links, ST_Perpendicular(geom, 10, 0.4, FALSE, TRUE) AS rechts, ST_Perpendicular(geom, 10, 0.4, TRUE, TRUE) AS samen  FROM testlijn;
*/

-- callbackfunctie om driehoek + params om te zetten in raster
	CREATE OR REPLACE FUNCTION CBF_TriangleAsRaster (
		val double precision [][][],
		pos int[][],
		VARIADIC userargs text[] -- argumenten: 1: upperleftx, 2: upperlefty, 3: pixelsize, 4: params
	)
	RETURNS
		double precision
	AS
	$BODY$
		DECLARE 
			upperleftx double precision;
			upperlefty double precision;
			pixelsize double precision;
			params double precision[];
			pixel_x double precision;
			pixel_y double precision;
			result double precision;
		BEGIN
			IF val[1][1][1] IS NULL --pixel valt buiten de mask
			THEN RETURN -9999;
			ELSE 
				upperleftx := userargs[1];
				upperlefty := userargs[2];
				pixelsize := userargs[3];
				params := userargs[4];

				pixel_x := upperleftx + pos[0][1]*pixelsize;
				pixel_y := upperlefty - pos[0][2]*pixelsize;
								
				RETURN params[1]*pixel_x + params[2]*pixel_y + params[3];
			END IF;
		END;
	$BODY$ LANGUAGE plpgsql IMMUTABLE;

	DROP FUNCTION IF EXISTS ST_PolygonZAsRaster(geometry(PolygonZ), double precision, double precision, double precision);
	DROP FUNCTION IF EXISTS ST_PolygonZAsRaster(geometry(PolygonZ), double precision, double precision, double precision, double precision);
	CREATE OR REPLACE FUNCTION ST_PolygonZAsRaster (
		inputgeom geometry(PolygonZ),
		scalex double precision,
		scaley double precision,
		nodatavalue double precision,
		simplify double precision default 0,
		min_segmentize_dist double precision default 0.1
	)
	RETURNS	raster
	AS
	$BODY$
		DECLARE 
			inputgeom_simple geometry(PolygonZ);
			result raster;
		BEGIN
			inputgeom_simple := ST_Densimplify(inputgeom, simplify, min_segmentize_dist);
					
			WITH tin AS (
				SELECT 	ST_DelaunayTriangles(inputgeom_simple,0,2) AS geom
			),
			rings AS (
				SELECT 	ST_ExteriorRing((ST_Dump(geom)).geom) AS geom
				FROM 	tin
			), 
			triangles AS (
				SELECT (ST_Dump(ST_MakePolygon(geom))).geom AS geom
				FROM	rings
			),
			triangles_filtered AS (
				SELECT 	geom
				FROM	triangles
				WHERE 	ST_Intersects(ST_Centroid(geom), inputgeom_simple)
					AND 
					ST_Area(geom) > 0.0001
			),
			ingredients AS (
				SELECT 	geom, 
					Triangle3DParameters(geom) as params, 
					ST_AsRaster(geom, abs(scalex), -1*abs(scaley), 0.0, 0.0, '2BUI', 1, 0) AS mask 
				FROM triangles_filtered
			),
			rasters AS (
				SELECT	ST_SetBandNoDataValue(
						ST_MapAlgebra(
							mask,
							1,	--integer nband
							'CBF_TriangleAsRaster(double precision [][][], int[][], text[])'::regprocedure,	--regprocedure callbackfunc
							'32BF',	--text pixeltype=NULL
							'FIRST',	--text extenttype=FIRST
							NULL::raster,
							0,	--integer distancex=0
							0,	--integer distancey=0
							ST_UpperLeftX(mask)::text,
							ST_UpperLeftY(mask)::text,
							ST_ScaleX(mask)::text,
							params::text
						),
						nodatavalue::double precision
					) AS rast
				FROM ingredients
			)
			SELECT ST_Union(rast) FROM rasters INTO result;
			RETURN result;
		END;
	$BODY$ LANGUAGE plpgsql;

	CREATE OR REPLACE FUNCTION ST_TinAsRaster (
		tin geometry(TinZ),
		scalex double precision,
		scaley double precision,
		nodatavalue double precision
	)
	RETURNS	raster
	AS
	$BODY$
		DECLARE 
			result raster;
		BEGIN
			WITH rings AS (
				SELECT 	ST_ExteriorRing((ST_Dump(tin)).geom) AS geom
			), 
			polys AS (
				SELECT (ST_Dump(ST_MakePolygon(geom))).geom AS geom
				FROM	rings
			),
			ingredients AS (
				SELECT geom, Triangle3DParameters(geom) as params, ST_AsRaster(geom, abs(scalex), -1*abs(scaley), 0.0, 0.0, '2BUI', 1, 0) AS mask FROM polys
			),
			rasters AS (
				SELECT	ST_SetBandNoDataValue(
						ST_MapAlgebra(
							mask,
							1,	--integer nband
							'CBF_TriangleAsRaster(double precision [][][], int[][], text[])'::regprocedure,	--regprocedure callbackfunc
							'32BF',	--text pixeltype=NULL
							'FIRST',	--text extenttype=FIRST
							NULL::raster,
							0,	--integer distancex=0
							0,	--integer distancey=0
							ST_UpperLeftX(mask)::text,
							ST_UpperLeftY(mask)::text,
							ST_ScaleX(mask)::text,
							params::text
						),
						nodatavalue::double precision
					) AS rast
				FROM ingredients
			)
			SELECT ST_Union(rast) FROM rasters INTO result;
			RETURN result;
		END;
	$BODY$ LANGUAGE plpgsql;

/* ----------------- TESTEN -------------------------- */ 
/*
-- testtabel met polygon_z maken
	DROP TABLE test_poly_z;
	CREATE TABLE test_poly_z AS 
	WITH dump AS (
		SELECT ST_NumPoints(ST_ExteriorRing(geom)) AS numpoints, ST_DumpPoints(geom_z) AS dp FROM test_poly WHERE geom_z IS NOT NULL 
 	), coords AS (
		SELECT	(dp).path,
			ST_X((dp).geom) x,
			ST_Y((dp).geom) y,
			random()*10.0 AS z,
			numpoints
		FROM	dump
 	), new_vertices AS (
		SELECT 	path, ST_MakePoint(x, y ,z) AS geom FROM coords WHERE path[2] < numpoints AND path[2] > 1
		UNION
		SELECT 	path, ST_MakePoint(x, y , 0) AS geom FROM coords WHERE path[2] IN (1, numpoints)
	)
-- 	SELECT path, ST_X(geom), ST_Y(geom), ST_Z(geom) FROM new_vertices ORDER BY path
	SELECT 	row_number() over() AS id,
		ST_SetSRID(ST_MakePolygon(ST_MakeLine(geom ORDER BY path)), 28992) AS geom
	FROM	new_vertices
	;

	SELECT ST_IsValid(geom) FROM test_poly_z
	SELECT ST_IsClosed(geom) FROM test_poly_z

	DROP TABLE IF EXISTS test_tesselate ;
	CREATE TABLE test_tesselate AS 
	SELECT ST_Tesselate(geom) AS geom FROM test_poly_z
	;


	ALTER TABLE test_poly_z ADD COLUMN IF NOT EXISTS rast raster;

	-- test ST_PolygonZAsRaster
	UPDATE test_poly_z 
	SET rast = ST_PolygonZAsRaster(geom, 0.5::double precision, 0.5::double precision, -9999::double precision)
	;

	-- test ST_TinAsRaster (werkt niet)
	UPDATE test_poly_z 
	SET rast = ST_TinAsRaster(ST_Tesselate(geom), 0.5::double precision, 0.5::double precision, -9999::double precision)
	;

	DROP TABLE IF EXISTS test_poly_z_dp CASCADE;
	CREATE TABLE test_poly_z_dp AS SELECT (ST_DumpPoints(geom)).geom FROM test_poly_z;
	ALTER TABLE test_poly_z_dp  ADD COLUMN IF NOT EXISTS z double precision;
	UPDATE test_poly_z_dp  SET z = ST_Z(geom);
*/
------------------ TRASH ----------------------
/*
	DROP TABLE IF EXISTS test_tin_in_polygon;
	CREATE TABLE test_tin_in_polygon AS 
	WITH tin AS (
		SELECT ST_AsEWKT(
			ST_3DIntersection(
				ST_Translate(ST_Extrude(ST_Force2D(geom), 0, 0, ST_ZMax(geom)-ST_ZMin(geom)+10),0,0,ST_ZMin(geom)-10), -- doosje (polyhedral surface (solid) ) met x & y extent van geom, z bodem = minimum z van geom, z dak is max z van geom
				ST_DelaunayTriangles(geom,0,2)
				)
			) AS geom
		FROM 	test_poly_z
	), 
 	rings AS (
		SELECT 	ST_ExteriorRing((ST_Dump(geom)).geom) AS geom
		FROM	tin
 	)
	SELECT (ST_Dump(ST_Polygonize(geom))).geom AS geom
	FROM	rings
	;
	
		ST_DelaunayTriangles
	)
	
		 FROM test_poly WHERE geom_z IS NOT NULL
	)
	SELECT ST_AsEWKT(geom) FROM test_poly_z

	SELECT ST_AsEWKT(geom) FROM test_tesselate;


 	WITH tin AS (
		SELECT 	id, ST_DelaunayTriangles(geom,0,2) AS geom
		FROM 	test_poly_z
	), 
 	rings AS (
		SELECT 	id, ST_ExteriorRing((ST_Dump(geom)).geom) AS geom
		FROM	tin
 	), 
 	polys AS (
		SELECT id, (ST_Dump(ST_Polygonize(geom))).geom AS geom
		FROM	rings
		GROUP BY id
 	)
 	
	SELECT	tri.id, tri.geom
	FROM	polys AS tri
	JOIN	test_poly_z AS ori
	ON	ori.id = tri.id
		AND
		ST_Intersects(ST_Centroid(tri.geom), ori.geom)
	;

	SELECT ST_AsEWKT(geom) FROM test_tesselate

	ALTER TABLE test_delaunay_3d_triangles ADD COLUMN tri_id serial;


-- parameters toevoegen die hoogteverloop beschrijven volgens y = ax + b
	ALTER TABLE test_delaunay_3d_triangles ADD COLUMN params double precision[];
	UPDATE test_delaunay_3d_triangles SET params = Triangle3DParameters(geom);

	SELECT * FROM test_delaunay_3d_triangles;
	SELECT params::text::double precision[] FROM test_delaunay_3d_triangles;

		DROP TABLE test_geom_to_rast; 
		CREATE TABLE test_geom_to_rast AS 
		SELECT id, tri_id, ST_AsRaster(geom, 1.0, -1.0, 0.0, 0.0, '2BUI', 1, 0) AS rast
		FROM test_delaunay_3d_triangles
		WHERE tri_id = 3
		;

		
		DROP TABLE test_makemask;
		CREATE TABLE test_makemask AS 
		SELECT id, tri_id, make_mask(geom, 1.0) AS rast
		FROM test_delaunay_3d_triangles
		WHERE tri_id = 3
		;

		SELECT 'test_geom_to_rast' AS naam, (ST_MetaData(rast)).* FROM test_geom_to_rast
		UNION
		SELECT 'test_makemask' AS naam, (ST_MetaData(rast)).* FROM test_makemask 
		
	-- nieuw raster maken
	ALTER TABLE test_delaunay_3d_triangles ADD COLUMN IF NOT EXISTS rast raster;
	WITH mask AS (
		SELECT id, tri_id, ST_AsRaster(geom, 1.0, -1.0, 0.0, 0.0, '2BUI', 1, 0) AS rast
		FROM test_delaunay_3d_triangles
	)
	UPDATE test_delaunay_3d_triangles AS tri
	SET rast = ST_SetBandNoDataValue(
		ST_MapAlgebra(
-- 			make_mask(geom, 1.00),	--raster rast
--   			ST_AsRaster(geom, 0.5, 0.5, 0.0, 0.0, '2BUI', 1, 0),
			mask.rast,
			1,	--integer nband
			'CBF_TriangleAsRaster(double precision [][][], int[][], text[])'::regprocedure,	--regprocedure callbackfunc
			'32BF',	--text pixeltype=NULL
			'FIRST',	--text extenttype=FIRST
			NULL::raster,
			0,	--integer distancex=0
			0,	--integer distancey=0
-- 			ST_UpperLeftX(make_mask(geom, 1.00))::text,
-- 			ST_UpperLeftY(make_mask(geom, 1.00))::text,
			ST_UpperLeftX(mask.rast)::text,
			ST_UpperLeftY(mask.rast)::text,
			ST_ScaleX(mask.rast)::text,
			params::text
		),
		-9999::double precision
	)
	FROM mask
	WHERE tri.id = mask.id AND tri.tri_id = mask.tri_id;

	SELECT (ST_MetaData(rast)).* FROM test_delaunay_3d_triangles;

	ALTER TABLE test_poly_z ADD COLUMN IF NOT EXISTS rast raster;
	UPDATE test_poly_z SET rast = (SELECT ST_Union(rast) FROM test_delaunay_3d_triangles);

	SELECT * FROM test_poly_z;		
*//*

DESCRIPTION: 
Scale a geometry by a factor without moving the centroid

INPUTS:
- Any geometry
- Scale factor; 0.5 shrinks the geometry to half its original area

OUTPUTS: 
- The input geometry scaled by the scale factor

DEPENDENCIES:
- None 

REMARKS: 
- Be aware that the resulting polygon does not necesarrily lie within the input polygon
- From PostGIS 2.5 onwards this function is probably not necessary. Instead, use can be made of ST_Scale(inputgeom, ST_MakePoint(0.5, 0.5), ST_Centroid(inputgeom));

EXAMPLE(S):
	SELECT ST_Shrink(the_geom, 0.5) AS geom_shrunk FROM v2_impervious_surface;

*/


CREATE OR REPLACE FUNCTION ST_Shrink (
	inputpoly geometry,
	factor double precision
)
RETURNS
	geometry
AS
$BODY$
	DECLARE
		inputpoly_scaled geometry;
		centroid_distance_x double precision;
		centroid_distance_y double precision;
	BEGIN
		inputpoly_scaled := ST_Scale(inputpoly, sqrt(factor), sqrt(factor));	
		centroid_distance_x = (ST_X(ST_Centroid(inputpoly)) - ST_X(ST_Centroid(inputpoly_scaled)));
		centroid_distance_y = (ST_Y(ST_Centroid(inputpoly)) - ST_Y(ST_Centroid(inputpoly_scaled)));
		RETURN ST_Translate(inputpoly_scaled, centroid_distance_x, centroid_distance_y);
	END;
$BODY$ LANGUAGE plpgsql;-- Dependencies: ST_Perpendicular; ST_DumpSegments; ST_NextPoint

-- inputlijn is the heart line of the polygon, which may be created using ST_MainAxis
-- inputpoly is the polygon for which to determine the side
-- side is either 'left' or 'right'

CREATE OR REPLACE FUNCTION ST_Side(
	inputlijn geometry(Linestring),
	inputpoly geometry(Polygon),
	side text
	)
RETURNS 
	geometry 
AS $$
DECLARE
	return_left boolean DEFAULT False;
	return_right boolean DEFAULT False;
	
	inputpolysize double precision;
	perpendicularline_start geometry;
	perpendicularline_end geometry;
	azimuth_start double PRECISION;
	azimuth_end double PRECISION;
	
	ring geometry;
	startpoint geometry;
	endpoint geometry;

	margin double PRECISION DEFAULT 0.025;

BEGIN
	
	RAISE NOTICE '--------------------------------------';
	
	IF 	side = 'left' 	THEN return_left := True;
	ELSIF 	side = 'right' 	THEN return_right := True;
	ELSE	RAISE EXCEPTION 'Side must be "left" or "right"';
	END IF;
	
	inputpolysize := ST_Length(ST_LongestLine(inputpoly, inputpoly)); 
	RAISE NOTICE 'inputpolysize = %', inputpolysize;	

	perpendicularline_start := ST_Perpendicular(inputlijn, 10, margin, return_left, return_right); -- length doesn't matter, only needed to compute azimuth
	azimuth_start := ST_Azimuth(ST_Startpoint(perpendicularline_start), ST_Endpoint(perpendicularline_start));
	RAISE NOTICE 'azimuth_start  = %', azimuth_start ;	

	perpendicularline_end := ST_Perpendicular(inputlijn, 10, 1-margin, return_left, return_right);
	RAISE NOTICE 'perpendicularline_end  = %', ST_AsEWKT(perpendicularline_end);	

	azimuth_end := ST_Azimuth(ST_Startpoint(perpendicularline_end), ST_Endpoint(perpendicularline_end));
	RAISE NOTICE 'azimuth_end  = %', azimuth_end;	
	
	ring := st_exteriorring(inputpoly);

	startpoint := ST_ClosestPoint(ring, ST_LineInterpolatePoint(inputlijn, margin), azimuth_start, inputpolysize);
	endpoint := ST_ClosestPoint(ring, ST_LineInterpolatePoint(inputlijn, 1-margin), azimuth_end, inputpolysize);
	RAISE NOTICE 'startpoint  = %', ST_AsEWKT(startpoint);	
	RAISE NOTICE 'endpoint  = %', ST_AsEWKT(endpoint);	
	
	RETURN ST_ClosedLineSubstring(ring,	startpoint,	endpoint);
END;
$$ LANGUAGE plpgsql;

/* TESTEN
SELECT (ST_NextPoint(st_mainaxis, 0.0, -1)).geom FROM st_mainaxis_test_result;
SELECT * FROM st_mainaxis_test_result;


UPDATE surface SET geom = ST_Normalize(ST_Simplify(geom, 0.001));

DROP TABLE IF EXISTS st_side_test_result;
CREATE TABLE st_side_test_result AS  
SELECT 	'left' AS side,
		ST_Side(
			ST_MainAxis(ST_Simplify(ST_Buffer(geom, 2, 'quad_segs=2'), 0.001)),
			ST_Simplify(ST_Buffer(geom, 2, 'quad_segs=2'), 0.001),
			'left'::text
		)
FROM	surface
UNION
SELECT 	'right' AS side,
		ST_Side(
			ST_MainAxis(ST_Simplify(ST_Buffer(geom, 2, 'quad_segs=2'), 0.001)),
			ST_Simplify(ST_Buffer(geom, 2, 'quad_segs=2'), 0.001),
			'right'::text
		)
FROM	surface
;

DROP TABLE test_simple_sides;
CREATE TABLE test_simple_sides AS 
WITH segments AS (
	SELECT id, (ST_DumpSegments(ST_Simplify(ST_ExteriorRing(geom), 0.1))).geom
	FROM	surface
),
mainaxis AS (
	SELECT id, ST_MainAxis(ST_Simplify(ST_Buffer(geom, 2, 'quad_segs=2'), 0.1)) AS geom FROM surface
)
SELECT seg.* 
FROM 	segments AS seg
JOIN	mainaxis AS ma
ON		seg.id = ma.id
		AND NOT ST_DWithin(seg.geom, ma.geom, 0.001)
;

WHERE NOT ST_Intersects(




DROP TABLE IF EXISTS st_mainaxis_test_result;  
CREATE TABLE st_mainaxis_test_result AS  
SELECT ST_MainAxis(ST_Normalize(ST_Simplify(geom, 0.001)))
FROM	surface
;

DROP TABLE IF EXISTS st_main_axis_tussenstappen;
CREATE TABLE 		st_main_axis_tussenstappen AS 
SELECT	(ST_Dump(ST_LineMerge(ST_ApproximateMedialAxis(geom)))).geom AS geom
FROM surface;
 
 */
-- Dependencies: ST_Perpendicular; ST_DumpSegments; ST_NextPoint

-- inputlijn is the heart line of the polygon, which may be created using ST_MainAxis
-- inputpoly is the polygon for which to determine the side
-- side is either 'left' or 'right'

CREATE OR REPLACE FUNCTION ST_Side(
	inputlijn geometry(Linestring),
	inputpoly geometry(Polygon),
	side text
	)
RETURNS 
	geometry 
AS $$
DECLARE
	return_left boolean DEFAULT False;
	return_right boolean DEFAULT False;
	result geometry;
BEGIN
	IF 	side = 'left' 	THEN return_left := True;
	ELSIF 	side = 'right' 	THEN return_right := True;
	ELSE	RAISE EXCEPTION 'Side must be "left" or "right"';
	END IF;
	
	WITH segments AS (
		SELECT (ST_DumpSegments(inputlijn)).geom
	),
	exterior_segments AS (
		SELECT (ST_DumpSegments(ST_ExteriorRing(inputpoly))).geom
	), 
	voelsprieten AS (
		SELECT	ST_Collect(
				ST_ClosestPoint(
					ST_ExteriorRing(inputpoly), 
					ST_LineInterpolatePoint(seg.geom, 0.5), 
					ST_Azimuth(ST_StartPoint(ST_Perpendicular(seg.geom, 10, 0.5, return_left, return_right)), ST_EndPoint(ST_Perpendicular(seg.geom, 10, 0.5, return_left, return_right))),
					ST_Length(ST_LongestLine(inputpoly, inputpoly))
				)
			) AS geom
		FROM	segments AS seg
	)
	SELECT	ST_LineMerge(ST_Union(exseg.geom)) 
	FROM	exterior_segments AS exseg,
		voelsprieten AS vs
	WHERE	ST_DWithin(exseg.geom, vs.geom, 0.0000001)
	INTO result;
	RETURN result;
END;
$$ LANGUAGE plpgsql;
-- Dependencies:
-- 	ST_InterpolateZInLinestring.sql


--- ST_Transect
	DROP FUNCTION IF EXISTS ST_Transect(geometry, text, text);
	CREATE OR REPLACE FUNCTION ST_Transect (
		geom geometry,
		rasttable text,
		rastcol text
	)
	RETURNS
		geometry(LinestringZ)
	AS
	$BODY$
		DECLARE 
			rasters_array raster[];
			line_segmentized geometry;
			result geometry(LinestringZ);
		BEGIN
			IF ST_GeometryType(geom) != 'ST_LineString' 
			THEN RAISE EXCEPTION 'Input geom is not a Linestring';
			END IF;
		
			EXECUTE '
				SELECT	array_agg('||rastcol||')
				FROM '||rasttable||'
				WHERE ST_Intersects('||rastcol||', ST_GeomFromEWKT('''||ST_AsEWKT(geom)||'''));
			' INTO rasters_array
			;

			line_segmentized := ST_Segmentize(geom, 10.0*0.5);

			WITH old_vertices AS (
				SELECT ST_DumpPoints(line_segmentized) as dp 
			),
			rasters AS (
				SELECT unnest(rasters_array) AS rast
			),
			new AS (		-- lijstje met path, x, y, z, point_2d per vertex. Z kan NULL zijn
				SELECT 	(dp).path,
					CASE WHEN ST_Value(r.rast, (dp).geom) IS NULL THEN -9999 ELSE ST_Value(r.rast, (dp).geom) END AS z,
					(dp).geom AS vertex_2d
				FROM 	old_vertices AS dp
				LEFT JOIN	rasters AS r
				ON	ST_Intersects((dp).geom, r.rast)
			)
			SELECT ST_InterpolateZInLinestring(ST_SetSRID(ST_MakeLine(ST_MakePoint(ST_X(vertex_2d), ST_Y(vertex_2d), z) ORDER BY path), ST_SRID(geom)))
			FROM new
			INTO result
			;
		
			RETURN result;
		END;
	$BODY$ LANGUAGE plpgsql;


--------------------- VOORBEELD ---------------------------------
/*

DROP TABLE IF EXISTS test_z_values;
CREATE TABLE test_z_values (
	id serial,
	z double precision
);


INSERT INTO test_z_values (z) VALUES (NULL), (NULL), (0.1), (0.2), (0.5), (NULL), (0.3), (NULL), (0.4), (NULL), (NULL), (0.6), (4.5), (NULL), (NULL);


ALTER TABLE test_z_values ADD COLUMN fraction double precision;
UPDATE test_z_values SET fraction = random();

WITH fractions_of_non_null_zs AS (
	SELECT 	fraction,
		fraction * ((z+999999)/(z+999999)) AS fraction_non_null_z, 
		z
	FROM	test_z_values		
),
next_and_previous_values AS (
	SELECT fraction, 
		z, 
		COALESCE(	first(z) over (order by fraction rows between current row and unbounded following),
				last(z) over (order by fraction rows between unbounded preceding and current row)
		) AS next_non_null_z,
		COALESCE(	last(z) over (order by fraction rows between unbounded preceding and current row),
				first(z) over (order by fraction rows between current row and unbounded following)
		) AS previous_non_null_z,
		first(fraction_non_null_z) over next_w AS next_fraction,
		last(fraction_non_null_z) over prev_w  AS previous_fraction
	FROM fractions_of_non_null_zs
	WINDOW  next_w AS (order by fraction rows between current row and unbounded following),
		prev_w AS (order by fraction rows between unbounded preceding and current row)
	ORDER BY fraction
)	
SELECT *,  
	COALESCE(	z, -- als z niet NULL is, moet z gewoon behouden blijven, zoniet dan linear interpoleren met y = a*x+b
			((next_non_null_z - previous_non_null_z)/(COALESCE(next_fraction, previous_fraction+1) - COALESCE(previous_fraction, next_fraction-1))) -- a = dy/dx; dy = (next_non_null_z - previous_non_null_z); dx = (next_fraction - previous_fraction), waarbij de coalesce-truc is bedoeld om dx 1 te laten worden als of next_fraction NULL is of previous_fraction NULL is, wat optreedt als het begin of eind van de lijn 1 of meer NULL waarden bevat; allebei kan niet, want dan valt er niks te interpoleren.
			* 
			(fraction - COALESCE(previous_fraction, 0)) -- x, tellend vanaf de previous_fraction, zijnde 0 als er geen previous_fraction is, want dan zijn alle z-waarden tot aan het begin waarde NULL 
			+ 
			previous_non_null_z -- b
	) AS interpolated_z
FROM next_and_previous_values
ORDER BY fraction;

CREATE TABLE test_raster_sample_line (
	id serial,
	geom geometry(LinestringZ, 28992)
);

CREATE INDEX ON test_raster_sample_line USING gist(geom);
ALTER TABLE test_raster_sample_line ADD PRIMARY KEY (id);

UPDATE test_raster_sample_line
SET geom = ST_Transect( geom, 'src.dem', 'rast')
;

DROP TABLE IF EXISTS test_raster_sample_line_vertices CASCADE;
CREATE TABLE test_raster_sample_line_vertices AS
SELECT 	id,
	(ST_DumpPoints(geom)).path,
	ST_Z((ST_DumpPoints(geom)).geom) AS z,
	(ST_DumpPoints(geom)).geom
FROM	test_raster_sample_line 
;

SELECT * FROM test_raster_sample_line

*/






