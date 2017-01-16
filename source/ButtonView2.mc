//!
//! Copyright 2016 by Garmin Ltd. or its subsidiaries.
//! Subject to Garmin SDK License Agreement and Wearables
//! Application Developer Agreement.
//!

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class ButtonView2 extends Ui.View {

    //! Constructor
    function initialize() {
        View.initialize();
    }

    //! Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.Button2Layout(dc));
    }

    //! Update the view
    function onUpdate(dc) {
    
        View.onUpdate(dc);
    	dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.drawText(40, 15, Gfx.FONT_LARGE, "OUTDOOR", Gfx.TEXT_JUSTIFY_LEFT);
        dc.drawText(40, 45, Gfx.FONT_LARGE, "(GPS ON)", Gfx.TEXT_JUSTIFY_LEFT); 
        dc.drawText(40, 95, Gfx.FONT_LARGE, "INDOOR", Gfx.TEXT_JUSTIFY_LEFT);
        dc.drawText(40, 125, Gfx.FONT_LARGE, "(GPS OFF)", Gfx.TEXT_JUSTIFY_LEFT);
    }
}
