<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis version="3.10.8-A Coruña" maxScale="0" minScale="1e+08" styleCategories="AllStyleCategories" hasScaleBasedVisibilityFlag="0">
  <flags>
    <Identifiable>1</Identifiable>
    <Removable>1</Removable>
    <Searchable>1</Searchable>
  </flags>
  <customproperties>
    <property key="WMSBackgroundLayer" value="false"/>
    <property key="WMSPublishDataSourceUrl" value="false"/>
    <property key="embeddedWidgets/count" value="0"/>
    <property key="identify/format" value="Value"/>
  </customproperties>
  <pipe>
    <rasterrenderer alphaBand="-1" classificationMin="-30000" type="singlebandpseudocolor" band="1" classificationMax="32767" opacity="1">
      <rasterTransparency>
        <singleValuePixelList>
          <pixelListEntry percentTransparent="100" min="-99" max="99"/>
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
        <colorrampshader colorRampType="INTERPOLATED" clip="0" classificationMode="2">
          <colorramp type="gradient" name="[source]">
            <prop v="202,0,32,255" k="color1"/>
            <prop v="5,113,176,255" k="color2"/>
            <prop v="0" k="discrete"/>
            <prop v="gradient" k="rampType"/>
            <prop v="0.25;244,165,130,255:0.5;247,247,247,255:0.75;146,197,222,255" k="stops"/>
          </colorramp>
          <item color="#ca0020" label="&lt; -4" value="-30000" alpha="255"/>
          <item color="#df5251" label="-3" value="-300" alpha="255"/>
          <item color="#f4a582" label="-2" value="-200" alpha="255"/>
          <item color="#f6cebd" label="-1" value="-100" alpha="255"/>
          <item color="#f7f7f7" label="0" value="0" alpha="0"/>
          <item color="#c5deeb" label="1" value="100" alpha="255"/>
          <item color="#92c5de" label="2" value="200" alpha="255"/>
          <item color="#4b9bc7" label="3" value="300" alpha="255"/>
          <item color="#0571b0" label="> 4" value="30000" alpha="255"/>
          <item color="#5f645f" label="Leerwert" value="32767" alpha="255"/>
        </colorrampshader>
      </rastershader>
    </rasterrenderer>
    <brightnesscontrast contrast="0" brightness="0"/>
    <huesaturation colorizeBlue="128" colorizeStrength="100" colorizeGreen="128" colorizeOn="0" colorizeRed="255" grayscaleMode="0" saturation="0"/>
    <rasterresampler maxOversampling="2"/>
  </pipe>
  <blendMode>0</blendMode>
</qgis>
