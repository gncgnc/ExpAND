class Particle{
	PVector pos, vel, acc;
	float size;

	Particle(){
		pos = new PVector();
		vel = new PVector();
		acc = new PVector();

		size = 5;
	}

	Particle(PVector pos){
		this.pos = pos;

		size = 5;
	}

	Particle(float x, float y){
		pos = new PVector(x,y);

		size = 5;
	}

	void display(){
		noStroke();
		fill(0);
		ellipse(pos.x, pos.y, size, size);
	}

	void update() {
	   vel.add(acc);
	   pos.add(vel);
	   acc.mult(0);
	}

	Particle copy(){
		Particle p = new Particle();
		p.pos = pos.copy();
		// p.vel = vel.copy();
		// p.acc = acc.copy();
		return p;
	}

}