import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import com.martinleopold.pui.*; 
import processing.pdf.*; 
import java.util.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class build extends PApplet {





boolean saveToPDF = false;
PGraphics pdf;

MultiForm mf;
float initialRad;

int currentFill, currentStroke, background;
float currentStrokeWeight;
boolean isFilled, isStroked;

float colArg1, colArg2, colArg3, 
	  dcolArg1, dcolArg2, dcolArg3,
	  bg1,bg2,bg3;

public void setup(){
	
	background(255);
	
	strokeCap(ROUND);
	colorMode(HSB);

	mf = new MultiForm(500);
	mf.displayMode(0);
	initialRad = width*0.05f;

	mf.curr().arrangeCircle(initialRad);

	bg1 = 134;
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

public void draw(){
	background = color(bg1,bg2,bg3);

	if(saveToPDF == true) {
		mf.displayMode(-1);
    	pdf = createGraphics(width, height, PDF, "../captures/expand-####.pdf");
    	pdf.beginDraw();
    	pdf.background(background);
    	pdf.endDraw();
    }

	background(background);

	pushMatrix();
	translate(width/2, height/2);
	mf.display();
	popMatrix();

	fill(0);
	text((String) mf.curr().expMode.get("name"), 
		textAscent(), height-textAscent());

	if(saveToPDF == true) {
    	endRecord();
    	saveToPDF = false; 
  	}
}

public void updateFormColors(){
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

public void keyPressed() {
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
			saveFrame("../captures/expand-####.png");
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
			int index = PApplet.parseInt(key)-48;
			if(index < mf.curr().expModes.length && index >= 0){
				mf.curr().expMode = mf.curr().expModes[index];
			} 
		break;		
	}
}

public ArrayList copyParticleArrayList(ArrayList<Particle> arrl){
	ArrayList<Particle> dest = new ArrayList<Particle>();
	for(int i=0; i<arrl.size(); i++){
		dest.add(arrl.get(i).copy());
	}

	return dest;
}

public ArrayList copyPVectorArrayList(ArrayList<PVector> arrl){
	ArrayList<PVector> dest = new ArrayList<PVector>();
	for(int i=0; i<arrl.size(); i++){
		dest.add(arrl.get(i).copy());
	}

	return dest;
}

class Form{
	ArrayList<Particle> ps;
	ArrayList<PVector> expansions;
	float numParticles;

	PShape s;

	boolean noStroke, noFill;
	int stroke, fill;
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

	public void display(){
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
				pdf.shape(s);
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

	public void expand(){
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

	public PVector compExpVec(Particle p, int i, HashMap<String, Object> mode){
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
				detail = detail==-1 ? 0.03f : detail;
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
				detail = detail==-1 ? 0.03f : detail;
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
				mag = 0.7f*n+0.3f*s; }
			break;

			case "sin*noise":{
				float detail = (float) mode.get("detail");
				detail = detail==-1 ? 0.03f : detail;
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
				detail = detail==-1 ? 0.03f : detail;
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

	public void compPShape(){
		s = createShape();
		s.beginShape();
		for (int i=0; i<ps.size(); i++) {
			Particle p1 = ps.get(i);
			s.vertex(p1.pos.x, p1.pos.y);
		}
		s.endShape(CLOSE);
	}

	public void updateStyle(){
		if(!noFill)	s.setFill(fill);
		if(!noStroke) s.setStroke(stroke);

		s.beginShape();
		s.strokeWeight(strokeWeight);
		if(noFill)	s.noFill();
		if(noStroke) s.noStroke();
		s.endShape(CLOSE);
	}

	public void displayMode(int mode){
		displayMode = mode;
	}

	public Form copy(){
		Form f = new Form(numParticles);

		f.ps = copyParticleArrayList(ps);
		f.expansions = copyPVectorArrayList(expansions);	

		f.displayMode = displayMode;
		f.expMode = expMode;

		return f;
	}

	public Form setStroke(float r, float g, float b){
		stroke = color(r,g,b);
		return this;
	}

	public Form setStroke(float r, float g, float b, float a){
		stroke = color(r,g,b,a);
		return this;
	}

	public Form setStroke(int col){
		stroke = col;
		return this;
	}

	public Form setStrokeWeight(float w){
		strokeWeight = w;
		return this;
	}

	public Form setFill(float r, float g, float b){
		fill = color(r,g,b);
		return this;
	}

	public Form setFill(float r, float g, float b, float a){
		fill = color(r,g,b,a);
		return this;
	}

	public Form setFill(int col){
		fill = col;
		return this;
	}

	public Form setNoFill(boolean b){
		noFill = b;
		return this;
	}

	public Form toggleFill(){
		noFill = !noFill;
		return this;
	}

	public Form setNoStroke(boolean b){
		noStroke = b;
		return this;
	}

	public Form toggleStroke(){
		noStroke = !noStroke;
		println("stroke toggled");
		return this;
	}

	public void arrangeCircle(float r){
		for (int i = 0; i < ps.size(); i++) {
			Particle p = ps.get(i);
			float a = 2*PI*i/ps.size();
			p.pos = new PVector(r*sin(a),r*cos(a));	
		}
		compPShape();
	}


	//@SupressWarnings("unchecked")
	public HashMap<String, Object>[] readExpModes(String file){

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
			mode.put("amount", PApplet.parseFloat(width/65));
			mode.put("range", width/65 * 0.5f);

			for (int j = 0; j < parameters.length; j++) {
				if(parameters[j] != "") mode.put(parameters[j], PApplet.parseFloat(-1)); //default value is -1
			}

		}

		return expModes; 
	} 

	public void setNumParticles(int num){
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

class MultiForm{
	ArrayList<Form> fs;
	int numParticles;
	int displayMode;

	MultiForm(int numParticles){
		fs = new ArrayList<Form>(); 
		this.numParticles = numParticles;

		fs.add(new Form(numParticles));
	}

	public void display() {
		for (int i=fs.size()-1; i>=0; i--) {
			fs.get(i).display();
		}
	}

	public void displayMode(int mode) {
		displayMode = mode;
		for (Form f : fs) {
			f.displayMode(mode);
		}
	}

	public void expandNext(){
		//implement
		Form newF = curr().copy();
		newF.expand();
		fs.add(newF);
	}

	public Form curr(){
		if(fs.size() > 0) {
			return fs.get(fs.size()-1);
		}
		return new Form(0);
	}

	public void reset(){
		fs.clear();
		fs.add(new Form(numParticles));
		displayMode(displayMode);
		curr().arrangeCircle(initialRad);	
		noiseSeed((long) random(1000));
	}
}
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

	public void display(){
		noStroke();
		fill(0);
		ellipse(pos.x, pos.y, size, size);
	}

	public void update() {
	   vel.add(acc);
	   pos.add(vel);
	   acc.mult(0);
	}

	public Particle copy(){
		Particle p = new Particle();
		p.pos = pos.copy();
		// p.vel = vel.copy();
		// p.acc = acc.copy();
		return p;
	}

}
PUI ui;
Slider[] formColorSliders, dformColorSliders, backgroundColorSliders;

public void constructUI(){
	ui = PUI.init(this).size(width/3, height);
	//with VSliders
	//ui.columnWidth(2*width/3);

	ui.addLabel("Appearence Menu").large();
	ui.newRow();

	ui.addButton().label("rand");
	ui.newRow();

	ui.addToggle().label("fill").sets("isFilled");
	ui.addToggle().label("stroke").sets("isStroked");
	ui.newRow();

	formColorSliders = addColorSliders("Color","colArg1","colArg2","colArg3", 255);
	dformColorSliders = addColorSliders("Increments", "dcolArg1", "dcolArg2", "dcolArg3", 127);
	backgroundColorSliders = addColorSliders("Background", "bg1", "bg2", "bg3", 255);

	updateColorSliders();

	for (int i = 0; i < 3; i++) {
		formColorSliders[i].calls("formColorsCallback");
		backgroundColorSliders[i].calls("backgroundColorCallback");	
	}
}

public Slider[] addColorSliders(String title, String p1, String p2, String p3, float maxVal){
	Slider[] sliders = new Slider[3];
	ui.addLabel(title);
	ui.newRow();
	
	sliders[0] = ui.addSlider().label("H / R").sets(p1).max(maxVal);
	sliders[1] = ui.addSlider().label("S / G").sets(p2).max(maxVal);
	sliders[2] = ui.addSlider().label("B / B").sets(p3).max(maxVal);

	ui.newRow();
	ui.addDivider();

	return sliders;
}

public void updateColorSliders(){
	formColorSliders[0].value(colArg1);
	formColorSliders[1].value(colArg2);
	formColorSliders[2].value(colArg3);

	dformColorSliders[0].value(dcolArg1);
	dformColorSliders[1].value(dcolArg2);
	dformColorSliders[2].value(dcolArg3);

	backgroundColorSliders[0].value(bg1);
	backgroundColorSliders[1].value(bg2);
	backgroundColorSliders[2].value(bg3);
}

public void formColorsCallback(Slider s){
	updateFormColors();
}

public void backgroundColorCallback(Slider s){
	background = color(bg1,bg2,bg3);
}
  public void settings() { 	size(650, 650, P2D); 	smooth(4); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--present", "--window-color=#000000", "--stop-color=#5F5D5D", "build" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
