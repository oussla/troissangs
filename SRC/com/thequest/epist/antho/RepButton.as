package com.thequest.epist.antho {
	import caurina.transitions.Tweener;
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.NavEvent;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.Font;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class RepButton extends MovieClip {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _rd:RepData;
		private var _corpus:int;
		private var _yMargin:Number = 20;
		private var _childs:Array;
		private var _childsContainer:Sprite;
		private var _pos:Point;
		private var _developped:Boolean = false;
		private var _isActive:Boolean = false;
		//
		//public var label_tf:TextField;
		public var ct:SimpleButton;
		public var bg:MovieClip;
		public var play_btn:SimpleButton;
		public var cache:MovieClip;
		public var label_mc:MovieClip;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function RepButton(p_rd:RepData, p_corpus:int = AnthoManager.COUCHANT) {
			_trace = SuperTrace.getTrace();
			_rd = p_rd;
			_corpus = p_corpus;
			bg.visible = false;
			bg.alpha = 0;
			play_btn.visible = false;
			cache.cacheAsBitmap = true;
			label_mc.label_tf.cacheAsBitmap = true;
			label_mc.cacheAsBitmap = true;
			label_mc.mask = cache;
			
			// ### Pas Top... ### Définition du corpus dans le RepData. 
			// Le RepData devrait savoir renvoyer tout seul son corpus...
			_rd.setCorpus(_corpus);
				
			if (_rd.hasChilds) {
				_childs = new Array();
				_childsContainer = new Sprite();
				_childsContainer.y = _yMargin;
				this.addChild(_childsContainer);
			}
			ct.addEventListener(MouseEvent.CLICK, _btnClick);
			
			
			// Traitement particulier pour les éléments de niveau 1 (racine LEVANT ou COUCHANT)
			if (_rd.level == 1) {
				// Développe d'office les éléments de niveau 1.
				this.develop();
				ct.visible = false;
				// le conteneur des rép. enfants est placé en 0 (pas besoin de laisser de place)
				_childsContainer.y = 0;
				_yMargin = 0;
			} else {
				// Les éléments de niveau 1 n'affichent pas leur label
				this.setLabel(_rd.title);
				ct.addEventListener(MouseEvent.MOUSE_OVER, _btnOver);
				ct.addEventListener(MouseEvent.MOUSE_OUT, _btnOut);
				play_btn.addEventListener(MouseEvent.MOUSE_OVER, _btnOver);
				play_btn.addEventListener(MouseEvent.MOUSE_OUT, _btnOut);
				play_btn.addEventListener(MouseEvent.CLICK, _play);
			}
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		/**
		 * Clic sur le bouton
		 * @param	evt
		 */
		private function _btnClick(evt:MouseEvent) {
			if (_rd.hasChilds) {
				switchDevelop();
			}
			// Diffuse OPEN, interprété différemment par l'intercepteur si le RepData contient des US ou une description.
			this.dispatchEvent(new Event(Event.OPEN, true));
		}
		/**
		 * 
		 * @param	p_label
		 */
		public function setLabel(p_label:String) {
			label_mc.label_tf.embedFonts = true;
			label_mc.label_tf.wordWrap = false;
			
			//var maxChar:int = 50;
			// Tronque la chaine
			//if (p_label.length > maxChar) {
				//_trace.debug("RepButton.setLabel : doit tronquer la chaine, longueur : " + p_label.length + "(" + p_label + ")")
				//p_label = p_label.substr(0, maxChar) + "...";
			//}
			
			var cf:CorpusFormats = CorpusFormats.getInstance();
			var css:StyleSheet = cf.getCSS(_corpus, _rd.level);
			
			if (_rd.level <= 3) p_label = p_label.toUpperCase();
			label_mc.label_tf.styleSheet = css;
			label_mc.label_tf.htmlText = p_label;
			label_mc.label_tf.x = (_rd.level + 1) * 10;
			//label_tf.setTextFormat(this._getTextFormat());
		}
		/**
		 * 
		 */
		public function develop() {
			var i, N:int;
			var posY:Number;
			_childsContainer.y = _yMargin;
			// Les boutons ne sont pas re-créés s'ils existent déjà dans le tableau
			if(_childs.length == 0) {
				var list:Array = _rd.getChilds();
				N = list.length;
				//_trace.debug("RepButton.develop, " + N + " rep enfants");
				for (i = 0; i < N; i++) {
					var rb:RepButton = new RepButton(list[i], _corpus);
					rb.addEventListener(Event.CHANGE, _childStateChange);
					_childsContainer.addChild(rb);
					_childs.push(rb);
					// Développe d'office le premier niveau de sous rubriques du niveau 1
					if (_rd.level == 1) {
						//rb.develop();
					}
				}
			}
			_positionChilds();
			_childsContainer.visible = true;
			_developped = true;
			this.dispatchEvent(new Event(Event.CHANGE));
		}
		/**
		 * 
		 */
		public function close() {
			_childsContainer.y = 0;
			_childsContainer.visible = false;
			var N:int = _childs.length;
			for (var i = 0; i < N; i++) {
				_childs[i].y = 0;
			}
			_developped = false;
			this.dispatchEvent(new Event(Event.CHANGE));
			this.dispatchEvent(new NavEvent(NavEvent.CLEAN_USLIST, true));
		}
		/**
		 * 
		 * @param	evt
		 */
		public function switchDevelop(evt:MouseEvent = null) {
			//_trace.debug("RepButton.switchDevelop");
			_developped ? this.close() : this.develop();
		}
		/**
		 * 
		 */
		public function get isDevelopped():Boolean {
			return _developped;
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
		/**
		 * Renvoi une hauteur simulée de l'objet, selon s'il est développé ou non
		 */
		public function get actualHeight():Number {
			var ah:Number = 0;
			if (_developped) {
				ah = _yMargin;
				var N:int = _childs.length;
				for (var i:int = 0; i < N; i++) {
					ah += _childs[i].actualHeight;
				}
			} else {
				ah = _yMargin;
			}
			//_trace.debug("RepButton.actualHeight (" + _rd.rawTitle + ") : " + ah);
			return ah;
		}
		/**
		 * 
		 */
		public function get repData():RepData {
			return _rd;
		}
		/**
		 * Appelé lorsque l'un des enfants déclenche un évenement Event.CHANGE
		 * @param	evt
		 */
		private function _childStateChange(evt:Event) {
			//_trace.debug("childStateChange (" + _rd.title + ")");
			_positionChilds();
			this.dispatchEvent(evt);
		}
		/**
		 * Place chaque enfant de la liste d'après les dimensions des autres enfants
		 */
		private function _positionChilds() {
			var N:int = _childs.length;
			var previousChild:RepButton;
			for (var i:int = 1; i < N; i++) {
				previousChild = _childs[i - 1];
				_childs[i].y = previousChild.actualHeight + previousChild.y;
			}
		}
		/**
		 * 
		 */
		private function _clearChilds() {
			_childs = _childs.splice(0, _childs.length);
		}
		/**
		 * 
		 * @param	evt
		 */
		private function _btnOver(evt:MouseEvent) {
			play_btn.visible = true;
			if(!_isActive) {
				this.bg.visible = true;
				Tweener.removeTweens(this);
				Tweener.addTween(this.bg, { alpha:1, time:0.3, transition:"easeOutQuart" } );
			}
		}
		/**
		 * 
		 * @param	evt
		 */
		private function _btnOut(evt:MouseEvent) {
			play_btn.visible = false;
			if(!_isActive) {
				Tweener.removeTweens(this);
				Tweener.addTween(this.bg, { alpha:0, time:0.3, transition:"easeOutQuart", onComplete:function() { bg.visible = false; } } );
			}
		}
		/**
		 * 
		 * @param	evt
		 */
		private function _play(evt:MouseEvent) {
			//_trace.debug("RepButton.dispatchEvent");
			// Diffuse l'évènement OPEN_US, avec "bubble" pour qu'il remonte toute l'arbo jusqu'au RepBrowser.
			this.dispatchEvent(new NavEvent(NavEvent.OPEN_US, true));
			this._btnClick(evt); //le bouton de lecture est dans un RepButton, son click doit aussi avoir l'effet d'un clic sur le RepButton
		}
		
		public function setActive() {
			_isActive = true;
			this.bg.visible = true;
			Tweener.removeTweens(this);
			Tweener.addTween(this.bg, { alpha:1, time:0.3, transition:"easeOutQuart" } );
		}
		
		public function setNormal() {
			_isActive = false;
			Tweener.removeTweens(this);
			Tweener.addTween(this.bg, { alpha:0, time:0.3, transition:"easeOutQuart", onComplete:function() { bg.visible = false; } } );
		}
		/**
		 * 
		 * @param	evt
		 */
		public function developUsList(evt:MouseEvent = null) {
			_trace.debug("RepButton.developUsList");
			this.dispatchEvent(new NavEvent(NavEvent.OPEN_USLIST, true));
		}
		/**
		 * 
		 */
		public function get heightMC():Number {
			var h:Number;
			if (_developped) {
				h = _childsContainer.height;
			} else {
				h = _yMargin;
			}
			_trace.debug("RepButton.heightMC (" + label_mc.label_tf.text + ") : " + h);
			return h;
		}
	}
	
}