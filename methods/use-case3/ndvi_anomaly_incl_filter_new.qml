<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis hasScaleBasedVisibilityFlag="0" maxScale="0" styleCategories="AllStyleCategories" minScale="1e+08" version="3.14.16-Pi">
  <flags>
    <Identifiable>1</Identifiable>
    <Removable>1</Removable>
    <Searchable>1</Searchable>
  </flags>
  <temporal enabled="0" mode="0" fetchMode="0">
    <fixedRange>
      <start></start>
      <end></end>
    </fixedRange>
  </temporal>
  <customproperties>
    <property key="WMSBackgroundLayer" value="false"/>
    <property key="WMSPublishDataSourceUrl" value="false"/>
    <property key="embeddedWidgets/count" value="0"/>
    <property key="identify/format" value="Value"/>
  </customproperties>
  <pipe>
    <rasterrenderer nodataColor="" classificationMax="32767" classificationMin="-32766" opacity="1" band="1" alphaBand="-1" type="singlebandpseudocolor">
      <rasterTransparency>
        <singleValuePixelList>
          <pixelListEntry percentTransparent="100" max="99" min="-99"/>
        </singleValuePixelList>
      </rasterTransparency>
      <minMaxOrigin>
        <limits>None</limits>
        <extent>WholeRaster</extent>
        <statAccuracy>Estimated</statAccuracy>
        <cumulativeCutLower>0.02</cumulativeCutLower>
        <cumulativeCutUpper>0.98</cumulativeCutUpper>
        <stdDevFactor>2</stdDevFactor>
      </minMaxOrigin>
      <rastershader>
        <colorrampshader maximumValue="32767" classificationMode="2" minimumValue="-32766" clip="0" colorRampType="INTERPOLATED">
          <colorramp name="[source]" type="gradient">
            <prop k="color1" v="202,0,32,255"/>
            <prop k="color2" v="5,113,176,255"/>
            <prop k="discrete" v="0"/>
            <prop k="rampType" v="gradient"/>
            <prop k="stops" v="0.25;244,165,130,255:0.5;247,247,247,255:0.75;146,197,222,255"/>
          </colorramp>
          <item label="&lt; -5" color="#ca0020" value="-32766" alpha="255"/>
          <item label="-4" color="#da3c43" value="-400" alpha="255"/>
          <item label="-3" color="#e97867" value="-300" alpha="255"/>
          <item label="-2" color="#f5ad8d" value="-200" alpha="255"/>
          <item label="-1" color="#f6cbb7" value="-100" alpha="255"/>
          <item label="0" color="#f7e8e2" value="0" alpha="0"/>
          <item label="1" color="#cee8f3" value="100" alpha="255"/>
          <item label="2" color="#93cfea" value="200" alpha="255"/>
          <item label="3" color="#6baed2" value="300" alpha="255"/>
          <item label="4" color="#3487b3" value="400" alpha="255"/>
          <item label="> 5" color="#04669e" value="32766" alpha="255"/>
          <item label="Nicht genug Daten" color="#696e69" value="32767" alpha="255"/>
        </colorrampshader>
      </rastershader>
    </rasterrenderer>
    <brightnesscontrast contrast="0" brightness="0"/>
    <huesaturation saturation="0" colorizeOn="0" colorizeBlue="128" grayscaleMode="0" colorizeRed="255" colorizeGreen="128" colorizeStrength="100"/>
    <rasterresampler maxOversampling="2"/>
  </pipe>
  <blendMode>0</blendMode>
</qgis>
