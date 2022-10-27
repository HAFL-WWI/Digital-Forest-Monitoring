<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc" version="1.0.0">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>ndvi_diff_2022_2021_thr200_gradient7</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="ramp">
              <sld:ColorMapEntry color="#cf2d2d" label="&lt;-0.4" quantity="-10000"/>
              <sld:ColorMapEntry color="#cf2d2d" label="-0.4" quantity="-4000"/>
              <sld:ColorMapEntry color="#e83232" label="-0.35" quantity="-3500"/>
              <sld:ColorMapEntry color="#ed4a4a" label="-0.3" quantity="-3000"/>
              <sld:ColorMapEntry color="#f06060" label="-0.25" quantity="-2500"/>
              <sld:ColorMapEntry color="#f17272" label="-0.2" quantity="-2000" opacity="0.942"/>
              <sld:ColorMapEntry color="#f48a8a" label="-0.15" quantity="-1500" opacity="0.842924"/>
              <sld:ColorMapEntry color="#f7b0b0" label="-0.1" quantity="-1000" opacity="0.695338"/>
              <sld:ColorMapEntry color="#f8baba" label="-0.09" quantity="-900" opacity="0.676051"/>
              <sld:ColorMapEntry color="#f9c3c3" label="-0.08" quantity="-800" opacity="0.656764"/>
              <sld:ColorMapEntry color="#f9c6c6" label="-0.07" quantity="-700" opacity="0.632197"/>
              <sld:ColorMapEntry color="#f9c6c6" label="-0.06" quantity="-600" opacity="0.605371"/>
              <sld:ColorMapEntry color="#fad0d0" label="-0.05" quantity="-500" opacity="0.578531"/>
              <sld:ColorMapEntry color="#fcdddd" label="-0.04" quantity="-400" opacity="0.551705"/>
              <sld:ColorMapEntry color="#fcdede" label="-0.03" quantity="-300" opacity="0.526726"/>
              <sld:ColorMapEntry color="#fcdede" label="-0.02" quantity="-200" opacity="0.501961"/>
              <sld:ColorMapEntry color="#ffffff" label=">-0.02" quantity="-199" opacity="0"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>
