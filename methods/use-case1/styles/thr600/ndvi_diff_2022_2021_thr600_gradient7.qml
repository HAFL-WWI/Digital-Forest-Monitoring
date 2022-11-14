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
    <rasterrenderer nodataColor="" opacity="1" alphaBand="-1" type="singlebandpseudocolor" band="1" classificationMin="-4000" classificationMax="-600">
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
        <colorrampshader clip="0" labelPrecision="0" minimumValue="-4000" classificationMode="2" maximumValue="-600" colorRampType="INTERPOLATED">
          <colorramp type="gradient" name="[source]">
            <prop v="207,45,45,255" k="color1"/>
            <prop v="255,255,255,0" k="color2"/>
            <prop v="0" k="discrete"/>
            <prop v="gradient" k="rampType"/>
            <prop v="0.147059;232,50,50,0:0.294118;237,74,74,0:0.441176;240,96,96,0:0.588235;241,114,114,0:0.735294;244,138,138,0:0.882353;247,176,176,0:0.911765;248,186,186,0:0.941176;249,195,195,0:0.970588;249,198,198,0:0.999706;249,198,198,0" k="stops"/>
          </colorramp>
          <item value="-4000" color="#cf2d2d" label=">-0.4" alpha="255"/>
          <item value="-3500" color="#e83232" label="-0.35" alpha="255"/>
          <item value="-3000" color="#ed4a4a" label="-0.3" alpha="255"/>
          <item value="-2500" color="#f06060" label="-0.25" alpha="255"/>
          <item value="-2000" color="#f17272" label="-0.2" alpha="240"/>
          <item value="-1500" color="#f48a8a" label="-0.15" alpha="215"/>
          <item value="-1000" color="#f7b0b0" label="-0.1" alpha="177"/>
          <item value="-900" color="#f8baba" label="-0.09" alpha="172"/>
          <item value="-800" color="#f9c3c3" label="-0.08" alpha="167"/>
          <item value="-700" color="#f9c6c6" label="-0.07" alpha="161"/>
          <item value="-601" color="#f9c6c6" label="-0.06" alpha="154"/>
          <item value="-600" color="#ffffff" label="&lt;-0.06" alpha="0"/>
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
