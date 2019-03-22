    -- Create rasters for 'filler' polygons
    CREATE OR REPLACE FUNCTION rc.fill (
        inputpoly geometry,
        filler_seg_dist double precision,
        pixelsize double precision
    )
    RETURNS raster AS
    $BODY$
        DECLARE
            nw_vertices geometry; 
            seg_poly geometry;
            polygonz geometry;
        BEGIN
            seg_poly := ST_Segmentize(inputpoly, filler_seg_dist);
            
            -- RAISE NOTICE 'seg_poly is: %', ST_AsEWKT(seg_poly);
            -- RAISE NOTICE 'buffered seg_poly is ring: %', ST_IsRing(ST_ExteriorRing(ST_Buffer(seg_poly, pixelsize)));
            
            WITH vertices_and_ring AS (
                SELECT  ST_DumpPoints(seg_poly) AS dp, 
                        ST_ExteriorRing(ST_Buffer(seg_poly, pixelsize/2.0)) AS ring 
            ), 
            samplepoints AS (
                SELECT  dp,
                        ST_ClosestPoint(ring, (dp).geom) AS samplepoint_xy
                FROM    vertices_and_ring
            ),
            sampled_values AS (
                SELECT 	sp.dp, 
                    sp.samplepoint_xy,  
                    CASE WHEN ST_Value(sa.rast, sp.samplepoint_xy) IS NULL THEN -9999 ELSE ST_Value(sa.rast, sp.samplepoint_xy) END AS z 
                FROM 	samplepoints AS sp
                LEFT JOIN rc.surface_admin AS sa
                ON	ST_Intersects(sp.samplepoint_xy, sa.rast)
                    AND sa.rast IS NOT NULL
            ), 
            distinct_sampled_values AS (
                SELECT DISTINCT ON (dp) dp, samplepoint_xy, COALESCE(z, -9999) AS z 
                FROM sampled_values
                ORDER BY dp ASC, COALESCE(z, -9999) DESC -- aanname: er zijn geen z-waarden lager dan -9999; als er twee rasters gesampled worden, moet het raster met data op die plek voorrang krijgen boven het raster zonder data op die plek
                    )
            ,
            new_vertices AS (
                SELECT  (dp).path, 
                        ST_SetSRID(
                            ST_MakePoint(   
                                ST_X((dp).geom), 
                                ST_Y((dp).geom),  
                                z
                            ), ST_SRID(inputpoly)
                        ) AS vertex
                FROM 	distinct_sampled_values
            )
            SELECT  ST_Collect(nw.vertex)
	    FROM    new_vertices AS nw
	    INTO    nw_vertices
	    ;

	    RETURN ST_Clip(ST_PolygonZAsRaster (ST_InterpolateZFromPoints (inputpoly, nw_vertices, pixelsize/2.0+0.000001), pixelsize, pixelsize, -9999, pixelsize/2.0, pixelsize), inputpoly);
	    
        END;
    $BODY$ LANGUAGE plpgsql;

  	CREATE OR REPLACE FUNCTION rc.update_filler(id_to_update integer)
	RETURNS VOID AS
	$BODY$
		DECLARE
		    _definition_type text;

		BEGIN
        
            SELECT 	definition_type
			FROM 	rc.surface 
			WHERE 	id = id_to_update 
			INTO 	_definition_type
			;
        
   			-- check if pixelsize has been set
			IF rc.LeesInstelling('pixelsize')::double precision IS NULL 
			THEN RAISE EXCEPTION 'RasterCaster Error: Pixelsize has not been set, exiting';
			END IF;

			IF _definition_type = 'filler' THEN
				UPDATE rc.surface_admin AS sa
				SET 	rast = rc.fill(geom, rc.LeesInstelling('filler_seg_dist')::double precision, rc.LeesInstelling('pixelsize')::double precision)
				FROM    rc.surface AS s
				WHERE   id_to_update = s.id AND s.id = sa.id
				;
			END IF;

            RETURN;

		END;
	$BODY$ LANGUAGE plpgsql;


--     SELECT rc.fill(geom, 1, 0.5) FROM rc.surface WHERE id = 3;

