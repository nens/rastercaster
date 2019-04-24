

	-- The following function updated the raster for the surfaces with the specified id;
	CREATE OR REPLACE FUNCTION rc.update_raster(id_to_update integer)
	RETURNS VOID AS
	$BODY$
		DECLARE
		    _definition text; _definition_type text;
		    _geom geometry; aux_1_geom geometry; aux_2_geom geometry; aux_3_geom geometry; aux_4_geom geometry; aux_5_geom geometry; aux_6_geom geometry;
		    _aux_1 integer; _aux_2 integer; _aux_3 integer; _aux_4 integer; _aux_5 integer; _aux_6 integer;
		    _param_1 double precision; _param_2 double precision; _param_3 double precision; _param_4 double precision; _param_5 double precision; _param_6 double precision;
		    mask raster;
		    cbf_name text;
		    cbf_fullname text;
		    custom_definition text;
		    empty_raster raster;
		BEGIN
			--RAISE NOTICE '-----------------------------------------';
			SELECT 	definition, 	definition_type, 	geom, 	aux_1, 	aux_2, 	aux_3, 	aux_4, 	aux_5, 	aux_6, 	param_1, 	param_2, 	param_3, 	param_4, 	param_5, 	param_6
			FROM 	rc.surface 
			WHERE 	id = id_to_update 
			INTO 	_definition, 	_definition_type, 	_geom, 	_aux_1, _aux_2,	_aux_3,	_aux_4,	_aux_5,	_aux_6,	_param_1, 	_param_2, 	_param_3, 	_param_4, 	_param_5, 	_param_6
			;
			

			-- do nothing (yet) for filler polygons
			IF _definition_type = 'filler' THEN
				RAISE NOTICE 'Postponing raster creation for surface with id %, because it is a filler polygon.', id_to_update; 
				RETURN; 
			END IF;

			-- check if pixelsize has been set
			IF rc.LeesInstelling('pixelsize')::double precision IS NULL 
			THEN RAISE EXCEPTION 'RasterCaster Error: Pixelsize has not been set, exiting';
			END IF;

			-- handle the 'tin' definition type
			IF _definition_type = 'tin' THEN
				UPDATE rc.surface_admin AS sa
				SET 	rast = rc.tin(geom, rc.LeesInstelling('elevation_point_search_radius')::double precision, rc.LeesInstelling('pixelsize')::double precision)
				FROM rc.surface AS s
				WHERE id_to_update = s.id AND s.id = sa.id
				;
				
				RETURN;
			END IF;

			-- handle all other definition types (custom, constant, etc)
			mask := ST_AsRaster(_geom, 
					abs(rc.LeesInstelling('pixelsize')::double precision), 
					-1*abs(rc.LeesInstelling('pixelsize')::double precision), 
					0.0, 
					0.0, 
					'2BUI', 
					1, 
					0
			);

			SELECT geom FROM rc.auxiliary_line WHERE id = _aux_1 INTO aux_1_geom;
			SELECT geom FROM rc.auxiliary_line WHERE id = _aux_2 INTO aux_2_geom;
			SELECT geom FROM rc.auxiliary_line WHERE id = _aux_3 INTO aux_3_geom;
			SELECT geom FROM rc.auxiliary_line WHERE id = _aux_4 INTO aux_4_geom;
			SELECT geom FROM rc.auxiliary_line WHERE id = _aux_5 INTO aux_5_geom;
			SELECT geom FROM rc.auxiliary_line WHERE id = _aux_6 INTO aux_6_geom;
			
			SELECT cbf.cbf_name FROM rc.callbackfunctions AS cbf WHERE _definition_type = cbf.definition_type INTO cbf_name;
			cbf_fullname := 'cbf_' || cbf_name || ' (double precision [][], int[][], text[])';
				
		    -- als definition_type 'custom' is dan anders afhandelen dan de andere definition types
		    -- 'custom' wordt namelijk het meest gebruikt, en op deze manier wordt zoveel mogelijk code buiten de callbackfucntie gehouden
		    -- en dus maar 1 keer uitgevoerd per polygoon ipv per pixel
			IF _definition_type = 'custom' THEN
				-- geom
				custom_definition := replace(_definition, 'geom', 'ST_GeomFromEWKT(''' ||ST_AsEWKT(_geom)||''')');
				--RAISE NOTICE 'ST_AsEWKT(_geom): %', 'ST_GeomFromEWKT(''' ||ST_AsEWKT(_geom)||''')';
				--RAISE NOTICE '_definition: %', _definition;
				--RAISE NOTICE 'custom_definition: %', custom_definition;
				-- aux 1 tm 6
				IF _aux_1 IS NOT NULL THEN custom_definition := replace(custom_definition, 'aux_1', 'ST_GeomFromEWKT(''' ||ST_AsEWKT(aux_1_geom)||''')'); END IF;
				IF _aux_2 IS NOT NULL THEN custom_definition := replace(custom_definition, 'aux_2', 'ST_GeomFromEWKT(''' ||ST_AsEWKT(aux_2_geom)||''')'); END IF;
				IF _aux_3 IS NOT NULL THEN custom_definition := replace(custom_definition, 'aux_3', 'ST_GeomFromEWKT(''' ||ST_AsEWKT(aux_3_geom)||''')'); END IF;
				IF _aux_4 IS NOT NULL THEN custom_definition := replace(custom_definition, 'aux_4', 'ST_GeomFromEWKT(''' ||ST_AsEWKT(aux_4_geom)||''')'); END IF;
				IF _aux_5 IS NOT NULL THEN custom_definition := replace(custom_definition, 'aux_5', 'ST_GeomFromEWKT(''' ||ST_AsEWKT(aux_5_geom)||''')'); END IF;
				IF _aux_6 IS NOT NULL THEN custom_definition := replace(custom_definition, 'aux_6', 'ST_GeomFromEWKT(''' ||ST_AsEWKT(aux_6_geom)||''')'); END IF;

				-- param_1 tm 6
				IF _param_1 IS NOT NULL THEN custom_definition := replace(custom_definition, 'param_1', _param_1::text); END IF;
				IF _param_2 IS NOT NULL THEN custom_definition := replace(custom_definition, 'param_2', _param_2::text); END IF;
				IF _param_3 IS NOT NULL THEN custom_definition := replace(custom_definition, 'param_3', _param_3::text); END IF;
				IF _param_4 IS NOT NULL THEN custom_definition := replace(custom_definition, 'param_4', _param_4::text); END IF;
				IF _param_5 IS NOT NULL THEN custom_definition := replace(custom_definition, 'param_5', _param_5::text); END IF;
				IF _param_6 IS NOT NULL THEN custom_definition := replace(custom_definition, 'param_6', _param_6::text); END IF;

				--RAISE NOTICE 'custom_definition: %', custom_definition;

				-- nieuw raster maken
				UPDATE rc.surface_admin AS sa
				SET 	rast = ST_SetBandNoDataValue(
						ST_MapAlgebra(
							mask,	--raster rast
							1,	--integer nband
							cbf_fullname::regprocedure,	--regprocedure callbackfunc
							'32BF',	--text pixeltype=NULL
							'FIRST',	--text extenttype=FIRST
							NULL::raster,
							0,	--integer distancex=0,
							0,	--integer distancey=0
							ST_SRID(_geom)::text, 
							ST_UpperLeftX(mask)::text,
							ST_UpperLeftY(mask)::text,
							rc.LeesInstelling('pixelsize'),
							custom_definition
						),
						-9999::double precision
					)
				FROM rc.surface AS s
				WHERE   id_to_update = s.id AND s.id = sa.id
				;

				RETURN;

			ELSE 
			    -- callbackfunctie selecteren op basis van het definition_type
				UPDATE rc.surface_admin AS sa
				SET 	rast = ST_SetBandNoDataValue(
						ST_MapAlgebra(
							mask,	--raster rast
							1,	--integer nband
							cbf_fullname::regprocedure,	--regprocedure callbackfunc
							'32BF',	--text pixeltype=NULL
							'FIRST',	--text extenttype=FIRST
							NULL::raster,
							0,	--integer distancex=0,
							0,	--integer distancey=0
							ST_AsEWKT(_geom)::text, 
							ST_AsEWKT(aux_1_geom)::text, 
							ST_AsEWKT(aux_2_geom)::text, 
							ST_AsEWKT(aux_3_geom)::text,
							ST_AsEWKT(aux_4_geom)::text, 
							ST_AsEWKT(aux_5_geom)::text, 
							ST_AsEWKT(aux_6_geom)::text,
							_param_1::text,
							_param_2::text,
							_param_3::text,
							_param_4::text,
							_param_5::text,
							_param_6::text,
							ST_UpperLeftX(mask)::text,
							ST_UpperLeftY(mask)::text,
							rc.LeesInstelling('pixelsize'),
							_definition
						),
						-9999::double precision
					)
				FROM rc.surface AS s
				WHERE id_to_update = s.id AND s.id = sa.id
				;

				IF (SELECT rast IS NULL FROM rc.surface_admin WHERE id_to_update = id) 
				THEN RAISE EXCEPTION 'update_raster() resulted in a a NULL raster for surface with id %', id_to_update;
				END IF;
				
				RETURN;
					
			END IF;

		END;
	$BODY$ LANGUAGE plpgsql;
