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
	import com.nlgd.mintmap.*;
	
	public class SuperTraceWindow extends MovieClip {
		
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var superTraceDisplay:SuperTraceDisplay;
		//public var debugWindow_closeBtn:SimpleButton;
		//public var debugWindow:MovieClip;
		public var tf:TextField;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function SuperTraceWindow() {
			tf = debugWindow.tf;
			_trace = SuperTrace.getTrace();
			superTraceDisplay = new SuperTraceDisplay(_trace, this, tf);
			debugWindow_closeBtn.addEventListener(MouseEvent.CLICK, switchVisible);
			debugWindow_closeBtn.visible = false;
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
			//trace("Key Down : " + evt.keyCode + ", ctrl : " + evt.ctrlKey)
			if(evt.keyCode == 96 && evt.ctrlKey == true) {
				switchVisible();
			}
			
		}
		
	}
}