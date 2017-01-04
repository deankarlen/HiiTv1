//!
//! Copyright 2016 by Garmin Ltd. or its subsidiaries.
//! Subject to Garmin SDK License Agreement and Wearables
//! Application Developer Agreement.
//!

using Toybox.WatchUi as Ui;
using Toybox.Attention as Attention;

class ButtonDelegate extends Ui.BehaviorDelegate {

	var sampleView = null;

    function initialize() {
        BehaviorDelegate.initialize();
    }
    
    function setSampleView(sv){
    	sampleView = sv;
    }

    function onNextMode() {
        sampleView.saveActivity();
        return true;
    }

    function onPreviousMode() {
        sampleView.discardActivity();
        return true;
    }

    function onBack() {
        Ui.popView(Ui.SLIDE_IMMEDIATE);
        return true;
    }
}
