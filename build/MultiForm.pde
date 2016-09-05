class MultiForm{
	ArrayList<Form> fs;
	int numParticles;
	int displayMode;
	String noiseSeed;

	MultiForm(int numParticles){
		fs = new ArrayList<Form>(); 
		this.numParticles = numParticles;

		fs.add(new Form(numParticles));
	}

	void display() {
		for (int i=fs.size()-1; i>=0; i--) {
			fs.get(i).display();
		}
	}

	void displayMode(int mode) {
		displayMode = mode;
		for (Form f : fs) {
			f.displayMode(mode);
		}
	}

	void expandNext(){
		//implement
		Form newF = curr().copy();
		newF.expand();
		fs.add(newF);
	}

	Form curr(){
		if(fs.size() > 0) {
			return fs.get(fs.size()-1);
		}
		return new Form(0);
	}

	void reset(){
		fs.clear();
		fs.add(new Form(numParticles));
		displayMode(displayMode);
		curr().arrangeCircle(initialRad);
		float ns = random(1000);	
		noiseSeed((long) ns);
		noiseSeed = "" + ns;
	}
}