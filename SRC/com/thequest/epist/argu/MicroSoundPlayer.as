package com.thequest.epist.argu {
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.antho.MediaEvent;
	import com.thequest.epist.antho.SoundManager;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class MicroSoundPlayer extends MovieClip	{
		private var _trace:SuperTrace;
		private var _mgr:MicroSoundPlayersManager;
		private var vol_ct:SimpleButton;
		private var volSlider_mc:MovieClip;
		private var _volWidth:Number = 23;
		private var _soundUrl:String;
		private var _sound:Sound;
		private var _pausePosition:Number;
		private var _channel:SoundChannel;
		private var _isPlaying:Boolean = false;
		private var _currentVolume:Number = 1;
		private var _transform:SoundTransform;
		private var _soundTimer:Timer;
		//
		public var volumeControl_mc:MovieClip;
		public var play_btn:SimpleButton;
		public var pause_btn:SimpleButton;
		public var playedTime_tf:TextField;
		
		
		public function MicroSoundPlayer(p_soundUrl:String) {
			_soundUrl = p_soundUrl;
			
			_mgr = MicroSoundPlayersManager.getInstance();
			_mgr.addEventListener(MicroSoundPlayersManager.STOP, _mgrStopEvent);
			/*
			_sndMgr = SoundManager.getInstance();
			_sndMgr.addEventListener(MediaEvent.SOUND_PLAYED, _soundPlayed);
			_sndMgr.addEventListener(MediaEvent.SOUND_STOPPED, _soundStopped);
			_sndMgr.addEventListener(Event.SOUND_COMPLETE, _soundStopped);
			*/
			
			vol_ct = volumeControl_mc.vol_ct;
			volSlider_mc = volumeControl_mc.volSlider_mc;
			vol_ct.addEventListener(MouseEvent.CLICK, volumeClick);
			vol_ct.addEventListener(MouseEvent.MOUSE_DOWN, volumeStartDrag);
			vol_ct.addEventListener(MouseEvent.MOUSE_UP, volumeStopDrag);
			vol_ct.addEventListener(MouseEvent.MOUSE_OUT, volumeStopDrag);
			
			pause_btn.addEventListener(MouseEvent.CLICK, stopSound);
			play_btn.addEventListener(MouseEvent.CLICK, playSound);
			
			_soundTimer = new Timer(40);
			_soundTimer.addEventListener(TimerEvent.TIMER, _soundPlayingHandler);
			
			// Etat initial : en pause.
			this.stopSound();
			
			_loadSound(_soundUrl);
		}		
		/**
		 * 
		 * @param	evt
		 */
		private function _mgrStopEvent(evt:Event) {
			// Si ce lecteur n'est pas à l'origine du déclenchement, stoppe.
			if (!_mgr.isActive(this)) stopSound();
		}
		
		
		/**
		 * Chargement d'un fichier de son
		 * @param	filename
		 */
		private function _loadSound(filename:String) {
			//_trace.debug("loadSound:" + filename);
			var newSound = new Sound();
			newSound.addEventListener(Event.COMPLETE, _soundLoadComplete);
			newSound.addEventListener(Event.ID3, _soundID3);
			newSound.addEventListener(IOErrorEvent.IO_ERROR, _soundError);
			newSound.load(new URLRequest(filename));
			//
			if(_sound) {
				_channel.stop();
			}				
			_pausePosition = 0;
			_sound = newSound;
			
		}
		
		/**
		 * Démarre la lecture du son
		 */
		public function playSound(evt:Event = null) {
			_mgr.registerPlaying(this);
			pause_btn.visible = true;
			play_btn.visible = false;
			_isPlaying = true;
			_soundTimer.start();
			try {
				_channel = _sound.play(_pausePosition);
			} catch (e:Error) {
				_trace.error("Erreur : MicroSoundPlayer._playSound : impossible de lire le son (" + e + ")");
			}
			this.setVolume(_currentVolume);
			_channel.addEventListener(Event.SOUND_COMPLETE, _soundComplete);
		}
		
		/**
		 * 
		 * @param	event
		 */
		public function stopSound(evt:Event = null) {
			pause_btn.visible = false;
			play_btn.visible = true;
			_isPlaying = false;
			_soundTimer.stop();
			if(_sound && _channel) {
				_channel.stop();
			}
		}
		/**
		 * 
		 * @param	evt
		 */
		private function _soundPlayingHandler(evt:TimerEvent) {
			playedTime_tf.text = _timeToString(_channel.position) + " / " + _timeToString(_sound.length);
		}
		//--------------------------------------------------
		//
		//		Volume management
		//
		//--------------------------------------------------
		private function volumeClick(evt:MouseEvent) {
			var dX:Number = Math.round((vol_ct.mouseX / _volWidth)*100)/100;
			setVolume(dX);
		}
		
		private function volumeStartDrag(evt:MouseEvent) {
			this.addEventListener(MouseEvent.MOUSE_MOVE, volumeDrag);
		}
		
		private function volumeDrag(evt:MouseEvent) {
			var dX:Number = Math.round((vol_ct.mouseX / _volWidth)*100)/100;
			setVolume(dX);
		}
		
		private function volumeStopDrag(evt:MouseEvent) {
			this.removeEventListener(MouseEvent.MOUSE_MOVE, volumeDrag);
		}
		
		public function setVolume(p_vol:Number) {
			var vol:Number = p_vol;
			if(vol < 0.05) vol = 0;
			if (vol > 1) vol = 1;
			volSlider_mc.x = 3 + (1 - vol) * -35;
			if (_channel) {
				_transform = _channel.soundTransform;
				_transform.volume = vol;
				_channel.soundTransform = _transform;
			}
			_currentVolume = p_vol;
		}
		/**
		 * 
		 * @param	tt
		 * @return
		 */
		private function _timeToString(tt:Number):String {
			// Conversion des secondes en minutes:secondes du temps joué
			tt = Math.floor(tt / 1000);
			
			var mm:Number = Math.floor( tt / 60 );
			var time:String = "";
			if ( mm < 10 ){
				time = "0" + mm;
			} else {
				time = time + mm;
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
		
		private function _soundComplete(evt:Event) {
			stopSound();
		}
		
		
		private function _soundLoadComplete(evt:Event) {
			playedTime_tf.text = _timeToString(0) + " / " + _timeToString(_sound.length);
		}
		
		private function _soundID3(evt:Event) {
			//_trace.debug("_soundID3");
			//infos_tf.text = sound.id3.songName + " - " + sound.id3.TCOM;
		}
		/**
		 * 
		 * @param	evt
		 */
		private function _soundError(evt:IOErrorEvent) {
			_trace.error("SoundManager._soundError : " + evt.text);
		}
		
	}
	
}