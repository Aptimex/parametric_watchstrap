/* [ Straps ] */
//Length of the strap with holes in it (not including bar loop)
longLen = 125;
strapWidth = 18;
strapFlatLen = longLen-strapWidth; //Allow space for curved end
//Length of the strap without holes (not including bar loop)
shortLen = 65;
//Make this a multiple of your layer height
strapThickness = 1.2;
//Diameter of retaining bars that came with the watch
barDia = 2;
//Amount of material surrounding/holding the watch bars
loopThickness = 1.2;
//Add cutouts to make it easier to remove retainer bars
loopCutouts = true;
//Length of cutouts in end of loops to allow bar removal
loopCutoutLen = 3;
barLoopOD = barDia + loopThickness*2;

/* [ Holes ] */
numHoles = 12;
//space between each hole
holeSpacing = 3;
holeLen = 2;
holeWidth = 6;
//approx distance from end of long strap to first hole
holeOffset = 20;
holesTotalLen = numHoles * (holeLen+holeSpacing);

/* [ Buckle ] */
latchWidth = holeWidth-.5;
latchThickness = 1.2;
//May be different from bar diameter; can also use a piece of filament
buckleBarDia = 2;
BuckleBarLoopOD = buckleBarDia + loopThickness*2;
buckleArmWidth = 1.5;


/* [ Render ] */
pattern = false;
border = false;
makeShortStrap=true;
makeLongStrap=true;
makeLargeBuckle=false;
makeMediumBuckle=false;
makeSmallBuckle=true;
makeBuckleLatch=true;
makeRetainerLoop=true;

/* [ Pattern and border stuff ] */
pattern_long_offset_y = -38.1;
pattern_long_offset_x = -53.1;
pattern_long_len_y = 100;
pattern_long_len_x = 100;
//adjust how far past/before the start of the holes the pattern can go (long strap only)
pattern_long_trim_x = 0;

pattern_short_offset_y = -38.1;
pattern_short_offset_x = -1.5;
pattern_short_len_y = 100;
pattern_short_len_x = 100;
//height of border and/or pattern
border_pattern_height = .6;
longPatternFile = "circuit-board.svg";
shortPatternFile = "circuit-board.svg";

//stop processing customizer variables
module blank() {}

$fn = 32;
e = 0.01;



module loophole(innerDia) {
    loopOD = innerDia + loopThickness*2;
    translate([0, 0, loopOD/2 - strapThickness/2])
    rotate([90, 0, 0])
    cylinder(d=innerDia, h=strapWidth+e, center=true);
}

module loop(innerDia, cutout=loopCutouts) {
    loopOD = innerDia + loopThickness*2;
    
    difference() {
        hull() {
            translate([0, 0, loopOD/2 - strapThickness/2])
            rotate([90, 0, 0])
            cylinder(d=loopOD, h=strapWidth, center=true);
            
            //meet strap body
            translate([loopOD/2, 0, 0])
            cube(size=[loopOD, strapWidth, strapThickness], center=true);
            
            translate([loopOD/2+(loopOD-loopThickness)/2, -strapWidth/2, -strapThickness/2])
            rotate([0, 0, 90])
            prism(strapWidth, loopOD/2, loopOD/2);
        }
        loophole(innerDia);
        
        //bar removal cutouts
        if (cutout) {
            difference() {
                translate([innerDia/2, -(strapWidth + loopCutoutLen + e)/2 + loopCutoutLen, 0])
                //rotate([0, -35, 0])
                cube(size=[2, loopCutoutLen, innerDia + loopThickness + e], center=true);
                
                //color([255/255, 0/255, 0/255])
                rotate([0, 180, -90])
                translate([-strapWidth/2, innerDia/2, -loopThickness/2-innerDia/2-e])
                prism(loopCutoutLen, 2, 2);
            }
        
            difference() {
                translate([innerDia/2, (strapWidth + loopCutoutLen + e)/2 - loopCutoutLen, 0])
                //rotate([0, -35, 0])
                cube(size=[2, loopCutoutLen, innerDia + loopThickness + e], center=true);
            
                //color([0/255, 255/255, 0/255])
                rotate([0, 180, -90])
                translate([strapWidth/2-loopCutoutLen, innerDia/2, -loopThickness/2-innerDia/2-e])
                prism(loopCutoutLen, 2, 2);
            }
        }
    }
}

//make short or long strap body
module strapBody(long=true) {
    if (long == true) {
        //strap body
        translate([strapFlatLen/2, 0, 0]) cube(size=[strapFlatLen, strapWidth, strapThickness], center=true);
        
        //strap end
        translate([strapFlatLen, 0, 0]) linear_extrude(height=strapThickness, center=true) circle(r=strapWidth/2);
    } else {
        //strap body
        translate([shortLen/2, 0, 0]) cube(size=[shortLen, strapWidth, strapThickness], center=true);
    }
    
    
}

