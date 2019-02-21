extensions [gis]
globals[
  threshold
  rainfall-data
  raindays-data
  rain-days
  mati
  count-dry-days
  n-cols
  n-rows
  xll
  yll
  cell-size
  patches-selected
  patches-in-map
  fire-duration
  total-fire
]

breed [households household]
breed [fires fire]

households-own[
  destination-patch
  power
]

patches-own[
  map-value
  map-value-biomass
  selection-index
  water-table
  vulnerability
  idx-canal-distance
  idx-land-use
  idx-land-status
  burned?
  water-level-first
  biomass
;  evap-rate
]

fires-own[
  duration
  fuel
]

to setup
  ca
  setup-function input-file
  set patches-in-map patches with [map-value != -9999]
  ask patches-in-map [
    set burned? false
    ;set idx-land-status random 2
    ;set idx-land-use random 3
  ]
  ;setup-function-biomass input-file-biomass
;  set-evap-biomass
  set-selection-index
  set-water-table
  set-households
  set-vulnerability
  set-rainfall
  reset-ticks
end

to go
  tick
  ask households
  [
    ifelse ticks = 1
    [search-land]
   [
    ifelse [burned?] of patch-here = true
      [search-land]
      [check-ignite]
   ]
  ]
  update-water-table
  update-raindays
  set-vulnerability
  count-kering

  if ticks >= 365 [stop]
end

to set-households
  repeat farmers[
    ask one-of initial-position with [any? households-here = false][
  sprout-households 1[
      set shape "person"
      set size 20
      set power 1 + random 3
        set xcor [pxcor] of myself
        set ycor [pycor] of myself
    ]
  ]]
;  set patches-selected patches with [any? households-here = true]
end

to update-water-table
   ask patches[
    ifelse item (ticks - 1) raindays-data = 1 [
      set water-table water-table - item (ticks - 1) rainfall-data
    ]
    [
      set water-table water-table + evapotranspiration
    ]
    if (water-table < min-water-table)
    [
      set water-table min-water-table
    ]

    if (water-table > max-water-table)
    [
       set water-table max-water-table
    ]
  ]
end

to count-kering
  ifelse ( item (ticks - 1) raindays-data = -1)
  [
    set count-dry-days count-dry-days + 1
  ]
  [
    set count-dry-days 0
  ]
end

to update-raindays
  set rain-days item (ticks - 1) rainfall-data + rain-days
end

to set-selection-index
    ask patches[
    set selection-index 1 + random 3 ;round ((idx-land-use + idx-land-status) / 2)
    ]
end

;inisialisasi water level
to set-water-table ;0 - 0.43
  ask patches
  [
;    set water-level-first (0.6 * 0.66 * peat-depth * 0.9) + (0.4 * 0.33 * peat-depth * 0.9) * canal-water-level
    if map-value = 1 [set water-table 0.38 + random-float 0.02 ]
    if map-value = 2 [set water-table 0.36 + random-float 0.02 ]
    if map-value = 3 [set water-table 0.34 + random-float 0.02]
    if map-value = 4 [set water-table 0.32 + random-float 0.02]
    if map-value = 5 [set water-table 0.30 + random-float 0.02]
    if map-value = 6 [set water-table 0.28 + random-float 0.02]
    if map-value = 7 [set water-table 0.26 + random-float 0.02]
    if map-value = 8 [set water-table 0.24 + random-float 0.02]
    if map-value = 9 [set water-table 0.22 + random-float 0.02]
    if map-value = 10 [set water-table 0.20 + random-float 0.02]
    if map-value = 11 [set water-table 0.18 + random-float 0.02]
    if map-value = 12 [set water-table 0.16 + random-float 0.02]
    if map-value = 13 [set water-table 0.14 + random-float 0.02]
    if map-value = 14 [set water-table 0.12 + random-float 0.02]
    if map-value = 15 [set water-table 0.10 + random-float 0.02]
    if map-value = 16 [set water-table 0.08 + random-float 0.02]
    if map-value = 17 [set water-table 0.06 + random-float 0.02]
    if map-value = 18 [set water-table 0.04 + random-float 0.02]
    if map-value = 19 [set water-table 0.02 + random-float 0.02]
    if map-value = 20 [set water-table 0 + random-float 0.02]
  ]
