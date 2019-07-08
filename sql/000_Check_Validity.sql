 
-- Raise an error if the raster generated for a surface is NULL

	CREATE OR REPLACE FUNCTION rc.check_validity(surface_id integer)
	RETURNS void AS
	$BODY$
        DECLARE 
            success boolean;
        BEGIN
            SELECT rast IS NOT NULL FROM rc.surface_admin WHERE id = surface_id INTO success;
			IF NOT success
			THEN RAISE EXCEPTION 'update_raster() resulted in a a NULL raster for surface with id %', surface_id;
			END IF;
            RETURN;
        END;
	$BODY$ LANGUAGE plpgsql;
    