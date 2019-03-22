SET XML OPTION DOCUMENT;
CREATE TABLE IF NOT EXISTS layer_styles (
	id serial NOT NULL,
	f_table_catalog varchar NULL,
	f_table_schema varchar NULL,
	f_table_name varchar NULL,
	f_geometry_column varchar NULL,
	stylename text NULL,
	styleqml xml NULL,
	stylesld xml NULL,
	useasdefault bool NULL,
	description text NULL,
	"owner" varchar(63) NULL,
	ui xml NULL,
	update_time timestamp NULL DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT layer_styles_pkey PRIMARY KEY (id)
);

INSERT INTO layer_styles (f_table_catalog,f_table_schema,f_table_name,f_geometry_column,stylename,styleqml,stylesld,useasdefault,description,"owner",ui,update_time) VALUES 
('rc_test','rc','elevation_point','geom','elevation_point','<!DOCTYPE qgis PUBLIC ''http://mrcc.com/qgis.dtd'' ''SYSTEM''>
<qgis simplifyAlgorithm="0" simplifyDrawingHints="0" simplifyMaxScale="1" hasScaleBasedVisibilityFlag="0" readOnly="0" simplifyLocal="1" styleCategories="AllStyleCategories" labelsEnabled="1" maxScale="0" minScale="1e+08" version="3.6.0-Noosa" simplifyDrawingTol="1">
 <flags>
  <Identifiable>1</Identifiable>
  <Removable>1</Removable>
  <Searchable>1</Searchable>
 </flags>
 <renderer-v2 forceraster="0" enableorderby="0" symbollevels="0" type="RuleRenderer">
  <rules key="{5cd6b092-54cf-4545-ae2a-4b02e4545532}">
   <rule label="in_polygon_only = false" filter="NOT in_polygon_only" symbol="0" key="{2814b447-38d4-4ed9-87e5-684bce9740e6}"/>
   <rule label="in_polygon_only = true" filter="in_polygon_only" symbol="1" key="{022a92b6-3db7-4904-96cc-751530ed1ad4}"/>
  </rules>
  <symbols>
   <symbol clip_to_extent="1" force_rhr="0" name="0" type="marker" alpha="1">
    <layer class="SimpleMarker" pass="0" enabled="1" locked="0">
     <prop v="0" k="angle"/>
     <prop v="255,255,255,0" k="color"/>
     <prop v="1" k="horizontal_anchor_point"/>
     <prop v="bevel" k="joinstyle"/>
     <prop v="circle" k="name"/>
     <prop v="0,0" k="offset"/>
     <prop v="3x:0,0,0,0,0,0" k="offset_map_unit_scale"/>
     <prop v="MM" k="offset_unit"/>
     <prop v="0,0,0,255" k="outline_color"/>
     <prop v="solid" k="outline_style"/>
     <prop v="0.2" k="outline_width"/>
     <prop v="3x:0,0,0,0,0,0" k="outline_width_map_unit_scale"/>
     <prop v="MM" k="outline_width_unit"/>
     <prop v="area" k="scale_method"/>
     <prop v="3.2" k="size"/>
     <prop v="3x:0,0,0,0,0,0" k="size_map_unit_scale"/>
     <prop v="MM" k="size_unit"/>
     <prop v="1" k="vertical_anchor_point"/>
     <data_defined_properties>
      <Option type="Map">
       <Option value="" name="name" type="QString"/>
       <Option name="properties"/>
       <Option value="collection" name="type" type="QString"/>
      </Option>
     </data_defined_properties>
    </layer>
    <layer class="SimpleMarker" pass="0" enabled="1" locked="0">
     <prop v="0" k="angle"/>
     <prop v="0,0,0,255" k="color"/>
     <prop v="1" k="horizontal_anchor_point"/>
     <prop v="bevel" k="joinstyle"/>
     <prop v="circle" k="name"/>
     <prop v="0,0" k="offset"/>
     <prop v="3x:0,0,0,0,0,0" k="offset_map_unit_scale"/>
     <prop v="MM" k="offset_unit"/>
     <prop v="0,0,0,255" k="outline_color"/>
     <prop v="solid" k="outline_style"/>
     <prop v="0.4" k="outline_width"/>
     <prop v="3x:0,0,0,0,0,0" k="outline_width_map_unit_scale"/>
     <prop v="MM" k="outline_width_unit"/>
     <prop v="area" k="scale_method"/>
     <prop v="0.7" k="size"/>
     <prop v="3x:0,0,0,0,0,0" k="size_map_unit_scale"/>
     <prop v="MM" k="size_unit"/>
     <prop v="1" k="vertical_anchor_point"/>
     <data_defined_properties>
      <Option type="Map">
       <Option value="" name="name" type="QString"/>
       <Option name="properties"/>
       <Option value="collection" name="type" type="QString"/>
      </Option>
     </data_defined_properties>
    </layer>
   </symbol>
   <symbol clip_to_extent="1" force_rhr="0" name="1" type="marker" alpha="1">
    <layer class="SimpleMarker" pass="0" enabled="1" locked="0">
     <prop v="0" k="angle"/>
     <prop v="255,255,255,0" k="color"/>
     <prop v="1" k="horizontal_anchor_point"/>
     <prop v="bevel" k="joinstyle"/>
     <prop v="circle" k="name"/>
     <prop v="0,0" k="offset"/>
     <prop v="3x:0,0,0,0,0,0" k="offset_map_unit_scale"/>
     <prop v="MM" k="offset_unit"/>
     <prop v="0,0,255,255" k="outline_color"/>
     <prop v="solid" k="outline_style"/>
     <prop v="0.2" k="outline_width"/>
     <prop v="3x:0,0,0,0,0,0" k="outline_width_map_unit_scale"/>
     <prop v="MM" k="outline_width_unit"/>
     <prop v="area" k="scale_method"/>
     <prop v="3.2" k="size"/>
     <prop v="3x:0,0,0,0,0,0" k="size_map_unit_scale"/>
     <prop v="MM" k="size_unit"/>
     <prop v="1" k="vertical_anchor_point"/>
     <data_defined_properties>
      <Option type="Map">
       <Option value="" name="name" type="QString"/>
       <Option name="properties"/>
       <Option value="collection" name="type" type="QString"/>
      </Option>
     </data_defined_properties>
    </layer>
    <layer class="SimpleMarker" pass="0" enabled="1" locked="0">
     <prop v="0" k="angle"/>
     <prop v="0,0,255,255" k="color"/>
     <prop v="1" k="horizontal_anchor_point"/>
     <prop v="bevel" k="joinstyle"/>
     <prop v="circle" k="name"/>
     <prop v="0,0" k="offset"/>
     <prop v="3x:0,0,0,0,0,0" k="offset_map_unit_scale"/>
     <prop v="MM" k="offset_unit"/>
     <prop v="0,0,255,255" k="outline_color"/>
     <prop v="solid" k="outline_style"/>
     <prop v="0.4" k="outline_width"/>
     <prop v="3x:0,0,0,0,0,0" k="outline_width_map_unit_scale"/>
     <prop v="MM" k="outline_width_unit"/>
     <prop v="area" k="scale_method"/>
     <prop v="0.7" k="size"/>
     <prop v="3x:0,0,0,0,0,0" k="size_map_unit_scale"/>
     <prop v="MM" k="size_unit"/>
     <prop v="1" k="vertical_anchor_point"/>
     <data_defined_properties>
      <Option type="Map">
       <Option value="" name="name" type="QString"/>
       <Option name="properties"/>
       <Option value="collection" name="type" type="QString"/>
      </Option>
     </data_defined_properties>
    </layer>
   </symbol>
  </symbols>
 </renderer-v2>
 <labeling type="rule-based">
  <rules key="{7e9aa8cf-3079-438c-9d89-f17335b39495}">
   <rule description="in_polygon_only = false" filter="NOT in_polygon_only" key="{a7417680-8cd2-4f57-821f-10988ea93c85}">
    <settings>
     <text-style fontSizeUnit="Point" fontUnderline="0" fontStrikeout="0" fontCapitals="0" fontSize="8" textColor="0,0,0,255" fontWordSpacing="0" isExpression="0" fontSizeMapUnitScale="3x:0,0,0,0,0,0" useSubstitutions="0" fontFamily="MS Gothic" fontLetterSpacing="0" fieldName="elevation" fontItalic="0" multilineHeight="1" fontWeight="50" textOpacity="1" namedStyle="Regular" previewBkgrdColor="#ffffff" blendMode="0">
      <text-buffer bufferSizeUnits="MM" bufferOpacity="1" bufferDraw="1" bufferColor="255,255,255,255" bufferBlendMode="0" bufferNoFill="1" bufferJoinStyle="128" bufferSize="0.4" bufferSizeMapUnitScale="3x:0,0,0,0,0,0"/>
      <background shapeSizeY="0" shapeBorderWidthUnit="MM" shapeSVGFile="" shapeOffsetUnit="MM" shapeRadiiX="0" shapeSizeType="0" shapeType="0" shapeFillColor="255,255,255,255" shapeRadiiMapUnitScale="3x:0,0,0,0,0,0" shapeSizeUnit="MM" shapeOffsetMapUnitScale="3x:0,0,0,0,0,0" shapeRadiiUnit="MM" shapeOffsetY="0" shapeRadiiY="0" shapeOpacity="1" shapeRotation="0" shapeBorderColor="128,128,128,255" shapeBorderWidthMapUnitScale="3x:0,0,0,0,0,0" shapeRotationType="0" shapeSizeMapUnitScale="3x:0,0,0,0,0,0" shapeOffsetX="0" shapeDraw="0" shapeJoinStyle="64" shapeBlendMode="0" shapeSizeX="0" shapeBorderWidth="0"/>
      <shadow shadowOffsetUnit="MM" shadowDraw="0" shadowOffsetGlobal="1" shadowRadiusUnit="MM" shadowUnder="0" shadowOffsetMapUnitScale="3x:0,0,0,0,0,0" shadowRadius="1.5" shadowBlendMode="6" shadowRadiusAlphaOnly="0" shadowOpacity="0.7" shadowColor="0,0,0,255" shadowOffsetDist="1" shadowRadiusMapUnitScale="3x:0,0,0,0,0,0" shadowScale="100" shadowOffsetAngle="135"/>
      <substitutions/>
     </text-style>
     <text-format placeDirectionSymbol="0" wrapChar="" multilineAlign="3" useMaxLineLengthForAutoWrap="1" addDirectionSymbol="0" autoWrapLength="0" decimals="3" formatNumbers="0" reverseDirectionSymbol="0" leftDirectionSymbol="&lt;" rightDirectionSymbol=">" plussign="0"/>
     <placement xOffset="1.7" repeatDistanceUnits="MM" yOffset="0" rotationAngle="0" distMapUnitScale="3x:0,0,0,0,0,0" centroidInside="0" placementFlags="10" maxCurvedCharAngleOut="-25" labelOffsetMapUnitScale="3x:0,0,0,0,0,0" offsetUnits="MM" maxCurvedCharAngleIn="25" repeatDistanceMapUnitScale="3x:0,0,0,0,0,0" distUnits="MM" placement="1" predefinedPositionOrder="TR,TL,BR,BL,R,L,TSR,BSR" dist="0" repeatDistance="0" preserveRotation="1" centroidWhole="0" quadOffset="2" priority="5" fitInPolygonOnly="0" offsetType="0"/>
     <rendering mergeLines="0" displayAll="0" scaleMin="0" obstacleFactor="1" upsidedownLabels="0" drawLabels="1" fontMinPixelSize="3" fontMaxPixelSize="10000" labelPerPart="0" limitNumLabels="0" fontLimitPixelSize="0" zIndex="0" maxNumLabels="2000" scaleMax="0" minFeatureSize="0" scaleVisibility="0" obstacleType="0" obstacle="1"/>
     <dd_properties>
      <Option type="Map">
       <Option value="" name="name" type="QString"/>
       <Option name="properties"/>
       <Option value="collection" name="type" type="QString"/>
      </Option>
     </dd_properties>
    </settings>
   </rule>
   <rule description="in_polygon_only = false" filter="in_polygon_only" key="{16de1840-3df5-4728-81b8-265f922c17c6}">
    <settings>
     <text-style fontSizeUnit="Point" fontUnderline="0" fontStrikeout="0" fontCapitals="0" fontSize="8" textColor="0,0,255,255" fontWordSpacing="0" isExpression="0" fontSizeMapUnitScale="3x:0,0,0,0,0,0" useSubstitutions="0" fontFamily="MS Gothic" fontLetterSpacing="0" fieldName="elevation" fontItalic="0" multilineHeight="1" fontWeight="50" textOpacity="1" namedStyle="Regular" previewBkgrdColor="#ffffff" blendMode="0">
      <text-buffer bufferSizeUnits="MM" bufferOpacity="1" bufferDraw="1" bufferColor="255,255,255,255" bufferBlendMode="0" bufferNoFill="1" bufferJoinStyle="128" bufferSize="0.4" bufferSizeMapUnitScale="3x:0,0,0,0,0,0"/>
      <background shapeSizeY="0" shapeBorderWidthUnit="MM" shapeSVGFile="" shapeOffsetUnit="MM" shapeRadiiX="0" shapeSizeType="0" shapeType="0" shapeFillColor="255,255,255,255" shapeRadiiMapUnitScale="3x:0,0,0,0,0,0" shapeSizeUnit="MM" shapeOffsetMapUnitScale="3x:0,0,0,0,0,0" shapeRadiiUnit="MM" shapeOffsetY="0" shapeRadiiY="0" shapeOpacity="1" shapeRotation="0" shapeBorderColor="128,128,128,255" shapeBorderWidthMapUnitScale="3x:0,0,0,0,0,0" shapeRotationType="0" shapeSizeMapUnitScale="3x:0,0,0,0,0,0" shapeOffsetX="0" shapeDraw="0" shapeJoinStyle="64" shapeBlendMode="0" shapeSizeX="0" shapeBorderWidth="0"/>
      <shadow shadowOffsetUnit="MM" shadowDraw="0" shadowOffsetGlobal="1" shadowRadiusUnit="MM" shadowUnder="0" shadowOffsetMapUnitScale="3x:0,0,0,0,0,0" shadowRadius="1.5" shadowBlendMode="6" shadowRadiusAlphaOnly="0" shadowOpacity="0.7" shadowColor="0,0,0,255" shadowOffsetDist="1" shadowRadiusMapUnitScale="3x:0,0,0,0,0,0" shadowScale="100" shadowOffsetAngle="135"/>
      <substitutions/>
     </text-style>
     <text-format placeDirectionSymbol="0" wrapChar="" multilineAlign="3" useMaxLineLengthForAutoWrap="1" addDirectionSymbol="0" autoWrapLength="0" decimals="3" formatNumbers="0" reverseDirectionSymbol="0" leftDirectionSymbol="&lt;" rightDirectionSymbol=">" plussign="0"/>
     <placement xOffset="1.7" repeatDistanceUnits="MM" yOffset="0" rotationAngle="0" distMapUnitScale="3x:0,0,0,0,0,0" centroidInside="0" placementFlags="10" maxCurvedCharAngleOut="-25" labelOffsetMapUnitScale="3x:0,0,0,0,0,0" offsetUnits="MM" maxCurvedCharAngleIn="25" repeatDistanceMapUnitScale="3x:0,0,0,0,0,0" distUnits="MM" placement="1" predefinedPositionOrder="TR,TL,BR,BL,R,L,TSR,BSR" dist="0" repeatDistance="0" preserveRotation="1" centroidWhole="0" quadOffset="2" priority="5" fitInPolygonOnly="0" offsetType="0"/>
     <rendering mergeLines="0" displayAll="0" scaleMin="0" obstacleFactor="1" upsidedownLabels="0" drawLabels="1" fontMinPixelSize="3" fontMaxPixelSize="10000" labelPerPart="0" limitNumLabels="0" fontLimitPixelSize="0" zIndex="0" maxNumLabels="2000" scaleMax="0" minFeatureSize="0" scaleVisibility="0" obstacleType="0" obstacle="1"/>
     <dd_properties>
      <Option type="Map">
       <Option value="" name="name" type="QString"/>
       <Option name="properties"/>
       <Option value="collection" name="type" type="QString"/>
      </Option>
     </dd_properties>
    </settings>
   </rule>
  </rules>
 </labeling>
 <customproperties>
  <property key="dualview/previewExpressions">
   <value>id</value>
  </property>
  <property value="0" key="embeddedWidgets/count"/>
  <property key="variableNames"/>
  <property key="variableValues"/>
 </customproperties>
 <blendMode>0</blendMode>
 <featureBlendMode>0</featureBlendMode>
 <layerOpacity>1</layerOpacity>
 <SingleCategoryDiagramRenderer diagramType="Histogram" attributeLegend="1">
  <DiagramCategory backgroundColor="#ffffff" rotationOffset="270" lineSizeType="MM" sizeType="MM" minimumSize="0" penColor="#000000" minScaleDenominator="0" scaleDependency="Area" backgroundAlpha="255" scaleBasedVisibility="0" opacity="1" width="15" maxScaleDenominator="1e+08" barWidth="5" lineSizeScale="3x:0,0,0,0,0,0" penAlpha="255" enabled="0" penWidth="0" diagramOrientation="Up" height="15" sizeScale="3x:0,0,0,0,0,0" labelPlacementMethod="XHeight">
   <fontProperties description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" style=""/>
   <attribute label="" field="" color="#000000"/>
  </DiagramCategory>
 </SingleCategoryDiagramRenderer>
 <DiagramLayerSettings dist="0" zIndex="0" obstacle="0" priority="0" showAll="1" linePlacementFlags="18" placement="0">
  <properties>
   <Option type="Map">
    <Option value="" name="name" type="QString"/>
    <Option name="properties"/>
    <Option value="collection" name="type" type="QString"/>
   </Option>
  </properties>
 </DiagramLayerSettings>
 <geometryOptions geometryPrecision="0" removeDuplicateNodes="0">
  <activeChecks/>
  <checkConfiguration/>
 </geometryOptions>
 <fieldConfiguration>
  <field name="id">
   <editWidget type="TextEdit">
    <config>
     <Option/>
    </config>
   </editWidget>
  </field>
  <field name="elevation">
   <editWidget type="TextEdit">
    <config>
     <Option/>
    </config>
   </editWidget>
  </field>
  <field name="geom_3d">
   <editWidget type="TextEdit">
    <config>
     <Option/>
    </config>
   </editWidget>
  </field>
  <field name="in_polygon_only">
   <editWidget type="CheckBox">
    <config>
     <Option type="Map">
      <Option value="" name="CheckedState" type="QString"/>
      <Option value="" name="UncheckedState" type="QString"/>
     </Option>
    </config>
   </editWidget>
  </field>
 </fieldConfiguration>
 <aliases>
  <alias index="0" field="id" name=""/>
  <alias index="1" field="elevation" name=""/>
  <alias index="2" field="geom_3d" name=""/>
  <alias index="3" field="in_polygon_only" name=""/>
 </aliases>
 <excludeAttributesWMS/>
 <excludeAttributesWFS/>
 <defaults>
  <default applyOnUpdate="0" field="id" expression=""/>
  <default applyOnUpdate="0" field="elevation" expression=""/>
  <default applyOnUpdate="0" field="geom_3d" expression=""/>
  <default applyOnUpdate="0" field="in_polygon_only" expression=""/>
 </defaults>
 <constraints>
  <constraint constraints="3" exp_strength="0" field="id" unique_strength="1" notnull_strength="1"/>
  <constraint constraints="0" exp_strength="0" field="elevation" unique_strength="0" notnull_strength="0"/>
  <constraint constraints="0" exp_strength="0" field="geom_3d" unique_strength="0" notnull_strength="0"/>
  <constraint constraints="1" exp_strength="0" field="in_polygon_only" unique_strength="0" notnull_strength="1"/>
 </constraints>
 <constraintExpressions>
  <constraint exp="" desc="" field="id"/>
  <constraint exp="" desc="" field="elevation"/>
  <constraint exp="" desc="" field="geom_3d"/>
  <constraint exp="" desc="" field="in_polygon_only"/>
 </constraintExpressions>
 <expressionfields/>
 <attributeactions>
  <defaultAction value="{00000000-0000-0000-0000-000000000000}" key="Canvas"/>
 </attributeactions>
 <attributetableconfig sortExpression="" sortOrder="0" actionWidgetStyle="dropDown">
  <columns>
   <column width="-1" hidden="0" name="id" type="field"/>
   <column width="-1" hidden="0" name="elevation" type="field"/>
   <column width="-1" hidden="0" name="geom_3d" type="field"/>
   <column width="-1" hidden="0" name="in_polygon_only" type="field"/>
   <column width="-1" hidden="1" type="actions"/>
  </columns>
 </attributetableconfig>
 <conditionalstyles>
  <rowstyles/>
  <fieldstyles/>
 </conditionalstyles>
 <editform tolerant="1"></editform>
 <editforminit/>
 <editforminitcodesource>0</editforminitcodesource>
 <editforminitfilepath></editforminitfilepath>
 <editforminitcode><![CDATA[# -*- coding: utf-8 -*-
"""
QGIS forms can have a Python function that is called when the form is
opened.

Use this function to add extra logic to your forms.

Enter the name of the function in the "Python Init function"
field.
An example follows:
"""
from qgis.PyQt.QtWidgets import QWidget

def my_form_open(dialog, layer, feature):
	geom = feature.geometry()
	control = dialog.findChild(QWidget, "MyLineEdit")
]]></editforminitcode>
 <featformsuppress>0</featformsuppress>
 <editorlayout>generatedlayout</editorlayout>
 <editable>
  <field editable="1" name="elevation"/>
  <field editable="1" name="geom_3d"/>
  <field editable="1" name="id"/>
  <field editable="1" name="in_polygon_only"/>
 </editable>
 <labelOnTop>
  <field labelOnTop="0" name="elevation"/>
  <field labelOnTop="0" name="geom_3d"/>
  <field labelOnTop="0" name="id"/>
  <field labelOnTop="0" name="in_polygon_only"/>
 </labelOnTop>
 <widgets/>
 <previewExpression>id</previewExpression>
 <mapTip></mapTip>
 <layerGeometryType>0</layerGeometryType>
</qgis>
','<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1.1.0/StyledLayerDescriptor.xsd" xmlns:ogc="http://www.opengis.net/ogc" xmlns:se="http://www.opengis.net/se" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1.0">
 <NamedLayer>
  <se:Name>elevation_point.geom</se:Name>
  <UserStyle>
   <se:Name>elevation_point.geom</se:Name>
   <se:FeatureTypeStyle>
    <se:Rule>
     <se:Name>in_polygon_only = false</se:Name>
     <se:Description>
      <se:Title>in_polygon_only = false</se:Title>
     </se:Description>
     <ogc:Filter xmlns:ogc="http://www.opengis.net/ogc">
      <ogc:Not>
       <ogc:PropertyName>in_polygon_only</ogc:PropertyName>
      </ogc:Not>
     </ogc:Filter>
     <se:PointSymbolizer>
      <se:Graphic>
       <se:Mark>
        <se:WellKnownName>circle</se:WellKnownName>
        <se:Fill>
         <se:SvgParameter name="fill">#ffffff</se:SvgParameter>
         <se:SvgParameter name="fill-opacity">0</se:SvgParameter>
        </se:Fill>
        <se:Stroke>
         <se:SvgParameter name="stroke">#000000</se:SvgParameter>
         <se:SvgParameter name="stroke-width">1</se:SvgParameter>
        </se:Stroke>
       </se:Mark>
       <se:Size>11</se:Size>
      </se:Graphic>
     </se:PointSymbolizer>
     <se:PointSymbolizer>
      <se:Graphic>
       <se:Mark>
        <se:WellKnownName>circle</se:WellKnownName>
        <se:Fill>
         <se:SvgParameter name="fill">#000000</se:SvgParameter>
        </se:Fill>
        <se:Stroke>
         <se:SvgParameter name="stroke">#000000</se:SvgParameter>
         <se:SvgParameter name="stroke-width">1</se:SvgParameter>
        </se:Stroke>
       </se:Mark>
       <se:Size>2</se:Size>
      </se:Graphic>
     </se:PointSymbolizer>
    </se:Rule>
    <se:Rule>
     <se:Name>in_polygon_only = true</se:Name>
     <se:Description>
      <se:Title>in_polygon_only = true</se:Title>
     </se:Description>
     <ogc:Filter xmlns:ogc="http://www.opengis.net/ogc">
      <ogc:PropertyName>in_polygon_only</ogc:PropertyName>
     </ogc:Filter>
     <se:PointSymbolizer>
      <se:Graphic>
       <se:Mark>
        <se:WellKnownName>circle</se:WellKnownName>
        <se:Fill>
         <se:SvgParameter name="fill">#ffffff</se:SvgParameter>
         <se:SvgParameter name="fill-opacity">0</se:SvgParameter>
        </se:Fill>
        <se:Stroke>
         <se:SvgParameter name="stroke">#0000ff</se:SvgParameter>
         <se:SvgParameter name="stroke-width">1</se:SvgParameter>
        </se:Stroke>
       </se:Mark>
       <se:Size>11</se:Size>
      </se:Graphic>
     </se:PointSymbolizer>
     <se:PointSymbolizer>
      <se:Graphic>
       <se:Mark>
        <se:WellKnownName>circle</se:WellKnownName>
        <se:Fill>
         <se:SvgParameter name="fill">#0000ff</se:SvgParameter>
        </se:Fill>
        <se:Stroke>
         <se:SvgParameter name="stroke">#0000ff</se:SvgParameter>
         <se:SvgParameter name="stroke-width">1</se:SvgParameter>
        </se:Stroke>
       </se:Mark>
       <se:Size>2</se:Size>
      </se:Graphic>
     </se:PointSymbolizer>
    </se:Rule>
    <se:Rule>
     <ogc:Filter xmlns:ogc="http://www.opengis.net/ogc">
      <ogc:Not>
       <ogc:PropertyName>in_polygon_only</ogc:PropertyName>
      </ogc:Not>
     </ogc:Filter>
     <se:TextSymbolizer>
      <se:Label>
       <ogc:PropertyName>elevation</ogc:PropertyName>
      </se:Label>
      <se:Font>
       <se:SvgParameter name="font-family">MS Gothic</se:SvgParameter>
       <se:SvgParameter name="font-size">10</se:SvgParameter>
      </se:Font>
      <se:LabelPlacement>
       <se:PointPlacement>
        <se:AnchorPoint>
         <se:AnchorPointX>0</se:AnchorPointX>
         <se:AnchorPointY>0</se:AnchorPointY>
        </se:AnchorPoint>
        <se:Displacement>
         <se:DisplacementX>6</se:DisplacementX>
         <se:DisplacementY>0</se:DisplacementY>
        </se:Displacement>
       </se:PointPlacement>
      </se:LabelPlacement>
      <se:Halo>
       <se:Radius>0.5</se:Radius>
       <se:Fill>
        <se:SvgParameter name="fill">#ffffff</se:SvgParameter>
       </se:Fill>
      </se:Halo>
      <se:Fill>
       <se:SvgParameter name="fill">#000000</se:SvgParameter>
      </se:Fill>
     </se:TextSymbolizer>
    </se:Rule>
    <se:Rule>
     <ogc:Filter xmlns:ogc="http://www.opengis.net/ogc">
      <ogc:PropertyName>in_polygon_only</ogc:PropertyName>
     </ogc:Filter>
     <se:TextSymbolizer>
      <se:Label>
       <ogc:PropertyName>elevation</ogc:PropertyName>
      </se:Label>
      <se:Font>
       <se:SvgParameter name="font-family">MS Gothic</se:SvgParameter>
       <se:SvgParameter name="font-size">10</se:SvgParameter>
      </se:Font>
      <se:LabelPlacement>
       <se:PointPlacement>
        <se:AnchorPoint>
         <se:AnchorPointX>0</se:AnchorPointX>
         <se:AnchorPointY>0</se:AnchorPointY>
        </se:AnchorPoint>
        <se:Displacement>
         <se:DisplacementX>6</se:DisplacementX>
         <se:DisplacementY>0</se:DisplacementY>
        </se:Displacement>
       </se:PointPlacement>
      </se:LabelPlacement>
      <se:Halo>
       <se:Radius>0.5</se:Radius>
       <se:Fill>
        <se:SvgParameter name="fill">#ffffff</se:SvgParameter>
       </se:Fill>
      </se:Halo>
      <se:Fill>
       <se:SvgParameter name="fill">#0000ff</se:SvgParameter>
      </se:Fill>
     </se:TextSymbolizer>
    </se:Rule>
   </se:FeatureTypeStyle>
  </UserStyle>
 </NamedLayer>
</StyledLayerDescriptor>
',true,'Styling for RasterCaster elevation_point',NULL,NULL,'2019-03-13 21:55:18.017')
,('rc_test','rc','surface','geom','surface','<!DOCTYPE qgis PUBLIC ''http://mrcc.com/qgis.dtd'' ''SYSTEM''>
<qgis simplifyAlgorithm="0" simplifyDrawingHints="1" simplifyMaxScale="1" hasScaleBasedVisibilityFlag="0" readOnly="0" simplifyLocal="1" styleCategories="AllStyleCategories" labelsEnabled="0" maxScale="0" minScale="1e+08" version="3.6.0-Noosa" simplifyDrawingTol="1">
 <flags>
  <Identifiable>1</Identifiable>
  <Removable>1</Removable>
  <Searchable>1</Searchable>
 </flags>
 <renderer-v2 forceraster="0" enableorderby="0" attr="definition_type" symbollevels="0" type="categorizedSymbol">
  <categories>
   <category value="custom" label="custom" symbol="0" render="true"/>
   <category value="constant" label="constant" symbol="1" render="true"/>
   <category value="tin" label="tin" symbol="2" render="true"/>
   <category value="filler" label="filler" symbol="3" render="true"/>
  </categories>
  <symbols>
   <symbol clip_to_extent="1" force_rhr="0" name="0" type="fill" alpha="1">
    <layer class="SimpleFill" pass="0" enabled="1" locked="0">
     <prop v="3x:0,0,0,0,0,0" k="border_width_map_unit_scale"/>
     <prop v="251,154,153,26" k="color"/>
     <prop v="bevel" k="joinstyle"/>
     <prop v="0,0" k="offset"/>
     <prop v="3x:0,0,0,0,0,0" k="offset_map_unit_scale"/>
     <prop v="MM" k="offset_unit"/>
     <prop v="251,91,91,255" k="outline_color"/>
     <prop v="solid" k="outline_style"/>
     <prop v="0.36" k="outline_width"/>
     <prop v="MM" k="outline_width_unit"/>
     <prop v="solid" k="style"/>
     <data_defined_properties>
      <Option type="Map">
       <Option value="" name="name" type="QString"/>
       <Option name="properties"/>
       <Option value="collection" name="type" type="QString"/>
      </Option>
     </data_defined_properties>
    </layer>
   </symbol>
   <symbol clip_to_extent="1" force_rhr="0" name="1" type="fill" alpha="1">
    <layer class="SimpleFill" pass="0" enabled="1" locked="0">
     <prop v="3x:0,0,0,0,0,0" k="border_width_map_unit_scale"/>
     <prop v="149,149,149,26" k="color"/>
     <prop v="bevel" k="joinstyle"/>
     <prop v="0,0" k="offset"/>
     <prop v="3x:0,0,0,0,0,0" k="offset_map_unit_scale"/>
     <prop v="MM" k="offset_unit"/>
     <prop v="118,118,118,255" k="outline_color"/>
     <prop v="solid" k="outline_style"/>
     <prop v="0.36" k="outline_width"/>
     <prop v="MM" k="outline_width_unit"/>
     <prop v="solid" k="style"/>
     <data_defined_properties>
      <Option type="Map">
       <Option value="" name="name" type="QString"/>
       <Option name="properties"/>
       <Option value="collection" name="type" type="QString"/>
      </Option>
     </data_defined_properties>
    </layer>
   </symbol>
   <symbol clip_to_extent="1" force_rhr="0" name="2" type="fill" alpha="1">
    <layer class="SimpleFill" pass="0" enabled="1" locked="0">
     <prop v="3x:0,0,0,0,0,0" k="border_width_map_unit_scale"/>
     <prop v="166,206,227,26" k="color"/>
     <prop v="bevel" k="joinstyle"/>
     <prop v="0,0" k="offset"/>
     <prop v="3x:0,0,0,0,0,0" k="offset_map_unit_scale"/>
     <prop v="MM" k="offset_unit"/>
     <prop v="0,155,232,255" k="outline_color"/>
     <prop v="solid" k="outline_style"/>
     <prop v="0.26" k="outline_width"/>
     <prop v="MM" k="outline_width_unit"/>
     <prop v="solid" k="style"/>
     <data_defined_properties>
      <Option type="Map">
       <Option value="" name="name" type="QString"/>
       <Option name="properties"/>
       <Option value="collection" name="type" type="QString"/>
      </Option>
     </data_defined_properties>
    </layer>
   </symbol>
   <symbol clip_to_extent="1" force_rhr="0" name="3" type="fill" alpha="1">
    <layer class="SimpleFill" pass="0" enabled="1" locked="0">
     <prop v="3x:0,0,0,0,0,0" k="border_width_map_unit_scale"/>
     <prop v="253,191,111,26" k="color"/>
     <prop v="bevel" k="joinstyle"/>
     <prop v="0,0" k="offset"/>
     <prop v="3x:0,0,0,0,0,0" k="offset_map_unit_scale"/>
     <prop v="MM" k="offset_unit"/>
     <prop v="253,139,0,255" k="outline_color"/>
     <prop v="solid" k="outline_style"/>
     <prop v="0.26" k="outline_width"/>
     <prop v="MM" k="outline_width_unit"/>
     <prop v="solid" k="style"/>
     <data_defined_properties>
      <Option type="Map">
       <Option value="" name="name" type="QString"/>
       <Option name="properties"/>
       <Option value="collection" name="type" type="QString"/>
      </Option>
     </data_defined_properties>
    </layer>
   </symbol>
  </symbols>
  <source-symbol>
   <symbol clip_to_extent="1" force_rhr="0" name="0" type="fill" alpha="1">
    <layer class="SimpleFill" pass="0" enabled="1" locked="0">
     <prop v="3x:0,0,0,0,0,0" k="border_width_map_unit_scale"/>
     <prop v="255,26,1,0" k="color"/>
     <prop v="bevel" k="joinstyle"/>
     <prop v="0,0" k="offset"/>
     <prop v="3x:0,0,0,0,0,0" k="offset_map_unit_scale"/>
     <prop v="MM" k="offset_unit"/>
     <prop v="149,149,149,255" k="outline_color"/>
     <prop v="solid" k="outline_style"/>
     <prop v="0.36" k="outline_width"/>
     <prop v="MM" k="outline_width_unit"/>
     <prop v="no" k="style"/>
     <data_defined_properties>
      <Option type="Map">
       <Option value="" name="name" type="QString"/>
       <Option name="properties"/>
       <Option value="collection" name="type" type="QString"/>
      </Option>
     </data_defined_properties>
    </layer>
   </symbol>
  </source-symbol>
  <colorramp name="[source]" type="randomcolors"/>
  <rotation/>
  <sizescale/>
 </renderer-v2>
 <customproperties>
  <property key="dualview/previewExpressions">
   <value>id</value>
  </property>
  <property value="0" key="embeddedWidgets/count"/>
  <property key="variableNames"/>
  <property key="variableValues"/>
 </customproperties>
 <blendMode>0</blendMode>
 <featureBlendMode>0</featureBlendMode>
 <layerOpacity>1</layerOpacity>
 <SingleCategoryDiagramRenderer diagramType="Histogram" attributeLegend="1">
  <DiagramCategory backgroundColor="#ffffff" rotationOffset="270" lineSizeType="MM" sizeType="MM" minimumSize="0" penColor="#000000" minScaleDenominator="0" scaleDependency="Area" backgroundAlpha="255" scaleBasedVisibility="0" opacity="1" width="15" maxScaleDenominator="1e+08" barWidth="5" lineSizeScale="3x:0,0,0,0,0,0" penAlpha="255" enabled="0" penWidth="0" diagramOrientation="Up" height="15" sizeScale="3x:0,0,0,0,0,0" labelPlacementMethod="XHeight">
   <fontProperties description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" style=""/>
  </DiagramCategory>
 </SingleCategoryDiagramRenderer>
 <DiagramLayerSettings dist="0" zIndex="0" obstacle="0" priority="0" showAll="1" linePlacementFlags="18" placement="1">
  <properties>
   <Option type="Map">
    <Option value="" name="name" type="QString"/>
    <Option name="properties"/>
    <Option value="collection" name="type" type="QString"/>
   </Option>
  </properties>
 </DiagramLayerSettings>
 <geometryOptions geometryPrecision="0" removeDuplicateNodes="0">
  <activeChecks/>
  <checkConfiguration/>
 </geometryOptions>
 <fieldConfiguration>
  <field name="id">
   <editWidget type="TextEdit">
    <config>
     <Option type="Map">
      <Option value="false" name="IsMultiline" type="bool"/>
      <Option value="false" name="UseHtml" type="bool"/>
     </Option>
    </config>
   </editWidget>
  </field>
  <field name="definition">
   <editWidget type="TextEdit">
    <config>
     <Option type="Map">
      <Option value="false" name="IsMultiline" type="bool"/>
      <Option value="false" name="UseHtml" type="bool"/>
     </Option>
    </config>
   </editWidget>
  </field>
  <field name="definition_type">
   <editWidget type="Classification">
    <config>
     <Option/>
    </config>
   </editWidget>
  </field>
  <field name="comment">
   <editWidget type="TextEdit">
    <config>
     <Option type="Map">
      <Option value="false" name="IsMultiline" type="bool"/>
      <Option value="false" name="UseHtml" type="bool"/>
     </Option>
    </config>
   </editWidget>
  </field>
  <field name="aux_1">
   <editWidget type="Range">
    <config>
     <Option type="Map">
      <Option value="true" name="AllowNull" type="bool"/>
      <Option value="2147483647" name="Max" type="int"/>
      <Option value="-2147483648" name="Min" type="int"/>
      <Option value="0" name="Precision" type="int"/>
      <Option value="1" name="Step" type="int"/>
      <Option value="SpinBox" name="Style" type="QString"/>
     </Option>
    </config>
   </editWidget>
  </field>
  <field name="aux_2">
   <editWidget type="Range">
    <config>
     <Option type="Map">
      <Option value="true" name="AllowNull" type="bool"/>
      <Option value="2147483647" name="Max" type="int"/>
      <Option value="-2147483648" name="Min" type="int"/>
      <Option value="0" name="Precision" type="int"/>
      <Option value="1" name="Step" type="int"/>
      <Option value="SpinBox" name="Style" type="QString"/>
     </Option>
    </config>
   </editWidget>
  </field>
  <field name="aux_3">
   <editWidget type="Range">
    <config>
     <Option type="Map">
      <Option value="true" name="AllowNull" type="bool"/>
      <Option value="2147483647" name="Max" type="int"/>
      <Option value="-2147483648" name="Min" type="int"/>
      <Option value="0" name="Precision" type="int"/>
      <Option value="1" name="Step" type="int"/>
      <Option value="SpinBox" name="Style" type="QString"/>
     </Option>
    </config>
   </editWidget>
  </field>
  <field name="param_1">
   <editWidget type="TextEdit">
    <config>
     <Option type="Map">
      <Option value="false" name="IsMultiline" type="bool"/>
      <Option value="false" name="UseHtml" type="bool"/>
     </Option>
    </config>
   </editWidget>
  </field>
  <field name="param_2">
   <editWidget type="TextEdit">
    <config>
     <Option type="Map">
      <Option value="false" name="IsMultiline" type="bool"/>
      <Option value="false" name="UseHtml" type="bool"/>
     </Option>
    </config>
   </editWidget>
  </field>
  <field name="param_3">
   <editWidget type="TextEdit">
    <config>
     <Option type="Map">
      <Option value="false" name="IsMultiline" type="bool"/>
      <Option value="false" name="UseHtml" type="bool"/>
     </Option>
    </config>
   </editWidget>
  </field>
  <field name="param_4">
   <editWidget type="TextEdit">
    <config>
     <Option type="Map">
      <Option value="false" name="IsMultiline" type="bool"/>
      <Option value="false" name="UseHtml" type="bool"/>
     </Option>
    </config>
   </editWidget>
  </field>
  <field name="param_5">
   <editWidget type="TextEdit">
    <config>
     <Option type="Map">
      <Option value="false" name="IsMultiline" type="bool"/>
      <Option value="false" name="UseHtml" type="bool"/>
     </Option>
    </config>
   </editWidget>
  </field>
  <field name="param_6">
   <editWidget type="TextEdit">
    <config>
     <Option type="Map">
      <Option value="false" name="IsMultiline" type="bool"/>
      <Option value="false" name="UseHtml" type="bool"/>
     </Option>
    </config>
   </editWidget>
  </field>
 </fieldConfiguration>
 <aliases>
  <alias index="0" field="id" name=""/>
  <alias index="1" field="definition" name=""/>
  <alias index="2" field="definition_type" name=""/>
  <alias index="3" field="comment" name=""/>
  <alias index="4" field="aux_1" name=""/>
  <alias index="5" field="aux_2" name=""/>
  <alias index="6" field="aux_3" name=""/>
  <alias index="7" field="param_1" name=""/>
  <alias index="8" field="param_2" name=""/>
  <alias index="9" field="param_3" name=""/>
  <alias index="10" field="param_4" name=""/>
  <alias index="11" field="param_5" name=""/>
  <alias index="12" field="param_6" name=""/>
 </aliases>
 <excludeAttributesWMS/>
 <excludeAttributesWFS/>
 <defaults>
  <default applyOnUpdate="0" field="id" expression=""/>
  <default applyOnUpdate="0" field="definition" expression=""/>
  <default applyOnUpdate="0" field="definition_type" expression=""/>
  <default applyOnUpdate="0" field="comment" expression=""/>
  <default applyOnUpdate="0" field="aux_1" expression=""/>
  <default applyOnUpdate="0" field="aux_2" expression=""/>
  <default applyOnUpdate="0" field="aux_3" expression=""/>
  <default applyOnUpdate="0" field="param_1" expression=""/>
  <default applyOnUpdate="0" field="param_2" expression=""/>
  <default applyOnUpdate="0" field="param_3" expression=""/>
  <default applyOnUpdate="0" field="param_4" expression=""/>
  <default applyOnUpdate="0" field="param_5" expression=""/>
  <default applyOnUpdate="0" field="param_6" expression=""/>
 </defaults>
 <constraints>
  <constraint constraints="3" exp_strength="0" field="id" unique_strength="1" notnull_strength="1"/>
  <constraint constraints="0" exp_strength="0" field="definition" unique_strength="0" notnull_strength="0"/>
  <constraint constraints="0" exp_strength="0" field="definition_type" unique_strength="0" notnull_strength="0"/>
  <constraint constraints="0" exp_strength="0" field="comment" unique_strength="0" notnull_strength="0"/>
  <constraint constraints="0" exp_strength="0" field="aux_1" unique_strength="0" notnull_strength="0"/>
  <constraint constraints="0" exp_strength="0" field="aux_2" unique_strength="0" notnull_strength="0"/>
  <constraint constraints="0" exp_strength="0" field="aux_3" unique_strength="0" notnull_strength="0"/>
  <constraint constraints="0" exp_strength="0" field="param_1" unique_strength="0" notnull_strength="0"/>
  <constraint constraints="0" exp_strength="0" field="param_2" unique_strength="0" notnull_strength="0"/>
  <constraint constraints="0" exp_strength="0" field="param_3" unique_strength="0" notnull_strength="0"/>
  <constraint constraints="0" exp_strength="0" field="param_4" unique_strength="0" notnull_strength="0"/>
  <constraint constraints="0" exp_strength="0" field="param_5" unique_strength="0" notnull_strength="0"/>
  <constraint constraints="0" exp_strength="0" field="param_6" unique_strength="0" notnull_strength="0"/>
 </constraints>
 <constraintExpressions>
  <constraint exp="" desc="" field="id"/>
  <constraint exp="" desc="" field="definition"/>
  <constraint exp="" desc="" field="definition_type"/>
  <constraint exp="" desc="" field="comment"/>
  <constraint exp="" desc="" field="aux_1"/>
  <constraint exp="" desc="" field="aux_2"/>
  <constraint exp="" desc="" field="aux_3"/>
  <constraint exp="" desc="" field="param_1"/>
  <constraint exp="" desc="" field="param_2"/>
  <constraint exp="" desc="" field="param_3"/>
  <constraint exp="" desc="" field="param_4"/>
  <constraint exp="" desc="" field="param_5"/>
  <constraint exp="" desc="" field="param_6"/>
 </constraintExpressions>
 <expressionfields/>
 <attributeactions>
  <defaultAction value="{00000000-0000-0000-0000-000000000000}" key="Canvas"/>
 </attributeactions>
 <attributetableconfig sortExpression="" sortOrder="0" actionWidgetStyle="dropDown">
  <columns>
   <column width="-1" hidden="0" name="id" type="field"/>
   <column width="-1" hidden="0" name="definition" type="field"/>
   <column width="-1" hidden="0" name="definition_type" type="field"/>
   <column width="-1" hidden="0" name="comment" type="field"/>
   <column width="-1" hidden="0" name="aux_1" type="field"/>
   <column width="-1" hidden="0" name="aux_2" type="field"/>
   <column width="-1" hidden="0" name="aux_3" type="field"/>
   <column width="-1" hidden="0" name="param_1" type="field"/>
   <column width="-1" hidden="0" name="param_2" type="field"/>
   <column width="-1" hidden="0" name="param_3" type="field"/>
   <column width="-1" hidden="0" name="param_4" type="field"/>
   <column width="-1" hidden="0" name="param_5" type="field"/>
   <column width="-1" hidden="0" name="param_6" type="field"/>
   <column width="-1" hidden="1" type="actions"/>
  </columns>
 </attributetableconfig>
 <conditionalstyles>
  <rowstyles/>
  <fieldstyles/>
 </conditionalstyles>
 <editform tolerant="1"></editform>
 <editforminit/>
 <editforminitcodesource>0</editforminitcodesource>
 <editforminitfilepath></editforminitfilepath>
 <editforminitcode><![CDATA[# -*- coding: utf-8 -*-
"""
QGIS forms can have a Python function that is called when the form is
opened.

Use this function to add extra logic to your forms.

Enter the name of the function in the "Python Init function"
field.
An example follows:
"""
from qgis.PyQt.QtWidgets import QWidget

def my_form_open(dialog, layer, feature):
	geom = feature.geometry()
	control = dialog.findChild(QWidget, "MyLineEdit")
]]></editforminitcode>
 <featformsuppress>0</featformsuppress>
 <editorlayout>generatedlayout</editorlayout>
 <editable>
  <field editable="1" name="aux_1"/>
  <field editable="1" name="aux_2"/>
  <field editable="1" name="aux_3"/>
  <field editable="1" name="comment"/>
  <field editable="1" name="definition"/>
  <field editable="1" name="definition_type"/>
  <field editable="1" name="id"/>
  <field editable="1" name="param_1"/>
  <field editable="1" name="param_2"/>
  <field editable="1" name="param_3"/>
  <field editable="1" name="param_4"/>
  <field editable="1" name="param_5"/>
  <field editable="1" name="param_6"/>
 </editable>
 <labelOnTop>
  <field labelOnTop="0" name="aux_1"/>
  <field labelOnTop="0" name="aux_2"/>
  <field labelOnTop="0" name="aux_3"/>
  <field labelOnTop="0" name="comment"/>
  <field labelOnTop="0" name="definition"/>
  <field labelOnTop="0" name="definition_type"/>
  <field labelOnTop="0" name="id"/>
  <field labelOnTop="0" name="param_1"/>
  <field labelOnTop="0" name="param_2"/>
  <field labelOnTop="0" name="param_3"/>
  <field labelOnTop="0" name="param_4"/>
  <field labelOnTop="0" name="param_5"/>
  <field labelOnTop="0" name="param_6"/>
 </labelOnTop>
 <widgets/>
 <previewExpression>id</previewExpression>
 <mapTip></mapTip>
 <layerGeometryType>2</layerGeometryType>
</qgis>
','<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1.1.0/StyledLayerDescriptor.xsd" xmlns:ogc="http://www.opengis.net/ogc" xmlns:se="http://www.opengis.net/se" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1.0">
 <NamedLayer>
  <se:Name>surface</se:Name>
  <UserStyle>
   <se:Name>surface</se:Name>
   <se:FeatureTypeStyle>
    <se:Rule>
     <se:Name>custom</se:Name>
     <se:Description>
      <se:Title>custom</se:Title>
     </se:Description>
     <ogc:Filter xmlns:ogc="http://www.opengis.net/ogc">
      <ogc:PropertyIsEqualTo>
       <ogc:PropertyName>definition_type</ogc:PropertyName>
       <ogc:Literal>custom</ogc:Literal>
      </ogc:PropertyIsEqualTo>
     </ogc:Filter>
     <se:PolygonSymbolizer>
      <se:Fill>
       <se:SvgParameter name="fill">#fb9a99</se:SvgParameter>
       <se:SvgParameter name="fill-opacity">0.1</se:SvgParameter>
      </se:Fill>
      <se:Stroke>
       <se:SvgParameter name="stroke">#fb5b5b</se:SvgParameter>
       <se:SvgParameter name="stroke-width">1</se:SvgParameter>
       <se:SvgParameter name="stroke-linejoin">bevel</se:SvgParameter>
      </se:Stroke>
     </se:PolygonSymbolizer>
    </se:Rule>
    <se:Rule>
     <se:Name>constant</se:Name>
     <se:Description>
      <se:Title>constant</se:Title>
     </se:Description>
     <ogc:Filter xmlns:ogc="http://www.opengis.net/ogc">
      <ogc:PropertyIsEqualTo>
       <ogc:PropertyName>definition_type</ogc:PropertyName>
       <ogc:Literal>constant</ogc:Literal>
      </ogc:PropertyIsEqualTo>
     </ogc:Filter>
     <se:PolygonSymbolizer>
      <se:Fill>
       <se:SvgParameter name="fill">#959595</se:SvgParameter>
       <se:SvgParameter name="fill-opacity">0.1</se:SvgParameter>
      </se:Fill>
      <se:Stroke>
       <se:SvgParameter name="stroke">#767676</se:SvgParameter>
       <se:SvgParameter name="stroke-width">1</se:SvgParameter>
       <se:SvgParameter name="stroke-linejoin">bevel</se:SvgParameter>
      </se:Stroke>
     </se:PolygonSymbolizer>
    </se:Rule>
    <se:Rule>
     <se:Name>tin</se:Name>
     <se:Description>
      <se:Title>tin</se:Title>
     </se:Description>
     <ogc:Filter xmlns:ogc="http://www.opengis.net/ogc">
      <ogc:PropertyIsEqualTo>
       <ogc:PropertyName>definition_type</ogc:PropertyName>
       <ogc:Literal>tin</ogc:Literal>
      </ogc:PropertyIsEqualTo>
     </ogc:Filter>
     <se:PolygonSymbolizer>
      <se:Fill>
       <se:SvgParameter name="fill">#a6cee3</se:SvgParameter>
       <se:SvgParameter name="fill-opacity">0.1</se:SvgParameter>
      </se:Fill>
      <se:Stroke>
       <se:SvgParameter name="stroke">#009be8</se:SvgParameter>
       <se:SvgParameter name="stroke-width">1</se:SvgParameter>
       <se:SvgParameter name="stroke-linejoin">bevel</se:SvgParameter>
      </se:Stroke>
     </se:PolygonSymbolizer>
    </se:Rule>
    <se:Rule>
     <se:Name>filler</se:Name>
     <se:Description>
      <se:Title>filler</se:Title>
     </se:Description>
     <ogc:Filter xmlns:ogc="http://www.opengis.net/ogc">
      <ogc:PropertyIsEqualTo>
       <ogc:PropertyName>definition_type</ogc:PropertyName>
       <ogc:Literal>filler</ogc:Literal>
      </ogc:PropertyIsEqualTo>
     </ogc:Filter>
     <se:PolygonSymbolizer>
      <se:Fill>
       <se:SvgParameter name="fill">#fdbf6f</se:SvgParameter>
       <se:SvgParameter name="fill-opacity">0.1</se:SvgParameter>
      </se:Fill>
      <se:Stroke>
       <se:SvgParameter name="stroke">#fd8b00</se:SvgParameter>
       <se:SvgParameter name="stroke-width">1</se:SvgParameter>
       <se:SvgParameter name="stroke-linejoin">bevel</se:SvgParameter>
      </se:Stroke>
     </se:PolygonSymbolizer>
    </se:Rule>
   </se:FeatureTypeStyle>
  </UserStyle>
 </NamedLayer>
</StyledLayerDescriptor>
',true,'Styling for RasterCaster surface',NULL,NULL,'2019-03-13 21:56:30.844')
,('rc_test','rc','auxiliary_line','geom','auxiliary_line','<!DOCTYPE qgis PUBLIC ''http://mrcc.com/qgis.dtd'' ''SYSTEM''>
<qgis simplifyAlgorithm="0" simplifyDrawingHints="1" simplifyMaxScale="1" hasScaleBasedVisibilityFlag="0" readOnly="0" simplifyLocal="1" styleCategories="AllStyleCategories" labelsEnabled="0" maxScale="0" minScale="1e+08" version="3.6.0-Noosa" simplifyDrawingTol="1">
 <flags>
  <Identifiable>1</Identifiable>
  <Removable>1</Removable>
  <Searchable>1</Searchable>
 </flags>
 <renderer-v2 forceraster="0" enableorderby="0" symbollevels="0" type="singleSymbol">
  <symbols>
   <symbol clip_to_extent="1" force_rhr="0" name="0" type="line" alpha="1">
    <layer class="SimpleLine" pass="0" enabled="1" locked="1">
     <prop v="round" k="capstyle"/>
     <prop v="5;2" k="customdash"/>
     <prop v="3x:0,0,0,0,0,0" k="customdash_map_unit_scale"/>
     <prop v="MM" k="customdash_unit"/>
     <prop v="0" k="draw_inside_polygon"/>
     <prop v="round" k="joinstyle"/>
     <prop v="66,66,66,255" k="line_color"/>
     <prop v="solid" k="line_style"/>
     <prop v="0" k="line_width"/>
     <prop v="MM" k="line_width_unit"/>
     <prop v="0" k="offset"/>
     <prop v="3x:0,0,0,0,0,0" k="offset_map_unit_scale"/>
     <prop v="MM" k="offset_unit"/>
     <prop v="0" k="ring_filter"/>
     <prop v="0" k="use_custom_dash"/>
     <prop v="3x:0,0,0,0,0,0" k="width_map_unit_scale"/>
     <data_defined_properties>
      <Option type="Map">
       <Option value="" name="name" type="QString"/>
       <Option name="properties"/>
       <Option value="collection" name="type" type="QString"/>
      </Option>
     </data_defined_properties>
    </layer>
    <layer class="MarkerLine" pass="0" enabled="1" locked="0">
     <prop v="3" k="interval"/>
     <prop v="3x:0,0,0,0,0,0" k="interval_map_unit_scale"/>
     <prop v="MM" k="interval_unit"/>
     <prop v="0" k="offset"/>
     <prop v="0" k="offset_along_line"/>
     <prop v="3x:0,0,0,0,0,0" k="offset_along_line_map_unit_scale"/>
     <prop v="MM" k="offset_along_line_unit"/>
     <prop v="3x:0,0,0,0,0,0" k="offset_map_unit_scale"/>
     <prop v="MM" k="offset_unit"/>
     <prop v="interval" k="placement"/>
     <prop v="0" k="ring_filter"/>
     <prop v="1" k="rotate"/>
     <data_defined_properties>
      <Option type="Map">
       <Option value="" name="name" type="QString"/>
       <Option name="properties"/>
       <Option value="collection" name="type" type="QString"/>
      </Option>
     </data_defined_properties>
     <symbol clip_to_extent="1" force_rhr="0" name="@0@1" type="marker" alpha="1">
      <layer class="SimpleMarker" pass="0" enabled="1" locked="0">
       <prop v="0" k="angle"/>
       <prop v="255,0,0,255" k="color"/>
       <prop v="1" k="horizontal_anchor_point"/>
       <prop v="bevel" k="joinstyle"/>
       <prop v="line" k="name"/>
       <prop v="0,0" k="offset"/>
       <prop v="3x:0,0,0,0,0,0" k="offset_map_unit_scale"/>
       <prop v="MM" k="offset_unit"/>
       <prop v="39,39,39,255" k="outline_color"/>
       <prop v="solid" k="outline_style"/>
       <prop v="0.2" k="outline_width"/>
       <prop v="3x:0,0,0,0,0,0" k="outline_width_map_unit_scale"/>
       <prop v="MM" k="outline_width_unit"/>
       <prop v="diameter" k="scale_method"/>
       <prop v="1" k="size"/>
       <prop v="3x:0,0,0,0,0,0" k="size_map_unit_scale"/>
       <prop v="MM" k="size_unit"/>
       <prop v="0" k="vertical_anchor_point"/>
       <data_defined_properties>
        <Option type="Map">
         <Option value="" name="name" type="QString"/>
         <Option name="properties"/>
         <Option value="collection" name="type" type="QString"/>
        </Option>
       </data_defined_properties>
      </layer>
     </symbol>
    </layer>
   </symbol>
  </symbols>
  <rotation/>
  <sizescale/>
 </renderer-v2>
 <customproperties>
  <property value="0" key="embeddedWidgets/count"/>
  <property key="variableNames"/>
  <property key="variableValues"/>
 </customproperties>
 <blendMode>0</blendMode>
 <featureBlendMode>0</featureBlendMode>
 <layerOpacity>1</layerOpacity>
 <SingleCategoryDiagramRenderer diagramType="Histogram" attributeLegend="1">
  <DiagramCategory backgroundColor="#ffffff" rotationOffset="270" lineSizeType="MM" sizeType="MM" minimumSize="0" penColor="#000000" minScaleDenominator="0" scaleDependency="Area" backgroundAlpha="255" scaleBasedVisibility="0" opacity="1" width="15" maxScaleDenominator="1e+08" barWidth="5" lineSizeScale="3x:0,0,0,0,0,0" penAlpha="255" enabled="0" penWidth="0" diagramOrientation="Up" height="15" sizeScale="3x:0,0,0,0,0,0" labelPlacementMethod="XHeight">
   <fontProperties description="MS Shell Dlg 2,7.8,-1,5,50,0,0,0,0,0" style=""/>
  </DiagramCategory>
 </SingleCategoryDiagramRenderer>
 <DiagramLayerSettings dist="0" zIndex="0" obstacle="0" priority="0" showAll="1" linePlacementFlags="18" placement="2">
  <properties>
   <Option type="Map">
    <Option value="" name="name" type="QString"/>
    <Option name="properties"/>
    <Option value="collection" name="type" type="QString"/>
   </Option>
  </properties>
 </DiagramLayerSettings>
 <geometryOptions geometryPrecision="0" removeDuplicateNodes="0">
  <activeChecks/>
  <checkConfiguration/>
 </geometryOptions>
 <fieldConfiguration>
  <field name="id">
   <editWidget type="TextEdit">
    <config>
     <Option/>
    </config>
   </editWidget>
  </field>
  <field name="comment">
   <editWidget type="TextEdit">
    <config>
     <Option/>
    </config>
   </editWidget>
  </field>
  <field name="autogenerated">
   <editWidget type="TextEdit">
    <config>
     <Option/>
    </config>
   </editWidget>
  </field>
 </fieldConfiguration>
 <aliases>
  <alias index="0" field="id" name=""/>
  <alias index="1" field="comment" name=""/>
  <alias index="2" field="autogenerated" name=""/>
 </aliases>
 <excludeAttributesWMS/>
 <excludeAttributesWFS/>
 <defaults>
  <default applyOnUpdate="0" field="id" expression=""/>
  <default applyOnUpdate="0" field="comment" expression=""/>
  <default applyOnUpdate="0" field="autogenerated" expression=""/>
 </defaults>
 <constraints>
  <constraint constraints="3" exp_strength="0" field="id" unique_strength="1" notnull_strength="1"/>
  <constraint constraints="0" exp_strength="0" field="comment" unique_strength="0" notnull_strength="0"/>
  <constraint constraints="0" exp_strength="0" field="autogenerated" unique_strength="0" notnull_strength="0"/>
 </constraints>
 <constraintExpressions>
  <constraint exp="" desc="" field="id"/>
  <constraint exp="" desc="" field="comment"/>
  <constraint exp="" desc="" field="autogenerated"/>
 </constraintExpressions>
 <expressionfields/>
 <attributeactions>
  <defaultAction value="{00000000-0000-0000-0000-000000000000}" key="Canvas"/>
 </attributeactions>
 <attributetableconfig sortExpression="" sortOrder="0" actionWidgetStyle="dropDown">
  <columns>
   <column width="-1" hidden="0" name="id" type="field"/>
   <column width="-1" hidden="0" name="comment" type="field"/>
   <column width="-1" hidden="0" name="autogenerated" type="field"/>
   <column width="-1" hidden="1" type="actions"/>
  </columns>
 </attributetableconfig>
 <conditionalstyles>
  <rowstyles/>
  <fieldstyles/>
 </conditionalstyles>
 <editform tolerant="1"></editform>
 <editforminit/>
 <editforminitcodesource>0</editforminitcodesource>
 <editforminitfilepath></editforminitfilepath>
 <editforminitcode><![CDATA[# -*- coding: utf-8 -*-
"""
QGIS forms can have a Python function that is called when the form is
opened.

Use this function to add extra logic to your forms.

Enter the name of the function in the "Python Init function"
field.
An example follows:
"""
from qgis.PyQt.QtWidgets import QWidget

def my_form_open(dialog, layer, feature):
	geom = feature.geometry()
	control = dialog.findChild(QWidget, "MyLineEdit")
]]></editforminitcode>
 <featformsuppress>0</featformsuppress>
 <editorlayout>generatedlayout</editorlayout>
 <editable>
  <field editable="1" name="autogenerated"/>
  <field editable="1" name="comment"/>
  <field editable="1" name="id"/>
 </editable>
 <labelOnTop>
  <field labelOnTop="0" name="autogenerated"/>
  <field labelOnTop="0" name="comment"/>
  <field labelOnTop="0" name="id"/>
 </labelOnTop>
 <widgets/>
 <previewExpression>id</previewExpression>
 <mapTip></mapTip>
 <layerGeometryType>1</layerGeometryType>
</qgis>
','<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1.1.0/StyledLayerDescriptor.xsd" xmlns:ogc="http://www.opengis.net/ogc" xmlns:se="http://www.opengis.net/se" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1.0">
 <NamedLayer>
  <se:Name>auxiliary_line</se:Name>
  <UserStyle>
   <se:Name>auxiliary_line</se:Name>
   <se:FeatureTypeStyle>
    <se:Rule>
     <se:Name>Single symbol</se:Name>
     <se:LineSymbolizer>
      <se:Stroke>
       <se:SvgParameter name="stroke">#424242</se:SvgParameter>
       <se:SvgParameter name="stroke-width">0.5</se:SvgParameter>
       <se:SvgParameter name="stroke-linejoin">round</se:SvgParameter>
       <se:SvgParameter name="stroke-linecap">round</se:SvgParameter>
      </se:Stroke>
     </se:LineSymbolizer>
     <se:LineSymbolizer>
      <se:Stroke>
       <se:GraphicStroke>
        <se:Graphic>
         <se:Mark>
          <se:WellKnownName>line</se:WellKnownName>
          <se:Fill>
           <se:SvgParameter name="fill">#ff0000</se:SvgParameter>
          </se:Fill>
          <se:Stroke>
           <se:SvgParameter name="stroke">#272727</se:SvgParameter>
           <se:SvgParameter name="stroke-width">1</se:SvgParameter>
          </se:Stroke>
         </se:Mark>
         <se:Size>4</se:Size>
        </se:Graphic>
        <se:Gap>
         <ogc:Literal>11</ogc:Literal>
        </se:Gap>
       </se:GraphicStroke>
      </se:Stroke>
     </se:LineSymbolizer>
    </se:Rule>
   </se:FeatureTypeStyle>
  </UserStyle>
 </NamedLayer>
</StyledLayerDescriptor>
',true,'Styling for RasterCaster auxiliary_line',NULL,NULL,'2019-03-13 21:57:09.992')
;

UPDATE layer_styles 
SET f_table_catalog = current_database(),
	update_time = now()
WHERE f_table_schema = 'rc' AND f_table_name IN ('surface', 'elevation_point', 'auxiliary_line')
;