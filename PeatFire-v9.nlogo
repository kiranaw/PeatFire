__includes["globals.nls" "calculation.nls"]

extensions [csv gis]

breed [households household]
breed [fires fire]
breed [below-fires below-fire]

households-own[
  destination-patch
  power
]

patches-own[
  selection-index
  water-table
  vulnerability
  burning? ; if TRUE = fire has been ignited and patch is burning
  biomass
  left-biomass
  left-biomass-below
  evap-rate
  direction
  probability
  inundated?
  fire-to-patch
  in-reserve?
  p-spread-below
  burnt? ; if TRUE = all biomass burnt out
  burnval
]

to setup
  ca
  set-biomass
  set-wtd
  set-biomass-below
  set-evap-rate
  set-burn-status
  set-selection-index
  set-households
  set-update-vulnerability
  set-rainfall
  set-lists
  reset-ticks
end

to go
  if ticks = 365 [stop]
    reset-total-fires
    tick
    search-and-ignite
    fire-process
    fire-spread
    count-fires
    update-water-table
    update-raindays
    set-update-vulnerability
    sum-dry-days
    save-fires-ticks
end

to set-households
  repeat frm[
    ask one-of initial-position with [any? households-here = false and in-reserve? = false]
    [
      sprout-households 1[
        set shape "person"
        set color blue + 2
        set size 3
        set power round(random-normal-in-bounds frp 1 0 4)
        set xcor [pxcor] of myself
        set ycor [pycor] of myself
        hide-turtle
      ]
  ]]
end

to search-and-ignite
  ask households
  [
      ifelse [burning?] of patch-here = true
      [search-land]
      [check-ignite]
  ]
end

to set-burn-status
  ask patches
  [
    set burning? false ; no patch is being ignited
    set burnt? false ; no patch is burnt (run out of biomass)
  ]
end

to update-water-table
   ask patches[
    ifelse item (ticks - 1) raindays-data = 1 [
      set water-table water-table - item (ticks - 1) rainfall-data
    ]
    [
      set water-table water-table + evap-rate
    ]
    if water-table < -0.5
    [
      set water-table -0.5
    ]
    if (water-table > 1)
    [
       set water-table 1
    ]
    set-ind
  ]
end

to sum-dry-days
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
    set selection-index 1 + random 3
    ]
end

to set-update-vulnerability
  ask patches
  [
    if water-table >= dth ;dry
    [
      set vulnerability 1
    ]
    if water-table <= dth ;wet
    [
      set vulnerability 0
    ]
  ]
end

to fire-process
  ask patches
  [
    if any? fires-here and burnt? = FALSE
    [
      set left-biomass left-biomass - bbr
      if left-biomass <= 0
      [
        set burnt? TRUE
        set burnt-patches burnt-patches + 1
      ]
    ]
    if any? below-fires-here
    [
      set left-biomass-below left-biomass-below - bbr
      if (vulnerability = 0 or left-biomass-below <= 0)
      [
        terminate-below-fire
      ]
    ]
    if (burnt? = TRUE or inundated? = true) and any? fires-here
    [
      terminate-above-fire
      set burning? false
    ]
  ]
end

to fire-spread
  ask patches with [any? fires-here]
  [
    if not any? below-fires-here and vulnerability = 1 and left-biomass-below > 0
    [
      ignite-below
    ]
    if spread-above? = true
    [
      ifelse spread-to-eight? = true
      [
        ask neighbors
        [
          set fire-to-patch towards myself
          let prob calculate-probability wind-direction-degree fire-to-patch
          if prob = 0 [set prob 0.01]
          set probability prob * wsp
          if random-float 1 < probability and not any? fires-here and left-biomass > 0 and inundated? = false
          [
            spread-above
          ]
        ]
      ]
      [
        ask neighbors4
        [
          set fire-to-patch towards myself
          let prob calculate-probability wind-direction-degree fire-to-patch
          if prob = 0 [set prob 0.01]
          set probability prob * wsp
          if random-float 1 < probability and not any? fires-here and left-biomass > 0 and inundated? = false
          [
            spread-above
          ]
        ]
      ]
    ]
  ]
  ask patches with [any? below-fires-here]
  [
    if left-biomass > 0 and not any? fires-here
    [
      ignite-above-from-below
    ]
    ifelse spread-to-eight? = true
    [
      if random-float 1 < psb and spread-below? = true
      [
        ask neighbors
        [
          if vulnerability = 1 and left-biomass-below > 0 and not any? below-fires-here
          [
            spread-below
          ]
        ]
      ]
    ]
    [
      if random-float 1 < psb and spread-below? = true
      [
        ask neighbors4
        [
          if vulnerability = 1 and left-biomass-below > 0 and not any? below-fires-here
          [
            spread-below
          ]
        ]
      ]
    ]
  ]
