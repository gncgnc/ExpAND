void constructUI(){
	ui = PUI.init(this).size(2*width/3, height);
	//with VSliders
	//ui.columnWidth(2*width/3);

	ui.addLabel("Appearence Menu").large();
	ui.newRow();

	ui.addButton().label("rand");
	ui.newRow();

	ui.addToggle().label("fill");
	ui.addToggle().label("stroke");
	ui.addToggle().label("both");
	ui.newColumn();

	ui.addLabel("Fill");
	ui.newRow();

	ui.addSlider().label("H");
	ui.addSlider().label("S");
	ui.addSlider().label("B");
	ui.newRow();
	ui.addDivider();

	ui.addSlider().label("dH");
	ui.addSlider().label("dS");
	ui.addSlider().label("dB");
	ui.newColumn();	

	ui.addLabel("Stroke");
	ui.newRow();
	ui.addSlider().label("H");
	ui.addSlider().label("S");
	ui.addSlider().label("B");
	ui.newRow();
	ui.addDivider();

	ui.addSlider().label("dH");
	ui.addSlider().label("dS");
	ui.addSlider().label("dB");
}
