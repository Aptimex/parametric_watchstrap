$fn = 32;
e = 0.01;

l = 100;
l2 = 65;
w = 18.5;
h = 1;

numHoles = 10;
holeSpacing = 3;
holeW = 2;
holeL = 6;
holeOffset = 0;
holesLen = numHoles * (holeW+holeSpacing);
latchWidth = holeL-2;
latchThick = 1;

barDia = 2;
loopThick = 1.5;
dia = barDia + loopThick*2;
filamentDia = 2; //extra space to rotate freely
loopSlotLen = 3;

module loophole(innerDia = barDia) {
    translate([0, 0, dia/2 - h/2])
    rotate([90, 0, 0])
    cylinder(d=innerDia, h=w+e, center=true);
}

module loop(innerDia = barDia) {
    difference() {
        union() {
            translate([0, 0, dia/2 - h/2]) rotate([90, 0, 0])
                cylinder(d=dia, h=w, center=true);
            
            //meet strap body
            translate([dia/2, 0, 0])
                cube(size=[dia, w, h], center=true);
            translate([dia+(dia-loopThick)/2, -w/2, -h/2]) rotate([0, 0, 90])
                prism(w,dia,0.85*dia);
        }
        loophole(innerDia);
        
        //bar removal cutouts
        translate([innerDia/3+.7, -(w+loopSlotLen+e)/2+loopSlotLen, .3])
        rotate([0, -35, 0])
        cube(size=[innerDia/1.5, loopSlotLen, innerDia+loopThick+e], center=true);
        
        
        translate([innerDia/3+.5, (w+loopSlotLen+e)/2-loopSlotLen, .3])
        rotate([0, -35, 0])
        cube(size=[innerDia/1.5, loopSlotLen, innerDia+loopThick+e], center=true);
    }
    
    
}

module strapBody(long=true) {
    if (long == true) {
        //strap body
        translate([l/2, 0, 0]) cube(size=[l, w, h], center=true);
        
        //strap end
        translate([l, 0, 0])circle(r=w/2);
    } else {
        //strap body
        translate([l2/2, 0, 0]) cube(size=[l2, w, h], center=true);
    }
    
    
}

module longStrap() {
    difference() {
        strapBody(true);
        
        //holes
        translate([l-holesLen-w/2 + (holeSpacing+holeW/2) + holeOffset, 0, 0])
        for (i=[0:numHoles-1]) {
            translate([i * (holeSpacing+holeW), 0, 0]) cube(size=[holeW, holeL, 10], center=true);
        }
    }
    
    //strap bar loop
    translate([-dia/2, 0, 0])
        loop();
    
}

module shortStrap() {
    difference() {
        strapBody(false);
    }
    
    //strap bar loop
    translate([-dia/2, 0, 0])
        loop();
    
    mirror([1, 0, 0])
    translate([-dia-l2, 0, 0])
    difference() {
        loop(filamentDia);
        cube(size=[dia*2, latchWidth+.5, dia+10], center=true);
    }
        
}

module buckle() {
    side = w+3*2;
    
    //calc curve radius from circle chord len and height
    curveH = 2;
    curveR = (w+3)*(w+3)/(8*curveH) + curveH/2;
    
    //main body
    difference() {
        intersection() { //curved body top
            cube(size=[side, side, h+3], center=true);
            translate([0, 0, -curveR+curveH+1]) rotate([90, 0, 0])  cylinder(r=curveR, h=side+e, center=true);
        }
        translate([0, 0, -curveR]) rotate([90, 0, 0])  cylinder(r=curveR, h=side+e, center=true); //form bottom curve
        
        cube(size=[w-2, w, 10], center=true); //center cutout
        translate([-w/2, 0, 1+h/2]) cube(size=[2+e, latchWidth+.5, latchThick+1], center=true); //latch groove
        rotate([90, 0, 0])
            cylinder(d=2, h=side+e, center=true); //bar hole
    }
    
    //axle holders
    difference() {
        scale([2, 1, 1])
        rotate([90, 0, 0])
            cylinder(d=2+2, h=side, center=true); //oblong holders
        translate([0, 1, 0]) rotate([90, 0, 0])
            cylinder(d=2, h=side+e, center=true); //axle hole
        rotate([90, 0, 0])
            cylinder(d=1.5, h=side+e, center=true); //axle push-out hole
        cube(size=[w-2, w, 10], center=true); //center cutout
    }
}

module latch() {
    difference() {
        rotate([90, 0, 0])
            cylinder(d=2.4+2, h=latchWidth, center=true); //loop
        rotate([90, 0, 0])
            cylinder(d=2.4, h=latchWidth+e, center=true); //bar hole
    }
    
    difference() {
        translate([-(w+1.5)/4, 0, (2+2-.5)/2]) cube(size=[(w+1.5)/2, latchWidth, latchThick], center=true); //latch end
        rotate([90, 0, 0])
            cylinder(d=2.4+2, h=latchWidth+e, center=true);
    }
    
}

translate([30, 0, 0]) longStrap();
translate([0, w*2, 0]) shortStrap();

buckle();
latch();








module prism(l, w, h){
    polyhedron(
        points=[[0,0,0], [l,0,0], [l,w,0], [0,w,0], [0,w,h], [l,w,h]],
        faces=[[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]
    );
}
