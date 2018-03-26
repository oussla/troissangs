package com.thequest.epist.argu {
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.EDPropal;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class PropalsLinks extends Sprite {
		private var _trace:SuperTrace;
		private var _mgr:NavManager;
		private var _elements:Array;
		private var _container:Sprite;
		private var _active:PropalButton;
		private var _clicked:PropalButton;
		
		public function PropalsLinks() {
			_trace = SuperTrace.getTrace();
			_trace.debug("Hello PropalsLinks !");
			
			_mgr = NavManager.getMgr();
			
			_elements = new Array();
			_container = new Sprite();
			this.addChild(_container);
			/*
			this.graphics.beginFill(0x00FF00);
			this.graphics.drawRect(0, 0, 10, 10);
			this.graphics.endFill();
			*/
			
		}
		
		public function open() {
			_createElements();
		}
		
		public function update() {
			if (_active) _active.setNormal();
			var current:int = _mgr.currentPropalIndex;
			var N:int = _elements.length;
			var found:Boolean = false;
			for (var i:int = 0; i < N && !found; i++) {
				var btn:PropalButton = _elements[i] as PropalButton;
				if (btn.elementData.id == current) {
					btn.setActive();
					_active = btn;
					found = true;
				}
			}
		}
		
		private function _createElements() {
			var elts:Array = _mgr.getCurrentPropals();
			var i:int;
			var N:int = elts.length;
			var current:int = _mgr.currentPropalIndex;
			_trace.debug("_createElements, N : " + N + ", current : " + current);
			_clearElements();
			for (i = 0; i < N; i++) {
				var ed:EDPropal = elts[i] as EDPropal;
				var btn:PropalButton = new PropalButton(ed);
				btn.addEventListener(MouseEvent.CLICK, _btnClick);
				btn.x = i * 50;
				if (ed.id == current) {
					btn.setActive();
					_active = btn;
				} else {
					btn.setNormal();
				}
				if (i < N -1) btn.traceSeparation();
				//btn.setPosition(new Point(0, i * 57));
				//btn.addEventListener(MouseEvent.CLICK, _antecClick);
				_container.addChild(btn);
				_elements.push(btn);
			}
		}
		
		private function _clearElements() {
			var i:int;
			var N:int = _elements.length;
			for (i = 0; i < N; i++) {
				var btn:PropalButton = _elements.shift();
				btn.removeEventListener(MouseEvent.CLICK, _btnClick);
				_container.removeChild(btn);
			}
		}
		/**
		 * 
		 * @param	evt
		 */
		private function _btnClick(evt:MouseEvent) {
			_clicked = evt.target as PropalButton;
			_trace.debug("_btnClick : " + _clicked);
			this.dispatchEvent(new Event(Event.OPEN));
		}
		
		
		public function get clickedElementData():EDPropal {
			return _clicked.elementData as EDPropal;
		}
	}
	
}