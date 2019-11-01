include <tiedown.scad>;
include <hull.scad>;

module goto_hole(h, z=0) {
     translate([h[0], h[1], z])
          children();
}


keypad_width = 70;
keypad_height = 77;
keypad_slot_ll_corner = [25.0, 2.0];
keypad_slot_width = 21.5;
keypad_slot_height = 4.00;
module keypad_opening(demo=false) {
     if(demo) {
          keypad_hole();
     }
     else {
          keypad_slot();
     }
}
module keypad_hole() {
     square([keypad_width, keypad_height]);
}
module keypad_slot() {
     translate(keypad_slot_ll_corner)
          union() {
          square([keypad_slot_width - keypad_slot_height, keypad_slot_height]);
          translate([0,keypad_slot_height]/2)
               circle(d=keypad_slot_height);
          translate([keypad_slot_width - keypad_slot_height, keypad_slot_height/2])
               circle(d=keypad_slot_height);
     }
}


// This display https://www.amazon.com/gp/product/B073R7BH1B
// Same as this: https://www.pjrc.com/store/display_ili9341_touch.html
display_board_width = 50.00;
display_board_height = 86.00;
display_ll_corner = [2.75, 10.40 + 8.75]; // offset of ll corner from board ll corner
display_width = display_board_width - (2.75*2);
display_height = display_board_height - 10.40 - 8.75 - 6.40 - 2.75;
display_post_height = 4.5;
display_holes = [[3.0,6.92],
         [display_board_width - 3.00, 6.92],
         [3.0, display_board_height - 3.0],
         [display_board_width - 3.00, display_board_height - 3.0]
     ];

module display_opening() {
         union() {
              translate(display_ll_corner)
                   square([display_width, display_height]);
              for(i=[0:3]) {
                   goto_hole(display_holes[i]) circle(d=3);
              }
         }
}

module display_posts() {
     post_width = 30;
     p_x = (display_board_width - post_width)/2;
     p_lower_y = 5;
     p_upper_y = 10.40 + 69.20 + (6.4/2);
     translate([p_x, p_lower_y])
          cube([post_width, 3, 4.5]);
     translate([p_x, p_upper_y])
          cube([post_width, 3, 4.5]);
}


// display_board_width = 86.00;
// display_board_height = 50.00;
// display_ll_corner = [6.40, 0];  // offset of ll corner from board ll corner
// display_width = 69.20;
// display_height = display_board_height;
//
// module display_opening(demo=false) {
//      holes = [[3.0,3.0],
//               [display_board_width - 6.92, 3.00],
//               [3.0, display_board_height - 3.0],
//               [display_board_width - 6.92, display_board_height - 3.0]
//           ];
//
//      if (demo) {
//           square([display_board_width, display_board_height]);
//      }
//      else {
//           union() {
//                translate(display_ll_corner)
//                     square([display_width, display_height]);
//                for(i=[0:3]) {
//                     goto_hole(holes[i]) circle(d=3);
//                }
//           }
//      }
// }


speaker_height = 57;
speaker_width = 172;
speaker_grill_height = 24.8 * 2;
speaker_grill_width = 165;
speaker_wall_thickness = 2;
speaker_wall_height = 6;
speaker_foot_x = 27;      // offset of little foot bump from either end
speaker_foot_width = 5;   // size of opening to use for foot bump

function speaker_offset() = [speaker_wall_thickness, speaker_wall_thickness];
function speaker_opening_offset() = [speaker_wall_thickness + (speaker_width - speaker_grill_width)/2,
                                     speaker_wall_thickness + (speaker_height - speaker_grill_height)/2];

module speaker_shape(w, h) {
     r = h / 2;
     translate([r, 0])
          union() {
          square([w - h, h ]);
          translate([0,r])
               circle(r=r);
          translate([w - r * 2, r])
               circle(r=r);
     }
}

module speaker() {
     color([0,1, 0], 0.5)
          linear_extrude(height=10)
          speaker_shape(speaker_width, speaker_height);
}

