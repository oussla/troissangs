package com.thequest.epist.argu {
	import com.nlgd.supertrace.SuperTrace;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class MicroSoundPlayersManager extends EventDispatcher {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		public static const STOP:String = "stop";
		//
		private var _trace:SuperTrace;
		private var _activePlayer:MicroSoundPlayer;
		//--------------------------------------------------
		//
		//		Singleton
		//
		//--------------------------------------------------
		private static var _instance:MicroSoundPlayersManager;
		//
		public static function getInstance():MicroSoundPlayersManager {
			if (_instance == null) {
				_instance = new MicroSoundPlayersManager(new SingletonBlocker());
			}
			return _instance;
		}
		//
		public function MicroSoundPlayersManager(p_key:SingletonBlocker) {
			if (p_key == null) {
				throw new Error("Error : Instantiation failed : Use MicroSoundPlayersManager.getInstance() instead of new.");
			} else {
				_trace = SuperTrace.getTrace();
				_trace.debug("Hello MicroSoundPlayersManager !");
				
			}
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		/**
		 * Enregistre un lecteur qui passe en "play"
		 * @param	p_player
		 */
		public function registerPlaying(p_player:MicroSoundPlayer) {
			_activePlayer = p_player;
			this.dispatchEvent(new Event(MicroSoundPlayersManager.STOP));
		}
		/**
		 * 
		 * @param	p_player
		 */
		public function isActive(p_player:MicroSoundPlayer) {
			return _activePlayer === p_player;
		}
		/**
		 * 
		 */
		public function stopAllPlayers() {
			_activePlayer = null;
			this.dispatchEvent(new Event(MicroSoundPlayersManager.STOP));
		}
		
		
	}
}

internal class SingletonBlocker {}