end

to-report calculate-probability [wind-direction fire-patch]
  let remainder-degree abs (wind-direction - fire-patch)
  ifelse remainder-degree > 180
  [report abs (remainder-degree - 360) / 360]
  [report remainder-degree / 360]
end

to terminate-above-fire
  ask fires-here
  [
     set pcolor black
     die
  ]
end

to terminate-below-fire
  ask below-fires-here
  [
     set pcolor black
     die
  ]
end

to set-rainfall
  ask patches [set rain-days 0]

  ifelse random-rainfall? = FALSE
  [
    set rainfall-data []
    file-open "rainfall.txt"
    while [not file-at-end?] [set rainfall-data lput file-read rainfall-data]
    file-close

    set raindays-data []
    file-open "raindays.txt"
    while [not file-at-end?] [set raindays-data lput file-read raindays-data]
    file-close
  ]
  [
    set rainfall-data []
    set raindays-data []
    let r 0

    file-open "rainfall15y.csv"
    let result csv:from-row file-read-line
    while [ not file-at-end? ] [
      let row (csv:from-row file-read-line ";")
      let avg item 0 row
      let std item 1 row
      let maks item 2 row
      let alpha 0
      let lambda 0
      if rain-distribution = "normal"
      [set r precision random-normal-in-bounds avg std 0 maks 3]
      if rain-distribution = "gamma" and std > 0 and avg > 0
      [
        set lambda 0
        set alpha (avg * avg) / (std ^ 2)
        set lambda 1 / ((std ^ 2) / avg)
        set r precision random-gamma-in-bounds alpha lambda 0 maks 3
      ]
      set rainfall-data lput r rainfall-data
      ifelse r > 0
      [set raindays-data lput 1 raindays-data]
      [set raindays-data lput -1 raindays-data]
    ]
    file-close
  ]
end

to search-land
  set destination-patch 0
  if [burning?] of patch-here = true and any? target-destination
  [
    set destination-patch one-of target-destination
    move-to destination-patch
  ]
  check-ignite
end

to check-ignite
  ask patch-here [
      if biomass > 0 and count-dry-days >= dbi and random-float 1 < igp and inundated? = false;and vulnerability = 1
      [
        ignite-above
      ]
    ]
end

to-report target-destination
  report patches with [selection-index > 2 and distance myself <= dst and burning? = false]
end

to-report initial-position
  report patches with [selection-index > 2 and burning? = false]
end

to ignite-above
  if not any? fires-here and burning? = false
  [
    sprout-fires 1
    [
      set color red
      set burning? true
      set size 2
      set shape "fire"
    ]
    ask households-here [
      ifelse power = 0
      [die]
      [set power power - 1]
    ]
    set total-fire-above total-fire-above + 1
    set selection-index 0
  ]
end

to ignite-above-from-below
  if not any? fires-here and burning? = false
  [
    sprout-fires 1
    [
      set color pink
      set burning? true
      set size 2
      set shape "fire"
    ]
    set total-fire-above total-fire-above + 1
    set selection-index 0
  ]
end

to ignite-below
  sprout-below-fires 1
    [
      set color violet
      set size 2
      set shape "fire"
    ]
  set total-below-fire total-below-fire + 1
end

to spread-above
  sprout-fires 1
  [
     set shape "fire"
     set size 1
     set color red
  ]
  set total-fire-above total-fire-above + 1
end

to spread-below
  sprout-below-fires 1
  [
     set shape "fire"
     set size 1
     set color violet
  ]
  set total-below-fire total-below-fire + 1
end

to set-wtd
  ask patches
  [
    set water-table random-normal-in-bounds wtd 0.1 -0.5 1
    set pcolor round (53 + (water-table))
    set-ind
    set in-reserve? false
  ]
end

to set-ind
  ifelse water-table < ind
    [ set inundated? true ]
    [ set inundated? false ]
end

to set-biomass
  ask patches
  [
    set biomass precision (random-normal-in-bounds bia 1 0 1) 1
    set left-biomass biomass * 10
  ]
end

to set-biomass-below
  ask patches
  [
    set biomass precision (random-normal-in-bounds bib 1 0 1) 1
    set left-biomass-below biomass * 10
  ]
end

to set-evap-rate
  ask patches [set evap-rate evp * biomass]
end
@#$#@#$#@
GRAPHICS-WINDOW
179
26
572
420
-1
-1
3.8515
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
99
0
99
0
0
1
ticks
30.0

BUTTON
21
26
84
59
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
92
26
155
59
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
9
79
167
112
frm
frm
0
100
50.0
1
1
NIL
HORIZONTAL

