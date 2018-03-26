package com.thequest.epist.argu {
	import caurina.transitions.Tweener;
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.EDEtape;
	import com.thequest.epist.ElementData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class MenuColumn extends Sprite {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _pos:Point;
		private var _btns:Array;
		private var _activeBtn:ElementButton;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function MenuColumn() {
			_trace = SuperTrace.getTrace();
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		public function createBtns(elts:Array, elementType:Class, yMargin:Number = 0) {
			var i:int;
			var N:int = elts.length;
			var posY:Number = 0;
			//_trace.debug("createBtns, N : " + N);
			this.alpha = 0;
			_btns = new Array();
			for (i = 0; i < N; i++) {
				var btn:ElementButton = new elementType(elts[i]);
				if (i > 0) {
					//posY += _btns[i - 1].height + yMargin;
					posY = _btns[i - 1].y + _btns[i - 1].height + btn.yMargin + yMargin;
				}
				btn.setPosition(new Point(0, int(posY)));
				if(elts[i].activeLink) {
					btn.addEventListener(MouseEvent.MOUSE_OVER, _btnOver);
					btn.addEventListener(MouseEvent.MOUSE_OUT, _btnOut);
					btn.addEventListener(MouseEvent.CLICK, _btnClick);
				}
				this.addChild(btn);
				_btns.push(btn);
			}
			Tweener.removeTweens(this);
			Tweener.addTween(this, {alpha:1, time:0.5, transition:"easeOutQuart" } );
		}
		/**
		 * 
		 */
		public function reset() {
			if (_btns) {
				var i:int;
				var N:int = _btns.length;
				for (i = 0; i < N; i ++) {
					var btn:ElementButton = _btns.shift();
					this.removeChild(btn);
				}
			}
		}
		
		public function setPosition(p_pos:Point) {
			_pos = p_pos;
			this.x = _pos.x;
			this.y = _pos.y;
		}
		
		public function get activeData():ElementData {
			return _activeBtn.elementData;
		}
		
		
		private function _btnOver(evt:MouseEvent) {
			var btn:ElementButton = evt.target as ElementButton;
			if(btn != _activeBtn) {
				btn.rollOver();
			}
		}
		
		private function _btnOut(evt:MouseEvent) {
			var btn:ElementButton = evt.target as ElementButton;
			if(btn != _activeBtn) {
				btn.rollOut();
			}
		}
		
		private function _btnClick(evt:MouseEvent) {
			var btn:ElementButton = evt.target as ElementButton;
			_change(btn);
			/*
			if (_activeBtn) {
				_activeBtn.setNormal();
			}
			btn.setActive();
			_activeBtn = btn;
			this.dispatchEvent(new Event(Event.CHANGE));
			*/
		}
		
		private function _change(btn:ElementButton, p_dispatch:Boolean = true) {
			if (_activeBtn) {
				_activeBtn.setNormal();
			}
			btn.setActive();
			_activeBtn = btn;
			if(p_dispatch) this.dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function change(p_id:int, p_dispatch:Boolean = true) {
			//_trace.debug("MenuColumn.change : " + p_id);
			var btn:ElementButton;
			if (p_id > 0 && p_id <= _btns.length) {
				btn = _btns[p_id - 1] as ElementButton;
				_change(btn, p_dispatch);
			}
			
		}
		
		public function replaceEtaps(etapes:Array) {
			_trace.debug("MenuColumn.replaceEtaps");
			var nbBtn:int = _btns.length;
			var tmpEtap:EDEtape;
			var tmpEltBtn:ElementButton;
			if (nbBtn > 0) {
				for (var i:int = 1; i < nbBtn; i++) {
					tmpEtap = etapes[i];
					tmpEltBtn = _btns[i];
					//if (tmpEtap.isTitle) {
						//_trace.debug("\ntitre à espacer : " + tmpEtap.title);
						//_trace.debug("=> elementY = "+tmpEltBtn.y+"\n");
					//}
					//else {
						//_trace.debug("Pas de décalage pour " + tmpEtap.title);
					//}
				}
			}
		}
		
	}
	
}