end

;to set-evap-biomass
;  ask patches-in-map
;  [
;    set biomass map-value-biomass
;    set evap-rate evapotranspiration * (biomass / 15)
;  ]
;end

to set-vulnerability
  ask patches-in-map ;patches-in-map
  [
    if water-table >= dry-threshold ;dry
    [
      set vulnerability 1
    ]
    if water-table <= dry-threshold ;wet
    [
      set vulnerability 0
      ask fires-here [
        set mati mati + 1
        set fire-duration duration
        die
      ]
     ]
  ]
end

to set-rainfall
  ask patches [set rain-days 0]

  set rainfall-data [] file-open "rainfall3.txt"
  while [not file-at-end?] [set rainfall-data lput file-read rainfall-data]
  file-close

  set raindays-data [] file-open "raindays.txt"
  while [not file-at-end?] [set raindays-data lput file-read raindays-data]
  file-close
end

to search-land
  set destination-patch 0
  if [burned?] of patch-here = true and any? target-destination
  [
    set destination-patch one-of target-destination
    move-to destination-patch
  ]
  check-ignite
end

to check-ignite
  ask patch-here [
      if vulnerability = 1 and count-dry-days >= mindays-decide-ignite and random-float 1 < ignite-probability
      [
        ignite
      ]
    ]
end

to-report target-destination
  report patches-in-map with [selection-index > 2 and distance myself <= max-distance-to-ignite and burned? = false]
end

to-report initial-position
  report patches-in-map with [selection-index > 2 and burned? = false]
end

to ignite
  if not any? fires-here and burned? = false
  [
    sprout-fires 1
    [
      set duration 1
      set color red
      set burned? true
      set size 20
    ]
    ask households-here [
      set power power - 1
      if power = 0
      [die]
    ]
    set total-fire total-fire + 1
    set selection-index 0
  ]
end

to setup-function [m]
  read-map-attributes m
  read-input-maps m
  display-map
end

to setup-function-biomass [m]
  read-map-attributes m
  read-input-map-biomass m
end

to read-map-attributes[m]
  let data-source word "input map/" m
  file-open data-source
  set n-cols read-from-string remove "NCOLS" file-read-line
  set n-rows read-from-string
  remove "NROWS" file-read-line
  set xll read-from-string remove "XLLCORNER" file-read-line
  set yll read-from-string remove "YLLCORNER" file-read-line
  set cell-size read-from-string remove "CELLSIZE"file-read-line
  file-close
  resize-map
end

to resize-map
  resize-world 0 n-cols 0 n-rows
  set-patch-size 3 / cell-size
end

to fire-spread
end

to read-input-maps[m]
  let data-source word "input map/" m
  let input-map read-map data-source
  gis:apply-raster input-map map-value
  ask patches
  [set map-value ifelse-value (map-value <= 0 or map-value >= 0)
  [map-value]
  [-9999]]
end

to read-input-map-biomass[m]
  let data-source word "input map/" m
  let input-map read-map data-source
  gis:apply-raster input-map map-value-biomass
  ask patches
  [set map-value-biomass ifelse-value (map-value-biomass <= 0 or map-value-biomass >= 0)
  [map-value-biomass]
  [-9999]]
end

to-report read-map[m]
  let raster-map gis:load-dataset m
  report raster-map
end

