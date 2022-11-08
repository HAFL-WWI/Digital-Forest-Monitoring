<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" xmlns:sld="http://www.opengis.net/sld" version="1.0.0" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
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
              <sld:ColorMapEntry color="#3ebebb" quantity="-10000" label=">-0.4"/>
              <sld:ColorMapEntry color="#3ebebb" quantity="-4000" label="-0.4"/>
              <sld:ColorMapEntry color="#5bddda" quantity="-3000" label="-0.3"/>
              <sld:ColorMapEntry color="#80e4e2" opacity="0.941176" quantity="-2000" label="-0.2"/>
              <sld:ColorMapEntry color="#b8f0ef" opacity="0.694118" quantity="-1000" label="-0.1"/>
              <sld:ColorMapEntry color="#c0f2f1" opacity="0.67451" quantity="-900" label="-0.09"/>
              <sld:ColorMapEntry color="#c9f3f2" opacity="0.654902" quantity="-800" label="-0.08"/>
              <sld:ColorMapEntry color="#cbf4f3" opacity="0.631373" quantity="-700" label="-0.07"/>
              <sld:ColorMapEntry color="#cbf4f3" opacity="0.603922" quantity="-600" label="-0.06"/>
              <sld:ColorMapEntry color="#d4f6f5" opacity="0.580392" quantity="-500" label="-0.05"/>
              <sld:ColorMapEntry color="#e0f9f8" opacity="0.552941" quantity="-400" label="-0.04"/>
              <sld:ColorMapEntry color="#e1f9f8" opacity="0.52549" quantity="-300" label="-0.03"/>
              <sld:ColorMapEntry color="#e1f9f8" opacity="0.501961" quantity="-200" label="-0.02"/>
              <sld:ColorMapEntry color="#ffffff" opacity="0" quantity="-199" label="&lt;-0.02"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>
