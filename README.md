# RasterCaster
** Make DEMs and other rasters from polygons with a specific gradient definition for each polygon. **

_Made by Leendert van Wolfswinkel, Nelen & Schuurmans in partnership with Deltares (2018-2019)_

## Introduction
The RasterCaster allows the user to create digital elevation models geotiffs from vector data (points, lines and polygons). Elevation is a continous variable and therefore better represented by a raster than polygons or other vector formats. However, raster data is much harder to edit than vector data. RasterCaster bridges this gap. The user makes a set of polygons that cover the area of interest and do not overlap. The polygons may be hand-drawn directly into GIS, but can also be derived from landscape desings (usually CAD drawings). 

The polygons can be seen as ‘molds’, that are used to ‘cast’ the elevation map into. Each polygon contains a definition of the altitude variations within it. Simple elevation profiles (e.g. the flat floor level within a building) can be cast using a simple definition, while at the same time the RasterCaster offers the user all flexibility to add more complex profiles (e.g. a sloping road with a convex cross section). Currently, molds can be defined in four different way - see under Definition Types.

The RasterCaster lives in a PostGIS database, so you need to install PostGIS or have access to an existing PostGIS database. All vector data are stored there. The first time you _cast_, for each polygon a raster is created and stored in the database. The next time you cast, rasters are only generated for polygons that have been edited (geometry and/or attributes). All data edits are done directly in the PostGIS tables (using QGIS for example). Installing the RasterCaster into your database, casting your raster and a few other things are done via a Python script that takes command line arguments. Depending on available funding, a QGIS plugin may be developed in the future. 

## Requirements
Postgres >= 10.0
PostGIS >= 2.2
Python 2 or 3
QGIS 3.x

Currently only the Dutch projection RD New (EPSG:28992) is supported.

## Command line user interface

### Installation
1. Clone or download the GitHub repo
2. Copy settings.ini and fill with the values specific to your project
3. In Command Prompt (or OSGeo4W):

`cd {path_to_your_GitHub_map} \ GitHub \ rastercaster

python rastercaster.py -install {path_to_your_projectmap} \ settings.ini`

### Casting (export to .tif)

- In Command Prompt (or OSGeo4W):

`cd {path_to_your_GitHub_map} \ GitHub \ rastercaster`

`python rastercaster.py -cast {path_to_your_projectmap} \ settings.ini`

### Generate guides
## Tables
After installation, the database contains an 'rc' schema. The tables in this schema represent the input data for the RasterCaster.

### Surface
The rc.surface table contains the polygons that are converted to rasters by the RasterCaster. The elevation gradient within a surface is defined by the attributes of the polygon, in a way that depends on the definition_type (see below). This table has the following fields:

    id | integer 
    definition | text | DEFAULT 'NULL'
    definition_type | text NOT NULL DEFAULT 'custom',
    comment | text
    geom | geometry(Polygon, 28992) NOT NULL,
    aux_1 .. aux_6 | integer
    param_1 .. param_6 | double precision
   
### Elevation Point
You must place this within the elevation_point_search_radius (in the .ini) of a line. If you want to make sure that the point is included, make sure you have snapping on.

The rc.elevation_point table has the following columns:

- id: integer, unique identifier. Will be filled in automatically if you leave this blank.
- elevation: height (mNAP)
- geom: point geometry without z-coordinate
- geom_3d: point geometry with the value entered in the 'elevation' field as z-coordinate. No filling is automatic.
- in_polygon_only: enter 'true' here to have the elevation count only for the surface where the point is located. Default is false. See below under definition type 'tin'.

### Auxiliary Line
You can use the rc.auxiliary_line table to define complex height profiles.

If you want to create a complicated height profile or the source data that you use (eg from a CAD drawing) contains too little detail (in rc.surface) then you can choose to draw guides. For example, a helpline can be: a line that indicates the axis of a road. For example, if you want to create a convex path, enter definition_type: 'custom' in the rc.surface table. Based on a function, the gradient of height between the axis and roadside can be interpolated. For more information see: definition_type.

## Definition Types
The definition_type field in the rc.surface table determines how the height gradient of the relevant polygon is defined. The following types can currently be entered in that field:

### "constant"
The same height in the entire polygon. Enter the desired height in the 'param_1' field. This is useful, for example, for installing floor levels of homes in the DEM.

### 'tin'
Elevation data is retrieved from elevation_points that lie on or near the edge of the polygon. This can be either an inner edge or the outer edge. The height is specified in the elevation field of the elevation_point. An elevation_point is included in the determination of the height gradient if it is closer to the edge than the elevation_point_search_radius in the settings. If you want two adjacent polygons to have a different height at their shared boundary (for example at a curb), you can place the elevation point in the polygon (close enough to the edge) and enter 'true' in the in_polygon_only field.

### 'filler'
The height gradient is interpolated based on the surrounding grid values.

### 'custom'
This definition type can be used to define complex profiles, such as a convex or concave path with a longitudinal gradient. The height gradient is determined by a formula that is specified in the definition field. The language of the formula is postgresql. The following terms are treated in a special way:

- pixel: the dot representation of the pixel in question
- geom: the geometry of the surface polygon
- aux_1 to aux_6: the auxiliary geometry from the rc.auxiliary_line table associated with the surface polygon
Examples of such formulas can be found in the [RasterCaster Mold Library] (https://docs.google.com/spreadsheets/d/1nrRuSO89Rfs1AuXtvw6QpmeLq1P5CMJCD1IZiEAK1dg/edit?usp=sharing).

## Errors / known issues