module speaker_opening() {
     speaker_shape(speaker_grill_width, speaker_grill_height);
}

module speaker_wall() {
     linear_extrude(height=speaker_wall_height) {
          difference() {
               w = speaker_width + speaker_wall_thickness * 2;
               h = speaker_height + speaker_wall_thickness * 2;
               speaker_shape(w, h);
               translate(speaker_offset())
                    speaker_shape(speaker_width, speaker_height);
               translate([29+speaker_wall_thickness, 0])
                    square([6,speaker_wall_thickness]);
               translate([speaker_width + speaker_wall_thickness - 29 - 6, 0])
                    square([6,speaker_wall_thickness]);
          }
     }
}

$fn = 32;
box_width = 220;
box_height = 180;
box_thickness = 75;
corner_radius = 4;
wall_thickness = corner_radius;

lip_height = 8;
lip_thickness = 5;
lid_cutout_height = 5;
lid_thickness = 2;

// tiedown dims
td_x = 32;
td_y = 5;
td_z = 10;
td_o = 22;
td_b = 3;

jack_diameter = 8.0;

// teensy audio board holes
ta_holes = [[19.558,  3.302],
            [ 3.302, 33.528],
            [32.258, 33,528],
];

module teensy_post(h, od, id, center) {
     // use for a screw hole instead of a pin
     difference() {
          cylinder(h, d=od, center);
          cylinder(h, d=id, center);
     }
//      union() {
//           cylinder(h, d=od, center);
//           translate([0,0,h])
//                cylinder(h, d=id, center);
//      }
}

module box() {
     speaker_pad = 10;
     h_pad = (box_width - keypad_width - display_board_width) / 3;
     v_pad = (speaker_pad + speaker_grill_height + 30);
     keypad_v_pad = v_pad + (keypad_height - display_height);

     corners = [[0,0],[box_width,0],[0,box_height],[box_width,box_height]];
     translate([0, 0, box_thickness/2])
          difference() {
          // the round bottom cube
          hull() {
               rb_cylinders(corners, corner_radius * 2, box_thickness);
          }
          // cut out the interior
          translate([0, 0, -box_thickness/2])
               cube([box_width, box_height, box_thickness]);
          // slot in top wall for lid
          translate([0, box_height, box_thickness/2-lid_cutout_height])
               cube([box_width, wall_thickness, lid_cutout_height]);
          translate([0, 0, -box_thickness/2-wall_thickness]) {
               translate([(box_width/2 - keypad_width)/2, v_pad])
                    linear_extrude(height=wall_thickness)
                    keypad_opening(demo=false);
               translate([box_width/2 + (box_width/2 - display_width)/2 + 10, v_pad])
                    linear_extrude(height=wall_thickness)
                    display_opening();
               translate([(box_width - speaker_width)/2 ,speaker_pad])
                    translate(speaker_opening_offset())
                    linear_extrude(height=wall_thickness)
                    speaker_opening();
          }
               // holes for battery holder
               translate([(box_width-60)/2,0,0])
                    rotate(a=[90,0,0])
                    union() {
                    cylinder(d=3, h=wall_thickness);
                    translate([30, 0, 0]) cylinder(d=3, h=wall_thickness);
                    translate([60, 0, 0]) cylinder(d=3, h=wall_thickness);
               }
               translate([(box_width-60)/2 + 90,0,0]) // go off middle screw hole of holder
               rotate(a=[90,0,0])
                    cylinder(d=15, h=wall_thickness);

               translate([box_width, box_height*0.80, 0]) // go off middle screw hole of holder
               rotate(a=[0,90,0])
               cylinder(d=jack_diameter, h=wall_thickness);



          }
     // lid lips
     translate([0, 0, box_thickness - lip_height])
          difference() {
          cube([box_width, box_height+wall_thickness, (lip_height-lid_thickness)/2]);
          translate([lip_thickness, lip_thickness, 0])
               cube([box_width-lip_thickness*2, box_height-lip_thickness*2, (lip_height-lid_thickness)/2]);
     }
     translate([0, 0, box_thickness-lip_height/2+lid_thickness/2])
          difference() {
          cube([box_width, box_height+wall_thickness, (lip_height-lid_thickness)/2]);
          translate([lip_thickness, lip_thickness, 0])
               cube([box_width-lip_thickness*2, box_height-lip_thickness*2, (lip_height-lid_thickness)/2]);
     }

