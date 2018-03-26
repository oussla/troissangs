package com.thequest.epist {
	import caurina.transitions.Tweener;
	import com.nlgd.supertrace.SuperTrace;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class Windows extends EventDispatcher {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private static var _instance:Windows;
		//
		private var _trace:SuperTrace;
		private var _windows:Array;
		private var _posX:Number = 72;
		//--------------------------------------------------
		//
		//		Singleton
		//
		//--------------------------------------------------
		public static function getInstance():Windows {
			if (_instance == null) {
				_instance = new Windows(new SingletonBlocker());
			}
			return _instance;
		}
		//
		public function Windows(p_key:SingletonBlocker) {
			if (p_key == null) {
				throw new Error("Error : Instantiation failed : Use Windows.getInstance() instead of new.");
			} else {
				_trace = SuperTrace.getTrace();
				_trace.debug("Hello Windows !");
				this.init();
			}
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		/**
		 * 
		 */
		private function init() {
			_windows = new Array();
		}
		/**
		 * Ouverture d'une fenêtre
		 * @param	p_wd
		 */
		public function openWindow(wd:Window) {
			_trace.debug("Windows.openWindow");
			
			if (_windows[wd.positionType] != undefined && _windows[wd.positionType] != wd) {
				_clearPosition(wd.positionType);
			}
			if(_windows[wd.positionType] != wd) {
				var originY:Number;
				if (_windows[wd.positionType - 1] != undefined) {
					originY = _windows[wd.positionType - 1].windowHeight - wd.height;
				} else {
					originY = -wd.height;
				}
				
				_windows[wd.positionType] = wd;
				wd.addEventListener(Event.CLOSE, _closeWindowHandler);
				wd.open();
				wd.x = _posX;
				wd.y = originY;
				_updateYPositions();
			}
			
		}
		/**
		 * Renvoi la hauteur totale des fenêtres ouvertes
		 */
		public function get windowsHeight():Number {
			var i:int;
			var N:int = _windows.length;
			var h:Number = 0;
			
			for (i = 0; i < N; i++) {
				if (_windows[i] != undefined) {
					var wd:Window = _windows[i];
					h += wd.windowHeight;
				}
			}
			
			return h;
		}
		/**
		 * 
		 * @param	evt
		 */
		private function _closeWindowHandler(evt:Event) {
			var wd:Window = evt.target as Window;
			_closeWindow(wd);
		}
		/**
		 * Ferme la fenêtre ayant déclenché l'Event "CLOSE"
		 * @param	evt
		 */
		private function _closeWindow(wd:Window) {
			_windows[wd.positionType] = undefined;
			Tweener.removeTweens(wd);
			Tweener.addTween(wd, { y: -wd.height - 1, time:0.7, transition:"easeInOutQuart" } );
			_updateYPositions();
		}
		/**
		 * Supprime une fenêtre ouverte sur une position donnée
		 * @param	pos
		 */
		private function _clearPosition(pos:int) {
			_trace.debug("Windows._clearPosition(" + pos + ")");
			if (_windows[pos] != undefined) {
				var wd:Window = _windows[pos];
				wd.removeEventListener(Event.CLOSE, _closeWindow);
				wd.close();
				_closeWindow(wd);
			}
		}
		/**
		 * 
		 */
		private function _updateYPositions() {
			var i:int;
			var N:int = _windows.length;
			var posY:Number = 0;
			
			for (i = 0; i < N; i++) {
				if (_windows[i] != undefined) {
					var wd:Window = _windows[i];
					Tweener.removeTweens(wd);
					Tweener.addTween(wd, { y:posY, time:1, transition:"easeInOutQuart" } );
					posY += wd.windowHeight;
				}
			}
			
		}
		
	}
	
}

internal class SingletonBlocker {}