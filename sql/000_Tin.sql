    -- Create rasters for 'tin' polygons
    CREATE OR REPLACE FUNCTION rc.tin (
        inputpoly geometry,
        tolerance double precision,
        pixelsize double precision
    )
    RETURNS raster AS
    $BODY$
        DECLARE
            result raster;
        BEGIN
	    WITH step1 AS (
            SELECT ST_Collect(geom_3d) AS points
            FROM rc.elevation_point 
            WHERE   (in_polygon_only AND ST_Intersects(geom_3d, inputpoly))
                    OR
                    ((NOT in_polygon_only) AND ST_DWithin(geom_3d, inputpoly, tolerance))
	    )
	    SELECT 	ST_PolygonZAsRaster ( ST_InterpolateZFromPoints (inputpoly, points, tolerance), pixelsize, pixelsize, -9999, pixelsize/2.0, pixelsize)
	    FROM	step1
	    INTO 	result
	    ;

	    -- if the input is a polygon that has elevation points at the exteriorring, but not at all interriorrings, the holes are filled in the raster. To cut these away:
	    result := ST_Clip(result, inputpoly);
	    
            RETURN result;
        END;
    $BODY$ LANGUAGE plpgsql;
