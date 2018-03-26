package com.thequest.epist.antho {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.display.Loader;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.IOErrorEvent;	
	
	import flash.net.URLLoader;
	import flash.net.URLRequest;	
	
	import fl.video.FLVPlayback;
	import fl.video.VideoEvent;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	
	import caurina.transitions.Tweener;
	import com.nlgd.supertrace.*;
	import fl.video.VideoScaleMode;
	import fl.video.AutoLayoutEvent;
	
	import com.thequest.epist.antho.SoundManager;
	
	public class VideoObject extends MediaObject	{
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _vidContainer:Sprite;
		private var _vidFilename:String;
		private var _imgLoader:Loader;
		private var _isLoaded:Boolean = false;
		private var _isPlaying:Boolean = false;
		
		private var _videoPlayer:FLVPlayback;
		private var _firstMedia:Boolean;
		private var _sndMgr:SoundManager;
		//
		public var heightContainer:int;
		//public var pauseButton:MovieClip;
		public var playButton:MovieClip;
		public var toolbar:MovieClip;
		public var seekbar:MovieClip;
		//
		public static const WIDTH_MAX_MEDIA:int = 455;
		public static const HEIGHT_MAX_MEDIA:int = 402;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function VideoObject() {
			_trace = SuperTrace.getTrace();
			//_trace.info("* Hello VideoObject");
			toolbar.visible = false;
			this.visible = true;
			this.alpha = 0;
			_vidContainer = new Sprite();
			this.addChild(_vidContainer);
			_sndMgr = SoundManager.getInstance();
			_sndMgr.addEventListener(MediaEvent.SOUND_PLAYED, _playingSound);
			
			toolbar.play_btn.addEventListener(MouseEvent.CLICK, playHandler);
			toolbar.pause_btn.addEventListener(MouseEvent.CLICK, pauseHandler);
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------	
		override public function setContentUrl(filename:String) {
			//_trace.debug("VideoObject.SetContentUrl override, filename = "+filename);
			_vidFilename = filename;
		}
		
		override public function load() {
			//_trace.debug("VideoObject.load override");
			if (!_isLoaded) {
				//_trace.debug("Charge la vidéo");
				loadVideo(_vidFilename);
			}
			else {
				//_trace.debug("Déja chargée!");
				this.dispatchEvent(new MediaEvent(MediaEvent.MEDIA_LOADED));	
			}
		}
		
		public function loadVideo(filename:String) {
			//_trace.debug("VideoObject.loadVideo");
			//_filename = filename;
			_videoPlayer = new FLVPlayback();
			
			if ((_videoPlayer.width > MediaObject.WIDTH_MAX_MEDIA) || (_videoPlayer.height > MediaObject.HEIGHT_MAX_MEDIA)) {
				_videoPlayer.registrationWidth = MediaObject.WIDTH_MAX_MEDIA;
				_videoPlayer.registrationHeight = MediaObject.HEIGHT_MAX_MEDIA;
			}
			_videoPlayer.addEventListener(VideoEvent.PLAYHEAD_UPDATE, playheadUpdate);
			_videoPlayer.addEventListener(VideoEvent.BUFFERING_STATE_ENTERED, bufferingVideo);
			_videoPlayer.addEventListener(VideoEvent.PLAYING_STATE_ENTERED, playingVideo);
			_videoPlayer.addEventListener(VideoEvent.COMPLETE, completeVideo);
			_videoPlayer.addEventListener(VideoEvent.READY, readyVideo);
			_videoPlayer.addEventListener(AutoLayoutEvent.AUTO_LAYOUT, autolayoutVideo);
			_videoPlayer.source = _vidFilename;
			_videoPlayer.autoPlay = false;
			_videoPlayer.scaleMode = VideoScaleMode.NO_SCALE ;
			_videoPlayer.fullScreenTakeOver = false;
			_vidContainer.addChild(_videoPlayer);
		}
		
		public function readyVideo(evt:VideoEvent) {
			//_trace.debug("VideoObject.readyVideo");
			_isLoaded = true;
			show();
			pauseHandler();
			playButton.alpha = 1;
			centre(_vidContainer, MediaObject.WIDTH_MAX_MEDIA);
			heightContainer = _vidContainer.height;
			this.dispatchEvent(new MediaEvent(MediaEvent.MEDIA_LOADED));
			displayPlayPause();
		}
		
		
		public function autolayoutVideo(evt:AutoLayoutEvent) {
			//_trace.debug("VideoObject.autolayoutVideo");	
		}	
		
		
		public function playheadUpdate(evt:VideoEvent) {
			//_trace.debug("VideoObject.playheadUpdate");
			/*
			var playtime:Number = _videoPlayer.playheadTime;
			var minutes:Number = Math.floor(playtime/60);
			var seconds:Number = Math.floor(playtime%60);
			var minutes_str:String = minutes < 10 ? "0" + String(minutes) : String(minutes);
			var seconds_str:String = seconds < 10 ? "0" + String(seconds) : String(seconds);
			*/
			//_trace.info(minutes_str+"min : " + seconds_str +" seconds");
			
			toolbar.playedTime_tf.text = _timeToString(_videoPlayer.playheadTime);
			toolbar.totalTime_tf.text = _timeToString(_videoPlayer.totalTime);
			
		}
		

		public function playHandler(evt:MouseEvent = null) {
			_videoPlayer.play();
			//playButton.visible = false;
			//pauseButton.visible = true;
			//_trace.debug("playHandler");
			_sndMgr.stopSound();
			_isPlaying = true;
			displayPlayPause();
		}
		
		private function bufferingVideo(evt:VideoEvent) {
			//_trace.debug("bufferingVideo");
		}
		
		private function playingVideo(evt:VideoEvent) {
			//_trace.debug("playingVideo");
		}

		private function completeVideo(evt:VideoEvent) {
			//_trace.debug("videoComplete");
			this.dispatchEvent(new VideoEvent(VideoEvent.COMPLETE));
			_videoPlayer.seek(0);
			_isPlaying = false;
			displayPlayPause();
		}

		override public function show() {
			//_trace.debug("VideoObject.show override");
			
			this.visible = true;
			Tweener.addTween(this, { alpha:1, time:1, transition:"easeOutQuart" } );
			this.setElementsLecteur();
			addEventListener(MouseEvent.MOUSE_OVER, showButtons);
			addEventListener(MouseEvent.MOUSE_OUT, hideButtons);
			
			_videoPlayer.x = 0;
			_videoPlayer.y = 0;
			
			//this.playHandler();
			this.pauseHandler();
			
			trace(_vidFilename);
		}
		
		override public function hide() {
			//_trace.debug("VideoObject.hide override");
			//super.hide();
			this.pauseHandler();
			Tweener.addTween(this, {alpha:0, time:1, transition:"easeOutQuart"});
		}
		
		
		private function centre(container:Sprite, widthMax:int):void {
			//_trace.debug("VideoObject.centre");
			container.x = (widthMax / 2) - (container.width / 2);
		}
		
		public function get hauteur():int {
			return heightContainer;
		}
		
		public function setElementsLecteur() {
			//_trace.debug("VideoObject.setElementsLecteur");
			

			playButton.x = ((_vidContainer.width)/2)-((playButton.width)/2);
			playButton.y = ((_vidContainer.height)/2)-((playButton.height)/2);
			playButton.addEventListener(MouseEvent.CLICK, playHandler);
			
			//pauseButton.x = ((_vidContainer.width)/2)-((playButton.width)/2);
			//pauseButton.y = ((_vidContainer.height)/2)-((playButton.height)/2);
			//pauseButton.addEventListener(MouseEvent.CLICK, pauseHandler);
		
			//pauseButton.alpha = 0;
			playButton.alpha = 1;
			
			setToolbar();
			
			_vidContainer.addChild(toolbar);
			//_vidContainer.addChild(pauseButton);
			_vidContainer.addChild(playButton);
			
			//_trace.debug("setElements : Position FLVPlayback : " + _videoPlayer.x + "," + _videoPlayer.y);
		}
		
		
		public function setToolbar() {
			toolbar.x = 0;
			toolbar.y = _vidContainer.height;
			toolbar.width = _vidContainer.width;
			toolbar.seekbar.fullness_mc.scaleX = 1;
			toolbar.seekbar.progress_mc.scaleX = 1;
			toolbar.seekbar.SeekBar.scaleX = 1;
			toolbar.alpha = 1;
			toolbar.visible = true;
			//toolbar.seekbar.ct.width = toolbar.seekbar.width;
			_videoPlayer.seekBar = toolbar.seekbar;
			toolbar.seekbar.ct.addEventListener(MouseEvent.CLICK, changeCursorVideo);

			toolbar.alpha = 0;
			toolbar.visible = true;
		}
		
		public function changeCursorVideo(evt:MouseEvent) {
			//_trace.info("changeCursorVideo");
			//_trace.info("evt.localX : " + evt.localX);
			var percent:Number = ((evt.localX) * 100 ) / (evt.target.width);
			//_trace.info("pourcentage : " + percent);
			_videoPlayer.seekPercent(percent);
		}
		
		public function showButtons(evt:MouseEvent=null) {
			//Tweener.addTween(pauseButton, { alpha:1, time:1, transition:"easeOutQuart" } );
			Tweener.addTween(playButton, { alpha:1, time:1, transition:"easeOutQuart" } );
			Tweener.addTween(toolbar, { alpha:1, time:1, transition:"easeOutQuart" } );
		}
		public function hideButtons(evt:MouseEvent) {
			//Tweener.addTween(pauseButton, { alpha:0, time:0.5, transition:"easeOutQuart" } );
			Tweener.addTween(toolbar, { alpha:0, time:0.5, transition:"easeOutQuart" } );
		}
		
		public function pauseHandler(event:MouseEvent = null):void{
			_videoPlayer.pause();
			_isPlaying = false;
			displayPlayPause();
		}
		
		public function _playingSound(evt:MediaEvent) {
			if (_isPlaying) {
				_trace.debug("VideoObject._playingSound");
				this.pauseHandler();
			}
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
	}
}