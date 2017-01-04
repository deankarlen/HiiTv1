//!
//! Copyright 2015 by Garmin Ltd. or its subsidiaries.
//! Subject to Garmin SDK License Agreement and Wearables
//! Application Developer Agreement.
//!

// HIIT application for vivactive HR
// User specifies "High Intensity" and "Recovery" (aka work and rest) duration and target HR
// Upon start, app switches between work and rest stages, giving feedback by vibration when target HR is achieved 
// and when stage is complete. During operation, the screen background is red (blue) during work (rest) stages and
// the following data is shown: current HR, previous stage max/min HR, time remaining in
// current stage, repetition counter, overall time of session
// screen updates every second

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.ActivityRecording as Record;
using Toybox.ActivityMonitor as Monitor;
using Toybox.FitContributor as Fit;
using Toybox.Timer as Timer;
using Toybox.Attention as Attention;
using Toybox.Time as Time;
using Toybox.Application as App;
using Toybox.Sensor as Sensor;
using Toybox.SensorHistory as SensoryHistory;

var session = null;
// stage: 0 - not recording, 1 - high intensity, 2 - recovery
var stage = 0;
var repCounter = 0;
var remainingTimeInStage = new Time.Duration(0);
var activityStartMoment = Time.now();
var prevMaxHR = 0;
var prevMinHR = 0;
var currHR = 0;

// Stage parameters [[work min, work sec, work HR],[rest min, rest sec, rest HR]]
var params = [[4,0,170],[1,0,130]];
var paramPoint = 0;

class BaseInputDelegate extends Ui.BehaviorDelegate
{

    var workDuration = null;
    var restDuration = null;
    var workHR = null;
    var restHR = null;

    
    var reachedTargetHR = false;
    // timer intervals specified in milliseconds
    var updateMilliseconds = 1000;
    var maxHR = 0;
    var minHR = 200;
    
	var stageTimer = new Timer.Timer();
	var lowVibeProfile = new Attention.VibeProfile(50,500);
    var highVibeProfile = new Attention.VibeProfile(100,100);
    var rampUpVibe = [new Attention.VibeProfile(50,200),new Attention.VibeProfile(60,150),new Attention.VibeProfile(75,100),new Attention.VibeProfile(100,50)];
	var rampDownVibe = [new Attention.VibeProfile(100,200),new Attention.VibeProfile(90,150),new Attention.VibeProfile(75,100),new Attention.VibeProfile(50,50)];

	var previousUpdateMoment = null;
	var stageEndMoment = null;
	
	function applyParams(){
		var workParams = params[0];
		workDuration = new Time.Duration(workParams[0]*60+workParams[1]);
		workHR = workParams[2];
		var restParams = params[1];
    	restDuration = new Time.Duration(restParams[0]*60+restParams[1]);
    	restHR = restParams[2];
	}
	
	function storeParams(){
		var workParams = params[0];
		App.getApp().setProperty("workDurMin",workParams[0]);
		App.getApp().setProperty("workDurSec",workParams[1]);
		App.getApp().setProperty("workHR",workParams[2]);
		var restParams = params[1];
		App.getApp().setProperty("restDurMin",restParams[0]);
		App.getApp().setProperty("restDurSec",restParams[1]);
		App.getApp().setProperty("restHR",restParams[2]);
	}
	
	function recoverParams(){
		var workParams = params[0];
		var val0 = App.getApp().getProperty("workDurMin");
		if (val0 != null){
			workParams[0] = val0;
		}
		var val1 = App.getApp().getProperty("workDurSec");
		if (val1 != null){
			workParams[1] = val1;
		}
		var val2 = App.getApp().getProperty("workHR");
		if (val2 != null){
			workParams[2] = val2;
		}
		var restParams = params[1];
		val0 = App.getApp().getProperty("restDurMin");
		if (val0 != null){
			restParams[0] = val0;
		}
		val1 = App.getApp().getProperty("restDurSec");
		if (val1 != null){
			restParams[1] = val1;
		}
		val2 = App.getApp().getProperty("restHR");
		if (val2 != null){
			restParams[2] = val2;
		}
		params = [workParams,restParams];
	}
	
	function startupStages(){
		applyParams();
		var now = Time.now();
		activityStartMoment = now;
	    Attention.vibrate(rampUpVibe);
	    previousUpdateMoment = now;
		stageEndMoment = now.add(workDuration);
		remainingTimeInStage = stageEndMoment.subtract(now);
		stage = 1;
        stageTimer.start(method(:updateStage),updateMilliseconds,true);
        repCounter = 1;
        Attention.backlight(true);
        Ui.requestUpdate();
	}
	