to display-map
  ask patches with[map-value = 1] [set pcolor 80]
  ask patches with[map-value = 2] [set pcolor 81]
  ask patches with[map-value = 3] [set pcolor 82]
  ask patches with[map-value = 4] [set pcolor 83]
  ask patches with[map-value = 5] [set pcolor 84]
  ask patches with[map-value = 6] [set pcolor 85]
  ask patches with[map-value = 7] [set pcolor 86]
  ask patches with[map-value = 8] [set pcolor 87]
  ask patches with[map-value = 9] [set pcolor 88]
  ask patches with[map-value = 10] [set pcolor 89]
  ask patches with[map-value = 11] [set pcolor 90]
  ask patches with[map-value = 12] [set pcolor 91]
  ask patches with[map-value = 13] [set pcolor 92]
  ask patches with[map-value = 14] [set pcolor 93]
  ask patches with[map-value = 15] [set pcolor 94]
  ask patches with[map-value = 16] [set pcolor 95]
  ask patches with[map-value = 17] [set pcolor 96]
  ask patches with[map-value = 18] [set pcolor 97]
  ask patches with[map-value = 19] [set pcolor 98]
  ask patches with[map-value = 20] [set pcolor 99]
end
@#$#@#$#@
GRAPHICS-WINDOW
217
10
601
464
-1
-1
0.03
1
1
1
1
1
0
0
0
1
0
563
0
667
0
0
1
ticks
30.0

BUTTON
15
16
78
49
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
95
16
158
49
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
17
61
189
94
farmers
farmers
0
200
100.0
20
1
NIL
HORIZONTAL

PLOT
614
142
951
293
fire occurence
NIL
NIL
0.0
10.0
0.0
8.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count fires / 9"

MONITOR
814
13
871
58
fires
count fires
3
1
11

MONITOR
814
68
883
113
dead fires
mati
17
1
11

SLIDER
16
105
189
138
dry-threshold
dry-threshold
0.1
1
0.4
0.01
1
NIL
HORIZONTAL

SLIDER
15
151
189
184
max-distance-to-ignite
max-distance-to-ignite
0
300
120.0
30
1
NIL
HORIZONTAL

SLIDER
15
198
187
231
ignite-probability
ignite-probability
0
1
0.2
0.1
1
NIL
HORIZONTAL

SLIDER
14
246
191
279
evapotranspiration
evapotranspiration
0.003
0.005
0.0042
0.0002
1
NIL
HORIZONTAL

PLOT
612
310
948
499
water table dynamics
NIL
NIL
0.0
2.0
0.0
1.0
true
true
"" ""
PENS
"water-level" 1.0 0 -15040220 true "" "plot mean [0 - water-table] of patches"
"rainfall" 1.0 0 -11033397 true "" "if ticks > 1 [ plot item (ticks - 1) rainfall-data ]"

SLIDER
617
11
789
44
mindays-decide-ignite
mindays-decide-ignite
0
10
3.0
1
1
NIL
HORIZONTAL

SLIDER
616
51
788
84
max-water-table
max-water-table
0.1
1
1.0
0.1
1
NIL
HORIZONTAL

CHOOSER
14
294
209
339
input-file
input-file
"rastert_moistur1.asc" "biomass1.asc"
0

SLIDER
616
98
788
131
min-water-table
min-water-table
0
1
0.0
0.1
1
NIL
HORIZONTAL

CHOOSER
16
353
209
398
input-file-biomass
input-file-biomass
"biomass1.asc"
0

MONITOR
892
12
954
57
total-fire
total-fire
17
1
11

MONITOR
894
72
951
117
farmers
count households
17
1
11

MONITOR
16
417
73
462
powers
sum [power] of households
17
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="farmers" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count total-fire</metric>
    <enumeratedValueSet variable="dry-threshold">
      <value value="0.42"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="farmers">
      <value value="10"/>
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
      <value value="50"/>
      <value value="60"/>
      <value value="70"/>
      <value value="80"/>
      <value value="90"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-water-table">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="input-file">
      <value value="&quot;rastert_moistur1.asc&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mindays-decide-ignite">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-water-table">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ignite-probability">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evapotranspiration">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="input-file-biomass">
      <value value="&quot;biomass1.asc&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-distance-to-ignite">
      <value value="23"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
