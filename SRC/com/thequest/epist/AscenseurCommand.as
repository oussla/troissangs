package com.thequest.epist {
	import flash.display.MovieClip;
	import com.nlgd.supertrace.*;
	import com.thequest.tools.ascenseur.Ascenseur;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.thequest.tools.ascenseur.AscenseurEvent;


	
	public class AscenseurCommand extends MovieClip {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------	
		private var _trace:SuperTrace;
		private var _asc:Ascenseur;
		//
		public var upBtn:SimpleButton;
		public var downBtn:SimpleButton;

		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------

		public function AscenseurCommand(asc:Ascenseur) {
			_trace = SuperTrace.getTrace();
			//_trace.debug("Hello AscenseurCommand!");
			
			_asc = asc;
			
			//écouteurs sur les boutons
			downBtn.addEventListener(MouseEvent.MOUSE_DOWN, function(evt:MouseEvent) { 
				_asc.startDown();
			} );
			downBtn.addEventListener(MouseEvent.MOUSE_UP, function(evt:MouseEvent) { 
				_asc.stopDown();
			} );
			downBtn.addEventListener(MouseEvent.MOUSE_OUT, function(evt:MouseEvent) { 
				_asc.stopDown();
			} );
			downBtn.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent) {
				_asc.downAction();
			} );
			
			upBtn.addEventListener(MouseEvent.MOUSE_DOWN, function(evt:MouseEvent) { 
				_asc.startUp();
			} );
			upBtn.addEventListener(MouseEvent.MOUSE_UP, function(evt:MouseEvent) { 
				_asc.stopUp();
			} );
			upBtn.addEventListener(MouseEvent.MOUSE_OUT, function(evt:MouseEvent) { 
				_asc.stopUp();
			} );
			upBtn.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent) {
				_asc.upAction();
			} );
			
			checkHeights();
			
		}
		
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		public function checkHeights() {
			//trace("AscenseurCommand -> checkHeights : " + _asc.objectHeight + " / " + _asc.zoneHeigth);
			this.visible = (_asc.objectHeight > _asc.zoneHeigth);
		}
	}
}