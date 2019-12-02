-- -- Deze interpolatiemethode interpoleert tussen een dwarsprofiel aan de bovenstroomse zijde en een dwarsprofiel aan de benedenstroomse zijde, waarbij de vorm (bochten e.d.) van het kanaal niet uitmaakt
-- Hartlijn: aux_1
-- Linkeroever: aux_2
-- Rechteroever: aux_3
-- Haakse startlijn: aux_4 (tekenrichting: van linkeroever naar rechteroever)
-- Haakse eindlijn: aux_5 (tekenrichting: van linkeroever naar rechteroever)

-- Zorg dat haakse start- en eindlijn goed getekend worden
---- Haakse startlijn
UPDATE 	rc.auxiliary_line AS a
SET		geom = ST_Reverse(geom)
FROM	rc.surface AS s
		rc.auxiliary_line AS linkeroever
WHERE	s.comment LIKE '%emielinterpolatie%'
		AND a.id = s.aux_4
		AND linkeroever.id = s.aux_2
		ST_Distance(ST_StartPoint(a.geom), linkeroever.geom) > ST_Distance(ST_EndPoint(a.geom), linkeroever.geom) 

---- Haakse eindlijn
UPDATE 	rc.auxiliary_line AS a
SET		geom = ST_Reverse(geom)
FROM	rc.surface AS s
		rc.auxiliary_line AS linkeroever
WHERE	s.comment LIKE '%emielinterpolatie%'
		AND a.id = s.aux_5
		AND linkeroever.id = s.aux_2
		ST_Distance(ST_StartPoint(a.geom), linkeroever.geom) > ST_Distance(ST_EndPoint(a.geom), linkeroever.geom) 
		
		
-- Bereken afstand pixel tot linkeroever als percentage van breedte rivier op die plek (fractie oever, Fo)
Fo = ST_Distance(pixel, aux_2) / (ST_Distance(pixel, aux_2) + ST_Distance(pixel, aux_3))
-- Bereken afstand over de hartlijn vanaf het begin van de hartlijn tot het closestpoint vd pixel op de hartlijn als percentage van lengte hartlijn (fractie hartlijn, Fh)
Fh = ST_LineLocatePoint(ST_ClosestPoint(aux_1, pixel), aux_1)
-- Bereken z-waarde op haakse startlijn op fractie Fo (z_Fo_s) en zelfde voor haakse eindlijn (z_Fo_e)
z_Fo_s = ST_Z(ST_LineInterpolatePoint(aux_4, Fo))
z_Fo_e = ST_Z(ST_LineInterpolatePoint(aux_5, Fo))
-- Z-Waarde pixel = z_Fo_s*(1-Fh)+z_Fo_e*Fh
ST_Z(ST_LineInterpolatePoint(aux_4, ST_Distance(pixel, aux_2) / (ST_Distance(pixel, aux_2) + ST_Distance(pixel, aux_3))))*(1-ST_LineLocatePoint(ST_ClosestPoint(aux_1, pixel), aux_1))+ST_Z(ST_LineInterpolatePoint(aux_5, ST_Distance(pixel, aux_2) / (ST_Distance(pixel, aux_2) + ST_Distance(pixel, aux_3))))*ST_LineLocatePoint(ST_ClosestPoint(aux_1, pixel), aux_1)
