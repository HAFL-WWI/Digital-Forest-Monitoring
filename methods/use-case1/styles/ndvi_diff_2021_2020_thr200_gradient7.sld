<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc" version="1.0.0">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>ndvi_diff_2021_2020_thr200_gradient7</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="ramp">
              <sld:ColorMapEntry color="#903cbc" label="&lt;-0.4" quantity="-4000"/>
              <sld:ColorMapEntry color="#ae59db" label="-0.3" quantity="-3000"/>
              <sld:ColorMapEntry color="#c17ee3" label="-0.2" quantity="-2000" opacity="0.942"/>
              <sld:ColorMapEntry color="#dcb7f0" label="-0.1" quantity="-1000" opacity="0.695338"/>
              <sld:ColorMapEntry color="#e6cbf4" label="-0.06" quantity="-600" opacity="0.605371"/>
              <sld:ColorMapEntry color="#f0e1f8" label="-0.02" quantity="-200" opacity="0.501961"/>
              <sld:ColorMapEntry color="#ffffff" label=">-0.02" quantity="-199" opacity="0"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>
