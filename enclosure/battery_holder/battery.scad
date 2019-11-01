use <roundedcube.scad>
include <tiedown.scad>  // tiedowns don't work for general case (yet...)


clipDiameter = 32.4;        // inner diameter of tube you want to hold
clipWidth    = 15;          // width of the clip
clipSpacing  = 60;          // distance between two clips
clipCount    = 2;           // number of clips
wall         = 3;           // thickness of the wall
angle        = 100;  // openings angle of clip 0 = no opening 360 = no clip
screwHoles   = true; // holes to fasten clip to wall (i prefere tape)

// tiedown dims
td_x = 30;
td_y = 5;
td_z = 10;
td_o = 20;
td_b = 3;

// $fn=128;
$fn=64;

clip();

module clip(clips = clipCount) {
     battery_length = 107.5 + 0.75; // extra for "kerf"/slop (0.5 is snuggy)
     length = clipSpacing * (clips - 1) + clipWidth;
     foo = battery_length - length;
     smidge = 1;                /* run base into the curved edge a bit */
     width  = clipDiameter + 2 * wall;

     difference() {
          union() {
               cube([width, length, wall], center = false);
               for(i=[0:clips-1]) {
                    translate([0, clipSpacing * i, wall])
                         openCylinder();
               }
               translate([0, -foo/2-1, 0])
                    cube([width, foo/2+smidge, wall], center = false);
               translate([0, -foo/2-2, 0])
                    roundedcube([width, 2 + smidge ,10], center=false, apply_to="zmax");
               translate([0, length, 0])
                    cube([width, foo/2+smidge, wall], center = false);
               translate([0, length+foo/2, 0])
                    roundedcube([width, 2 + smidge ,10], center=false, apply_to="zmax");
          }
          for(i=[0:clips-1]) {
               translate([width / 2, clipSpacing * i + clipWidth / 2, wall/2])
                    if (screwHoles)
                         screwHole();
          }
          translate([width/2, (clipSpacing * (clips-1) + clipWidth)/2, , wall/2])
               screwHole();
     }

     translate([2, (clipSpacing * (clips-1) + clipWidth)/2 - 15, 0])
          translate([5,0,wall])
          rotate([0,0,90])
          tiedown(td_x, td_y, td_z, td_o, td_b);
     translate([width - 5 - 2, (clipSpacing * (clips-1) + clipWidth)/2 - 15, 0])
          translate([5,0,wall])
          rotate([0,0,90])
          tiedown(td_x, td_y, td_z, td_o, td_b);
}

module screwHole() {

    d=3; // screw hole diameter
    union() {
        linear_extrude(height=wall, scale = 2)
        circle(d=d,$fn=60);
        translate([0, 0, -clipDiameter / 2 + wall])
        cylinder(d=d, center=true, h = clipDiameter);
        translate([0, 0, clipDiameter / 2 + wall])
        cylinder(d=2*d, center=true, h = clipDiameter);
    }
}



module openCylinder() {
    D = clipDiameter + wall * 2;

    translate([D, clipWidth, D] / 2)
    rotate([0, -90, 90])
    union() {

        rotate([0, 0, angle / 2])
        translate([0, 0, -clipWidth / 2])
        rotate_extrude(angle = 360 - angle)
        translate([clipDiameter/2, 0, 0] )
        square([wall, clipWidth]);


        rotate([0, 0, angle / 2])
        translate([(clipDiameter + wall) / 2, 0, 0])
        cylinder(d = wall, h = clipWidth, center=true);
        rotate([0, 0, -angle / 2])
        translate([(clipDiameter + wall) / 2, 0, 0])
        cylinder(d = wall, h = clipWidth, center=true);
        block();
    }
}

module block() {
    angle = acos((clipDiameter / 2) / (clipDiameter / 2 + wall));
    w = sin(angle) * (clipDiameter /2 + wall) * 2;

    translate([-(clipDiameter + wall)/2, 0, 0])
    rotate([90, 0, 90])
    cube([w, clipWidth, wall], true);
}

module cutOut() {

    D = clipDiameter + wall * 2;
    x = D / 2 * sin((180 - angle) / 2);
    y = abs(D / 2 * (cos((180-angle)/2)));
    points = [ [ 0,  0]
             , [ x,  y]
             , [ D,  y]
             , [ D, -y]
             , [ x, -y] ];

    translate([0, 0, -clipWidth])
    linear_extrude(clipWidth * 2)
    polygon(points);
}
