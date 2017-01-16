//!
//! Copyright 2016 by Garmin Ltd. or its subsidiaries.
//! Subject to Garmin SDK License Agreement and Wearables
//! Application Developer Agreement.
//!

using Toybox.WatchUi as Ui;
using Toybox.Attention as Attention;
using Toybox.Position as Position;

class ButtonDelegate2 extends Ui.BehaviorDelegate {

	var sampleView = null;

    function initialize() {
        BehaviorDelegate.initialize();
    }
    
    function setSampleView(sv){
    	sampleView = sv;
    }
    
    function onNextMode() {
    	sampleView.startupSession();
    	Ui.popView(Ui.SLIDE_IMMEDIATE);
        return true;
    }

    function onPreviousMode() {
        Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
        sampleView.startupSession();
        Ui.popView(Ui.SLIDE_IMMEDIATE);
        return true;
    }

}