	function updateStage(){
	    applyParams();
		var now = Time.now();
		remainingTimeInStage = stageEndMoment.subtract(now);
		if (remainingTimeInStage.value() <= 0) {
			if (stage == 1){
				// High Intensity stage completed
				Attention.vibrate(rampDownVibe);
				stageEndMoment = now.add(restDuration);
				stage = 2;
			} else if (stage ==2){
				// Recovery stage completed
				Attention.vibrate(rampUpVibe);
				stageEndMoment = now.add(workDuration);
				stage = 1;
				repCounter = repCounter+1;
			}
			remainingTimeInStage = stageEndMoment.subtract(now);
			prevMaxHR = maxHR;
			prevMinHR = minHR;
			maxHR = 10;
			minHR = 100;
			reachedTargetHR = false;
			Attention.backlight(true);
			session.addLap();
		}
	    // this does not seem to work if a duration is given
		//var hri = Monitor.getHeartRateHistory(1,true);
		//currHR = hri.getMax();
		
		//var iter = SensorHistory.getHeartRateHistory({:period=>1});
		//currHR = iter.getMax();
		
		//currHR is filled by onSensor() method below	
		
		if (currHR > maxHR) {
			maxHR = currHR;
		}
		if (currHR < minHR) {
			minHR = currHR;
		}
		if (!reachedTargetHR && ( (stage == 1 && currHR >= workHR) || (stage == 2 && currHR <= restHR) )){
			reachedTargetHR = true;
			Attention.vibrate([highVibeProfile]);
		}
		
		previousUpdateMoment = Time.now();
		Ui.requestUpdate();
	}

    function initialize() {
        BehaviorDelegate.initialize();
        recoverParams();
    }

    function onKey(evt){
        // if right button pushed, start or stop activity
    	if (evt.getKey() == Ui.KEY_ENTER){
    		toggleActivity();
    		return true;
    	}
    	return false;
    }
    
    function onTap(evt){
    	Attention.backlight(true);
    	return true;
    }

	function onMenu(){
		var menuButtonView = new MenuButtonView();
		var menuButtonDelegate = new MenuButtonDelegate();
		menuButtonView.setSampleView(me);
		menuButtonDelegate.setSampleView(me);
		Ui.pushView(menuButtonView,menuButtonDelegate, Ui.SLIDE_IMMEDIATE);
        return true;
	}
	
	function discardActivity(){
		stageTimer.stop();
        session.stop();
        session.discard();
        Sensor.setEnabledSensors([]);
		session = null;
        Ui.popView(Ui.SLIDE_IMMEDIATE);
	}
	
	function saveActivity(){
		stageTimer.stop();
        session.stop();
        Sensor.setEnabledSensors([]);
        session.save();
		session = null;
        Ui.popView(Ui.SLIDE_IMMEDIATE);
	}

    function onSensor(sensorInfo){
    	var hrinfo = sensorInfo.heartRate;
    	// System.println("hr:"+hrinfo);
    	if (hrinfo != null){
	    	currHR = hrinfo;
	    }
    }

    function toggleActivity() {
        if( Toybox has :ActivityRecording ) {
            if( ( session == null ) || ( session.isRecording() == false ) ) {
                session = Record.createSession({:name=>"Hiit", :sport=>Record.SPORT_TRAINING, :subSport=>Record.SUB_SPORT_CARDIO_TRAINING});
                startupStages();
                Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE]);
                Sensor.enableSensorEvents(method(:onSensor));
                session.start();
                Ui.requestUpdate();
            }
            else if( ( session != null ) && session.isRecording() ) {
                var buttonView = new ButtonView();
				var buttonDelegate = new ButtonDelegate();
				buttonDelegate.setSampleView(me);
				Ui.pushView(buttonView,buttonDelegate, Ui.SLIDE_IMMEDIATE);
            }
        }
        return true;
    }
}

class RecordSampleView extends Ui.View {

    function initialize() {
        View.initialize();
    }

    //! Stop the recording if necessary
    function stopRecording() {
        if( Toybox has :ActivityRecording ) {
            if( session != null && session.isRecording() ) {
                session.stop();
                session.save();
                session = null;
                Ui.requestUpdate();
            }
        }
    }

    //! Load your resources here
    function onLayout(dc) {
    }

    function onHide() {
    }
    
    //! Restore the state of the app and prepare the view to be shown.
    function onShow() {
    }
    
