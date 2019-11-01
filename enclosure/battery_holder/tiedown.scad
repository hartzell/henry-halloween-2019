include <roundedcube.scad>;

module fillet(r, h) {
    translate([r / 2, r / 2, 0])

        difference() {
            cube([r, r, h], center = true);

            translate([r/2, r/2, 0])
                cylinder(r = r, h = h + 1, center = true);

        }
}

// x = "width"
// y = "depth"
// z = "height"
// o = width of opening
// b = material left for bridge
module tiedown(x, y, z, o, b) {
     translate([0,0,-2])
          difference() {
          roundedcube(size=[x, y, z]);
          translate([(x-o)/2, 0, 0])
               cube(size=[o, y, z-b]);

          translate([(x-o)/2, 0, b])
               rotate(a=[0, 0, -270])
               fillet(1.5, z-b+1); // 1 is magic...
          translate([x-(x-o)/2, 0, 3])
               fillet(1.5, z-b+1); // 1 is magic...
          translate([(x-o)/2, 0, b])
               translate([0,y,0])
               rotate(a=[0, 0, -180])
               fillet(1.5, z-b+1); // 1 is magic...
          translate([x-(x-o)/2, 0, 3])
               translate([0, y, 0])
               rotate(a=[0, 0, -90])
               fillet(1.5, z-b+1); // 1 is magic...

          translate([(x-o)/2+o/2, 0, z-b]) // fill is centered
               rotate(a=[90, 0, 0])
               rotate(a=[0, 90, 0])
               fillet(1.5, o);
          translate([(x-o)/2+o/2, y, z-b]) // fill is centered
               rotate(a=[180,0,0])
               rotate(a=[0,90,0])
               fillet(1.5,20);

          translate([(x-o)/2, 0, z-b])
                rotate([-90,0,0])
                corner_fillet();
          translate([(x-o)/2+o, 0, z-b])
                rotate([-90,0,0])
                corner_fillet();
          translate([(x-o)/2, y, z-b])
                rotate([90,0,0])
                corner_fillet();
          translate([(x-o)/2+o, y, z-b])
                rotate([90,0,0])
                corner_fillet();
          cube([x, y, 2]);
    }
}

// This doesn't quite do the right thing,
// plus the fillets are too long....
module corner_fillet(r=1.5) {
     rotate_extrude(angle=360) {
          difference() {
               square([r, r]);
               translate([r, r])
                    circle(r=r);
          }
     }
}
// $fn=16;
// render() {
//      tiedown(30, 5, 10, 20, 3);
// }
