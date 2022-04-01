/**
Parametric Pelton wheel by Jonathan Foucher from work by Ricardo Redin (https://www.thingiverse.com/thing:3592800)
Creative Commons CC-BY-SA License
https://creativecommons.org/licenses/by-sa/4.0/legalcode

This is a human-readable summary of (and not a substitute for) the license.
You are free to:

    Share — copy and redistribute the material in any medium or format
    Adapt — remix, transform, and build upon the material
    for any purpose, even commercially.

This license is acceptable for Free Cultural Works.

    The licensor cannot revoke these freedoms as long as you follow the license terms.

Under the following terms:

    Attribution — You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.

    ShareAlike — If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.

    No additional restrictions — You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.

**/

//Number of blades around hub
nblades = 15;
//Outer hub diameter
hubdiam = 60;

//Diameter of all screws in the assembly
screw_diameter = 3;

// Total blade width
blade_width = 20;
blade_size = blade_width/1.7;
//Thickness of the blade walls
blade_thickness = 3;
// hub height, excluding hub thickness
hub_height = blade_size/2;
//Thickness of top and bottom part of hub
hub_thickness = 3;

//Shaft diameter
shaft_diameter = 9;
//number of screw holes around shaft
shaft_nscrews = 0;
// Thickness of extension around shaft
shaft_holder_thickness = 4;
// Shaft key size
key_width = 3;

// Whether to output the bottom part of the hub (a 1 outputs it, a 0 does not)
print_bottom_hub = 1;
// Wheher to output the top part of the hub (a 1 outputs it, a 0 does not)
print_top_hub = 1;
// Wheher to output a single blade (a 1 outputs it, a 0 does not)
print_single_blade = 0;
// Wheher to output all blades around the hub (a 1 outputs it, a 0 does not)
print_all_blades = 1;

//Change this to false if you wish to work on the file, it makes opensCAD a bit faster at rendering
production = true;

/* No need to change anything further down than this */

blade_fits = hubdiam * 3.14159 / (blade_size*0.75- blade_size / 10);
blade_resolution = production ? 128 : 32;
resolution =production ? 64: 32;


if (blade_fits < nblades) {
    assert(false, "Not enough space around hub to fit all the blades. Either reduce the blade size, increase the hub diameter, or number the number of blades");
}



module half_blade(){
    difference(){
    // Outer shphere
        scale([1.25,2.5,1.5])sphere($fn = blade_resolution, $fa = 1, $fs = 1, d= blade_size);
        // Inner sphere
        scale([1.25,2.5 + blade_thickness / blade_size,1.5])sphere($fn = blade_resolution, $fa = 1, $fs = 1, d= blade_size - blade_thickness);
        // Top cube 
        translate([0,0,blade_size/2 - blade_size / 10])cube([blade_size*3,blade_size*3,blade_size],center = true);
        //Side cube
        translate([-blade_size/2-blade_size/2.5+blade_thickness/4,0,0])cube([blade_size,blade_size*3,blade_size*2],center = true);
        //Cutout at end of blade
        translate([-blade_size/6,blade_size,0])scale([1,2,1])cylinder($fn = blade_resolution, $fa = 1, $fs = 1, h=blade_size * 2,r=blade_size / 3.5, center = true);
    }
}

module blade(){
    union(){
        translate([blade_size/2.5-blade_thickness/4,0,0])half_blade();
        translate([-blade_size/2.5+blade_thickness/4,0,0])mirror([1,0,0])half_blade();
    }
}

module wedge() {
    h = blade_size*0.75;
    angle = 360/nblades > 20 ? 20 : 360/nblades;

    translate([0, -hubdiam/8 - blade_size * 1.25, -h/2]) {
        difference() {
            cube([hub_height, hubdiam/3, h], center=true);
            translate([0, 0, h - (hubdiam/12)*sin(angle)]) {
                rotate([angle, 0, 0]) {
                    cube([hub_height, hubdiam, h], center=true);
                }
            }
            translate([0, -screw_diameter/2, (-hubdiam/6+blade_size/8)*sin(angle/2)]){
                rotate([angle/2, 0, 0]) {
                    translate([0, +hubdiam/12+blade_size/8, 0]) {
                        rotate([0, 90, 0]) {
                            cylinder(blade_size*2, screw_diameter/2, screw_diameter/2, center=true, $fn=resolution);
                        }
                    }

                    translate([0, -hubdiam/12+blade_size/4,0]) {
                        rotate([0, 90, 0]) {
                            cylinder(blade_size*2, screw_diameter/2, screw_diameter/2, center=true, $fn=resolution);
                        }
                    }
                }
            }
        }
    }
}

module socket() {
    h = blade_size*0.75 + 0.5;
    angle = 360/nblades > 20 ? 20 : 360/nblades;
    translate([-0.25, 0, h/2]) {
        translate([0, -screw_diameter/2, (-hubdiam/6+blade_size/8)*sin(angle/2)]){
            rotate([angle/2, 0, 0]) {
                translate([0, +hubdiam/12+blade_size/8, 0]) {
                    rotate([0, 90, 0]) {
                        cylinder(blade_size*2, screw_diameter/2, screw_diameter/2, center=true, $fn=resolution);
                    }
                }

                translate([0, -hubdiam/12+blade_size/4,0]) {
                    rotate([0, 90, 0]) {
                        cylinder(blade_size*2, screw_diameter/2, screw_diameter/2, center=true, $fn=resolution);
                    }
                }
            }
        }
        difference() {
            cube([hub_height, hubdiam/3, h], center=true);
            translate([0, 0, 0.25 + h - (hubdiam/8)*sin(angle)]) {
                rotate([angle, 0, 0]) {
                    cube([hub_height, hubdiam, h], center=true);


                }
            }
            
        }
    }
}




