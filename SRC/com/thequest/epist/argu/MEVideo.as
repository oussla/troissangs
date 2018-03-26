package com.thequest.epist.argu {
	import caurina.transitions.Tweener;
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.EDMedia;
	import com.thequest.tools.baseurl.BaseUrl;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.IOErrorEvent;
	
	import fl.video.FLVPlayback;
	import fl.video.VideoEvent;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	
	import fl.video.VideoScaleMode;
	import fl.video.AutoLayoutEvent;
	
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class MEVideo extends MediaElement {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _vidContainer:Sprite;
		private var _vidFilename:String;
		private var _isLoaded:Boolean = false;
		private var _isPlaying:Boolean = false;
		private var _videoPlayer:FLVPlayback;
		private var _baseUrl:BaseUrl;
		//
		public var toolbar:MovieClip;
		//public var pauseButton:MovieClip;
		public var playButton:MovieClip;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function MEVideo(p_ed:EDMedia) {
			super(p_ed);
			_baseUrl = BaseUrl.getInstance();
			_trace = SuperTrace.getTrace();
			_trace.debug("Hello MEVideo!");
			toolbar.alpha = 0;
			toolbar.visible = false;
			

			_vidContainer = new Sprite();
			_vidContainer.alpha = 0;
			this.addChild(_vidContainer);
			_vidFilename = p_ed.url;
			//_vidFilename = p_ed.url;
			trace("_vidFilename : " + _vidFilename);
			
			playButton.visible = false;
			//pauseButton.visible = false;
			playButton.alpha = 1;
			//pauseButton.alpha = 0;
			
			playButton.ct.addEventListener(MouseEvent.CLICK, playHandler);
			//pauseButton.ct.addEventListener(MouseEvent.CLICK, pauseHandler);
			
			toolbar.play_btn.addEventListener(MouseEvent.CLICK, playHandler);
			toolbar.pause_btn.addEventListener(MouseEvent.CLICK, pauseHandler);
			
			// Replace la toolbar par dessus
			this.addChild(toolbar);
			
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		/**
		 * Ecrase la fonction d'init.
		 */
		override public function init() {
			loadVideo(_vidFilename);
		}
		/**
		 * Chargement 
		 */
		public function loadVideo(filename:String) {
			_trace.debug("MeVideo.loadVideo : "+filename);
			_videoPlayer = new FLVPlayback();
			_videoPlayer.addEventListener(VideoEvent.COMPLETE, completeVideo);
			_videoPlayer.addEventListener(VideoEvent.READY, readyVideo);
			_videoPlayer.addEventListener(VideoEvent.PLAYHEAD_UPDATE, _playHeadUpdate);
			_videoPlayer.source = filename;
			_videoPlayer.autoPlay = false;
			_videoPlayer.scaleMode = VideoScaleMode.NO_SCALE ;
			_videoPlayer.fullScreenTakeOver = false;
			_videoPlayer.x = 0;
			_videoPlayer.y = 0;
			_videoPlayer.x = Math.round((_zoneWidth - _videoPlayer.width) / 2);
			_videoPlayer.y = Math.round((_zoneHeight - _videoPlayer.height) / 2);
			_vidContainer.addChild(_videoPlayer);
		}
		
		public function readyVideo(evt:VideoEvent) {
			_trace.debug("MEVideo.readyVideo");
			_isLoaded = true;

			Tweener.addTween(_vidContainer, { alpha:1, time:0.5, transition:"easeOutQuart" } );
			
			// Laisser la vidéo en pause à l'ouverture
			//_videoPlayer.play();
			//_isPlaying = true;
			
			playButton.x = Math.round((_zoneWidth - playButton.width) / 2);
			playButton.y = Math.round((_zoneHeight - playButton.height) / 2);
			//pauseButton.x = Math.round((_zoneWidth - pauseButton.width) / 2);
			//pauseButton.y = Math.round((_zoneHeight - pauseButton.height) / 2);
			//pauseButton.visible = false;
			playButton.visible = true;
			
			this.setToolbar();
			_videoPlayer.seekBar = toolbar.seekbar;
			
			this.addChild(playButton);
			//this.addChild(pauseButton);
			
			this.addEventListener(MouseEvent.MOUSE_OVER, function(evt:MouseEvent) {
				if (_isPlaying)	showButtons();
			});
			this.addEventListener(MouseEvent.MOUSE_OUT, function(evt:MouseEvent) {
				if (_isPlaying)	hideButtons();
			});	
			
			this.displayPlayPause();
			
			toolbar.totalTime_tf.text = _timeToString(_videoPlayer.totalTime);
		}
		
		public function showButtons(evt:MouseEvent = null) {
			//Tweener.addTween(pauseButton, { alpha:1, time:1, transition:"easeOutQuart" } );
			Tweener.addTween(playButton, { alpha:1, time:1, transition:"easeOutQuart" } );
			Tweener.addTween(toolbar, { alpha:1, time:1, transition:"easeOutQuart" } );
		}
		public function hideButtons(evt:MouseEvent = null) {
			//Tweener.addTween(pauseButton, { alpha:0, time:0.5, transition:"easeOutQuart" } );
			Tweener.addTween(playButton, { alpha:0, time:0.5, transition:"easeOutQuart" } );
			Tweener.addTween(toolbar, { alpha:0, time:0.5, transition:"easeOutQuart" } );
		}

		
		public function pauseHandler(event:MouseEvent = null) {
			_trace.debug("MEVideo.pauseHandler!");
			if (_isPlaying) {
				_videoPlayer.pause();
				_isPlaying = false;
			}
			this.displayPlayPause();
		}
		public function playHandler(evt:MouseEvent = null) {
			if (!_isPlaying) {
				_videoPlayer.play();
				_isPlaying = true;
			}
			this.displayPlayPause();
		}
		
		public function displayPlayPause() {
			if (_isPlaying) {
				playButton.visible = false;
				toolbar.pause_btn.visible = true;
				toolbar.play_btn.visible = false;
			}
			else {
				playButton.visible = true;
				toolbar.pause_btn.visible = false;
				toolbar.play_btn.visible = true;
			}
		}
		
		public function setToolbar() {
			toolbar.x = _videoPlayer.x + Math.round((_videoPlayer.width - toolbar.width) / 2);
			toolbar.y = Math.round(_videoPlayer.y + _videoPlayer.height);// + toolbar.height;
			//toolbar.width = _vidContainer.width;
			_trace.debug("MEVideo.setToolbar, x :" + toolbar.x);
			toolbar.seekbar.fullness_mc.scaleX = 1;
			toolbar.seekbar.progress_mc.scaleX = 1;
			toolbar.seekbar.SeekBar.scaleX = 1;
			toolbar.alpha = 1;
			toolbar.visible = true;
			_videoPlayer.seekBar = toolbar.seekbar;
			toolbar.seekbar.ct.addEventListener(MouseEvent.CLICK, changeCursorVideo);
		}
		
		public function changeCursorVideo(evt:MouseEvent) {
			var percent:Number = ((evt.localX) * 100 ) / (evt.target.width);
			_videoPlayer.seekPercent(percent);
		}

		private function completeVideo(evt:VideoEvent) {
			//_trace.debug("videoComplete");
			this.dispatchEvent(new VideoEvent(VideoEvent.COMPLETE));
			_videoPlayer.seek(0);
			_isPlaying = false;
			//pauseButton.visible = false;
			//playButton.visible = true;
			//playButton.alpha = 1;
			displayPlayPause();
		}
		
		private function _playHeadUpdate(evt:VideoEvent) {
			toolbar.playedTime_tf.text = _timeToString(_videoPlayer.playheadTime);
			//toolbar.totalTime_tf.text = _timeToString(_videoPlayer.totalTime);
		}
		/**
		 * 
		 * @param	tt
		 * @return
		 */
		private function _timeToString(tt:Number):String {
			// Conversion des secondes en minutes:secondes du temps joué
			tt = Math.floor(tt);
			
			var mm:Number = Math.floor( tt / 60 );
			var time:String = "";
			if ( mm < 10 ){
				time = "0" + mm;
			} else {
				time = time+mm;
			}
			
			var ss:Number = tt % 60;
			
			if ( ss < 10 ){
				time = time+":0" + ss;
			} else {
				time = time+":" + ss;
			}
			//_trace.debug("calcul du temps joué = "+time);
			return time;
		}
		
		/**
		 * 
		 */
		override public function clear() {
			super.clear();
			if(_videoPlayer) {
				_videoPlayer.pause();
			}
		}
		
	}
	
}