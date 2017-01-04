//!
//! Copyright 2016 by Garmin Ltd. or its subsidiaries.
//! Subject to Garmin SDK License Agreement and Wearables
//! Application Developer Agreement.
//!

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class MenuButtonView extends Ui.View {

	var stageString = ["Hi Int ","Recov "];
	var paramString = ["mins","secs","HR"];
	var sampleView = null;

    //! Constructor
    function initialize() {
        View.initialize();
    }

    //! Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.MenuButtonLayout(dc));
    }
    
    function setSampleView(sv){
    	sampleView = sv;
    	sampleView.paramPoint = 0;
    }

    //! Update the view
    function onUpdate(dc) { 
        View.onUpdate(dc);
    	dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
    	var point = sampleView.paramPoint;
    	if (point==0 || point==1){
    		var stageParams = sampleView.params[point];
        	dc.drawText(0, 10, Gfx.FONT_MEDIUM, stageString[point], Gfx.TEXT_JUSTIFY_LEFT);
        	dc.drawText(0, 30, Gfx.FONT_MEDIUM, paramString[0], Gfx.TEXT_JUSTIFY_LEFT);
        	dc.drawText(100, 20, Gfx.FONT_LARGE, stageParams[0].toString(), Gfx.TEXT_JUSTIFY_CENTER);
        	dc.drawText(0, 70, Gfx.FONT_MEDIUM, stageString[point], Gfx.TEXT_JUSTIFY_LEFT);
        	dc.drawText(0, 90, Gfx.FONT_MEDIUM, paramString[1], Gfx.TEXT_JUSTIFY_LEFT);
        	dc.drawText(100, 80, Gfx.FONT_LARGE, stageParams[1].toString(), Gfx.TEXT_JUSTIFY_CENTER);  
        	dc.drawText(0, 130, Gfx.FONT_MEDIUM, stageString[point], Gfx.TEXT_JUSTIFY_LEFT);
        	dc.drawText(0, 150, Gfx.FONT_MEDIUM, paramString[2], Gfx.TEXT_JUSTIFY_LEFT);
        	dc.drawText(90, 140, Gfx.FONT_LARGE, stageParams[2].toString(), Gfx.TEXT_JUSTIFY_CENTER);
        }
    }
}
