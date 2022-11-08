<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" xmlns:sld="http://www.opengis.net/sld" version="1.0.0" xmlns:gml="http://www.opengis.net/gml" xmlns:ogc="http://www.opengis.net/ogc">
  <UserLayer>
    <sld:LayerFeatureConstraints>
      <sld:FeatureTypeConstraint/>
    </sld:LayerFeatureConstraints>
    <sld:UserStyle>
      <sld:Name>ndvi_diff_2017_2016_thr200_gradient7</sld:Name>
      <sld:FeatureTypeStyle>
        <sld:Rule>
          <sld:RasterSymbolizer>
            <sld:ChannelSelection>
              <sld:GrayChannel>
                <sld:SourceChannelName>1</sld:SourceChannelName>
              </sld:GrayChannel>
            </sld:ChannelSelection>
            <sld:ColorMap type="ramp">
              <sld:ColorMapEntry color="#dac521" quantity="-10000" label="&lt;-0.4"/>
              <sld:ColorMapEntry color="#dac521" quantity="-4000" label="-0.4"/>
              <sld:ColorMapEntry color="#f9e43e" quantity="-3000" label="-0.3"/>
              <sld:ColorMapEntry color="#fbe968" opacity="0.941176" quantity="-2000" label="-0.2"/>
              <sld:ColorMapEntry color="#fcf3ab" opacity="0.694118" quantity="-1000" label="-0.1"/>
              <sld:ColorMapEntry color="#fdf5b5" opacity="0.67451" quantity="-900" label="-0.09"/>
              <sld:ColorMapEntry color="#fdf6bf" opacity="0.654902" quantity="-800" label="-0.08"/>
              <sld:ColorMapEntry color="#fdf6c2" opacity="0.631373" quantity="-700" label="-0.07"/>
              <sld:ColorMapEntry color="#fdf6c2" opacity="0.603922" quantity="-600" label="-0.06"/>
              <sld:ColorMapEntry color="#fdf8cd" opacity="0.580392" quantity="-500" label="-0.05"/>
              <sld:ColorMapEntry color="#fefadb" opacity="0.552941" quantity="-400" label="-0.04"/>
              <sld:ColorMapEntry color="#fefadc" opacity="0.52549" quantity="-300" label="-0.03"/>
              <sld:ColorMapEntry color="#fefadc" opacity="0.501961" quantity="-200" label="-0.02"/>
              <sld:ColorMapEntry color="#ffffff" opacity="0" quantity="-199" label=">-0.02"/>
            </sld:ColorMap>
          </sld:RasterSymbolizer>
        </sld:Rule>
      </sld:FeatureTypeStyle>
    </sld:UserStyle>
  </UserLayer>
</StyledLayerDescriptor>
