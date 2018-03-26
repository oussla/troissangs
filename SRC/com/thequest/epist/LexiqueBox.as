package com.thequest.epist {
	import caurina.transitions.Tweener;
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.tools.ascenseur.Ascenseur;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class LexiqueBox extends Window {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private static var _instance:LexiqueBox;
		//
		private var _trace:SuperTrace;
		private var _lex:Lexique;
		private var _isInit:Boolean = false;
		private var _letters:Array;
		private var _lettersContainer:Sprite;
		private var _terms:Array;
		private var _termsContainer:Sprite;
		private var _termsAsc:Ascenseur;
		private var _termsAscCom:AscenseurCommand;
		private var _defAsc:Ascenseur;
		private var _defAscCom:AscenseurCommand;
		private var _curLetterId:int;
		private var _curTermId:int;
		private var _currentLetter:LexiqueBoxLetterButton;
		private var _currentTerm:LexTermButton;
		private var _currentLtd:LexTermData;
		private var _basicFormat:BasicFormat;
		//
		public var letter_tf:TextField;
		//public var definition_tf:TextField;
		public var definition_mc:MovieClip;
		
		public var debug_tf:TextField;
		//--------------------------------------------------
		//
		//		Singleton
		//
		//--------------------------------------------------
		public static function getInstance():LexiqueBox {
			if (_instance == null) {
				_instance = new LexiqueBox(new SingletonBlocker());
			}
			return _instance;
		}
		//
		public function LexiqueBox(p_key:SingletonBlocker) {
			if (p_key == null) {
				throw new Error("Error : Instantiation failed : Use LexiqueBox.getInstance() instead of new.");
			} else {
				_trace = SuperTrace.getTrace();
				_trace.info("Hello LexiqueBox !");
			}
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		/**
		 * Initialisation
		 */
		public function init() {
			if (!_isInit) {
				_isInit = true;
			
				trace("LexiqueBox.init");
				title_tf.text = _translator.translate("lexique").toUpperCase();
				_lex = Lexique.getInstance();
				_lex.addEventListener(Event.OPEN, _openDefHandler);
				_lex.addEventListener(LexiqueEvent.READY, _onLexiqueReady);
				_basicFormat = BasicFormat.getInstance();
				// Crée les 26 boutons lettres
				_letters = new Array();
				_lettersContainer = new Sprite();
				_lettersContainer.x = 1;
				_lettersContainer.y = 40;
				this.addChild(_lettersContainer);
				var i:int = 0;
				var N:int = 26;
				for (i; i < N; i++) {
					var lBtn:LexiqueBoxLetterButton = new LexiqueBoxLetterButton(String.fromCharCode(i + 65));
					lBtn.y = i * 20;
					lBtn.addEventListener(MouseEvent.CLICK, _letterClick);
					lBtn.addEventListener(MouseEvent.CLICK, _letterClick);
					_lettersContainer.addChild(lBtn);
					_letters.push(lBtn);
				}
				// Prépare la liste des termes
				_terms = new Array();
				_termsContainer = new Sprite();
				_termsContainer.x = 26;
				_termsContainer.y = 100;
				this.addChild(_termsContainer);
				
				//_termsAsc = new Ascenseur(_termsContainer, new Rectangle(25, 100, 301, 158));
				//_termsAscCom = new AscenseurCommand(_termsAsc);
				//_termsAscCom.x = 306;
				//_termsAscCom.y = 235;
				//this.addChild(_termsAscCom);
				
				var list:Sprite = new Sprite();
				list.addChild(_termsContainer);
				
				_termsAsc = new Ascenseur(_termsContainer, new Rectangle(25, 100, 301, 158));
				list.addChild(_termsAsc);
				_termsAscCom = new AscenseurCommand(_termsAsc);
				_termsAscCom.x = list.width;
				_termsAscCom.y = 110;
				_termsAscCom.visible = true;
				list.addChild(_termsAscCom);
				this.addChild(list);
				
				//
				// Prépare l'affichage des définitions
				definition_mc.definition_tf.autoSize = TextFieldAutoSize.LEFT;
				_defAsc = new Ascenseur(definition_mc.definition_tf, new Rectangle(0, 0, definition_mc.width, 245));
				definition_mc.addChild(_defAsc);
				_defAscCom = new AscenseurCommand(_defAsc);
				_defAscCom.x = definition_mc.width;
				_defAscCom.y = 10;
				_defAscCom.visible = true;
				definition_mc.addChild(_defAscCom);
				this.addChild(definition_mc);
				
				
				//
				this.visible = false;
				//this.x = -this.width;
				_openLetter("a");
				
				_translator.addEventListener(Event.CHANGE, _changeLanguage);
				
				//trace("LexiqueBox coords : x: " + this.x + ", y:" + this.y);
			}
		}
		/**
		 * Ouverture de la boite lexique
		 * @param	evt
		 */
		override public function open(evt:MouseEvent = null) {
			if (!_isOpen) {
				_isOpen = true;
				
				this.alpha = 0;
				this.visible = true;
				Tweener.removeTweens(this);
				Tweener.addTween(this, { alpha:1, time:0.75, transition:"easeOutQuart" } );
				/*
				this.visible = true;
				Tweener.removeTweens(this);
				Tweener.addTween(this, { x:0, time:0.75, transition:"easeOutQuart" } );
				*/
			}
		}
		/**
		 * Fermeture de la boite
		 * @param	evt
		 */
		override public function close(evt:MouseEvent = null) {
			_isOpen = false;
			Tweener.removeTweens(this);
			
			Tweener.addTween(this, { alpha:0, time:0.5, transition:"easeOutQuart", onComplete:function() {
				visible = false;
			}});
			/*
			Tweener.addTween(this, {x:-this.width, time:0.5, transition:"easeOutQuart", onComplete:function() {
				visible = false;
			}});
			*/
		}
		/**
		 * 
		 * @param	evt
		 */
		private function _onLexiqueReady(evt:Event):void {
			trace("LexiqueBox -> _onLexiqueReady");
			_currentLetter = null;
			_openLetter("a");
		}
		/**
		 * Appelée lorsque Lexique déclenche "open".
		 * @param	term
		 */
		private function _openDefHandler(evt:Event) {
			var term:String = "";
			var ltData:LexTermData = _lex.openingLtData;
			_trace.debug("LexiqueBox._openDefHandler : " + ltData.term);
			_openLetter(ltData.letter);
			_showDef(ltData);
			this.open();
		}
		/**
		 * 
		 * @param	evt
		 */
		private function _letterOver(evt:MouseEvent) {
			
		}
		/**
		 * 
		 * @param	evt
		 */
		private function _letterOut(evt:MouseEvent) {
			
		}
		/**
		 * Click sur un bouton de lettre
		 * @param	evt
		 */
		private function _letterClick(evt:MouseEvent) {
			var lBtn:LexiqueBoxLetterButton = evt.target as LexiqueBoxLetterButton;
			_openLetter(lBtn.letter);
		}
		/**
		 * Ouverture d'une lettre : création de la liste de tous les termes commençant par "letter"
		 * @param	letter
		 */
		private function _openLetter(letter:String) {
			letter = letter.toLowerCase();
			var lid:int = letter.charCodeAt(0) - 97;
			letter = letter.charAt(0);
			// N'ouvre la lettre que si le caractère demandé correspond bien à [a-z]
			if(lid >= 0 && lid < 26) {
				// N'ouvre la lettre que si elle n'était pas déjà ouverte
				if (!_currentLetter || _currentLetter != _letters[lid]) {
					_resetTerms();
					letter_tf.text = letter.toUpperCase();
					var t:Array = _lex.getTermsList(letter);
					var N:int = t.length;
					for (var i:int = 0; i < N; i++) {
						var ltBtn:LexTermButton = new LexTermButton(t[i]);
						ltBtn.y = i * 21;
						ltBtn.addEventListener(MouseEvent.CLICK, _termClick);
						ltBtn.addEventListener(MouseEvent.MOUSE_OVER, _termOver);
						ltBtn.addEventListener(MouseEvent.MOUSE_OUT, _termOut);
						_termsContainer.addChild(ltBtn);
						_terms.push(ltBtn);
					}
					_termsAsc.resetPosition();
					if (N > 0) {
						_showDef(_terms[0].ltData);
					} else {
						_resetDef();
					}
					// Marque la lettre active
					if (_currentLetter != null) {
						_currentLetter.setNormal();
					}
					_currentLetter = _letters[lid];
					_currentLetter.setActive();
				}
			}
		}
		/**
		 * Reset de la liste de termes
		 */
		private function _resetTerms() {
			if (_terms) {
				if (_terms.length > 0) {
					var N:int = _terms.length;
					for (var i:int = 0; i < N; i++) {
						var ltBtn:LexTermButton = _terms.shift() as LexTermButton;
						_termsContainer.removeChild(ltBtn);
					}
				}
			}
		}
		/**
		 * Reset de la définition
		 */
		private function _resetDef() {
			definition_mc.definition_tf.text = "";
		}
		/**
		 * Click sur un terme du lexique
		 * @param	evt
		 */
		private function _termClick(evt:MouseEvent) {
			var ltBtn:LexTermButton = evt.target as LexTermButton;
			this._showDef(ltBtn.ltData);
		}
		private function _termOver(evt:MouseEvent) {
			var ltBtn:LexTermButton = evt.target as LexTermButton;
			ltBtn.btnOver();
		}
		private function _termOut(evt:MouseEvent) {
			var ltBtn:LexTermButton = evt.target as LexTermButton;
			ltBtn.btnOut();
		}
		/**
		 * Affichage de la définition d'un terme du lexique
		 * @param	term
		 */
		private function _showDef(ltData:LexTermData) {
			_currentLtd = ltData;
			definition_mc.definition_tf.text = "";
			//definition_tf.height = 1;
			_defAsc.resetPosition();
			definition_mc.definition_tf.styleSheet = _basicFormat.getBasicCSS();
			definition_mc.definition_tf.htmlText = _basicFormat.transformItaTags(ltData.term.toUpperCase() + "\n" + ltData.definition);
			definition_mc.definition_tf.height = definition_mc.definition_tf.textHeight;
			_defAscCom.checkHeights();
		}
		/**
		 * Renvoi le terme sélectionné dans la lexBox.
		 * @return
		 */
		public function getCurrentTerm():String {
			var str:String;
			if (_currentLtd) str = _currentLtd.term;
			return str;
		}
		
		
		/**
		 * Changement de langue indiqué par le Translator
		 * @param	evt
		 */
		private function _changeLanguage(evt:Event) {
			_trace.debug("LexiqueBox._changeLanguage");
			_resetTerms();
			_resetDef();
			close();
		}
	}
}

internal class SingletonBlocker {}