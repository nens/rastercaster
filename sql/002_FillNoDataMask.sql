	CREATE OR REPLACE FUNCTION rc.create_fillnodatamask ()
    RETURNS void 
	AS
    $BODY$
		DECLARE
			rasterextent geometry;
			geometryextent geometry;
			difference_geom geometry;
			pixelsize double precision;
		BEGIN
			pixelsize = rc.LeesInstelling('pixelsize')::double precision;
			SELECT ST_Buffer(ST_Union(geom), -1 * pixelsize/2.0) FROM rc.surface INTO geometryextent;
	
			DROP TABLE IF EXISTS rc.fillnodatamask CASCADE;
			CREATE TABLE rc.fillnodatamask AS
			SELECT 
				ST_SetValue(
					ST_AddBand(
						ST_MakeEmptyRaster(
							rc.LeesInstelling('vrt_width')::integer, 	--integer width, 
							rc.LeesInstelling('vrt_height')::integer, 	--integer height, 
							rc.LeesInstelling('vrt_ulx')::double precision, 										--float8 upperleftx, 
							rc.LeesInstelling('vrt_uly')::double precision, 										--float8 upperlefty, 
							pixelsize, 													--float8 scalex, 
							pixelsize, 												--float8 scaley, 
							0.0, 															--float8 skewx, 
							0.0, 															--float8 skewy, 
							ST_SRID(geometryextent)										--integer srid=unknown);																	  
						), 	-- raster rast, 
						'1BB'::text, 	-- text pixeltype,
						1.0, 		-- double precision initialvalue=0, 
						1.0 		-- double precision nodataval=NULL;
					),	--raster rast, 
					geometryextent,	--geometry geom, 
					0	--double precision newvalue
				) AS rast
			;										   
							 
			PERFORM AddRasterConstraints('rc'::name, 'fillnodatamask'::name,'rast'::name);
		END;
    $BODY$ LANGUAGE plpgsql;		
	