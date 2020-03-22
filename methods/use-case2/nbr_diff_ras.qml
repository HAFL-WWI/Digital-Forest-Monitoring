<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis maxScale="0" styleCategories="AllStyleCategories" version="3.4.5-Madeira" hasScaleBasedVisibilityFlag="0" minScale="1e+08">
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
    <rasterrenderer classificationMax="0" type="singlebandpseudocolor" alphaBand="-1" band="1" opacity="1" classificationMin="-100">
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
        <colorrampshader classificationMode="2" clip="0" colorRampType="INTERPOLATED">
          <colorramp name="[source]" type="gradient">
            <prop v="0,0,4,255" k="color1"/>
            <prop v="252,253,191,255" k="color2"/>
            <prop v="0" k="discrete"/>
            <prop v="gradient" k="rampType"/>
            <prop v="0.0196078;2,2,11,255:0.0392157;5,4,22,255:0.0588235;9,7,32,255:0.0784314;14,11,43,255:0.0980392;20,14,54,255:0.117647;26,16,66,255:0.137255;33,17,78,255:0.156863;41,17,90,255:0.176471;49,17,101,255:0.196078;57,15,110,255:0.215686;66,15,117,255:0.235294;74,16,121,255:0.254902;82,19,124,255:0.27451;90,22,126,255:0.294118;98,25,128,255:0.313725;106,28,129,255:0.333333;114,31,129,255:0.352941;121,34,130,255:0.372549;129,37,129,255:0.392157;137,40,129,255:0.411765;145,43,129,255:0.431373;153,45,128,255:0.45098;161,48,126,255:0.470588;170,51,125,255:0.490196;178,53,123,255:0.509804;186,56,120,255:0.529412;194,59,117,255:0.54902;202,62,114,255:0.568627;210,66,111,255:0.588235;217,70,107,255:0.607843;224,76,103,255:0.627451;231,82,99,255:0.647059;236,88,96,255:0.666667;241,96,93,255:0.686275;244,105,92,255:0.705882;247,114,92,255:0.72549;249,123,93,255:0.745098;251,133,96,255:0.764706;252,142,100,255:0.784314;253,152,105,255:0.803922;254,161,110,255:0.823529;254,170,116,255:0.843137;254,180,123,255:0.862745;254,189,130,255:0.882353;254,198,138,255:0.901961;254,207,146,255:0.921569;254,216,154,255:0.941176;253,226,163,255:0.960784;253,235,172,255:0.980392;252,244,182,255" k="stops"/>
          </colorramp>
          <item color="#665c5c" alpha="255" label="-100" value="-100"/>
          <item color="#02020b" alpha="255" label="-98" value="-98.0392156862745"/>
          <item color="#050416" alpha="255" label="-96.1" value="-96.078431372549"/>
          <item color="#090720" alpha="255" label="-94.1" value="-94.1176470588235"/>
          <item color="#0e0b2b" alpha="255" label="-92.2" value="-92.156862745098"/>
          <item color="#140e36" alpha="255" label="-90.2" value="-90.1960784313726"/>
          <item color="#1a1042" alpha="255" label="-88.2" value="-88.2352941176471"/>
          <item color="#21114e" alpha="255" label="-86.3" value="-86.2745098039216"/>
          <item color="#29115a" alpha="255" label="-84.3" value="-84.3137254901961"/>
          <item color="#311165" alpha="255" label="-82.4" value="-82.3529411764706"/>
          <item color="#390f6e" alpha="255" label="-80.4" value="-80.3921568627451"/>
          <item color="#420f75" alpha="255" label="-78.4" value="-78.4313725490196"/>
          <item color="#4a1079" alpha="255" label="-76.5" value="-76.4705882352941"/>
          <item color="#52137c" alpha="255" label="-74.5" value="-74.5098039215686"/>
          <item color="#5a167e" alpha="255" label="-72.5" value="-72.5490196078431"/>
          <item color="#621980" alpha="255" label="-70.6" value="-70.5882352941177"/>
          <item color="#6a1c81" alpha="255" label="-68.6" value="-68.6274509803922"/>
          <item color="#721f81" alpha="255" label="-66.7" value="-66.6666666666667"/>
          <item color="#792282" alpha="255" label="-64.7" value="-64.7058823529412"/>
          <item color="#812581" alpha="255" label="-62.7" value="-62.7450980392157"/>
          <item color="#892881" alpha="255" label="-60.8" value="-60.7843137254902"/>
          <item color="#912b81" alpha="255" label="-58.8" value="-58.8235294117647"/>
          <item color="#992d80" alpha="255" label="-56.9" value="-56.8627450980392"/>
          <item color="#a1307e" alpha="255" label="-54.9" value="-54.9019607843137"/>
          <item color="#aa337d" alpha="255" label="-52.9" value="-52.9411764705882"/>
          <item color="#b2357b" alpha="255" label="-51" value="-50.9803921568627"/>
          <item color="#ba3878" alpha="255" label="-49" value="-49.0196078431373"/>
          <item color="#c23b75" alpha="255" label="-47.1" value="-47.0588235294118"/>
          <item color="#ca3e72" alpha="255" label="-45.1" value="-45.0980392156863"/>
          <item color="#d2426f" alpha="255" label="-43.1" value="-43.1372549019608"/>
          <item color="#d9466b" alpha="255" label="-41.2" value="-41.1764705882353"/>
          <item color="#e04c67" alpha="255" label="-39.2" value="-39.2156862745098"/>
          <item color="#e75263" alpha="255" label="-37.3" value="-37.2549019607843"/>
          <item color="#ec5860" alpha="255" label="-35.3" value="-35.2941176470588"/>
          <item color="#f1605d" alpha="255" label="-33.3" value="-33.3333333333333"/>
          <item color="#f4695c" alpha="255" label="-31.4" value="-31.3725490196078"/>
          <item color="#f7725c" alpha="255" label="-29.4" value="-29.4117647058824"/>
          <item color="#f97b5d" alpha="255" label="-27.5" value="-27.4509803921569"/>
          <item color="#fb8560" alpha="255" label="-25.5" value="-25.4901960784314"/>
          <item color="#fc8e64" alpha="255" label="-23.5" value="-23.5294117647059"/>
          <item color="#fd9869" alpha="255" label="-21.6" value="-21.5686274509804"/>
          <item color="#fea16e" alpha="255" label="-19.6" value="-19.6078431372549"/>
          <item color="#feaa74" alpha="255" label="-17.6" value="-17.6470588235294"/>
          <item color="#feb47b" alpha="255" label="-15.7" value="-15.6862745098039"/>
          <item color="#febd82" alpha="255" label="-13.7" value="-13.7254901960784"/>
          <item color="#fec68a" alpha="255" label="-11.8" value="-11.7647058823529"/>
          <item color="#fecf92" alpha="0" label="-9.8" value="-9.80392156862746"/>
          <item color="#fed89a" alpha="0" label="-7.84" value="-7.84313725490196"/>
          <item color="#fde2a3" alpha="0" label="-5.88" value="-5.88235294117648"/>
          <item color="#fdebac" alpha="0" label="-3.92" value="-3.92156862745098"/>
          <item color="#fcf4b6" alpha="0" label="-1.96" value="-1.9607843137255"/>
          <item color="#fcfdbf" alpha="0" label="0" value="0"/>
        </colorrampshader>
      </rastershader>
    </rasterrenderer>
    <brightnesscontrast brightness="0" contrast="0"/>
    <huesaturation colorizeOn="0" colorizeGreen="128" saturation="0" colorizeRed="255" colorizeStrength="100" colorizeBlue="128" grayscaleMode="0"/>
    <rasterresampler maxOversampling="2"/>
  </pipe>
  <blendMode>0</blendMode>
</qgis>
