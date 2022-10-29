<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" xmlns:sld="http://www.opengis.net/sld" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc" version="1.0.0">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>ndvi_diff_2019_2018_thr200_gradient7</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="ramp">
              <sld:ColorMapEntry color="#3ebebb" label="&lt;-0.4" quantity="-4000"/>
              <sld:ColorMapEntry color="#5bddda" label="-0.3" quantity="-3000"/>
              <sld:ColorMapEntry color="#80e4e2" label="-0.2" quantity="-2000" opacity="0.941176"/>
              <sld:ColorMapEntry color="#b8f0ef" label="-0.1" quantity="-1000" opacity="0.694118"/>
              <sld:ColorMapEntry color="#cbf4f3" label="-0.06" quantity="-600" opacity="0.603922"/>
              <sld:ColorMapEntry color="#e1f9f8" label="-0.02" quantity="-200" opacity="0.501961"/>
              <sld:ColorMapEntry color="#ffffff" label=">-0.02" quantity="-199" opacity="0"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>