module longStrap(noLoop=false) {
    difference() {
        strapBody(long=true);
        
        //holes
        //translate([strapFlatLen-holesTotalLen-strapWidth/2 + (holeSpacing+holeLen/2) + holeOffset, 0, 0])
        translate([strapFlatLen-holesTotalLen+strapWidth/2+holeSpacing - holeOffset, 0, 0])
        for (i=[0:numHoles-1]) {
            translate([i * (holeSpacing+holeLen), 0, 0]) cube(size=[holeLen, holeWidth, strapThickness*3], center=true);
        }
    }
    
    //strap bar loop
    if (noLoop == false) {
        translate([-barLoopOD/2, 0, 0])
            loop(barDia);
    }
    
    
}

module longStrapPattern() {
    longStrap();
    patternLen = strapFlatLen-strapWidth/2-holesTotalLen+holeSpacing+pattern_long_trim_x;
    
    if (pattern) {
        //add pattern
        intersection() {
            scale([1, 1, 5]) longStrap(noLoop=true);
            //resize([strapFlatLen-holesTotalLen,0,strapThickness*5]) strapBody(true);
            translate([patternLen/2, 0, 0]) cube(size=[patternLen, strapWidth, strapThickness*5], center=true);
            translate([pattern_long_offset_x, pattern_long_offset_y-strapWidth/2, border_pattern_height/2]) resize([pattern_long_len_x, pattern_long_len_y, 0]) linear_extrude(height=strapThickness+border_pattern_height, center=true)
                import(longPatternFile);
        }
    }
    //translate([patternLen/2, 0, 0]) cube(size=[patternLen, strapWidth, strapThickness*5], center=true);
    
    if (border) {
        //add border
        difference() {
            translate([0, 0, border_pattern_height/2]) resize([0, 0, strapThickness+border_pattern_height]) strapBody();
            translate([-e, 0, strapThickness/2]) resize([(strapFlatLen+strapWidth/2)-1, strapWidth-2, 20]) strapBody();
        }
    }
    
    
}

module shortStrap(addLoop=true) {
    strapBody(long=false);
    
    //strap bar loops
    if (addLoop) {
        translate([-barLoopOD/2, 0, 0])
            loop(barDia);
        
        //cutout for latch
        mirror([1, 0, 0])
        translate([-barLoopOD-shortLen, 0, 0])
        difference() {
            loop(buckleBarDia, false);
            cube(size=[barLoopOD+2, latchWidth+.5, barLoopOD+10], center=true);
        }
    }
}

module shortStrapPattern() {
    shortStrap();
    
    if (pattern) {
        //add pattern
        intersection() {
            scale([1, 1, 5]) shortStrap(addLoop=false);
            translate([pattern_short_offset_x, pattern_short_offset_y-strapWidth/2, border_pattern_height/2]) resize([pattern_short_len_x, pattern_short_len_y, 0]) linear_extrude(height=strapThickness+border_pattern_height, center=true)
                import(shortPatternFile);
        }
    }
    
    if (border) {
        //add border
        difference() {
            translate([0, 0, border_pattern_height/2]) resize([0, 0, strapThickness+border_pattern_height]) strapBody(long=false);
            translate([-e, 0, strapThickness/2]) resize([(strapFlatLen+strapWidth/2)-1, strapWidth-2, 20]) strapBody(long=false);
        }
    }
    
}

module buckle() {
    width = strapWidth+.5;
    side = width + buckleArmWidth*2; //~3mm crossbar thickness
    
    //calc curve radius from circle chord len and height
    curveH = 2;
    curveR = (strapWidth+3)*(strapWidth+3)/(8*curveH) + curveH/2;
    curveTopR= curveR+0;
    
    //main body
    difference() {
        intersection() { //curved body top
            cube(size=[side+2, side, strapThickness+3], center=true);
            
            translate([0, 0, -curveTopR+curveH+1])
            rotate([90, 0, 0])
            cylinder(r=curveTopR, h=side+e, center=true);
        }
        
        translate([0, 0, -curveR])
        rotate([90, 0, 0])
        cylinder(r=curveR, h=side+e, center=true); //form bottom curve
        
        translate([0, 0, -curveR*3])
        rotate([90, 0, 0])
        cylinder(r=curveR*3+.5, h=width, center=true); //front cutout in center curve
        
        cube(size=[width-2, width, 10], center=true); //center cutout
        
        translate([-width/2, 0, 1+strapThickness/2])
        cube(size=[2+e, latchWidth+.5, latchThickness+1], center=true); //latch groove
        
        rotate([90, 0, 0])
        cylinder(d=buckleBarDia, h=side+e, center=true); //bar hole
    }
    
