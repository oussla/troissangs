package com.thequest.epist.antho {
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.NavEvent;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.display.SimpleButton;
	import caurina.transitions.Tweener;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class USCommand extends MovieClip {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _mgr:AnthoManager;
		private var _sndMgr:SoundManager;
		private var _pourcentage:Number;
		private var _oldPosXCursor:Number;
		private var _lineToolbar:Rectangle;
		private var volWidth:Number = 35;
		private var _timer:Timer;
		private var _pos:Point;
		private var _isOpen:Boolean = false;
		//
		public var nextBtn:MovieClip;
		public var previousBtn:MovieClip;
		public var playedTime_tf:TextField;
		public var totalTime_tf:TextField;
		public var playPauseBtn:MovieClip;
		public var toolbar:MovieClip;
		public var bg:MovieClip;
		public var volumeControl_mc:MovieClip;
		public var vol_ct:SimpleButton;
		public var volSlider_mc:MovieClip;
		
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function USCommand() {
			_mgr = AnthoManager.getInstance();
			_sndMgr = SoundManager.getInstance();
			_trace = SuperTrace.getTrace();
			_trace.debug("Hello USCommand !");
			
			//écouteurs
			_sndMgr.addEventListener(MediaEvent.SOUND_LOADED, _soundLoaded);
			_sndMgr.addEventListener(MediaEvent.SOUND_PLAYED, _soundPlayed);
			_sndMgr.addEventListener(MediaEvent.SOUND_STOPPED, _soundStopped);
			_sndMgr.addEventListener(MediaEvent.MOVED_SEEK, _updatePositions);
			_sndMgr.addEventListener(MediaEvent.SOUND_PLAYING, _updatePositions);
			
			this._setListenersOnNextPrevBtn();
			
			//bg.ct.addEventListener(MouseEvent.MOUSE_DOWN, _dragCommand);
			//bg.ct.addEventListener(MouseEvent.MOUSE_UP, _dropCommand);
			
			toolbar.seekbar.ct.addEventListener(MouseEvent.CLICK, _seekbarClick); 
			
			//prépare le bouton play-pause qui servira de curseur
			this._preparePlayBtn();
			
			vol_ct = volumeControl_mc.vol_ct;
			volSlider_mc = volumeControl_mc.volSlider_mc;
			vol_ct.addEventListener(MouseEvent.CLICK, volumeClick);
			vol_ct.addEventListener(MouseEvent.MOUSE_DOWN, volumeStartDrag);
			vol_ct.addEventListener(MouseEvent.MOUSE_UP, volumeStopDrag);
			vol_ct.addEventListener(MouseEvent.MOUSE_OUT, volumeStopDrag);
			
			this.alpha = 1;
			this.visible = true;
		}
		
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		public function init() {
			//_timer = new Timer(3000);
			//_timer.addEventListener(TimerEvent.TIMER, _hideCommand);
			//_timer.start();
			this.parent.addEventListener(MouseEvent.MOUSE_MOVE, _checkMousePosition);
		}
		
		private function _setListenersOnNextPrevBtn() { //écouteurs sur les boutons next et previous US
			nextBtn.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent) { 
				_mgr.gotoNextUS(false);
				_timer.reset();
				_timer.start();
			} );
			previousBtn.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent) { 
				_mgr.gotoPreviousUS(false);
				_timer.reset();
				_timer.start();
			} );
			nextBtn.addEventListener(MouseEvent.MOUSE_OVER, function(evt:MouseEvent) { 
				nextBtn.gotoAndPlay('over');
			} );
			previousBtn.addEventListener(MouseEvent.MOUSE_OVER, function(evt:MouseEvent) { 
				previousBtn.gotoAndPlay('over');
			} );
			nextBtn.addEventListener(MouseEvent.MOUSE_OUT, function(evt:MouseEvent) { 
				nextBtn.gotoAndPlay('normal');
			} );
			previousBtn.addEventListener(MouseEvent.MOUSE_OUT, function(evt:MouseEvent) { 
				previousBtn.gotoAndPlay('normal');
			} );	
		}
		
		private function _preparePlayBtn() {
			_trace.debug("USCommand._preparePlayBtn");
			playPauseBtn.ct.addEventListener(MouseEvent.MOUSE_UP, _dropPlayPause);
			playPauseBtn.ct.addEventListener(MouseEvent.MOUSE_DOWN, _dragPlayPause);
			
			playPauseBtn.x = toolbar.x;
			playPauseBtn.y = toolbar.y + ((toolbar.seekbar.height) / 2) - 2;
			playPauseBtn.play_mc.alpha = 0;
			playPauseBtn.pause_mc.alpha = 1;
			
			playPauseBtn.pause_mc.gotoAndPlay('normal');
			playPauseBtn.play_mc.gotoAndPlay('normal');
				
			playPauseBtn.ct.addEventListener(MouseEvent.MOUSE_OVER, function(evt:MouseEvent) { 
				playPauseBtn.pause_mc.gotoAndPlay('over');
				playPauseBtn.play_mc.gotoAndPlay('over');
			});
			
			playPauseBtn.ct.addEventListener(MouseEvent.MOUSE_OUT, function(evt:MouseEvent) { 
				playPauseBtn.pause_mc.gotoAndPlay('normal');
				playPauseBtn.play_mc.gotoAndPlay('normal');
			});
		}
		
		/**
		 * 
		 * @param	event
		 */
		private function _soundLoaded(evt:MediaEvent) {
			totalTime_tf.text = _sndMgr.getTotalTime();
		}
		/**
		 * 
		 * @param	event
		 */
		private function _soundPlayed(evt:MediaEvent) {
			playPauseBtn.pause_mc.alpha = 1;
			playPauseBtn.play_mc.alpha = 0;
		}
		/**
		 * 
		 * @param	event
		 */
		private function _soundStopped(evt:MediaEvent) {
			playPauseBtn.pause_mc.alpha = 0;
			playPauseBtn.play_mc.alpha = 1;
		}

		//--------------------------------------------------
		//
		//		Cursor management
		//
		//--------------------------------------------------
		
		private function _updatePositions(evt:Event = null) {
			//_trace.debug("UsCommand._updatePositions");
			// TOOLBAR
			var position:Number;
			if (_sndMgr.isPlaying)
				_pourcentage = ((_sndMgr.soundPosition * 100) / _sndMgr.soundLength);
			else
				_pourcentage = ((_sndMgr.pausePosition * 100) / _sndMgr.soundLength);
			position = ((_pourcentage / 100) * (toolbar.width));
			toolbar.seekbar.fullness.width = position;
			// CURSEUR
			playPauseBtn.x = position + toolbar.x;
			//TEMPS LU
			playedTime_tf.text = _sndMgr.getPlayedTime();
		}
		
		private function _seekbarClick(evt:MouseEvent):void {
			var timeToGo:Number;
			var percent:Number = (evt.localX / toolbar.seekbar.width) * 100;
			timeToGo = (percent / 100) * _sndMgr.soundLength;
			_sndMgr.goToSeek(timeToGo);
		}
		
		
		private function _dragPlayPause(evt:MouseEvent):void {
			//_trace.debug("\n*** UsCommand._dragPlayPause");
			_sndMgr.removeEventListener(MediaEvent.SOUND_PLAYING, _updatePositions);//arrête l'écoute pour arrêter le déplacement du bouton-curseur
			_oldPosXCursor = playPauseBtn.x;
			playPauseBtn.ct.addEventListener(MouseEvent.MOUSE_OUT, _dropPlayPause);
			_lineToolbar = new Rectangle(toolbar.x, playPauseBtn.y, toolbar.width, 0);
			playPauseBtn.startDrag(false, _lineToolbar);
			
		}
			
		private function _dropPlayPause(evt:MouseEvent):void {
			//_trace.debug("\n*** UsCommand._dropPlayPause");
			playPauseBtn.ct.removeEventListener(MouseEvent.MOUSE_OUT, _dropPlayPause);
			playPauseBtn.stopDrag();
			if (_oldPosXCursor == playPauseBtn.x) { //le curseur n'a pas bougé, on a demandé la pause!
				//_trace.debug("Le curseur n'a pas bougé -> Pause!");
				_sndMgr.switchPlayPause();
			}
			else { //on a déplacé le curseur
				//_trace.debug("Le curseur a bougé -> Fin du dragging !");
				var timeToGo:Number;
				var percent:Number = ((playPauseBtn.x-toolbar.x) / toolbar.seekbar.width) * 100;
				timeToGo = (percent / 100) * _sndMgr.soundLength;
				_sndMgr.goToSeek(timeToGo);
			}
			_oldPosXCursor = 0;
			_sndMgr.addEventListener(MediaEvent.SOUND_PLAYING, _updatePositions);//reprend l'écoute pour recommencer le déplacement du bouton-curseur
		}

		//--------------------------------------------------
		//
		//		Drag & Drop
		//
		//--------------------------------------------------
		function _dragCommand(evt:MouseEvent):void {
			var rect:Rectangle = new Rectangle(0, 0, stage.stageWidth-this.width, stage.stageHeight-this.height);
			this.startDrag(false, rect);
		}
			
		function _dropCommand(evt:MouseEvent):void{
			this.stopDrag();
		}
		
		//--------------------------------------------------
		//
		//		Volume management
		//
		//--------------------------------------------------
		private function volumeClick(evt:MouseEvent) {
			var dX:Number = Math.round((vol_ct.mouseX / volWidth)*100)/100;
			setVolume(dX);
		}
		
		private function volumeStartDrag(evt:MouseEvent) {
			this.addEventListener(MouseEvent.MOUSE_MOVE, volumeDrag);
		}
		
		private function volumeDrag(evt:MouseEvent) {
			var dX:Number = Math.round((vol_ct.mouseX / volWidth)*100)/100;
			setVolume(dX);
		}
		
		private function volumeStopDrag(evt:MouseEvent) {
			this.removeEventListener(MouseEvent.MOUSE_MOVE, volumeDrag);
		}
		
		public function setVolume(p_vol:Number) {
			var vol:Number = p_vol;
			if(vol < 0.05) vol = 0;
			if (vol > 1) vol = 1;
			_sndMgr.setVolume(vol);
			volSlider_mc.x = 3 + (1 - vol) * -35;
		}
		
		/**
		 * 
		 * @param	p_pos
		 */
		public function setPosition(p_pos:Point) {
			_pos = p_pos;
			this.x = _pos.x;
			this.y = _pos.y;
		}
		
		//--------------------------------------------------
		//
		//		affichage de la commande
		//
		//--------------------------------------------------
		/**
		 * 
		 * @param	evt
		 */
		private function _checkMousePosition(evt:MouseEvent) {
			//_trace.debug("._checkMousePosition : stageY:" + evt.stageY);
			if (evt.stageY > 750) {
				_moveIn();
			} else if(evt.stageY < 680) {
				if(_isOpen) _moveOut();
			}
		}
		private function _moveIn() {
			if (!_isOpen) {
				Tweener.addTween(this, { y:_pos.y, time:0.5, transition:"easeOutQuart" } );
				_isOpen = true;
			}
		}
		
		private function _moveOut() {
			if(_isOpen) {
				Tweener.addTween(this, { y:_pos.y + 27, time:0.7, transition:"easeOutQuart" } );
				_isOpen = false;
			}
		}
	}
}