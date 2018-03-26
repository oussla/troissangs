package com.thequest.epist.antho {
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.Lexique;
	import com.thequest.epist.NavEvent;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Mouse;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class USViewer extends MovieClip {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _mgr:AnthoManager;
		private var _ud:USData;
		private var _isOpen:Boolean = false;
		private var _mediaViewer:MediaViewer;
		private var _multilangues:USMultilangues;
		private var _lexique:Lexique;
		private var _usCommand:USCommand;
		private var tabNumLine:Array; // tableau contenant les champs de numéros de lignes
		//
		public var comment_tf:TextField;
		public var lineNums_tf:TextField;
		public var commentDotLine_mc:MovieClip;
		public var strophe_tf:TextField;
		public var cleanStrophe_tf:TextField;
		public var firstNumLine:MovieClip;
		
		private var _temp:Sprite;
		
		//public var usCode_tf:TextField;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function USViewer() {
			_mgr = AnthoManager.getInstance();
			_mgr.addEventListener(NavEvent.OPEN_US, _openUS);
			_trace = SuperTrace.getTrace();
			_mediaViewer = new MediaViewer();
			_mediaViewer.setPosition(new Point(351, 43));
			this.addChild(_mediaViewer);
			_multilangues = new USMultilangues();
			_multilangues.addEventListener(Event.CHANGE, _langChange);
			_multilangues.x = 23;
			_multilangues.y = 23;
			this.addChild(_multilangues);
			this.visible = false;

			_usCommand = new USCommand();
			//_usCommand.x = 560;
			//_usCommand.y = 670;
			_usCommand.setPosition(new Point(679, 768));
			this.addChild(_usCommand);
			_usCommand.init();
			
			_lexique = Lexique.getInstance();
			
			var cf:CorpusFormats = CorpusFormats.getInstance();
			var css:StyleSheet = cf.getBasicCSS();
			css.setStyle("a", {color:"#C7C7C7"} );
			comment_tf.styleSheet = css;
			
			comment_tf.addEventListener(TextEvent.LINK, _textEventHandler);
			
			//this.addChild(lineNums_tf);
			
			//usCode_tf.visible = false;
			tabNumLine = new Array();
			
			// the "cleanStrophe" textfield allows to easily detect the charBoundaries, without being annoyed by the italic markups.
			cleanStrophe_tf.visible = false;
			
		}
		
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		private function _openUS(evt:NavEvent) {
			//_trace.debug("USViewer._openUS");
			//trace("UsViewer._openUs");
			_ud = _mgr.currentUD;
			_setComment(_ud.comment);
			//lineNums_tf.text = _ud.getLineNums();
			
			var usPath:Array = _mgr.getCurrentPath();
			//usCode_tf.text = "Référence de l'US : " + usPath.join(",");
			
			//comment_tf.htmlText = _ud.comment;
			//_multilangues.reset();
			//_multilangues.init(_ud.strophe); //remplacé par l'écoute d'AnthoManager par USMultilangues
			//vers_tf.htmlText = _ud.strophe;
			// Ouverture de la liste de médias
			_mediaViewer.openMediaList(_ud.getMediaList());
			//
			this.show();
			
			_clearNumLines();
			
			// get rid of the italics
			var cleanStrophe:String = _cleanItals(_ud.strophe);
			// place the clean text into the reference textfield
			cleanStrophe_tf.text = cleanStrophe;
			// place the complete text into the visible strophe field
			strophe_tf.htmlText = _ud.strophe;
			// search for lines into the clean strophe (get rid of all the italic markups)
			var rtLinesPos:Array = _getLinesPositions(cleanStrophe);
			// and finally place the line numbers at the correct places.
			_placeLineNums(cleanStrophe_tf, rtLinesPos);
		}
		/**
		 * 
		 */
		private function show() {
			if (!_isOpen) {
				this.visible = true;
				_isOpen = true;
			}
		}
		/**
		 * Changement entendu dans les colonnes de langues
		 * @param	evt
		 */
		private function _langChange(evt:Event) {
			//_trace.debug("USViewer._langChange (" + _multilangues.nbLang + " langues ouvertes)");
			// Si une colonne est ouverte, afficher média + comment
			// Si 2 colonnes, masquer média
			// Si 3 colonnes, masquer comment_tf
			switch(_multilangues.nbLang) {
				case 1:
					//_mediaViewer.visible = true;
					_mediaViewer.show();
					comment_tf.visible = true;
					commentDotLine_mc.visible = true;
					break;
				case 2:
					//_mediaViewer.visible = false;
					_mediaViewer.hide();
					comment_tf.visible = true;
					commentDotLine_mc.visible = true;
					break;
				case 3:
					//_mediaViewer.visible = false;
					_mediaViewer.hide();
					comment_tf.visible = false;
					commentDotLine_mc.visible = false;
					break;
				default:
					break;
			}
			
		}
		
		private function _setComment(p_text:String) {
			comment_tf.autoSize = TextFieldAutoSize.LEFT;
			comment_tf.text = "";
			comment_tf.height = 20;
			comment_tf.htmlText = p_text;
			comment_tf.y = 680 - comment_tf.height;
		}
		
		private function _textEventHandler(evt:TextEvent) {
			_trace.debug("_textEventHandler : " + evt.type + ", " + evt.text);
			var term:String;
			var split:Array = evt.text.split(":");
			term = split[1];
			_lexique.openDef(term);
		}
		
		/**
		 * Clean str from every italic HTML markups.
		 * @param	str
		 */
		private function _cleanItals(str:String):String {
			var pattern:RegExp = /<i>/gi;
			str = str.replace(pattern, "");
			pattern = /<\/i>/gi;
			str = str.replace(pattern, "");
			return str;
		}
		
		/**
		 * Returns all the new line character's positions found into str.
		 * @param	str
		 * @return
		 */
		private function _getLinesPositions(str:String):Array {
			//trace("UsViewer._getLinesPositions");
			var rtLignesPos:Array = new Array();
			var index:int = 0;
			var len:uint = str.length;
			while (index != -1) {
				index = str.indexOf("\n", index);
				if (index != -1) {
					var nbPos:uint = rtLignesPos.length;
					if (nbPos > 0 && ((index - rtLignesPos[nbPos - 1]) <= 1)) {
							rtLignesPos.pop();
					}
					rtLignesPos.push(index);
					index++;
				}
			}
			return rtLignesPos;
		}
		/**
		 * 
		 * @param	tf
		 * @param	rtLignesPos
		 */
		private function _placeLineNums(tf:TextField, rtLinesPos:Array, firstLineNum:uint = 0):void {
			//trace("UsViewer._placeLineNums");
			var N:uint = rtLinesPos.length;
			//trace("nombre de numéros de lignes à placer : " + rtLinesPos.length);
			var pos:uint;
			var rect:Rectangle;
			var numTemp:LineNum;
			//firstNumLine.numTf.text = _ud.firstVerseNumber;
			_ud.firstVerseNumber == -1 ? firstNumLine.numTf.text = "" : firstNumLine.numTf.text = String(_ud.firstVerseNumber + numLigne);
			var numLigne:int = 1; // la première ligne est traité différement
			
			for (var i:uint = 0; i < N; i++) {
				//création du tableau des positions
				pos = rtLinesPos[i] + 1;
				rect = tf.getCharBoundaries(pos);
				//trace("rect " + i + " : " + rect);
				if(rect) {
					//création des champs de numéros de lignes
					numTemp = new LineNum();
					numTemp.setNum(String(_ud.firstVerseNumber + numLigne));
					tabNumLine.push(numTemp);
					numTemp.x = -4;
					numTemp.y = 44+rect.y;
					this.addChild(numTemp);
					numLigne++;
				}
			}
		}
		
		private function _clearNumLines():void {
			var N:int = tabNumLine.length;
			//trace("UsViewer._clearNumLines : "+N);
			var i:int;
			for (i = 0; i < N; i++) {
				var tmp:LineNum = tabNumLine[i];
				tmp.clear();
				if (this.contains(tmp))
					this.removeChild(tmp);
			}
		}
	}
	
}