PUI ui;
Slider[] formColorSliders, dformColorSliders, backgroundColorSliders;

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

	formColorSliders = addColorSliders("Color","colArg1","colArg2","colArg3", 255);
	dformColorSliders = addColorSliders("Increments", "dcolArg1", "dcolArg2", "dcolArg3", 127);
	backgroundColorSliders = addColorSliders("Background", "bg1", "bg2", "bg3", 255);

	updateColorSliders();

	for (int i = 0; i < 3; i++) {
		formColorSliders[i].calls("formColorsCallback");
		backgroundColorSliders[i].calls("backgroundColorCallback");	
	}
}

Slider[] addColorSliders(String title, String p1, String p2, String p3, float maxVal){
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

void updateColorSliders(){
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

void formColorsCallback(Slider s){
	updateFormColors();
}

void backgroundColorCallback(Slider s){
	background = color(bg1,bg2,bg3);
}