    //axle holders
    difference() {
        scale([2, 1, 1])
        rotate([90, 0, 0])
        cylinder(d=buckleBarDia+2, h=side, center=true); //oblong holders
        
        translate([0, 1, 0])
        rotate([90, 0, 0])
        cylinder(d=buckleBarDia, h=side*2, center=true); //axle hole
            
        //rotate([90, 0, 0])
        //cylinder(d=buckleBarDia-.5, h=side+e, center=true); //axle push-out hole
            
        cube(size=[width-2, width, 10], center=true); //center cutout
    }
}

module halfBuckle() {
    difference() {
        buckle();
        translate([(strapWidth+buckleBarDia+2)/2, 0, 0]) cube(size=[strapWidth, strapWidth*2, strapWidth], center=true);
    }
}

module mediumBuckle() {
    difference() {
        buckle();
        
        translate([(strapWidth+buckleBarDia+5.8)/2, 0, 0])
        cube(size=[strapWidth, strapWidth*2, strapWidth], center=true);
    }
    
    //back bar
    translate([4.9, 0, 1.1]) cube(size=[2, strapWidth+.5 + buckleArmWidth*2, 2], center=true);
}

module smallBuckle() {
    difference() {
        buckle();
        
        translate([(strapWidth+buckleBarDia+2.4)/2, 0, 0])
        cube(size=[strapWidth, strapWidth*2, strapWidth], center=true);
    }
}

module latch() {
    difference() {
        rotate([90, 0, 0])
        cylinder(d=buckleBarDia + 2.4, h=latchWidth, center=true); //loop
        
        rotate([90, 0, 0])
        cylinder(d=buckleBarDia + 0.4, h=latchWidth+e, center=true); //bar hole
    }
    
    difference() {
        //translate([-(strapWidth+1.5)/4, 0, (2+2-.5)/2])
        translate([-(strapWidth+1.5)/4, 0, (buckleBarDia + latchThickness)/2])
        cube(size=[(strapWidth+1.5)/2, latchWidth, latchThickness], center=true); //latch end
        
        rotate([90, 0, 0])
        cylinder(d=buckleBarDia + 0.4 + e, h=latchWidth+e, center=true);
    }
    
}

module retainer() {
    extra = 0.6;
    retainerThickness = 1.2;
    retainerHeight = 9;
    bandThickness = (border || pattern) ? strapThickness+border_pattern_height : strapThickness;
    echo(str("bandThickness", bandThickness));
    
    difference() {
        //cube(size=[bandThickness*2 + retainerThickness*2 + extra, strapWidth + retainerThickness*2 + extra, 9], center=true);
        roundedcube_simple(size=[bandThickness*2 + retainerThickness*2 + extra, strapWidth + retainerThickness*2 + extra, 9], center=true, radius=.8);
        cube(size=[bandThickness*2 + extra, strapWidth + extra, retainerHeight+e], center=true);
    }
    echo(str("loop width = ", strapWidth + retainerThickness*2 + extra));
    
}

if (makeShortStrap) {
    translate([0, 3*strapWidth, 0]) shortStrapPattern();
}
if (makeLongStrap) {
    translate([0, 1.5*strapWidth, 0]) longStrapPattern();
}
/*
if (makeBuckle) {
    translate([2*strapWidth, 0, 0]) {
        //halfBuckle();
        mediumBuckle();
        //buckle();
        //latch();
    }
}
*/
if (makeLargeBuckle) {
    translate([2*strapWidth, 0, 0])
    buckle();
}
if (makeMediumBuckle) {
    translate([2*strapWidth, 0, 0])
    mediumBuckle();
}
if (makeSmallBuckle) {
    translate([2*strapWidth, 0, 0])
    smallBuckle();
}

if (makeBuckleLatch) {
    translate([2*strapWidth, 0, 0]) {
        latch();
    }
}

if (makeRetainerLoop) {
    translate([3*strapWidth, 0, 0]) retainer();
}












module prism(len, width, h){
    polyhedron(
        points=[[0,0,0], [len,0,0], [len,width,0], [0,width,0], [0,width,h], [len,width,h]],
        faces=[[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]
    );
}

//https://gist.github.com/groovenectar/292db1688b79efd6ce11
module roundedcube_simple(size = [1, 1, 1], center = false, radius = 0.5) {
	// If single value, convert to [x, y, z] vector
	size = (size[0] == undef) ? [size, size, size] : size;

	translate = (center == false) ?
		[radius, radius, radius] :
		[
			radius - (size[0] / 2),
			radius - (size[1] / 2),
			radius - (size[2] / 2)
	];

	translate(v = translate)
	minkowski() {
		cube(size = [
			size[0] - (radius * 2),
			size[1] - (radius * 2),
			size[2] - (radius * 2)
		]);
		sphere(r = radius);
	}
}
