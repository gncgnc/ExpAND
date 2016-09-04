PUI ui;

void constructUI(){
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

	ui.addLabel("Color");
	ui.newRow();

	ui.addSlider().label("H / R").sets("colArg1").max(255);
	ui.addSlider().label("S / G").sets("colArg2").max(255);
	ui.addSlider().label("B / B").sets("colArg3").max(255);
	ui.newRow();
	ui.addDivider();

	ui.addSlider().label("dH / dR").sets("dcolArg1").max(50);
	ui.addSlider().label("dS / dG").sets("dcolArg2").max(50);
	ui.addSlider().label("dB / dB").sets("dcolArg3").max(50);
	ui.addDivider();

	addColorSliders("Background", "bg1", "bg2", "bg3");
	
	//ui.newColumn();	

	// ui.addLabel("Stroke");
	// ui.newRow();
	// ui.addSlider().label("H");
	// ui.addSlider().label("S");
	// ui.addSlider().label("B");
	// ui.newRow();
	// ui.addDivider();

	// ui.addSlider().label("dH");
	// ui.addSlider().label("dS");
	// ui.addSlider().label("dB");
}

void addColorSliders(String title, String p1, String p2, String p3){
	ui.addLabel(title);
	ui.newRow();
	
	ui.addSlider().label("H / R").sets(p1).max(255);
	ui.addSlider().label("S / G").sets(p2).max(255);
	ui.addSlider().label("B / B").sets(p3).max(255);
	ui.newRow();
	ui.addDivider();
}