    // show time in mm:ss
    function durationToString(dur) {
	    var minutes = dur.value()/60;
        var seconds = dur.value()%60;
        var buff = "";
        if (minutes < 10){
        	buff = buff + "0";
        }
        buff = buff + minutes.toString() + ":";
        if (seconds < 10){
        	buff = buff + "0";
        }
        buff = buff + seconds.toString();
        return buff;
    }

    //! Update the view
    function onUpdate(dc) {
        // Set background color
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        dc.clear();
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
        dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());
        //dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_WHITE);
        //dc.drawText(dc.getWidth()/2, 0, Gfx.FONT_XTINY, "M:"+Sys.getSystemStats().usedMemory, Gfx.TEXT_JUSTIFY_CENTER);

        if( Toybox has :ActivityRecording ) {
            // Draw the instructions
            if( ( session == null ) || ( session.isRecording() == false ) ) {
                dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
                dc.drawText(dc.getWidth() / 2, 10, Gfx.FONT_LARGE, 
                "HiiT App", Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
                dc.drawLine(0,25,dc.getWidth(),25);
                dc.drawLine(0,28,dc.getWidth(),28);
                dc.drawText(dc.getWidth() / 2, 70, Gfx.FONT_MEDIUM, 
                "Press right\n button to Start\n& Stop Recording", Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
                dc.drawLine(0,118,dc.getWidth(),118);
                dc.drawText(dc.getWidth() / 2, 160, Gfx.FONT_MEDIUM, 
                "Hold right\n button to\nChange Options", Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
            }
            else if( ( session != null ) && session.isRecording() ) {
                var x = dc.getWidth() / 2;
                var y = 0;
                var foreground = Gfx.COLOR_WHITE;
                var background0 = Gfx.COLOR_BLACK;
                var background1 = Gfx.COLOR_BLACK;
                var background2 = Gfx.COLOR_BLACK;
                var stageText = "Not Started";
                if (stage==1) {
                	background1 = Gfx.COLOR_RED;
                	background2 = Gfx.COLOR_BLUE;
                	stageText = "High Int";
                }
                if (stage==2) {
                	background1 = Gfx.COLOR_BLUE;
                	background2 = Gfx.COLOR_RED;
                	stageText = "Recovery";
                }
                dc.setColor(background0, background0);
                dc.fillRectangle(0, 0, dc.getWidth(), dc.getFontHeight(Gfx.FONT_LARGE));
                dc.setColor(foreground, background0);
                var now = Time.now();
                var dur = now.subtract(activityStartMoment);
                var timeString = durationToString(dur);
                dc.drawText(x, y, Gfx.FONT_LARGE, "Time: "+timeString, Gfx.TEXT_JUSTIFY_CENTER);
                y += dc.getFontHeight(Gfx.FONT_LARGE);
                
                dc.setColor(background1, background1);
                dc.fillRectangle(0, y, dc.getWidth(), dc.getFontHeight(Gfx.FONT_LARGE)+2*dc.getFontHeight(Gfx.FONT_NUMBER_HOT));
                dc.setColor(foreground, background1);
                dc.drawText(x, y, Gfx.FONT_LARGE, stageText+" "+repCounter.toString(), Gfx.TEXT_JUSTIFY_CENTER);
                y += dc.getFontHeight(Gfx.FONT_LARGE)-1;
                dc.drawText(0, y+20, Gfx.FONT_LARGE, "HR: ", Gfx.TEXT_JUSTIFY_LEFT);
                dc.drawText(x, y, Gfx.FONT_NUMBER_HOT, currHR.toString(), Gfx.TEXT_JUSTIFY_CENTER);
                y += dc.getFontHeight(Gfx.FONT_NUMBER_HOT)-1;
                var timeString2 = durationToString(remainingTimeInStage);
                dc.drawText(x, y, Gfx.FONT_NUMBER_HOT, timeString2, Gfx.TEXT_JUSTIFY_CENTER);
                y += dc.getFontHeight(Gfx.FONT_NUMBER_HOT)-1;
                
                dc.setColor(background2, background2);
                dc.fillRectangle(0, y-3, dc.getWidth(), dc.getFontHeight(Gfx.FONT_NUMBER_HOT));
                dc.setColor(foreground, background2);
                dc.drawText(x, y-3, Gfx.FONT_NUMBER_MEDIUM, prevMinHR.toString()+"-"+prevMaxHR.toString(), Gfx.TEXT_JUSTIFY_CENTER);
            }
        }
        // tell the user this sample doesn't work
        else {
            dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_WHITE);
            dc.drawText(dc.getWidth() / 2, dc.getWidth() / 2, Gfx.FONT_MEDIUM, "This product doesn't\nhave FIT Support", Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
        }
    }

}
