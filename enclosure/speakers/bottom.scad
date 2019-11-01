module post(h, od, id, center) {
     difference() {
          cylinder(h, d=od, center);
          hole(h, id, center);
     }
}

module hole(h, d, center) {
     cylinder(h, d=d, center);
}
