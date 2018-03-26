package com.thequest.epist {
	import caurina.transitions.Tweener;
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.antho.RepBrowser;
	import com.thequest.epist.antho.SearchWindow;
	import com.thequest.tools.baseurl.BaseUrl;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import com.thequest.epist.antho.Listenning;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.system.Capabilities;
	import flash.net.navigateToURL;
	import mdm.*;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class NavMenu extends MovieClip {
		
		private var _trace:SuperTrace;
		private var _appNav:AppNav;
		private var _pos:Point;
		private var _windows:Windows;
		private var _btns:Array;
		private var _isOpen:Boolean = false;
		private var _translator:Translator;
		
		
		public var home_btn:SimpleButton;
		public var quit_btn:SimpleButton;
		public var repBrowser_btn:SimpleButton;
		public var listen_btn:SimpleButton;
		public var lex_btn:SimpleButton;
		public var search_btn:SimpleButton;
		public var credits_btn:SimpleButton;
		public var logiciste_btn:SimpleButton;
		public var reduire_btn:SimpleButton;
		public var legend_tf:TextField;
		public var symbol_mc:MovieClip;

		
		public function NavMenu() {
			_appNav = AppNav.getInstance();
			_windows = Windows.getInstance();
			_trace = SuperTrace.getTrace();
			_translator = Translator.getInstance();
			_translator.addEventListener(Event.CHANGE, _translatorChangeHandler);
			
			_appNav.addEventListener(NavEvent.OPEN_RUB, _update);
			
			this.visible = false;
			
			quit_btn.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent) { 				
				_appNav.setWindowed();
				if (_appNav.currentId == AppNav.CS_CREDITS) {
					_appNav.quit();
				} else {
					_appNav.change(AppNav.CS_CREDITS);
				}
			} );
			
			home_btn.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent) { 
				_appNav.change(AppNav.CS_HOME);
			} );
			
			lex_btn.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent) {
				var lexBox:LexiqueBox = LexiqueBox.getInstance();
				lexBox.switchOpen();
			});
			
			repBrowser_btn.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent) {
				var bsr:RepBrowser = RepBrowser.getInstance();
				//_windows.openWindow(bsr);
				bsr.openCurrent();
			});
			
			listen_btn.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent) {
				var listen:Listenning = Listenning.getInstance();
				//listen.switchOpen();
				_windows.openWindow(listen);
			});
			
			search_btn.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent) {
				var sw:SearchWindow = SearchWindow.getInstance();
				sw.openCurrent();
				//_windows.openWindow(sw);
			});
			
			credits_btn.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent) {
				_appNav.change(AppNav.CS_CREDITS);
			});
			
			reduire_btn.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent) {
				_appNav.switchFullScreen();
			});
			
			logiciste_btn.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent) {
				var url:String = BaseUrl.getInstance().BASE + "appdata/" + Translator.getInstance().language + "/schema_logiciste.pdf";
				//navigateToURL(new URLRequest(url), "_blank");
				
				_appNav.setWindowed();
				
				var appFilename:String = mdm.Application.filename;
				if (appFilename) mdm.System.exec(url);
				else navigateToURL(new URLRequest(url), "_blank");
				
			});
			
			// Stocke tous les boutons dans un tableau (plus facile d'accès pour activations / désactivations)
			_btns = new Array();
			_btns.push(quit_btn, home_btn, lex_btn, repBrowser_btn, listen_btn, search_btn, credits_btn, logiciste_btn, reduire_btn);
			
			symbol_mc.alpha = 0;
			
		}
		/**
		 * Initialisation de tout ce qui change selon la langue
		 */
		private function _versionInit() {
			_activateLegendHandlers(home_btn, _translator.translate("menu_home"));
			_activateLegendHandlers(lex_btn, _translator.translate("menu_lexique"));
			_activateLegendHandlers(repBrowser_btn, _translator.translate("menu_repertoires"));
			_activateLegendHandlers(search_btn, _translator.translate("menu_recherche"));
			_activateLegendHandlers(listen_btn, _translator.translate("menu_enecoute"));
			_activateLegendHandlers(credits_btn, _translator.translate("menu_credits"));
			_activateLegendHandlers(quit_btn, _translator.translate("menu_quit"));
			_activateLegendHandlers(logiciste_btn, _translator.translate("menu_logiciste"));
			_activateLegendHandlers(reduire_btn, _translator.translate("menu_reduire"));
		}
		/**
		 * Appelé après un changement de langue diffusé par le Translator
		 * @param	evt
		 */
		private function _translatorChangeHandler(evt:Event) {
			_versionInit();
		}
		/**
		 * Actions affichage / masquage selon mouvements de la souris
		 */
		public function activateMouseInteractions() {
			_trace.debug("NavMenu.activateMouseInteractions");
			if (stage) {
				stage.addEventListener(MouseEvent.MOUSE_MOVE, _checkMousePosition);
			}
		}
		/**
		 * 
		 * @param	evt
		 */
		private function _checkMousePosition(evt:MouseEvent) {
			//_trace.debug("NavMenu._checkMousePosition : stageY:" + evt.stageY);
			if (evt.stageY > 750) {
				_moveIn();
			} else if(evt.stageY < 680) {
				if(_isOpen) _moveOut();
			}
		}
		
		/**
		 * Active les interactions entre la souris et les boutons, pour affichage légendes
		 * @param	button
		 * @param	legend
		 */
		private function _activateLegendHandlers(p_button:SimpleButton, p_legend:String) {
			p_button.addEventListener(MouseEvent.MOUSE_OVER, function(evt:MouseEvent) {
				//legend_tf.alpha = 0;
				legend_tf.text = p_legend;
				//Tweener.removeTweens(legend_tf);
				//Tweener.addTween(legend_tf, { alpha:1, time:0.2, transition:"easeOutQuart" } );
			});
			p_button.addEventListener(MouseEvent.MOUSE_OUT, function(evt:MouseEvent) {
				legend_tf.text = "";
			});
		}
		
		
		/**
		 * 
		 * @param	evt
		 */
		private function _update(evt:NavEvent) {
			switch(_appNav.currentId) {
				case AppNav.CS_INTRO:
					// pas de menu
					break;
				case AppNav.CS_HOME:
					_setButtons([credits_btn, reduire_btn, quit_btn]);
					legend_tf.x = 12.0;
					break;
				case AppNav.CS_ARGU_INTRO:
				case AppNav.CS_ARGU_BROWSE:
					_setButtons([logiciste_btn, lex_btn, home_btn, reduire_btn, quit_btn]);
					legend_tf.x = 65.0;
					break;
				case AppNav.CS_ANTHO_INTRO:
					_setButtons([repBrowser_btn, search_btn, listen_btn, lex_btn, home_btn, reduire_btn, quit_btn]);
					legend_tf.x = 112.0;
					break;
				case AppNav.CS_CREDITS:
					_setButtons([home_btn, quit_btn]);
					legend_tf.x = 12.0;
					break;
				default:
					_setButtons([home_btn, reduire_btn, quit_btn]);
					legend_tf.x = 12.0;
					break;
			}
		}
		/**
		 * Définit les boutons actifs
		 * @param	activeBtns : tableau contenant tous les boutons à activer
		 */
		private function _setButtons(activeBtns:Array) {
			var N:int = _btns.length;
			var i:int;
			for (i = 0; i < N; i++) {
				if (activeBtns.indexOf(_btns[i]) >= 0) {
					_btns[i].visible = true;
				} else {
					_btns[i].visible = false;
				}
			}
			
		}
		/**
		 * 
		 */
		private function _moveIn() {
			if (!_isOpen) {
				Tweener.removeTweens(this);
				Tweener.addTween(this, { y:_pos.y, time:0.5, transition:"easeOutQuart" } );
				Tweener.addTween(symbol_mc, { alpha:0, time:0.3, transition:"easeOutQuart" } );
				_isOpen = true;
			}
		}
		
		private function _moveOut() {
			if (_isOpen) {
				Tweener.removeTweens(this);
				Tweener.addTween(this, { y:_pos.y + 27, time:0.7, transition:"easeOutQuart" } );
				Tweener.addTween(symbol_mc, { alpha:1, time:0.5, transition:"easeOutQuart" } );
				_isOpen = false;
			}
		}
		/**
		 * 
		 */
		public function show() {
			//_trace.debug("NavMenu.show");
			this.visible = true;
		}
		/**
		 * 
		 */
		public function hide() {
			//_trace.debug("NavMenu.hide");
			this.visible = false;
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
		
		
	}
	
}