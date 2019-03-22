# RasterCaster
**DEMs en andere rasters maken aan de hand van polygonen met voor elke polygoon een specifieke definitie van het hoogteverloop.**

_Gemaakt door Leendert van Wolfswinkel (2018-2019)_

## Python user interface
### Installatie
- Zorg dat je de GitHub repository nens\rastercaster hebt gekloond en gesynchroniseerd
- Kopieer het bestandje {pad_naar_jouw_GitHub_map}\GitHub\rastercaster\settings.ini naar een projectmapje
- Open settings.ini en vul in.
- In OSGeo4W:

`cd {pad_naar_jouw_GitHub_map}\GitHub\rastercaster`

`python rastercaster.py -install {pad_naar_jouw_projectmap}\settings.ini`

### Casten (exporteren naar .tif)

- In OSGeo4W:

`cd {pad_naar_jouw_GitHub_map}\GitHub\rastercaster`

`python rastercaster.py -cast {pad_naar_jouw_projectmap}\settings.ini`

### Hulplijnen genereren
## Tabellen
Na installatie bevat de database een schema 'rc'.  De tabellen in dit schema vormen de inputdata voor de RasterCaster. 

### Surface
De tabel rc.surface bevat de polygonen die door de RasterCaster in rasters worden omgezet. Het hoogteverloop binnen een surface wordt gedefiniëerd door de attributen van de polygoon, op een manier die afhangt van de  definition_type (zie hieronder).

### Elevation Point
Deze moet je binnen de elevation_point_search_radius (in de .ini) van een lijn leggen. Als je zeker wilt weten dat het punt wordt meegenomen, zorg dat je snapping aan hebt.

De tabel rc.elevation_point heeft de volgende kolommen:

- id: integer, unieke identifier. Wordt automatisch ingevuld als je deze leeg laat.
- elevation: hoogte (mNAP)
- geom: puntgeometrie zonder z-coördinaat
- geom_3d: puntgeometrie met als z-coördinaat de waarde die in het veld 'elevation' is ingevuld. Niet vullen, gaat automatisch.
- in_polygon_only: vul hier 'true' in om de elevation alleen mee te laten tellen voor de surface waar het punt in ligt. Default is false. Zie hieronder bij definition type 'tin'.

### Auxiliary Line
De tabel rc.auxiliary_line kan je inzetten om ingewikkelde hoogteprofielen te definieren. 

Als je een ingewikkeld hoogteprofiel wil maken of de brondata die je gebruikt (bijv. vanuit een CAD-tekening) bevat te weinig detail (in rc.surface) dan kan je er voor kiezen om hulplijnen te trekken. Een hulplijn kan bijvoorbeeld zijn: een lijn die de as van een weg aan geeft. Als je bijvoorbeeld een bolle weg wil creëren dan geef je, in de rc.surface tabel, definition_type: 'custom' op. Aan de hand van een functie kan het hoogteverloop tussen de as en kant van de weg geïnterpoleerd worden.  Voor meer informatie zie: definition_type.

## Definition Types
Het veld definition_type in de tabel rc.surface bepaalt hoe het hoogteverloop van de betreffende polygoon wordt gedefinieerd. In dat veld kunnen momenteel de volgende types worden ingevuld:

### 'constant'
Dezelfde hoogte in de gehele polygoon. De gewenste hoogte geef je op in het veld 'param_1'. Dit is bijvoorbeeld bruikbaar voor het aanbrengen van vloerpeilen van woningen in de DEM. 

### 'tin'
Hoogtegegevens worden uit elevation_points gehaald die op of nabij de rand van de polygoon liggen. Dit kan zowel een binnenrand als de buitenrand zijn. De hoogte wordt opgegeven in het veld elevation van de elevation_point. Een elevation_point wordt meegenomen in de bepaling van het hoogteverloop als hij dichter bij de rand ligt dan de elevation_point_search_radius in de instellingen. Als je wilt dat twee aangrenzende polygonen op hun gedeelde grens een verschillende hoogte krijgen (bijvoorbeeld bij een stoeprand), kan je de elevation point in de polygoon leggen (wel dicht genoeg bij de rand) en 'true' invullen in het veld in_polygon_only.

### 'filler'
Het hoogteverloop wordt geinterpoleerd op basis van de omliggende rasterwaarden. 

### 'custom'
Deze definition type is te gebruiken om ingewikkelde profielen te definiëren, zoals een bolle of holle weg met tevens een verloop in de lengterichting. Het hoogteverloop wordt bepaald door een formule die opgegeven wordt in het veld definition. De taal van de formule is postgresql.  De volgende termen worden op een speciale manier behandeld:

- pixel: de puntrepresentatie van de betreffende pixel
- geom: de geometrie van de surface polygoon
- aux_1 t/m aux_6: de bij de surface polygoon horende hulpgeometrie uit de tabel rc.auxiliary_line
Voorbeelden van dergelijke formules zijn te vinden in de [RasterCaster Mold Library](https://docs.google.com/spreadsheets/d/1nrRuSO89Rfs1AuXtvw6QpmeLq1P5CMJCD1IZiEAK1dg/edit?usp=sharing).

## Errors / known issues
