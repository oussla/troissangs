package com.thequest.epist.editor {
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.*;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class TextEditor extends Sprite {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		protected var _trace:SuperTrace;
		protected var _str:String = "";
		protected var _bg:Sprite;
		protected var _lexique:Lexique;
		protected var _hasChanges:Boolean = false;
		//
		public var ref_tf:TextField;
		public var edit_tf:TextField;
		public var edit_btn:SimpleButton;
		public var toolbar:MovieClip;
		public var cancel_btn:SimpleButton;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function TextEditor() {
			_trace = SuperTrace.getTrace();
			edit_btn.addEventListener(MouseEvent.CLICK, _edit);
			cancel_btn.addEventListener(MouseEvent.CLICK, _promptBeforeCancelEdit);
			toolbar.accept_btn.addEventListener(MouseEvent.CLICK, _acceptEdit);
			toolbar.ital_btn.addEventListener(MouseEvent.CLICK, _insertItal);
			toolbar.lex_btn.addEventListener(MouseEvent.CLICK, _insertLex);
			var bf:BasicFormat = BasicFormat.getInstance();
			var css:StyleSheet = bf.getBasicCSS();
			css.setStyle("a", {color:"#C7C7C7"} );
			ref_tf.styleSheet = css;
			ref_tf.addEventListener(TextEvent.LINK, _textEventHandler);
			edit_tf.addEventListener(Event.CHANGE, _textChangeHandler);
			_bg = new Sprite();
			_bg.graphics.beginFill(0x212121);
			_bg.graphics.drawRect(0, 0, this.width + 10, this.height + 10);
			_bg.graphics.endFill();
			this.addChildAt(_bg, 0);
			//
			_lexique = Lexique.getInstance();
			//
			_switchEditMode(false);
		}
		/**
		 * Récupère le texte à afficher, en version "brute" (italique marqués <i>)
		 * @param	p_str
		 */
		public function setText(p_str:String) {
			_str = p_str;
			ref_tf.htmlText = _toHTML(_str);
		}
		/**
		 * 
		 */
		public function get text():String {
			return _str;
		}
		/**
		 * 
		 * @param	evt
		 */
		protected function _edit(evt:MouseEvent = null) {
			edit_tf.text = _str;
			edit_tf.setSelection(0, 0);
			_switchEditMode(true);
		}
		/**
		 * 
		 * @param	evt
		 */
		protected function _acceptEdit(evt:MouseEvent = null) {
			this.setText(edit_tf.text);
			_switchEditMode(false);
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		/**
		 * Demande confirmation avant d'annuler les modifications
		 * @param	evt
		 */
		protected function _promptBeforeCancelEdit(evt:MouseEvent = null) {
			if (_hasChanges) {
				var alert:AlertPopup = AlertPrompt.getInstance().newAlert("Annuler les modifications ?", "Oui", "Non");
				alert.addEventListener(AlertPrompt.ACCEPT, _cancelEdit, false, 0, true);
			} else {
				_cancelEdit();
			}
		}
		/**
		 * Annule les modifications
		 * @param	evt
		 */
		protected function _cancelEdit(evt:Event = null) {
			_switchEditMode(false);
		}
		/**
		 * 
		 * @param	b
		 */
		protected function _switchEditMode(b:Boolean) {
			edit_btn.visible = !b;
			edit_tf.visible = b;
			toolbar.visible = b;
			cancel_btn.visible = b;
		}
		
		protected function _textChangeHandler(evt:Event) {
			_hasChanges = true;
		}
		
		/**
		 * Convertit la chaine au format HTML, avec balises "body" et mise en forme spéciale des italiques.
		 * @param	str
		 * @return
		 */
		protected function _toHTML(str:String):String {
			// Remplace les "<i>" par des "<span class=ita>"
			var regIStart:RegExp = /<i>/g;
			str = str.replace(regIStart, "<span class=\"ita\">");
			var regIEnd:RegExp = /<\/i>/g;
			str = str.replace(regIEnd, "</span>");
			str = "<body>" + str + "</body>";
			
			return str;
		}
		/**
		 * Insertion italique
		 * @param	evt
		 */
		protected function _insertItal(evt:MouseEvent = null) {
			var str:String = edit_tf.text;
			var strStart:String = str.slice(0, edit_tf.selectionBeginIndex);
			var word:String = str.slice(edit_tf.selectionBeginIndex, edit_tf.selectionEndIndex);
			var strEnd:String = str.slice(edit_tf.selectionEndIndex, str.length);
			edit_tf.text = strStart + "<i>" + word + "</i>" + strEnd;
			edit_tf.setSelection(edit_tf.selectionBeginIndex, edit_tf.selectionEndIndex + 7);
		}
		/**
		 * Insertion d'un lien vers le lexique
		 * @param	evt
		 */
		protected function _insertLex(evt:MouseEvent = null) {
			var str:String = edit_tf.text;
			var strStart:String = str.slice(0, edit_tf.selectionBeginIndex);
			var word:String = str.slice(edit_tf.selectionBeginIndex, edit_tf.selectionEndIndex);
			var strEnd:String = str.slice(edit_tf.selectionEndIndex, str.length);
			var lexTerm:String = LexiqueBox.getInstance().getCurrentTerm();
			if (!lexTerm) lexTerm = "";
			//var strNew:String = "<a href=\"event:lexique:" + toolbar.lexId_tf.text + "\">" + word + "</a>";
			var strNew:String = "<a href=\"event:lexique:" + lexTerm + "\">" + word + "</a>";
			edit_tf.text = strStart + strNew + strEnd;
			edit_tf.setSelection(edit_tf.selectionBeginIndex, edit_tf.selectionBeginIndex + strNew.length);
		}
		/**
		 * Intercepte les évènements déclenchés par les liens dans le texte
		 * @param	evt
		 */
		private function _textEventHandler(evt:TextEvent) {
			_trace.debug("_textEventHandler : " + evt.type + ", " + evt.text);
			var term:String;
			var split:Array = evt.text.split(":");
			term = split[1];
			_lexique.openDef(term);
		}
		
	}
	
}