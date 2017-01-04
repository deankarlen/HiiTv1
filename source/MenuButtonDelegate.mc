//!
//! Copyright 2016 by Garmin Ltd. or its subsidiaries.
//! Subject to Garmin SDK License Agreement and Wearables
//! Application Developer Agreement.
//!

using Toybox.WatchUi as Ui;
using Toybox.Attention as Attention;

class MenuButtonDelegate extends Ui.BehaviorDelegate {

	var sampleView = null;

    function initialize() {
        BehaviorDelegate.initialize();
    }
    
    function setSampleView(sv){
    	sampleView = sv;
    }
    
    function onMenu() {
        if (sampleView.paramPoint==0){
        	sampleView.paramPoint=1;
        } else {
        	sampleView.paramPoint=0;
        	sampleView.applyParams();
        	sampleView.storeParams();
        	Ui.popView(Ui.SLIDE_IMMEDIATE);
        }
        Ui.requestUpdate();
        return true;
    }

    function onPreviousMode() {
    	var stageParams = sampleView.params[sampleView.paramPoint];
        var minutes = stageParams[0];
        if (minutes>0){
        	sampleView.params[sampleView.paramPoint]=[minutes-1,stageParams[1],stageParams[2]];
        }
        Ui.requestUpdate();
        return true;
    }
    
    function onNextMode() {
        var stageParams = sampleView.params[sampleView.paramPoint];
        var minutes = stageParams[0];
        if (minutes<20){
        	sampleView.params[sampleView.paramPoint]=[minutes+1,stageParams[1],stageParams[2]];
        }
        Ui.requestUpdate();
        return true;
    }
    
    function onPreviousPage() {
    	var stageParams = sampleView.params[sampleView.paramPoint];
        var seconds = stageParams[1];
        if (seconds>0){
        	sampleView.params[sampleView.paramPoint]=[stageParams[0],seconds-5,stageParams[2]];
        }
        Ui.requestUpdate();
        return true;
    }
    
    function onNextPage() {
    	var stageParams = sampleView.params[sampleView.paramPoint];
        var seconds = stageParams[1];
        if (seconds<55){
        	sampleView.params[sampleView.paramPoint]=[stageParams[0],seconds+5,stageParams[2]];
        }
        Ui.requestUpdate();
        return true;
    }
    
    function onBack() {
        var stageParams = sampleView.params[sampleView.paramPoint];
        var hr = stageParams[2];
        if (hr>40){
        	sampleView.params[sampleView.paramPoint]=[stageParams[0],stageParams[1],hr-5];
        }
        Ui.requestUpdate();
        return true;
    }
    
    function onSelect() {
        var stageParams = sampleView.params[sampleView.paramPoint];
        var hr = stageParams[2];
        if (hr<240){
        	sampleView.params[sampleView.paramPoint]=[stageParams[0],stageParams[1],hr+5];
        }
        Ui.requestUpdate();
        return true;
    }

}