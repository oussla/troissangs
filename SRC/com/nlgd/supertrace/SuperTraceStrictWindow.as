/**
*
*
*	DebugWindow
*	
*	@author	NLGD
*	@version	0.1
*
*/

package com.nlgd.supertrace {
	
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Stage;
	import flash.text.TextField;
	
	import com.nlgd.supertrace.*;
	
	public class SuperTraceStrictWindow extends MovieClip {
		
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var superTraceDisplay:SuperTraceDisplay;
		//public var debugWindow_closeBtn:SimpleButton;
		public var debugWindow:MovieClip;
		public var tf:TextField;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function SuperTraceStrictWindow() {
			tf = debugWindow.tf;
			_trace = SuperTrace.getTrace();
			//_trace.debug("##### ATTENTION : la touche 'Command' pour Mac ouvre la fenêtre de trace ! #####");
			superTraceDisplay = new SuperTraceDisplay(_trace, this, tf);
			debugWindow.visible = false;
			stage.addEventListener(KeyboardEvent.KEY_DOWN, debugWindowKeyDown);
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		public function switchVisible(evt:MouseEvent = null) {
			debugWindow.visible = !debugWindow.visible;
		}
		
		private function debugWindowKeyDown(evt:KeyboardEvent) {
			//_trace.info("Key Down : " + evt.keyCode + ", ctrl : " + evt.ctrlKey)
			if((evt.keyCode == 96 || evt.keyCode == 45) && evt.ctrlKey == true) {
			//if((evt.keyCode == 96 || evt.keyCode == 45 || evt.keyCode == 17) && evt.ctrlKey == true) {
				switchVisible();
			}
			if((evt.keyCode == 105) && evt.ctrlKey == true) {
				superTraceDisplay.flush();
			}			
		}
		
	}
}