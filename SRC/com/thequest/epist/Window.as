package com.thequest.epist {
	import com.nlgd.supertrace.SuperTrace;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class Window extends MovieClip {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		//
		protected var _translator:Translator;
		protected var _isOpen:Boolean = false;
		protected var _positionType:int = 0;
		protected var _windowHeight:Number = 40;
		protected var _draggable:Boolean = false;
		//
		public var close_btn:SimpleButton;
		public var title_tf:TextField;
		public var picto_mc:MovieClip;
		public var dragZone_mc:MovieClip;
		//--------------------------------------------------
		//
		//		Contructor
		//
		//--------------------------------------------------
		public function Window() {
			_translator = Translator.getInstance();
			close_btn.addEventListener(MouseEvent.CLICK, close);
			this.visible = false;
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		/**
		 * Ouverture de la fenêtre
		 */
		public function open(evt:MouseEvent = null) {
			_isOpen = true;
			this.visible = true;
		}
		/**
		 * Fermeture
		 */
		public function close(evt:MouseEvent = null) {
			_isOpen = false;
			this.dispatchEvent(new Event(Event.CLOSE));
		}
		/**
		 * Switch
		 */
		public function switchOpen() {
			if (_isOpen) {
				this.close();
			} else {
				this.open();
			}
		}
		/**
		 * Renvoi "positionType", indique la façon dont la fenêtre se positionne par rapport aux autres
		 */
		public function get positionType():int {
			return _positionType;
		}
		
		public function get windowHeight():Number {
			return _windowHeight;
		}
		/**
		 * 
		 * @param	bool
		 */
		protected function setDraggable(bool:Boolean = true) {
			this._draggable = true;
			// ### Rend la fenêtre draggable
		}
		
	}
	
}