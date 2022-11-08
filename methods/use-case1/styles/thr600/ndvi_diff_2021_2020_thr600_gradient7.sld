<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" xmlns:sld="http://www.opengis.net/sld" version="1.0.0" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>ndvi_diff_2021_2020_thr600_gradient7</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="ramp">
              <sld:ColorMapEntry color="#903cbc" quantity="-10000" label="&lt;-0.4"/>
              <sld:ColorMapEntry color="#903cbc" quantity="-4000" label="-0.4"/>
              <sld:ColorMapEntry color="#ae59db" quantity="-3000" label="-0.3"/>
              <sld:ColorMapEntry color="#c17ee3" opacity="0.941176" quantity="-2000" label="-0.2"/>
              <sld:ColorMapEntry color="#dcb7f0" opacity="0.694118" quantity="-1000" label="-0.1"/>
              <sld:ColorMapEntry color="#e5c8f3" opacity="0.654902" quantity="-800" label="-0.08"/>
              <sld:ColorMapEntry color="#e6cbf4" opacity="0.603922" quantity="-600" label="-0.06"/>
              <sld:ColorMapEntry color="#ffffff" opacity="0" quantity="-599" label="&lt;-0.06"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>