module blade_support() {
    difference() {
        h = blade_size*0.75- blade_size / 10;
        w = blade_size*0.8;
        d = blade_size/4;
        d2 = blade_size/8;
        
        union() {
            //rounded part at tip of support
            translate([-w/2, 0, -blade_size + d*2]) {
                rotate([0, 90, 0]) {
                    cylinder(w, d, d);
                }
            }

            //End support
             translate([0, w/2, -blade_size + d2*3.5]) {
                rotate([105, 0, 0]) {
                    scale([1.5, 1, 1])
                    cylinder(w+d2, d2, d2, center=true, $fn=resolution);
                }
            }



            //main support
            translate([-w/2, -blade_size*1.5, -h- blade_size / 10]) {
                cube([w,blade_size*1.5,h]);
            }
        }
        union(){
            //clean up bottom
            translate([0,0,-blade_size*1.25])
                cube([blade_size*3, blade_size*3, blade_size], center=true);
            //remove hub from root
            translate([0, -hubdiam/2-blade_size*1.25,-blade_size/10]) {
                rotate([0, 90, 0])
                    cylinder(hubdiam, hubdiam/2, hubdiam/2, center=true, $fn=resolution);
            }
            //remove blades
            translate([blade_size/2.5-blade_thickness/4,0,0]){
                scale([1.25,2.5 + blade_thickness / blade_size,1.5]) {
                    sphere($fn = blade_resolution, $fa = 1, $fs = 1, d= blade_size - blade_thickness);
                }
                translate([-blade_size/6,blade_size,0])scale([1,2,1])cylinder($fn = blade_resolution, $fa = 1, $fs = 1, h=blade_size * 2,r=blade_size / 3.5, center = true);
            }
            translate([-blade_size/2.5+blade_thickness/4,0,0]) {
                scale([1.25,2.5 + blade_thickness / blade_size,1.5])sphere($fn = blade_resolution, $fa = 1, $fs = 1, d= blade_size - blade_thickness);
                translate([blade_size/6,blade_size,0])scale([1,2,1])cylinder($fn = blade_resolution, $fa = 1, $fs = 1, h=blade_size * 2,r=blade_size / 3.5, center = true);
            }


            
        }

    //translate([0,0,blade_size/8])rotate([-10, 0, 0])cube([blade_size, hubdiam, blade_size/2], center=true);
    }
}


module pelton() {
    h = blade_size*0.75;
    translate([0, blade_size*1.25, +h]) {
        blade();
        blade_support();
        wedge();
    }
}


module sockets() {
    for(angle = [0 : nblades-1]) {
        translate([0,0,hub_height/2-0.25])rotate([0,90,angle * 360/nblades])translate([0, hubdiam/2-hubdiam / 8,-blade_size*0.65- 0.25])socket();
    }
}
module hub_bottom() {
    difference() {
        union() {
            translate([0, 0, (hub_height + hub_thickness)/2]){
                cylinder(hub_height + hub_thickness, hubdiam/2, hubdiam/2, center=true, $fn=resolution);
            }
            cylinder((hub_height + hub_thickness) * 2, shaft_diameter/2+shaft_holder_thickness, shaft_diameter/2+shaft_holder_thickness);
        }
        union() {
            translate([shaft_diameter/2, 0, hub_height + hub_thickness]) {
                cube([hub_thickness,key_width,(hub_height + hub_thickness) * 4], center=true);
            }
            translate([0, 0, hub_thickness]){
                sockets();
            }
            cylinder((hub_height + hub_thickness) * 3, shaft_diameter/2, shaft_diameter/2);
            if (shaft_nscrews > 0) {
                for(angle = [0 : shaft_nscrews-1]) {
                    rotate([0,0,angle * 360/shaft_nscrews])translate([shaft_diameter/2+shaft_holder_thickness+screw_diameter, 0, -hub_thickness])
                        cylinder((hub_height + hub_thickness) * 2, screw_diameter/2, screw_diameter/2, $fn=resolution);
                }
            }
        }
    }
}

module hub_top() {
    difference() {
        translate([0, 0, hub_height+hub_thickness/2 + hub_thickness])
            cylinder(hub_thickness, hubdiam/2, hubdiam/2, center=true, $fn=resolution);
        union() {
            translate([0, 0, hub_thickness]){
                sockets();
            }
            cylinder((hub_height + hub_thickness) * 2, shaft_diameter/2+ hub_thickness, shaft_diameter/2+ hub_thickness);
            if (shaft_nscrews > 0) {
                for(angle = [0 : shaft_nscrews-1]) {
                    rotate([0,0,angle * 360/shaft_nscrews])translate([shaft_diameter/2+shaft_holder_thickness+screw_diameter, 0, -hub_thickness])
                        cylinder((hub_height + hub_thickness) * 2, screw_diameter/2, screw_diameter/2, $fn=resolution);
                }
            }
        }
    }
}

module blades() {
    for(angle = [0 : nblades-1]) {
        rotate([0,90,angle * 360/nblades])translate([-hub_height/2-hub_thickness, hubdiam/2,-blade_size*0.65])pelton();
    }
}
if (print_bottom_hub) {
    hub_bottom();
}
if (print_top_hub) {
    hub_top();
}
if (print_all_blades) {
    blades();
}
if (print_single_blade) {
    pelton();
}

