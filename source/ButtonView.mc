//!
//! Copyright 2016 by Garmin Ltd. or its subsidiaries.
//! Subject to Garmin SDK License Agreement and Wearables
//! Application Developer Agreement.
//!

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class ButtonView extends Ui.View {

    //! Constructor
    function initialize() {
        View.initialize();
    }

    //! Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.ButtonLayout(dc));
    }

    //! Update the view
    function onUpdate(dc) {
    
        View.onUpdate(dc);
    	dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.drawText(40, 20, Gfx.FONT_LARGE, "Save", Gfx.TEXT_JUSTIFY_LEFT);
        dc.drawText(40, 80, Gfx.FONT_LARGE, "Discard", Gfx.TEXT_JUSTIFY_LEFT);  
        dc.drawText(40, 140, Gfx.FONT_LARGE, "Return", Gfx.TEXT_JUSTIFY_LEFT);
    }
}
