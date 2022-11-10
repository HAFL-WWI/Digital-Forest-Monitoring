<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis hasScaleBasedVisibilityFlag="0" maxScale="0" version="3.16.11-Hannover" minScale="1e+08" styleCategories="AllStyleCategories">
  <flags>
    <Identifiable>1</Identifiable>
    <Removable>1</Removable>
    <Searchable>1</Searchable>
  </flags>
  <temporal fetchMode="0" enabled="0" mode="0">
    <fixedRange>
      <start></start>
      <end></end>
    </fixedRange>
  </temporal>
  <customproperties/>
  <pipe>
    <provider>
      <resampling maxOversampling="2" enabled="false" zoomedOutResamplingMethod="nearestNeighbour" zoomedInResamplingMethod="nearestNeighbour"/>
    </provider>
    <rasterrenderer nodataColor="" opacity="1" alphaBand="-1" type="singlebandpseudocolor" band="1" classificationMin="-4000" classificationMax="-599">
      <rasterTransparency/>
      <minMaxOrigin>
        <limits>None</limits>
        <extent>WholeRaster</extent>
        <statAccuracy>Estimated</statAccuracy>
        <cumulativeCutLower>0.02</cumulativeCutLower>
        <cumulativeCutUpper>0.98</cumulativeCutUpper>
        <stdDevFactor>2</stdDevFactor>
      </minMaxOrigin>
      <rastershader>
        <colorrampshader clip="0" labelPrecision="0" minimumValue="-4000" classificationMode="2" maximumValue="-599" colorRampType="INTERPOLATED">
          <colorramp type="gradient" name="[source]">
            <prop v="61,61,191,255" k="color1"/>
            <prop v="225,225,249,128" k="color2"/>
            <prop v="0" k="discrete"/>
            <prop v="gradient" k="rampType"/>
            <prop v="0.15;69,69,217,0:0.27;91,91,222,0:0.419574;114,114,226,0:0.6;136,136,231,0:0.7;158,158,235,0:0.780426;181,181,240,0:0.85;203,203,244,0:0.9;203,203,244,0:0.95;225,225,249,0" k="stops"/>
          </colorramp>
          <item value="-4000" color="#3d3dbf" label=">-0.4" alpha="255"/>
          <item value="-3000" color="#5a5ade" label="-0.3" alpha="255"/>
          <item value="-2000" color="#7f7fe5" label="-0.2" alpha="240"/>
          <item value="-1000" color="#b8b8f1" label="-0.1" alpha="177"/>
          <item value="-900" color="#c0c0f2" label="-0.09" alpha="172"/>
          <item value="-800" color="#c9c9f4" label="-0.08" alpha="167"/>
          <item value="-700" color="#cbcbf4" label="-0.07" alpha="161"/>
          <item value="-600" color="#cbcbf4" label="-0.06" alpha="154"/>
          <item value="-599" color="#ffffff" label="&lt;-0.06" alpha="0"/>
        </colorrampshader>
      </rastershader>
    </rasterrenderer>
    <brightnesscontrast contrast="0" gamma="1" brightness="0"/>
    <huesaturation saturation="0" colorizeRed="255" colorizeStrength="100" colorizeOn="0" colorizeGreen="128" grayscaleMode="0" colorizeBlue="128"/>
    <rasterresampler maxOversampling="2"/>
    <resamplingStage>resamplingFilter</resamplingStage>
  </pipe>
  <blendMode>0</blendMode>
</qgis>
