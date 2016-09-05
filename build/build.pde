import com.martinleopold.pui.*;
import processing.pdf.*;
import java.util.*;

boolean saveToPDF = false;
PGraphics pdf;

MultiForm mf;
float initialRad;

color currentFill, currentStroke, background;
float currentStrokeWeight;
boolean isFilled, isStroked;

float colArg1, colArg2, colArg3, 
	  dcolArg1, dcolArg2, dcolArg3,
	  bg1,bg2,bg3;

void setup(){
	size(650, 650, JAVA2D);
	background(255);
	smooth(4);
	strokeCap(ROUND);
	colorMode(HSB);

	mf = new MultiForm(500);
	mf.displayMode(0);
	initialRad = width*0.05;

	mf.curr().arrangeCircle(initialRad);

	bg1 = 40; //134 for cyan
	bg2 = 161;
	bg3 = 227;
	background = color(bg1,bg2,bg3);

	dcolArg1 = 10;
	dcolArg2 = 0;
	dcolArg3 = 30;

	colArg1 = 200;
	colArg2 = 200;
	colArg3 = 200;
	currentFill = color(colArg1, colArg2, colArg3);
	currentStroke = color(colArg1, colArg2, colArg3);
	currentStrokeWeight = 1;
	isStroked = false;
	isFilled = true;

	constructUI();
	updateFormColors();
}

void draw(){
	background = color(bg1,bg2,bg3);

	if(saveToPDF == true) {
		mf.displayMode(-1);
    	pdf = createGraphics(width, height, PDF, "../captures/pdfs/expand-"+mf.noiseSeed+".pdf");
    	pdf.beginDraw();
    	pdf.background(background);
    	pdf.endDraw();
    } else {
    	background(background);
    }

	pushMatrix();
	translate(width/2, height/2);
	mf.display();
	popMatrix();

	if(saveToPDF == true) {
    	mf.displayMode(0); 
    	pdf.beginDraw();
    	pdf.dispose();
    	pdf.endDraw();
    	saveToPDF = false; 
  	}

  	fill(0);
	text((String) mf.curr().expMode.get("name"), 
		textAscent(), height-textAscent());
}

void updateFormColors(){
	currentFill = color(colArg1, colArg2, colArg3);
	currentStroke = color(colArg1, colArg2, colArg3);

	mf.curr()
		.setFill(currentFill)
		.setStroke(currentStroke)
		.setStrokeWeight(currentStrokeWeight)
		.setNoStroke(!isStroked)
		.setNoFill(!isFilled)
		.updateStyle()
	;

	updateColorSliders();
}

void keyPressed() {
	switch (key) {
		case '\n': 
			mf.expandNext(); 
			colArg1 += dcolArg1;
			colArg2 += dcolArg2;
			colArg3 += dcolArg3;
			colArg1 %= 256;
			colArg2 %= 256;
			colArg3 %= 256;
			updateFormColors();
		break;

		case ' ':
			mf.reset();
			updateFormColors();
		break;

		case '.' :
			colArg1 -= dcolArg1;
			colArg2 -= dcolArg2;
			colArg3 -= dcolArg3;
			colArg1 %= 256;
			colArg2 %= 256;
			colArg3 %= 256;
			if(mf.fs.size() > 1) mf.fs.remove(mf.curr());
		break;	

		case 'x' : //for debugging
			HashMap<String, Object>[] arr = mf.curr().expModes;
			for (int i = 0; i < arr.length; i++) {
				HashMap<String, Object> mp = arr[i];
				println(mp);
			}
			println(mf.curr().expModes.length);
		break;	

		case 's':
			saveFrame("../captures/expand-"+mf.noiseSeed+".png");
		break;

		case 'r' :
			ui.hide();
			saveToPDF = true;
		break;	

		case 'q':
			exit();
		break;

		case '+' :
			ui.toggle();
		break;	

		default :
			int index = int(key)-48;
			if(index < mf.curr().expModes.length && index >= 0){
				mf.curr().expMode = mf.curr().expModes[index];
			} 
		break;		
	}
}

ArrayList copyParticleArrayList(ArrayList<Particle> arrl){
	ArrayList<Particle> dest = new ArrayList<Particle>();
	for(int i=0; i<arrl.size(); i++){
		dest.add(arrl.get(i).copy());
	}

	return dest;
}

ArrayList copyPVectorArrayList(ArrayList<PVector> arrl){
	ArrayList<PVector> dest = new ArrayList<PVector>();
	for(int i=0; i<arrl.size(); i++){
		dest.add(arrl.get(i).copy());
	}

	return dest;
}

