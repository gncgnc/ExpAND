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

	addColorSliders("Color","colArg1","colArg2","colArg3");
	addColorSliders("Increments", "dcolArg1", "dcolArg2", "dcolArg3");
	addColorSliders("Background", "bg1", "bg2", "bg3");
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
