﻿package com.thequest.tools.scroller {
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Rectangle; 
	import flash.display.Shape;
	

	public class Scroller extends MovieClip	{
		
		private var _dragged:MovieClip; 
		private var _mask:MovieClip; 
		private var _ruler:MovieClip; 
		private var _background:MovieClip; 
		private var _hitarea:MovieClip; 
		private var _blurred:Boolean; 
		private var _YFactor:Number; 
		
		private var _initY:Number; 
		
		private var minY:Number;
		private var maxY:Number;
		private var percentuale:uint;
		private var contentstarty:Number; 
		private var bf:BlurFilter;
		
		private var initialized:Boolean = false;
		
		public function Scroller(dragged:MovieClip, maskclip:MovieClip, ruler:MovieClip, background:MovieClip, hitarea:MovieClip, blurred:Boolean = false, yfactor:Number = 4 )
		{
			super();
			_dragged = dragged; 
			_mask = maskclip; 
			_ruler = ruler; 
			_background = background; 
			_hitarea = hitarea as MovieClip; 
			_blurred = blurred; 
			_YFactor = yfactor;
			
		}
		
		public function set dragged (v:MovieClip) {
			_dragged = v; 
		}
		
		public function set maskclip (v:MovieClip) {
			_mask = v; 
		}
		
		public function set ruler (v:MovieClip) {
			_ruler = v; 
		}
		
		public function set background (v:MovieClip) {
			_background = v; 
		}
		
		public function set hitarea (v:MovieClip) {
			_hitarea = v; 
		}		
		
		private function checkPieces():Boolean {
			var ok:Boolean = true; 
			if (_dragged == null) {
				trace("SCROLLBAR: DRAGGED not set"); 
				ok = false; 	
			}
			if (_mask == null) {
				trace("SCROLLBAR: MASK not set"); 
				ok = false; 	
			}
			if (_ruler == null) {
				trace("SCROLLBAR: RULER not set"); 	
				ok = false; 
			}
			if (_background == null) {
				trace("SCROLLBAR: BACKGROUND not set"); 	
				ok = false; 
			}
			if (_hitarea == null) {
				trace("SCROLLBAR: HITAREA not set"); 	
				ok = false; 
			}
			return ok; 
		}
		
		public function init(e:Event = null):void {
			if (checkPieces() == false) {
				trace("SCROLLBAR: CANNOT INITIALIZE"); 
			} else { 
				if (initialized == true) {
					reset();
				}
				if(_blurred) {
					bf = new BlurFilter(0, 0, 1); 
					this._dragged.filters = new Array(bf);
					this._dragged.cacheAsBitmap = true; 
				}
				this._dragged.mask = this._mask; 
				
				this.minY = _background.y; 
				
				this._ruler.buttonMode = true; 
	
				this.contentstarty = _dragged.y; 
	
				_ruler.addEventListener(MouseEvent.MOUSE_DOWN, clickHandle); 
				stage.addEventListener(MouseEvent.MOUSE_UP, releaseHandle); 
				stage.addEventListener(MouseEvent.MOUSE_WHEEL, wheelHandle, true); 
				this.addEventListener(Event.ENTER_FRAME, enterFrameHandle);
				
				// Le click sur la barre "background" déclenche un scroll
				_background.addEventListener(MouseEvent.CLICK, backgroundClickHandle);
				
				initialized = true; 
			}
		}
		
		private function clickHandle(e:MouseEvent) 
		{
			var rect:Rectangle = new Rectangle(_background.x-(_ruler.width/2), minY, 0, maxY);
			_ruler.startDrag(false, rect);
		}
		
		private function releaseHandle(e:MouseEvent) 
		{
			_ruler.stopDrag();
		}
		
		private function wheelHandle(e:MouseEvent)
		{
			if (this._hitarea.hitTestPoint(stage.mouseX, stage.mouseY, false))
			{
				scrollData(e.delta);		
			}
		}
		
		private function enterFrameHandle(e:Event)
		{
			positionContent();
		}
		
		// Clic sur le background
		private function backgroundClickHandle(e:MouseEvent) {
			var rY:Number = _background.mouseY - _ruler.height / 2;
			if(rY < 0) {
				rY = 0;
			}
			if((rY + _ruler.height) > _background.height) {
				rY = _background.height - _ruler.height;
			}
			_ruler.y = rY;
		}
		
		
		private function scrollData(q:int)
		{
			//
			var d:Number;
			var rulerY:Number; 
			
			var quantity:Number = this._ruler.height / 5; 

			d = -q * Math.abs(quantity); 
	
			if (d > 0) {
				rulerY = Math.min(maxY, _ruler.y + d);
			}
			if (d < 0) {
				rulerY = Math.max(minY, _ruler.y + d);
			}
			
			_ruler.y = rulerY; 
	
			positionContent();
		}
		
		public function scrollUp(evt:MouseEvent = null) {
			scrollData(5);
		}
		
		public function scrollDown(evt:MouseEvent = null) {
			scrollData(-5);
		}
		
		public function positionContent():void {
			var upY:Number;
			var downY:Number;
			var curY:Number;
			
			/* thanks to Kalicious (http://www.kalicious.com/) */
			this._ruler.height = (this._mask.height / this._dragged.height) * this._background.height;
			this.maxY = this._background.height - this._ruler.height;
			/*	*/ 		

			var limit:Number = this._background.height - this._ruler.height; 

 			if (this._ruler.y > limit) {
				this._ruler.y = limit; 
			} 
	
			checkContentLength();	
	
			percentuale = (100 / maxY) * _ruler.y;
				
			upY = 0;
			downY = _dragged.height - (_mask.height / 2);
			 
			var fx:Number = contentstarty - (((downY - (_mask.height/2)) / 100) * percentuale); 
			
			var curry:Number = _dragged.y; 
			var finalx:Number = fx; 
			
			if (curry != finalx) {
				var diff:Number = finalx-curry;
				curry += diff / _YFactor; 
				
				var bfactor:Number = Math.abs(diff)/8; 
				// Le filtre n'est appliqué que s'il est défini
				if(bf) {
					bf.blurY = bfactor/2; 
					if (_blurred == true) {
						_dragged.filters = new Array(bf);
					}
				}
			}
			
			_dragged.y = curry; 
		}
		
		public function checkContentLength():void
		{
			if (_dragged.height < _mask.height) {
				_ruler.visible = false;
				reset();
			} else {
				_ruler.visible = true; 
			}
		}
		
		public function reset():void {
			_dragged.y = contentstarty; 
			_ruler.y = 0; 			
		}
		
	}
}