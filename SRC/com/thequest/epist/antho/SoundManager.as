package com.thequest.epist.antho {
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.AppNav;
	import com.thequest.epist.NavEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import flash.events.TimerEvent;

	
	/**
	 * ...
	 * @author nlgd
	 */
	public class SoundManager extends EventDispatcher {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private static var _instance:SoundManager;
		//
		private var _trace:SuperTrace;
		private var _mgr:AnthoManager;
		private var _sound:Sound;
		private var _channel:SoundChannel;
		private var _pausePosition:Number;
		private var _isPlaying:Boolean = true;
		private var _transform:SoundTransform;
		private var _currentVolume:Number = 1;
		private var _soundTimer:Timer;
		private var _appNav:AppNav;
		private var _isIndeSound:Boolean;
		private var _autoNext:Boolean = true;
		//
		
		//--------------------------------------------------
		//
		//		Singleton
		//
		//--------------------------------------------------
		public static function getInstance():SoundManager {
			if (_instance == null) {
				_instance = new SoundManager(new SingletonBlocker());
			}
			return _instance;
		}
		//
		public function SoundManager(p_key:SingletonBlocker) {
			if (p_key == null) {
				throw new Error("Error : Instantiation failed : Use SoundManager.getInstance() instead of new.");
			} else {
				_trace = SuperTrace.getTrace();
				_trace.debug("Hello SoundManager !");
				_mgr = AnthoManager.getInstance();
				_mgr.addEventListener(NavEvent.OPEN_US, _openSound);
				_mgr.addEventListener(Event.COMPLETE, function(evt:Event) {
					stopSound();
				} );
				_soundTimer = new Timer(40);
				_soundTimer.addEventListener(TimerEvent.TIMER, _soundHandler);
				var _appNav:AppNav = AppNav.getInstance();
				_appNav = AppNav.getInstance();
				_appNav.addEventListener(NavEvent.OPEN_RUB, function(evt:Event) {
					//_trace.debug("SoundManager réagit au changement de rubrique");
					stopSound();
					stopAllSounds();
				});
			}
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		/**
		 * Déclenché lors de l'évenement OPEN_US envoyé par le AnthoManager
		 * @param	evt
		 */
		private function _openSound(evt:Event) {
			//_trace.debug("SoundManager._openSound");
			var ud:USData = _mgr.currentUD;
			//_trace.debug("l'url du fichier à ouvrir : " + ud.soundURL);
			_isIndeSound = false;
			_loadSound(ud.soundURL);
		}		
		
		/**
		 * Chargement d'un fichier de son
		 * @param	filename
		 */
		private function _loadSound(filename:String, autoplay:Boolean = true) {
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
			
			// ##### TODO : gérer l'état "son en pause" / traiter différemment 
			
			if (_isPlaying || _mgr.forcePlaying) {
				_playSound();
			} else {
				this.goToSeek(0);
			}
			
			
			//if(autoplay) _playSound();
		}
		
		public function loadIndeSound(filename:String, autoplay:Boolean = true) {
			//_trace.debug("SoundManager.loadIndeSound" + filename);
			this.stopSound();
			_isIndeSound = true;
			this._loadSound(filename, autoplay);
		}
		
		public function setAutoNext(bool:Boolean) {
			_autoNext = bool;
		}
		
		/**
		 * 
		 * @param	evt
		 */
		private function _soundLoadComplete(evt:Event) {
			//_trace.debug("_soundLoadComplete");
			this.dispatchEvent(new MediaEvent(MediaEvent.SOUND_LOADED));
		}
		
		
		public function switchPlayPause() {
			//_trace.debug("SoundManager.switchPlayPause");
			if (_isPlaying)
				this.stopSound();
			else
				this._playSound();
		}
		
		/**
		 * Démarre la lecture du son
		 */
		private function _playSound() {
			//_trace.debug("SoundManager._playSound");
			_soundTimer.start();
			_isPlaying = true;
			try {
				_channel = _sound.play(_pausePosition);
			} catch (e:Error) {
				_trace.error("Erreur : SoundManager._playSound : impossible de lire le son (" + e + ")");
			}
			this.setVolume(_currentVolume);
			_channel.addEventListener(Event.SOUND_COMPLETE, _soundComplete);
			this.dispatchEvent(new MediaEvent(MediaEvent.SOUND_PLAYED));
		}
		
		public function playSound() {
			this._playSound();
		}

		/**
		 * Arrête le son
		 */
		public function stopSound() {
			if (_isPlaying) {
				if(_channel) {
					//_trace.debug("SoundManager.stopSound");
					_soundTimer.stop();
					_channel.stop();
					_pausePosition = _channel.position;
					_isPlaying = false;
					this.dispatchEvent(new MediaEvent(MediaEvent.SOUND_STOPPED));
				}
			}
		}
		/**
		 * Arrête tous les sons de l'appli 
		 * (utilisée pour stopper les sons des SWF chargés sur lesquels on n'a pas la main, ni les sources)
		 */
		public function stopAllSounds() {
			SoundMixer.stopAll();
		}
		
		/**
		 * 
		 * @param	evt
		 */
		private function _soundHandler(evt:TimerEvent) {
			//_trace.debug("SoundManager._soundHandler");
			this.dispatchEvent(new MediaEvent(MediaEvent.SOUND_PLAYING));
		}
		
		/**
		 * 
		 * @param	evt
		 */
		private function _soundComplete(evt:Event) {
			//_trace.debug("_soundComplete");
			if (!_isIndeSound && _autoNext) {
				_mgr.gotoNextUS();
			}
			this.dispatchEvent(new Event(Event.SOUND_COMPLETE));
		}
		/**
		 * 
		 * @param	evt
		 */
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
		
		
		
		public function setVolume(vol:Number) {
			//_trace.debug("SoundManager.setVolume = "+vol);
			if (_channel) {
				_transform = _channel.soundTransform;
				_transform.volume = vol;
				_channel.soundTransform = _transform;
			}
			_currentVolume = vol;
		}
		
		/**
		 * Déplace la tete de lecture du son au 
		 * nombre de millisecondes demandées
		 */
		public function goToSeek(ms:Number) {
			//_trace.debug("SoundManager.goToSeek => "+ms);
			if (_isPlaying) {
				//_trace.debug("\t -> playing!");
				this.stopSound();
				_pausePosition = ms;
				this._playSound();
			}
			else {
				//_trace.debug("\t -> not playing!");
				_pausePosition = ms;
			}
			this.dispatchEvent(new MediaEvent(MediaEvent.MOVED_SEEK));
		}
		
		
		/**
		 * Renvoie le temps total
		 * du son(String)
		 *
		 */
		public function getTotalTime():String {
			// Conversion des millisecondes en minutes/secondes du temps joue
			var tt:Number = Math.floor(_sound.length / 1000); // en secondes
			var mm:Number = Math.floor( tt / 60 );
			var total:String = "";
			if ( mm < 10 ){
				total = "0" + mm;
			} else {
				total = total+mm;
			}
			
			var ss:Number = tt % 60;
			
			if ( ss < 10 ){
				total = total+":0" + ss;
			} else {
				total = total+":" + ss;
			}
			return total;
		}
		
		
		/**
		 * Renvoie le temps joué 
		 * du son (String)
		 *
		 */
		public function getPlayedTime():String {
			// Conversion des millisecondes en minutes:secondes du temps joué
			var tt:Number;
			if (_isPlaying)
				tt = Math.floor(_channel.position / 1000);
			else
				tt = Math.floor(_pausePosition / 1000);
			
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
		 * Getters nécéssaires pour connaitre l'état d'avancement du son,
		 * pour que USCommand mette à jour sa toolbar
		 */
		public function get soundLength():Number {
			var length:Number = 1;
			if (_sound.length)
				length = _sound.length;
			return length;
		}
		public function get soundPosition():Number {
			var position:Number = 0;
			if (_channel.position)
				position = _channel.position;
			//_trace.debug("SoundManager.soundPosition = " + position);
			return position;
		}
		public function get pausePosition():Number {
			//_trace.debug("SoundManager.pausePosition = " + _pausePosition);
			return _pausePosition;
		}
		public function get currentVolume():Number {
			return _currentVolume;
		}
		
		public function get isPlaying():Boolean {
			return _isPlaying;
		}
	}
}

internal class SingletonBlocker {}