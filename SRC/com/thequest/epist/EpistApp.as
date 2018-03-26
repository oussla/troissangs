package com.thequest.epist {
	import caurina.transitions.properties.ColorShortcuts;
	import com.nlgd.supertrace.SuperTrace;
	import com.nlgd.supertrace.SuperTraceStrictWindow;
	import com.thequest.epist.antho.SoundManager;
	import com.thequest.tools.baseurl.BaseUrl;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.fscommand;
	import flash.system.Capabilities;
	import mdm.*;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;

	/**
	 * ...
	 * @author nlgd
	 */
	public class EpistApp extends MovieClip {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _translator:Translator;
		private var _appNav:AppNav;
		private var _currentScr:ContentScreen;
		private var _container:Sprite;
		private var _containerMask:Sprite;
		private var _visualLoad:VisualLoad;
		private var _navMenu:NavMenu;
		private var _xmlLoader:XMLLiteLoader;
		private var _lexique:Lexique;
		private var _lexBox:LexiqueBox;
		private var _windows:Windows;
		private var _baseUrl:BaseUrl;
		private var _soundMgr:SoundManager;
		//
		public var superTraceWindow:SuperTraceStrictWindow;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function EpistApp() {
			mdm.Application.init(this, onInit);		
			stage.scaleMode = StageScaleMode.NO_SCALE;
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		/**
		 * Fonction appelée lors de l'init MDM.
		 */
		public function onInit() {
			
			
			/*
			var os:String = Capabilities.os;
			os = os.substr(0, 3).toLowerCase();
			//mdm.Dialogs.prompt("Système : " + os);
			
			// Si "filename" n'est pas défini, force l'init hors Zinc.
			var filename:String = mdm.Application.filename;
			if (filename) {
				switch(os) {
					case "mac":
						mdm.Forms.thisForm.showFullScreen(true);
						break;
					case "win":
					default:
						mdm.Forms.thisForm.hideCaption(true);
						mdm.Forms.thisForm.maximize();
						break;
				}
			}
			*/
			
			this._init();
			
		}
		/**
		 * 
		 */
		private function _init() {
			_trace = SuperTrace.getTrace();
			_trace.debug("Hello EpistApp !");
			_trace.setLevel(SuperTrace.DEBUG);
			//
			
			_baseUrl = BaseUrl.getInstance();
			 //Si on est dans Zinc, utilise le chemin de l'appli comme url de base
			var myAppPath:String = mdm.Application.path;
			//var myAppPath:String = mdm.Application.pathUnicode;
			if (myAppPath) {
				_baseUrl.setBaseUrl(myAppPath);
			} else {
				 //Sinon, calcule le path d'après les infos du loader
				//var rootUrl:String;
				//_trace.debug("---- url : " + this.loaderInfo.url);
				//_trace.debug("---- loaderURL : " + this.loaderInfo.loaderURL);
				//var truncateAt:int = this.loaderInfo.url.lastIndexOf("/");
				//if (truncateAt > 0) {
					//rootUrl = this.loaderInfo.url.substring(0, truncateAt) + "/";
				//} else {
					//rootUrl = "./";
				//}		
				_baseUrl.setBaseUrl("");
			}
			_trace.debug("baseUrl : " + _baseUrl.BASE);
			//
			ColorShortcuts.init();
			//
			_soundMgr = SoundManager.getInstance();
			_visualLoad = VisualLoad.getInstance();
			_appNav = AppNav.getInstance();
			_appNav.addEventListener(Event.FULLSCREEN, _fullScreenHandler); //#ajout jenny nov10
			_appNav.setFullScreen();
			_appNav.addEventListener(NavEvent.PREPARE, _prepareChange);
			_appNav.addEventListener(NavEvent.OPEN_RUB, _openScreen);
			_container = new Sprite();
			_containerMask = new Sprite();
			_containerMask.graphics.beginFill(0x00FF00);
			_containerMask.graphics.drawRect(0, 0, 1024, 768);
			_containerMask.graphics.endFill();
			_container.mask = _containerMask;
			this.addChild(_containerMask);
			this.addChild(_container);
			//
			_visualLoad.x = 512;
			_visualLoad.y = 384;
			this.addChild(_visualLoad);
			//
			_windows = Windows.getInstance();
			//
			_navMenu = new NavMenu();
			_navMenu.setPosition(new Point(72, 768));
			_container.addChild(_navMenu);
			_navMenu.activateMouseInteractions();
			//
			this.addChild(superTraceWindow);
			//
			_appNav.change(0);
			_appNav.setFullScreen();
		}
		
		private function _fullScreenHandler(evt:Event):void {
			trace("EpistApp_fullScreenHandler");
			
			// ZINC -----
			var os:String = Capabilities.os;
			os = os.substr(0, 3).toLowerCase();
			var filename:String = mdm.Application.filename;
			
			
			if (!_appNav.isFullScreen) {
				trace("on est en fullscreen, on doit passer en normal");
				//stage.displayState = StageDisplayState.NORMAL;
				
				
				// N'applique le changement que si on est dans Zinc
				
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
				} else {
					stage.displayState = StageDisplayState.NORMAL;
				}
				// ----------
				
				
				
				
			}
			else {
				trace("on est en normal, on doit passer en fullscreen");
				//stage.displayState = StageDisplayState.FULL_SCREEN;
				
				
				// ZINC -----
				// N'applique le changement que si on est dans Zinc
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
				} else {
					stage.displayState = StageDisplayState.FULL_SCREEN;
				}
				// ----------
				
			}
		}
		/**
		 * Changement de langue.
		 * Initialise le Translator.
		 * @param	evt
		 */
		private function _languageChange(evt:Event) {
			var langSelector:LanguageSelector = evt.target as LanguageSelector;
			var lang:String = langSelector.language;
			_trace.debug("Langue : " + lang);
			_translator = Translator.getInstance();
			_translator.addEventListener(Event.CHANGE, _translatorReady);
			_translator.init(lang);
		}
		/**
		 * Le traducteur est prêt : ouvre l'écran d'accueil.
		 * @param	evt
		 */
		private function _translatorReady(evt:Event) {
			_trace.debug(_translator.translate("testMessage"));
			//this.removeChild(scrPreHome);
			_appNav.change(1);
			
			//préparation du lexique
			_xmlLoader = new XMLLiteLoader();
			_xmlLoader.addEventListener(Event.COMPLETE, _xmlLexiqueLoaded);
			_xmlLoader.load(_baseUrl.BASE + "appdata/" + _translator.language + "/lexique.xml");
		}
		
		private function _xmlLexiqueLoaded(evt:Event) {
			_lexique = Lexique.getInstance();
			_lexique.init(_xmlLoader.xml);
			_lexBox = LexiqueBox.getInstance();
			_lexBox.x = 72;
			//_lexBox.y = 25;
			_lexBox.init();
			_container.addChild(_lexBox);
			//
		}
		
		/**
		 * Changement d'écran demandé depuis AppNav 
		 * @param	evt
		 */
		private function _prepareChange(evt:Event) {
			if(_currentScr) {
				_currentScr.addEventListener(Event.CLOSE, _contentClosed);
				_currentScr.close();
			} else {
				_appNav.readyToOpen();
			}
		}
		/**
		 * Le contenu précédent est fermé 
		 * @param	evt
		 */
		private function _contentClosed(evt:Event) {
			if (_currentScr != null && _container.contains(_currentScr)) {
				_container.removeChild(_currentScr);
			}
			_currentScr = null;
			_appNav.readyToOpen();
			//_openScreen();
		}
		
		
		private function _openScreen(evt:NavEvent) {
			_trace.debug("_openScreen " + _appNav.currentId);
			var showMenu:Boolean = true;
			switch(_appNav.currentId) {
				// Ecran de pré-home (choix langue)
				case AppNav.CS_INTRO:
					var preHome:CSPreHome = new CSPreHome();
					preHome.langSelector.addEventListener(Event.CHANGE, _languageChange);
					_currentScr = preHome;
					showMenu = false;
					break;
				// Ecran Home
				case AppNav.CS_HOME:
					var home:CSHome = new CSHome();
					home.langSelector.addEventListener(Event.CHANGE, _languageChange);
					_currentScr = home;
					_navMenu.show();
					break;
				// Ecran d'intro Argumentaire
				case AppNav.CS_ARGU_INTRO:
					_currentScr = new CSArguIntro();
					break;
				// Ecran Browse Argumentaire
				case AppNav.CS_ARGU_BROWSE:
					_currentScr = new CSArguBrowse();
					break;
				// Ecran Intro Anthologie
				case AppNav.CS_ANTHO_INTRO:
					_currentScr = new CSAnthoIntro();
					break;
				// Ecran Crédits
				case AppNav.CS_CREDITS:
					_currentScr = new CSCredits();
					break;
				default:
					break;
			}
			if (_currentScr) {
				_container.addChild(_currentScr);
				// Définit le contexte (ANTHO, ARGU, DEFAULT)
				_appNav.context = _currentScr.context;
			}
			showMenu ? _navMenu.show() : _navMenu.hide();
			
			// Replace les éléments devant...
			if (_lexBox)	_container.addChild(_lexBox);
			if (_navMenu) _container.addChild(_navMenu);
		}
		
	}
	
}