PLOT
586
225
893
405
fire occurence
NIL
NIL
0.0
10.0
0.0
8.0
true
true
"" ""
PENS
"total" 1.0 0 -16777216 true "" "plot count fires + count below-fires"
"above" 1.0 0 -2674135 true "" "plot count fires"
"below" 1.0 0 -8630108 true "" "plot count below-fires"

MONITOR
798
430
873
475
above fires
sum-tfa
3
1
11

SLIDER
8
117
166
150
dth
dth
0.1
1
0.54
0.01
1
NIL
HORIZONTAL

SLIDER
7
157
164
190
dst
dst
10
100
55.0
1
1
NIL
HORIZONTAL

SLIDER
9
196
164
229
igp
igp
0.1
1
0.55
0.1
1
NIL
HORIZONTAL

SLIDER
8
237
163
270
evp
evp
0.003
0.01
0.0065
0.0002
1
NIL
HORIZONTAL

PLOT
585
28
892
217
water table dynamics
NIL
NIL
0.0
2.0
0.0
0.1
true
true
"" ""
PENS
"water-level" 1.0 0 -13345367 true "" "plot mean [0 - water-table] of patches"

SLIDER
8
277
162
310
dbi
dbi
0
10
5.0
1
1
NIL
HORIZONTAL

MONITOR
587
430
644
475
farmers
count households
17
1
11

MONITOR
653
430
710
475
powers
sum [power] of households
17
1
11

SLIDER
9
354
160
387
wtd
wtd
0
1
0.5
0.05
1
NIL
HORIZONTAL

SLIDER
8
394
160
427
frp
frp
1
5
3.0
1
1
NIL
HORIZONTAL

SLIDER
8
433
160
466
bia
bia
0
1
0.5
0.1
1
NIL
HORIZONTAL

PLOT
908
28
1133
196
distribution-of-wtd
NIL
NIL
-0.5
1.0
0.0
10.0
true
false
"" ""
PENS
"default" 0.1 1 -16777216 true "histogram [water-table] of patches" "histogram [water-table] of patches"

SLIDER
10
316
161
349
bbr
bbr
0.1
1
0.55
0.1
1
NIL
HORIZONTAL

MONITOR
885
432
958
477
below fires
sum-tfb
17
1
11

SLIDER
176
471
309
504
wind-direction-degree
wind-direction-degree
0
315
0.0
45
1
NIL
HORIZONTAL

MONITOR
711
491
805
536
inundated (%)
(count patches with [inundated? = true] / count patches) * 100
2
1
11

SLIDER
316
430
437
463
ind
ind
0
0.2
0.1
0.01
1
NIL
HORIZONTAL

SWITCH
446
432
569
465
spread-above?
spread-above?
0
1
-1000

SLIDER
177
429
310
462
wsp
wsp
0.1
1
0.55
0.1
1
NIL
HORIZONTAL

SLIDER
9
471
160
504
bib
bib
0
1
0.5
.1
1
NIL
HORIZONTAL

SLIDER
317
470
438
503
psb
psb
0.1
1
0.55
0.1
1
NIL
HORIZONTAL

SWITCH
13
518
145
551
spread-to-eight?
spread-to-eight?
0
1
-1000

SWITCH
446
472
569
505
spread-below?
spread-below?
0
1
-1000

MONITOR
720
429
787
474
total-fires
sum-tf
17
1
11

SWITCH
174
519
318
552
random-rainfall?
random-rainfall?
0
1
-1000

CHOOSER
327
520
465
565
rain-distribution
rain-distribution
"normal" "gamma"
1

PLOT
903
226
1141
408
rainfall dynamics
NIL
NIL
0.0
10.0
0.0
0.1
true
true
"" ""
PENS
"rainfall" 1.0 0 -15390905 true "" "if ticks > 0 [plot item (ticks - 1) rainfall-data]"

MONITOR
589
490
639
535
burnt
burnt-patches
17
1
11

MONITOR
646
490
703
535
unburnt
count patches - burnt-patches
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

fire
false
0
Polygon -7500403 true true 151 286 134 282 103 282 59 248 40 210 32 157 37 108 68 146 71 109 83 72 111 27 127 55 148 11 167 41 180 112 195 57 217 91 226 126 227 203 256 156 256 201 238 263 213 278 183 281
Polygon -955883 true false 126 284 91 251 85 212 91 168 103 132 118 153 125 181 135 141 151 96 185 161 195 203 193 253 164 286
Polygon -2674135 true false 155 284 172 268 172 243 162 224 148 201 130 233 131 260 135 282

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
NetLogo 6.0.4
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
