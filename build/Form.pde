class Form{
	ArrayList<Particle> ps;
	ArrayList<PVector> expansions;
	float numParticles;

	PShape s;

	boolean noStroke, noFill;
	color stroke, fill;
	float strokeWeight;

	int displayMode;
	String expMode;

	String[] expModes;

	Form(float numParticles){
		this.numParticles = numParticles;

		ps = new ArrayList<Particle>();
		expansions = new ArrayList<PVector>();

		for (int i = 0; i < numParticles; i++) {
			ps.add(new Particle());
		}

		fill = color(255,10);
		stroke = color(0);
		noFill = true;
		noStroke = false;

		expModes = loadStrings("expModes.txt");
		expMode = "";
	}

	void display(){
		switch (displayMode) {
			case 0:
				// beginShape();
				// for (int i=0; i<ps.size(); i++) {
				// 	Particle p1 = ps.get(i);
				// 	vertex(p1.pos.x, p1.pos.y);
				// }
				// endShape(CLOSE);
				shape(s);
			break;

			case 1: 
				for (Particle p : ps) {
					p.display();
				}
			break;

			default :
				for (Particle p : ps) {
					point(p.pos.x, p.pos.y);
				}
			break;	
		}
	}

	void expand(){
		for (int i = 0; i < ps.size(); i++) {
			Particle p = ps.get(i);

			//compute expansion vectors:
			PVector v = compExpVec(p, i, expMode);
			expansions.add(v);
			//add expansion vectors to positions
			p.pos.add(v);
		}

		compPShape();
		//later: add new Particles between far apart Particles??
	}

	PVector compExpVec(Particle p, int i, String mode){
		//Computes expansion vector of a Particle p at index i w.r.t. the expMode
		PVector v = p.pos.copy();
		v.normalize();
		float mag = 1;
		switch (mode) {
			case "":
				mag = 10;
			break;

		 	case "random":
		 		mag = random(10,15);
		 	break;

		 	case "randomGaussian":
		 		mag = map(randomGaussian(),-2,2,10,15);
		 	break;

		 	case "noise":
		 		mag = noise((ps.size()-i-1)*0.03)*10 + noise(i*0.03)*10;
		 	break;

		 	case "sin":
		 		mag = 5*sin(TWO_PI / ps.size() * i * 10) + 10;
		 	break;

			case "sin+noise": {
				float n = 10 * noise(((ps.size()-i-1)*0.03) + noise(i*0.03));
				float s = 2.5 * (sin(TWO_PI / ps.size() * i * 10)+2);
				mag = n+s; }
			break;

			case "sin*noise":{
				float n = noise(((ps.size()-i-1)*0.03) + noise(i*0.03));
				float s = 10 * (sin(TWO_PI / ps.size() * i * 10)+3);
				mag = n*s;}
			break;

			default :
				mag = 10;
			break;	
		 } 

		 return v.mult(mag);
	}

	void compPShape(){
		s = createShape();
		s.beginShape();
		for (int i=0; i<ps.size(); i++) {
			Particle p1 = ps.get(i);
			s.vertex(p1.pos.x, p1.pos.y);
		}
		s.endShape(CLOSE);
	}

	void updateStyle(){
		if(!noFill)	s.setFill(fill);
		if(!noStroke) s.setStroke(stroke);

		s.beginShape();
		s.strokeWeight(strokeWeight);
		if(noFill)	s.noFill();
		if(noStroke) s.noStroke();
		s.endShape(CLOSE);
	}

	void displayMode(int mode){
		displayMode = mode;
	}

	Form copy(){
		Form f = new Form(numParticles);

		f.ps = copyParticleArrayList(ps);
		f.expansions = copyPVectorArrayList(expansions);	

		f.displayMode = displayMode;
		f.expMode = expMode;

		return f;
	}

	Form setStroke(float r, float g, float b){
		stroke = color(r,g,b);
		return this;
	}

	Form setStroke(float r, float g, float b, float a){
		stroke = color(r,g,b,a);
		return this;
	}

	Form setStrokeWeight(float w){
		strokeWeight = w;
		return this;

	}

	Form setFill(float r, float g, float b){
		fill = color(r,g,b);
		return this;
	}

	Form setFill(float r, float g, float b, float a){
		fill = color(r,g,b,a);
		return this;
	}

	Form setNoFill(boolean b){
		noFill = b;
		return this;
	}

	Form setNoStroke(boolean b){
		noStroke = b;
		return this;
	}

	void arrangeCircle(float r){
		for (int i = 0; i < ps.size(); i++) {
			Particle p = ps.get(i);
			float a = 2*PI*i/ps.size();
			p.pos = new PVector(r*sin(a),r*cos(a));	
		}
		compPShape();
	}

	void setNumParticles(int num){
		if(num > ps.size()){
			for (int i = ps.size(); i < num; i++) {
				ps.add(new Particle());
			}
		} else {
			for (int i = num; i < ps.size(); i++) {
				ps.remove(i);
			}
		}
	}
}

