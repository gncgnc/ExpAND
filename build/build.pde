MultiForm mf;
float initialRad;

void setup(){
	size(650, 650,P2D);
	background(255);
	smooth(4);
	strokeCap(ROUND);

	mf = new MultiForm(500);
	mf.displayMode(0);
	initialRad = width*0.05;

	mf.curr().arrangeCircle(initialRad);

	configColors();
}

void draw(){
	background(255);

	pushMatrix();
	translate(width/2, height/2);
	mf.display();
	popMatrix();

	fill(0);
	text(mf.curr().expMode, textAscent(), height-textAscent());
}

void configColors(){
	mf.curr()
		.setFill(0,frameCount%256,100)
		.setStroke(100,frameCount%256,100)
		.setStrokeWeight(1)
		.setNoStroke(false)
		.setNoFill(true)
		.updateStyle()
	;
}

void keyPressed() {
	switch (key) {
		case '\n': 
			mf.expandNext(); 
			configColors();
		break;

		case ' ':
			mf.reset();
			configColors();
		break;

		case '.' :
			mf.fs.remove(mf.curr());
		break;	

		case 's':
			saveFrame("../try5-####.png");
		break;

		case 'q':
			exit();
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