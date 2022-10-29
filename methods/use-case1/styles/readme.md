UC1 Styling
==============================================

To ensure a clearly distinguishable color pattern, which will be conistent for the first seven and every following year, a rainbow-color-cycle was developed (compare [issue#100](https://github.com/HAFL-WWI/Digital-Forest-Monitoring/issues/100) ). Basis are the following seven color tones:

```
/* OVERVIEW RAINBOW 1 - 7 */
--cg-red: #eb3333ff;
--deep-saffron: #f3942cff;
--yellow-pantone: #f8e025ff;
--mantis: #80c757ff;
--medium-turquoise: #46d8d5ff;
--iris: #4545d9ff;
--dark-orchid: #a444d6ff;
```

These base tones then were graduated in their "lightness" to ensure contrast. Less intense changes are additionally distinguished via opacity. The final color gradients (created in QGIS) were created using the following pattern:

| value						|	-1	|	0	|	1	|	2	|	3	|	4	|	5	|	6	|	7	|	8	|	9	|	10	|	11	|
|---------------------------|-------|-------|-------|-------|-------|-------|-------|-------|-------|-------|-------|-------|-------|
|gradient stop %			|	-1	|	0	|	15	|	27	|	45	|	60	|	70	|	80	|	85	|	90	|	95	|	100	| 101	|
|base color tint / shade %	|	-12	|	-12	|	0	|	12	|	24	|	36	|	48	|	60	|	72	|	72	|	84	|	84	|	#ffffff |
|opacity %					|	0	|	0	|	0	|	0	|	0	|	90	|	80	|	70	|	65	|	60	|	55	|	50	| 0	|
|NDVI value (approx)		| -1.0	| -0.4	| -0.35	| -0.3	| -0.25	| -0.2	| -0.15	| -0.1	| -0.08	| -0.06	| -0.04	| -0.02	| -0.0199	|
|in legend?					|	(L)	|	L	|		|	L	|		|	L	|		|	L	|		|	L	|		|	(L)	|	L	|

Originally, this was linerarly interpolated on ~40 stops +2 added pseudo stops, that were added after interpolation to ensure 100% transparency below a threshold and display of values larger than -0.4. But since the legend is automatically generated (in Geoserver/QGIS), stops were removed to allow for a condensed legend, making the color-curve "less round".

The colors were distributed for the complete negative spectrum (NDVI -0.4 to -0.02) to ensure consistency and compatibility with the feature of manual threshold-adjustment in the range -0.1 to -0.02 (in steps of -0.01). For default viewing the curve is "capped" (threshold = -0.06, respectively previous to Oct 2022 threshold = -0.1) and the NDVI-value of the last pseudo-stop adjusted accordingly (= thresholdvalue - 0.0001).

The base color tints were previously generated using a linear curve (through lightness), e.g. using this online-tool with a 12% step in tint/shade:
https://noeldelgado.github.io/shadowlord/#eb3333

Respective values are listed here:

```
/* GRADIENTS RAINBOW */
/* 1  --cg-red: #eb3333ff; */
tint 84%: #fcdede
tint 72%: #f9c6c6
tint 60%: #f7adad
tint 48%: #f59595
tint 36%: #f27c7c
tint 24%: #f06464
tint 12%: #ed4b4b
base 0%: #eb3333
shade 12%: #cf2d2d

/* 2  --deep-saffron: #f3942cff; */
tint 84%: #fdeedd
tint 72%: #fce1c4
tint 60%: #fad4ab
tint 48%: #f9c791
tint 36%: #f7bb78
tint 24%: #f6ae5f
tint 12%: #f4a145
base 0%: #f3942c
shade 12%: #d68227

/* 3 --yellow-pantone: #f8e025ff; */ 
tint84%: #fefadc
tint72%: #fdf6c2
tint60%: #fcf3a8
tint48%: #fbef8e
tint36%: #fbeb73
tint24%: #fae759
tint12%: #f9e43f
base0%: #f8e025
shade12%: #dac521

/* 4 --mantis: #80c757ff; */ 
tint84%: #ebf6e4
tint72%: #dbefd0
tint60%: #cce9bc
tint48%: #bde2a8
tint36%: #aedb93
tint24%: #9ed47f
tint12%: #8fce6b
base0%: #80c757
shade 12%: #71af4d

/* 5 --medium-turquoise: #46d8d5ff; */
tint84%: #e1f9f8
tint72%: #cbf4f3
tint60%: #b5efee
tint48%: #9febe9
tint36%: #89e6e4
tint24%: #72e1df
tint12%: #5cddda
base0%: #46d8d5
shade12%: #3ebebb

/* 6 --iris: #4545d9ff; */
tint84%: #e1e1f9
tint72%: #cbcbf4
tint60%: #b5b5f0
tint48%: #9e9eeb
tint36%: #8888e7
tint24%: #7272e2
tint12%: #5b5bde
base0%: #4545d9
shade 12%: #3d3dbf

/* 7 --dark-orchid: #a444d6ff; */
tint84%: #f0e1f8
tint72%: #e6cbf4
tint60%: #dbb4ef
tint48%: #d09eea
tint36%: #c587e5
tint24%: #ba71e0
tint12%: #af5adb
base0%: #a444d6
shade 12%: #903cbc
```