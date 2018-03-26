package com.thequest.epist {
	import com.nlgd.supertrace.SuperTrace;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import flash.system.fscommand;
	import flash.system.Capabilities;
	import mdm.*;

	
	/**
	 * ...
	 * @author nlgd
	 */
	public class AppNav extends EventDispatcher {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		// Définition des id de rubriques
		public static const CS_INTRO:int = 0;
		public static const CS_HOME:int = 1;
		public static const CS_ARGU_INTRO:int = 2;
		public static const CS_ARGU_BROWSE:int = 3;
		public static const CS_ANTHO_INTRO:int = 20;
		public static const CS_CREDITS:int = 30;
		//
		private static var _instance:AppNav = null;
		private var _trace:SuperTrace;
		private var _currentId:int;
		private var _subNavId:int;
		private var _currentScr:String;
		private var _context:String;
		private var _isFullscreen:Boolean = false;
		private var _windowRect:Rectangle;
		
		//--------------------------------------------------
		//
		//		Singleton
		//
		//--------------------------------------------------
		public static function getInstance():AppNav {
			if (_instance == null) {
				_instance = new AppNav(new SingletonBlocker());
			}
			return _instance;
		}
		//
		public function AppNav(p_key:SingletonBlocker) {
			if (p_key == null) {
				throw new Error("Error : Instantiation failed : Use AppNav.getInstance() instead of new.");
			} else {
				_trace = SuperTrace.getTrace();
				_trace.debug("Hello AppNav !");
			}
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		public function change(p_id:int) {
			_trace.debug("AppNav.change");
			_currentId = p_id;
			this.dispatchEvent(new Event(NavEvent.PREPARE));
		}
		
		public function readyToOpen() {
			_trace.info("AppNav.readyToOpen : " + _currentId);
			this.dispatchEvent(new NavEvent(NavEvent.OPEN_RUB));
		}
		
		public function get currentId():int {
			return _currentId;
		}
		
		/**
		 * Passage en mode plein écran
		 */
		public function setFullScreen() {
			trace("PASSAGE EN PLEIN ECRAN");
			/*
			var os:String = Capabilities.os;
			os = os.substr(0, 3).toLowerCase();
			// N'applique le changement que si on est dans Zinc
			var filename:String = mdm.Application.filename;
			if (filename) {
				switch(os) {
					case "mac":
						mdm.Forms.thisForm.showFullScreen(true);
						break;
					case "win":
						mdm.Application.bringToFront();
						mdm.Forms.thisForm.hideCaption(true);
						mdm.Forms.thisForm.maximize();
						break;
					default:
						break;
				}
			}
			*/
			_isFullscreen = true;
			this.dispatchEvent(new Event(Event.FULLSCREEN));
			
		}
		/**
		 * Passage en mode écran normal
		 */
		public function setWindowed() {
			trace("PASSAGE EN MODE NORMAL");
			/*
			var os:String = Capabilities.os;
			os = os.substr(0, 3).toLowerCase();
			
			// N'applique le changement que si on est dans Zinc
			var filename:String = mdm.Application.filename;
			if (filename) {				
				switch(os) {
					case "mac":
						mdm.Forms.thisForm.showFullScreen(false);
						break;
					case "win":
						mdm.Forms.thisForm.hideCaption(false);
						mdm.Forms.thisForm.restore();
						// #### Recale la hauteur de la fenêtre pour compenser la coupure
						mdm.Forms.thisForm.height = 790;
						mdm.Application.sendToBack();
						break;
					default:
						break;
				}
			}*/
			_isFullscreen = false;
			this.dispatchEvent(new Event(Event.FULLSCREEN));
			
		}
		/**
		 * Switche d'un mode à l'autre
		 */
		public function switchFullScreen() {
			if (_isFullscreen) setWindowed();
			else setFullScreen();
		}
		/**
		 * Ferme l'application
		 */
		public function quit() {
			_trace.debug("quit");
			fscommand("quit");
			mdm.Application.exit();
		}
		
		
		public function set context(c:String) {
			_context = c;
		}
		
		public function get context():String {
			return _context;
		}
		
		/**
		 * Identifiant utilisé pour les échanges d'infos sur les sous-rub entre deux écrans
		 * (typiquement pour le passage de l'intro argu à la navigation argu...)
		 */
		public function set subNavId(s:int) {
			_subNavId = s;
		}
		
		public function get subNavId():int {
			return _subNavId;
		}
		
		public function get isFullScreen():Boolean {
			return _isFullscreen;
		}

	}
	
}

internal class SingletonBlocker {}