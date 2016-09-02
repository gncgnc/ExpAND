import com.martinleopold.pui.*;

MultiForm mf;
float initialRad;

color currentFill, currentStroke, background;
float currentStrokeWeight;
boolean isFilled, isStroked;

float colArg1, colArg2, colArg3, 
	  dcolArg1, dcolArg2, dcolArg3,
	  bg1,bg2,bg3;

void setup(){
	size(650, 650, P2D);
	background(255);
	smooth(4);
	strokeCap(ROUND);
	colorMode(HSB);

	constructUI();

	mf = new MultiForm(500);
	mf.displayMode(0);
	initialRad = width*0.05;

	mf.curr().arrangeCircle(initialRad);

	bg1 = 0;
	bg2 = 0;
	bg3 = 0;
	background = color(bg1,bg2,bg3);

	colArg1 = 200;
	colArg2 = 200;
	colArg3 = 200;
	currentFill = color(colArg1, colArg2, colArg3);
	currentStroke = color(colArg1, colArg2, colArg3);
	currentStrokeWeight = 1;
	isStroked = false;
	isFilled = true;
	configColors();
}

void draw(){
	background = color(bg1,bg2,bg3);
	background(background);

	pushMatrix();
	translate(width/2, height/2);
	mf.display();
	popMatrix();

	fill(0);
	text(mf.curr().expMode, textAscent(), height-textAscent());
}

void configColors(){
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
			configColors();
		break;

		case ' ':
			mf.reset();
			configColors();
		break;

		case '.' :
			colArg1 -= dcolArg1;
			colArg2 -= dcolArg2;
			colArg3 -= dcolArg3;
			colArg1 %= 256;
			colArg2 %= 256;
			colArg3 %= 256;
			mf.fs.remove(mf.curr());
		break;	

		case 's':
			saveFrame("../captures/expand-####.png");
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