     translate([(box_width - speaker_width)/2 ,speaker_pad])
          speaker_wall();

     translate([(box_width-td_x)/2, 4, 0])
          tiedown(td_x, td_y, td_z, td_o, td_b);
     translate([(box_width-td_x)/2, speaker_pad+speaker_height+2*speaker_wall_thickness + 4, 0])
          tiedown(td_x, td_y, td_z, td_o, td_b);

     translate([box_width/2 + (box_width/2 - display_width)/2 + 10, v_pad])
          display_posts();

     translate([145,130,0]) {
          rotate([0,0,90])
               for(i=[0:2]) {
                    hole_diam=3.5;
                    goto_hole(ta_holes[i])
                         teensy_post(15, 1.25*hole_diam, 0.8*hole_diam, true);
               }
     }


}

module multiLine(spacing=12){
  union(){
    for (i = [0 : $children-1])
      translate([0 , -i * spacing, 0 ]) children(i);
  }
}

module lid() {
     finger_d = 30;
     union() {
          difference() {
               cube([box_width*0.98, (box_height+wall_thickness)*0.98, lid_thickness * 0.9]); // loose fit...
               translate([box_width/2, box_height*.8, lid_thickness/2])
                         cylinder(h=lid_thickness, d=finger_d, center=true);
          }
          translate([box_width/2, 100, lid_thickness-0.2])
               linear_extrude(height=lid_thickness)  // because, reasonable thickness...
            multiLine(spacing=24){
               text("Henry", halign="center", font="Chalkboard", size=20);
               text("the", halign="center", font="Chalkboard", size=20);
               text("Robot", halign="center", font="Chalkboard", size=20);
          }
     }
}


render() {
     *box();
     translate([0,0,box_thickness-lid_thickness - lip_height/2])
          lid();
}

// render() {
//      cube([38, 10, 0.5]);
//      // only works for this size...  BUG
//      translate([2.5, 2.5])
//
// }

// render(){
//      difference() {
//           union() {
//                cube([60, 90, 0.5]);
//                translate([5, 0])
//                     display_posts();
//           }
//           linear_extrude(height=0.5)
//                translate([5, 0])
//                display_opening();
//      }
// }

// render() {
//      union() {
//           difference() {
//                cube([175,61,1]);
//                     linear_extrude(height=1)
//                     translate(speaker_opening_offset())
//                     speaker_opening();
//           }
//           translate([0,0,1])
//                speaker_wall();
//      }
// }

// render() {
//      thickness=0.5;
//      speaker_pad = 15;
//      h_pad = (box_width - keypad_width - display_board_width) / 3;
//      v_pad = (speaker_pad + speaker_grill_height + 19);
//      keypad_v_pad = v_pad + (keypad_height - display_height);
//
//      union() {
//           *translate([h_pad + keypad_width + h_pad, display_v_pad])
//                linear_extrude(height=thickness)
//                display_opening(demo=true);
//
//           difference() {
//                cube([box_width, box_height, thickness]);
//                translate([(box_width/2 - keypad_width)/2, keypad_v_pad])
//                     linear_extrude(height=thickness)
//                     keypad_opening(demo=true);
//                translate([box_width/2 + (box_width/2 - display_width)/2, v_pad])
//                     linear_extrude(height=thickness)
//                     display_opening(demo=true);
//
//                translate([(box_width - speaker_grill_width)/2 ,speaker_pad])
//                     linear_extrude(height=thickness)
//                     speaker_opening(speaker_grill_width, speaker_grill_height);
//           }
//      }
// }
//
