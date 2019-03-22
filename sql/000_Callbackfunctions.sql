CREATE EXTENSION IF NOT EXISTS postgis;

CREATE OR REPLACE FUNCTION cbf_custom (
	val double precision [][][],
	pos int[][],
	VARIADIC userargs text[] -- argumenten: 1: srid, 2: upperleftx, 3: upperlefty, 4: pixelsize, 5: custom_definition
)
RETURNS
	double precision
AS
$BODY$
	DECLARE 
		srid integer;
		upperleftx double precision;
		upperlefty double precision;
		pixelsize double precision;
		custom_definition text;
		pixel geometry(Point);
		result double precision;
	BEGIN
		IF val[1][1][1] IS NULL --pixel valt buiten de mask
		THEN RETURN -9999;
		ELSE 
			srid := userargs[1];
			upperleftx := userargs[2];
			upperlefty := userargs[3];
			pixelsize := userargs[4];
			pixel := ST_SetSRID(
				ST_MakePoint(
					upperleftx + pos[0][1]*pixelsize, 
					upperlefty - pos[0][2]*pixelsize
				), 
				srid
			);

			custom_definition := replace(userargs[5], 'pixel', 'ST_GeomFromEWKT(''' ||ST_AsEWKT(pixel)||''')');

			EXECUTE 'SELECT '|| custom_definition INTO result;
			RETURN result;
		END IF;
	END;
$BODY$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION cbf_constant (
	val double precision [][][],
	pos int[][],
	VARIADIC userargs text[] -- argumenten: 1: geom, 2: aux_1, 3: aux_2, 4: aux_3, 5: aux_4, 6: aux_5, 7: aux_6, 8: param_1, 9: param_2, 10: param_3, 11: param_4, 12: param_5, 13: param_6, 14: upperleftx, 15: upperlefty, 16: pixelsize, 17: custom_definition
)
RETURNS
	double precision
AS
$BODY$
	BEGIN
		IF val[1][1][1] IS NULL --pixel valt buiten de mask
		THEN RETURN -9999;
		ELSE RETURN userargs[8]::double precision;
		END IF;
	END;
$BODY$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION cbf_NULL (
	val double precision [][][],
	pos int[][],
	VARIADIC userargs text[] -- argumenten: 1: geom, 2: aux_1, 3: aux_2, 4: aux_3, 5: aux_4, 6: aux_5, 7: aux_6, 8: param_1, 9: param_2, 10: param_3, 11: param_4, 12: param_5, 13: param_6, 14: upperleftx, 15: upperlefty, 16: pixelsize, 17: custom_definition
)
RETURNS
	double precision
AS
$BODY$
	BEGIN
 		RETURN -9999;
	END;
$BODY$ LANGUAGE plpgsql IMMUTABLE;
