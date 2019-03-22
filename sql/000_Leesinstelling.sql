set client_min_messages='error';

-- Schema
CREATE SCHEMA IF NOT EXISTS rc;
    
CREATE OR REPLACE FUNCTION rc.LeesInstelling(var text)
RETURNS text AS $$
	DECLARE
		resultaat text;
	BEGIN
		SELECT waarde FROM rc.instellingen WHERE variabele = var INTO resultaat;
		RETURN resultaat;
	END
$$ LANGUAGE plpgsql
;

-- SELECT rc.LeesInstelling('projectnaam');