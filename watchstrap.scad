$fn = 32;
e = 0.01;

totalLen = 125;
w = 18;
l = totalLen-w;
l2 = 65;

h = 1;

numHoles = 12;
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

pattern=true;
border = true;

//long strap patter offsets
p_l_off_y = -38;
p_l_off_x = -51;
p_l_len_y = 100;
p_l_len_x = p_l_len_y;
p_l_xTrim = 0; //adjust how far past/before the start of the holes the pattern can go (long strap only)

//short strap patter offsets
p_s_off_y = p_l_off_y;
p_s_off_x = -.5;
p_s_len_y = p_l_len_y;
p_s_len_x = p_s_len_y;

border_height = .6;

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
        translate([l, 0, 0]) linear_extrude(height=h, center=true) circle(r=w/2);
    } else {
        //strap body
        translate([l2/2, 0, 0]) cube(size=[l2, w, h], center=true);
    }
    
    
}

module longStrap(noLoop=false) {
    difference() {
        strapBody(true);
        
        //holes
        translate([l-holesLen-w/2 + (holeSpacing+holeW/2) + holeOffset, 0, 0])
        for (i=[0:numHoles-1]) {
            translate([i * (holeSpacing+holeW), 0, 0]) cube(size=[holeW, holeL, 10], center=true);
        }
    }
    
    //strap bar loop
    if (noLoop == false) {
        translate([-dia/2, 0, 0])
            loop();
    }
    
    
}

module longStrapPattern() {
    longStrap();
    patternLen = l-w/2-holesLen+holeSpacing+p_l_xTrim;
    
    if (pattern) {
        //add pattern
        intersection() {
            scale([1, 1, 5]) longStrap(noLoop=true);
            //resize([l-holesLen,0,h*5]) strapBody(true);
            translate([patternLen/2, 0, 0]) cube(size=[patternLen, w, h*5], center=true);
            translate([p_l_off_x, p_l_off_y-w/2, border_height/2]) resize([p_l_len_x, p_l_len_y, 0]) linear_extrude(height=h+border_height, center=true)
                import("circuit-board.svg");
        }
    }
    //translate([patternLen/2, 0, 0]) cube(size=[patternLen, w, h*5], center=true);
    
    if (border) {
        //add border
        difference() {
            translate([0, 0, border_height/2]) resize([0, 0, h+border_height]) strapBody();
            translate([-e, 0, h/2]) resize([(l+w/2)-1, w-2, 20]) strapBody();
        }
    }
    
    
}

module shortStrap(noLoop=false) {
    difference() {
        strapBody(false);
    }
    
    //strap bar loops
    if (noLoop==false) {
        translate([-dia/2, 0, 0])
            loop();
        
        //cutout for latch
        mirror([1, 0, 0])
        translate([-dia-l2, 0, 0])
        difference() {
            loop(filamentDia);
            cube(size=[dia+2, latchWidth+.5, dia+10], center=true);
        }
    }
    
        
}

module shortStrapPattern() {
    shortStrap();
    
    if (pattern) {
        //add pattern
        intersection() {
            scale([1, 1, 5]) shortStrap(noLoop=true);
            translate([p_s_off_x, p_s_off_y-w/2, border_height/2]) resize([p_s_len_x, p_s_len_y, 0]) linear_extrude(height=h+border_height, center=true)
                import("circuit-board.svg");
        }
    }
    
    if (border) {
        //add border
        difference() {
            translate([0, 0, border_height/2]) resize([0, 0, h+border_height]) strapBody(long=false);
            translate([-e, 0, h/2]) resize([(l+w/2)-1, w-2, 20]) strapBody(long=false);
        }
    }
    
}

module buckle() {
    side = w+3*2;
    width=w+.5;
    
    //calc curve radius from circle chord len and height
    curveH = 2;
    curveR = (w+3)*(w+3)/(8*curveH) + curveH/2;
    curveTopR= curveR+0;
    
    //main body
    difference() {
        intersection() { //curved body top
            cube(size=[side, side, h+3], center=true);
            translate([0, 0, -curveTopR+curveH+1]) rotate([90, 0, 0])  cylinder(r=curveTopR, h=side+e, center=true);
        }
        translate([0, 0, -curveR]) rotate([90, 0, 0])  cylinder(r=curveR, h=side+e, center=true); //form bottom curve
        
        cube(size=[width-2, width, 10], center=true); //center cutout
        translate([-width/2, 0, 1+h/2]) cube(size=[2+e, latchWidth+.5, latchThick+1], center=true); //latch groove
        rotate([90, 0, 0])
            cylinder(d=2, h=side+e, center=true); //bar hole
    }
    
    //axle holders
    difference() {
        scale([2, 1, 1])
        rotate([90, 0, 0])
            cylinder(d=filamentDia+2, h=side, center=true); //oblong holders
        translate([0, 1, 0]) rotate([90, 0, 0])
            cylinder(d=filamentDia, h=side+e, center=true); //axle hole
        rotate([90, 0, 0])
            cylinder(d=filamentDia-.5, h=side+e, center=true); //axle push-out hole
        cube(size=[width-2, width, 10], center=true); //center cutout
    }
}

module halfBuckle() {
    difference() {
        buckle();
        translate([(w+filamentDia+2)/2, 0, 0]) cube(size=[w, w*2, w], center=true);
    }
}

module latch() {
    difference() {
        rotate([90, 0, 0])
            cylinder(d=2+.4 + 2, h=latchWidth, center=true); //loop
        rotate([90, 0, 0])
            cylinder(d=2+.4, h=latchWidth+e, center=true); //bar hole
    }
    
    difference() {
        translate([-(w+1.5)/4, 0, (2+2-.5)/2]) cube(size=[(w+1.5)/2, latchWidth, latchThick], center=true); //latch end
        rotate([90, 0, 0])
            cylinder(d=2.4+2, h=latchWidth+e, center=true);
    }
    
}

module retainer() {
    extra = 0.6;
    retainerThickness = 1.2;
    retainerHeight = 9;
    bandThickness = (border || pattern) ? h+border_height : h;
    //echo(str("bandThickness", bandThickness));
    
    difference() {
        cube(size=[bandThickness*2 + retainerThickness*2 + extra, w + retainerThickness*2 + extra, 9], center=true);
        cube(size=[bandThickness*2 + extra, w + extra, retainerHeight+e], center=true);
    }
    
}

translate([0, 1.5*w, 0]) longStrapPattern();
//translate([0, 3*w, 0]) shortStrapPattern();

translate([2*w, 0, 0]) {
    //halfBuckle();
    //buckle();
    //latch();
}

//translate([3*w, 0, 0]) retainer();








module prism(l, w, h){
    polyhedron(
        points=[[0,0,0], [l,0,0], [l,w,0], [0,w,0], [0,w,h], [l,w,h]],
        faces=[[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]
    );
}
