$fn=64;

module brace(a, b, w) {
     translate(a)
          cylinder(2, d=w, true);
     translate(b)
          cylinder(2, d=w, true);

     if (a[1] == b[1]) {
          echo("horizontal", a, b);
          translate(a)
               translate([0, -w/2, 0])
               cube([b[0] - a[0], w, 2], false);
     }
     else {
          echo("vertical", a, b);
          translate(a)
               translate([-w/2, 0, 0])
               cube([w, b[1] - a[1], 2], false);
     }
}

speaker_opening = [[18.4, 1.25],        /* bottom left */
                   [57.6, 1.25],        /* bottom right */
                   [18.4, 29.5],        /* top left */
                   [57.6, 29.5]         /* top right */
     ];
screw_holes = [[3.2, 3.2],            /* bottom left */
               [66.54, 3.2],             /* bottom right */
               [3.2, 27.6],           /* top left */
               [66.54, 27.6]             /* top right */
     ];

module post(h, od, id, center) {
     difference() {
          cylinder(h, d=od, center);
          hole(h, id, center);
     }
}

module hole(h, d, center) {
     cylinder(h, d=d, center);
}

module opening(corners, depth) {
     cube([corners[1][0] - corners[0][0],
           corners[2][1] - corners[0][1],
           depth]
          );
}

module goto_hole(h, z=0) {
     translate([h[0], h[1], z])
          children();
}

module single_cutouts(speaker_opening, screw_holes, depth) {
     union() {
          translate([speaker_opening[0][0], speaker_opening[0][1], 0])
               opening(speaker_opening, depth);
          for(i = [0:3]) {
               goto_hole(screw_holes[i]) hole(depth, 3, true);
          }
     }
}

face_gap = 60;
unit_width = 69.74;                        /* single speaker width */
face_width = (2 * unit_width ) + face_gap; /* x */
face_height = 30.8;                        /* y */

module speaker_face(thickness) {
     difference() {
          cube([face_width, face_height, thickness]);
          single_cutouts(speaker_opening, screw_holes, thickness);
          translate([unit_width + face_gap, 0, 0])
               rotate([0,0,180])
               translate([-unit_width, -face_height, 0])
               single_cutouts(speaker_opening, screw_holes, thickness);
     }
     for(i = [0:3]) {
          goto_hole(screw_holes[i], thickness) post(1.7, 5, 3, true);
          translate([unit_width+face_gap, 0, 0])
               rotate([0,0,180])
               translate([-unit_width, -face_height, 0])
               goto_hole(screw_holes[i], thickness) post(1.7, 5, 3, true);
     }

}

amp_width = 29;
knob_diameter = 7.2;
knob_x_offset = 1.4;     /* from left edge of amp to hole's edge */
knob_x_center = knob_x_offset + knob_diameter/2;
knob_top_offset = 1.4;
knob_top_center = knob_top_offset + knob_diameter/2;
jack_diameter = 8.0;

fudge = 2;

module knob_hole(thickness) {
     x = face_width/2 - amp_width/2 + knob_x_center;
     y = fudge + knob_top_center;
     translate([x, y, 0])
          cylinder(thickness, d=knob_diameter, true);
}

module jack_hole(thickness) {
     /* same distance from edge as knob */
     x = face_width/2 + amp_width/2 - knob_x_center;
     y = fudge + knob_top_center;
     translate([x, y, 0])
     cylinder(thickness, d=jack_diameter, true);
}

module bottom(thickness) {
     difference() {
          cube([face_width, face_height, thickness]);
          translate([0,0,0])
               knob_hole(thickness);
          translate([0,0,0])
               jack_hole(thickness);
     }
}

module top(thickness) {
     cube([face_width, face_height, thickness]);
}

module end(thickness) {
     cube([face_height, face_height, thickness]);
}

module fillet(r, h) {
    translate([r / 2, r / 2, 0])

        difference() {
            cube([r + 0.01, r + 0.01, h], center = true);

            translate([r/2, r/2, 0])
                cylinder(r = r, h = h + 1, center = true);

        }
}

module stick(x,y,z) {
     cube([x,y,z]);
}

module box() {
     w = 3;                     /* wall thickness */
     union() {
          speaker_face(w);
          translate([0,0,w])
               rotate([90,0,0])
               top(w);
          translate([0, w*2+face_height, 0])
               translate([0,0,w])
               translate([0, -w, 0])
               rotate([90,0,0])
               bottom(w);
          // left end
          translate([0,w, w])
               translate([0, -w, 0])
               rotate([0,-90,0])
               end(w);
          translate([0,w, w])
               translate([face_width+w, -w, 0])
               rotate([0,-90,0])
               end(w);

          translate([-w, -w, 0])
               stick(face_width+2*w, w, w);

          translate([-w, face_height, 0])
               stick(face_width+2*w, w, w);

          translate([-w, face_height, 0])
               stick(w, w, face_height+w);
          translate([-w, -w, 0])
               stick(w, w, face_height+w);
          translate([-w, -w, w])
               rotate([-90,0,0])
               stick(w, w, face_height+2*w);

          translate([face_width, face_height, 0])
               stick(w, w, face_height+w);
          translate([face_width, -w, 0])
               stick(w, w, face_height+w);
          translate([face_width, -w, w])
               rotate([-90,0,0])
               stick(w, w, face_height+2*w);
     }
}

//render() {
box();
//}
