package com.thequest.tools.ascenseur {
	import caurina.transitions.Tweener;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import com.nlgd.supertrace.*;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.events.TimerEvent;

	
	public class Ascenseur extends MovieClip {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------	
		private var _trace:SuperTrace;
		private var _mcToDisplay:DisplayObject;
		private var _visibleArea:Sprite;
		private var _scrollTimer:Timer;
		private var _isDowning:Boolean = false;
		private var _isUpping:Boolean = false;
		//
		public var superTraceWindow:SuperTraceStrictWindow;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------

		public function Ascenseur(mc:DisplayObject, dim:Rectangle) {
			_trace = SuperTrace.getTrace();
			//_trace.debug("Hello Ascenseur!");
			_mcToDisplay = mc;
			_mcToDisplay.alpha = 1;
			
			//construction du masque
			this.y = dim.y;
			this.x = dim.x;
			_visibleArea = new Sprite();
			_visibleArea.graphics.lineStyle(1, 0x000000);
			_visibleArea.graphics.beginFill(0xff0000);
			_visibleArea.graphics.drawRect(0, 0, dim.width, dim.height);
			_visibleArea.graphics.endFill();
			this.addChild(_visibleArea);

			//application du masque sur le movie clip
			
			_mcToDisplay.mask = _visibleArea;
			
			
			//_visibleArea.alpha = 0.1;
			
			//préparation du timer pour le scroll
			_scrollTimer = new Timer(1000/24);
			_scrollTimer.addEventListener(TimerEvent.TIMER, _timerHandler);
		}
		
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		public function startDown() {
			//_trace.debug("Ascenseur.startDown");
			//_scrollTimer.addEventListener(TimerEvent.TIMER, _timerHandler);
			_scrollTimer.reset();
			_scrollTimer.start();
			_isDowning = true;
		}
		
		public function stopDown() {
			if (_isDowning) {
				//_trace.debug("Ascenseur.stopDown");
				_scrollTimer.stop();
				//_scrollTimer.removeEventListener(TimerEvent.TIMER, _timerHandler);
				_isDowning = false;
			}
			
		}
		
		public function startUp() {
			//_trace.debug("Ascenseur.startUp");
			//_scrollTimer.addEventListener(TimerEvent.TIMER, _timerHandler);
			_scrollTimer.reset();
			_scrollTimer.start();
			_isUpping = true;
		}
		
		public function stopUp() {
			if (_isUpping) {
				//_trace.debug("Ascenseur.stopUp");
				_scrollTimer.stop();
				//_scrollTimer.removeEventListener(TimerEvent.TIMER, _timerHandler);
				_isUpping = false;
			}
		}
		
		private function _timerHandler(event:TimerEvent):void {
			if (_isDowning) {
				this.downAction();
			}
			if (_isUpping) {
				this.upAction();
			}
		}
		
		public function upAction() {
			//_trace.debug("Ascenseur.upAction");
			var tmpY:int = _mcToDisplay.y + 15; 
			var maxY:Number = this.y;
			if (tmpY < maxY ) {
				_mcToDisplay.y = tmpY;
			} else {
				_mcToDisplay.y = maxY;
				this.dispatchEvent(new AscenseurEvent(AscenseurEvent.MAX_UP));
			}
		}
		
		public function downAction() {
			//_trace.debug("Ascenseur.downAction");
			var tmpY:int = _mcToDisplay.y - 15;
			var minY:Number = -_mcToDisplay.height + _visibleArea.height + this.y;
			if (_visibleArea.height>_mcToDisplay.height) {
				//_trace.debug("Hauteur du clip à afficher < hauteur du masque");
			} else {
				if (tmpY > minY) {
					_mcToDisplay.y = tmpY;
				} else {
					_mcToDisplay.y = minY;
					this.dispatchEvent(new AscenseurEvent(AscenseurEvent.MAX_DOWN));
				}
			}
		}
		
		public function resetPosition() {
			//_trace.debug("Ascenseur.resetPosition");
			_mcToDisplay.y = this.y;
		}
		
		public function setYVisible(posY:Number) {
			_trace.debug("Ascenseur.setYVisible(" + posY +")");
			// Doit replacer posY au max visible, donc quasi au bord du masque
			
			var B:Number = posY - _mcToDisplay.y;
			
			
			
			var d:Number = 0;
			if(_mcToDisplay.y + posY > _visibleArea.height + this.y) {
				d = posY - (_mcToDisplay.y + _visibleArea.height + this.y);
			}
			
			_trace.debug("Ascenseur doit remonter de " + d);
			var newY:Number = _mcToDisplay.y - d;
			Tweener.addTween(_mcToDisplay, { y:newY, time:0.3, transition:"easeOutQuart" } );
			
		}
		
		public function get objectHeight():Number {
			return _mcToDisplay.height;
		}
		
		public function get zoneHeigth():Number {
			return _visibleArea.height;
		}
		
	}
}