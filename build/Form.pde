class Form{
	ArrayList<Particle> ps;
	ArrayList<PVector> expansions;
	float numParticles;

	PShape s;

	boolean noStroke, noFill;
	color stroke, fill;
	float strokeWeight;

	int displayMode;
	HashMap<String, Object> expMode;

	HashMap<String, Object>[] expModes;

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

		//expModes = loadStrings("expModes.txt");
		expModes = readExpModes("expModes.txt");
		expMode = expModes[0];
	}

	void display(){
		switch (displayMode) {
			case 0:
				// *this might have better performance for animation purposes
				// beginShape();
				// for (int i=0; i<ps.size(); i++) {
				// 	Particle p1 = ps.get(i);
				// 	vertex(p1.pos.x, p1.pos.y);
				// }
				// endShape(CLOSE);
				shape(s);
			break;

			case -1 :
				pdf.beginDraw();
				pdf.pushMatrix();
				pdf.translate(width/2, height/2);
				pdf.shape(s);
				pdf.popMatrix();
				pdf.endDraw();
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

	PVector compExpVec(Particle p, int i, HashMap<String, Object> mode){
		//Computes expansion vector of a Particle p at index i w.r.t. the expMode
		PVector v = p.pos.copy();
		v.normalize();
		float mag = 1;

		String name = (String) mode.get("name");
		float amount = (float) mode.get("amount");
		float range = (float) mode.get("range");

		switch (name) {
			case "":
				mag = amount;
			break;

		 	case "random":
		 		mag = random(amount, amount + range);
		 	break;

		 	case "randomGaussian":
		 		mag = map(randomGaussian(), -2, 2, amount, amount + range);
		 	break;

		 	case "noise":{
		 		float detail = (float) mode.get("detail");
				detail = detail==-1 ? 0.03 : detail;
				float yoff = (float) mode.get("yoff");
				yoff = yoff==-1 ? 0 : yoff;
		 		mag = map(noise((ps.size()-i-1)*detail, yoff) + noise(i*detail, yoff),
		 		          0,
		 		          2,
		 		          amount - range,
		 		          amount + range  
		 		        );}
		 	break;

		 	case "sin":{
		 		float numPeaks = (float) mode.get("numPeaks");
				numPeaks = numPeaks==-1 ? 12 : numPeaks;
				float phase = (float) mode.get("phase");
				phase = phase==-1 ? 0 : phase;
		 		mag = map(sin(TWO_PI / ps.size() * i * numPeaks + phase), 
		 			      -1,
		 			      1,
		 			      amount - range/2,
		 			      amount + range/2
		 			); }
		 	break;

			case "sin+noise": {
				float detail = (float) mode.get("detail");
				detail = detail==-1 ? 0.03 : detail;
				float numPeaks = (float) mode.get("numPeaks");
				numPeaks = numPeaks==-1 ? 12 : numPeaks;
				float phase = (float) mode.get("phase");
				phase = phase==-1 ? 0 : phase;
				float yoff = (float) mode.get("yoff");
				yoff = yoff==-1 ? 0 : yoff;
				//float n = 10 * noise(((ps.size()-i-1)*0.03) + noise(i*0.03));
				float n = noise((ps.size()-i-1)*detail, yoff) + noise(i*detail, yoff);
				n = map(n, 0, 2, amount, amount + range);
		 		//float s = 2.5 * (sin(TWO_PI / ps.size() * i * 10)+2);
				float s = map(sin(TWO_PI / ps.size() * i * numPeaks + phase),
						  	  -1, 1, amount - range, amount + range);
				mag = 0.7*n+0.3*s; }
			break;

			case "sin*noise":{
				float detail = (float) mode.get("detail");
				detail = detail==-1 ? 0.03 : detail;
				float numPeaks = (float) mode.get("numPeaks");
				numPeaks = numPeaks==-1 ? 12 : numPeaks;
				float phase = (float) mode.get("phase");
				phase = phase==-1 ? 0 : phase;
				float yoff = (float) mode.get("yoff");
				yoff = yoff==-1 ? 0 : yoff;
				// float n = noise(((ps.size()-i-1)*0.03)) + noise(i*0.03);
				// float s = 10 * (sin(TWO_PI / ps.size() * i * 10)+3);
				float n = noise(((ps.size()-i-1)*detail), yoff) + noise(i*detail, yoff);
				float s = map(sin(TWO_PI / ps.size() * i * numPeaks + phase), 
							  -1, 1, amount, amount+range*2);
				mag = n*s;}
			break;

			case "e^noise" : {
				float detail = (float) mode.get("detail");
				detail = detail==-1 ? 0.03 : detail;
				float exponent = (float) mode.get("exponent");
				exponent = exponent==-1 ? 3 : exponent;
				float yoff = (float) mode.get("yoff");
				yoff = yoff==-1 ? 200 : yoff;

				float n = noise(((ps.size()-i-1)*detail), yoff) + noise(i*detail, yoff);
				mag = map(exp(exponent*n), 0, exp(exponent), amount, amount+range);
			}
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

	Form setStroke(color col){
		stroke = col;
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

	Form setFill(color col){
		fill = col;
		return this;
	}

	Form setNoFill(boolean b){
		noFill = b;
		return this;
	}

	Form toggleFill(){
		noFill = !noFill;
		return this;
	}

	Form setNoStroke(boolean b){
		noStroke = b;
		return this;
	}

	Form toggleStroke(){
		noStroke = !noStroke;
		println("stroke toggled");
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


	//@SupressWarnings("unchecked")
	HashMap<String, Object>[] readExpModes(String file){

		String[] lines = loadStrings(file);
		//Array of HashMaps, each corresponding to an expansion mode
		expModes = (HashMap<String, Object>[]) new HashMap[lines.length/2];


		for (int i = 0; i < lines.length; i+=2) {
			HashMap<String, Object> mode = new HashMap<String, Object>(); 
			expModes[i/2] = mode;

			String name = lines[i];
			String[] parameters = lines[i+1].split(" ");

			//default parameters, the first being the name
			mode.put("name",(String) name);
			mode.put("amount", float(width/65));
			mode.put("range", width/65 * 0.5);

			for (int j = 0; j < parameters.length; j++) {
				if(parameters[j] != "") mode.put(parameters[j], float(-1)); //default value is -1
			}

		}

		return expModes; 
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

