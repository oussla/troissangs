package com.thequest.epist.editor {
	import caurina.transitions.properties.ColorShortcuts;
	import com.nlgd.supertrace.SuperTraceDisplay;
	import com.thequest.epist.Lexique;
	import com.thequest.epist.LexiqueBox;
	import com.thequest.epist.Translator;
	import com.thequest.epist.Windows;
	import com.thequest.epist.XMLLiteLoader;
	import com.thequest.tools.air.NativeWindowManager;
	import com.thequest.tools.baseurl.BaseUrl;
	import fl.controls.*;
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.antho.*;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.*;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class DataEditor extends MovieClip {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _traceDisplay:SuperTraceDisplay;
		private var _baseUrl:BaseUrl;
		private var _mgr:AnthoManager;
		private var _translator:Translator;
		private var _lexique:Lexique;
		private var _lexBox:LexiqueBox;
		private var _open_btn:Button;
		private var _saveAs_btn:Button;
		private var _save_btn:Button;
		private var _browse_btn:Button;
		private var _lex_btn:Button;
		private var _menuContainer:Sprite;
		private var _btnMargin:Number = 5;
		private var _windows:Windows;
		private var _repBrowser:RepBrowser;
		private var _usEditor:USEditor;
		private var _isInit:Boolean = false;
		private var _saveFile:File;
		private var _xmlLoader:XMLLiteLoader;
		private var _soundManager:SoundManager;
		private var _nativeWindowMgr:NativeWindowManager;
		private var _alert:AlertPrompt;
		private var _appdataPath:String;
		//
		public var trace_tf:TextField;
		public var filename_tf:TextField;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function DataEditor() {
			_trace = SuperTrace.getTrace();
			_trace.setLevel(SuperTrace.INFO);
			_traceDisplay = new SuperTraceDisplay(_trace, this, trace_tf);
			_translator = Translator.getInstance();
			_mgr = AnthoManager.getInstance();
			_windows = Windows.getInstance();
			_soundManager = SoundManager.getInstance();
			_soundManager.setAutoNext(false);
			//
			var rootUrl:String;
			//_trace.debug("---- url : " + this.loaderInfo.url);
            //_trace.debug("---- loaderURL : " + this.loaderInfo.loaderURL);
            var truncateAt:int = this.loaderInfo.url.lastIndexOf("/");
            if (truncateAt > 0) {
                rootUrl = this.loaderInfo.url.substring(0, truncateAt) + "/";
            } else {
                rootUrl = "./";
            }
            _trace.debug("rootUrl : " + rootUrl);
			_baseUrl = BaseUrl.getInstance();
			_baseUrl.setBaseUrl(rootUrl);
			//
			if(stage) stage.scaleMode = StageScaleMode.NO_SCALE;
			ColorShortcuts.init();
			//
			_menuContainer = new Sprite();
			_menuContainer.x = 5;
			_menuContainer.y = 5;
			this.addChild(_menuContainer);
			_open_btn = new Button();
			_open_btn.label = "Ouvrir";
			_open_btn.addEventListener(MouseEvent.CLICK, _openFileHandler);
			_menuContainer.addChild(_open_btn);
			_saveAs_btn = new Button();
			_saveAs_btn.label = "Enregistrer sous...";
			_saveAs_btn.enabled = false;
			_saveAs_btn.x = _open_btn.x + _open_btn.width + _btnMargin;
			_saveAs_btn.addEventListener(MouseEvent.CLICK, _saveAsHandler);
			_menuContainer.addChild(_saveAs_btn);
			_save_btn = new Button();
			_save_btn.label = "Enregistrer";
			_save_btn.enabled = false;
			_save_btn.x = _saveAs_btn.x + _saveAs_btn.width + _btnMargin;
			_save_btn.addEventListener(MouseEvent.CLICK, _saveHandler);
			_menuContainer.addChild(_save_btn);
			_browse_btn = new Button();
			_browse_btn.label = "Parcourir";
			_browse_btn.enabled = false;
			_browse_btn.addEventListener(MouseEvent.CLICK, _browseHandler);
			_browse_btn.x = _save_btn.x + _save_btn.width + _btnMargin;
			_menuContainer.addChild(_browse_btn);
			_lex_btn = new Button();
			_lex_btn.label = "Lexique";
			_lex_btn.enabled = false;
			_lex_btn.addEventListener(MouseEvent.CLICK, _lexiqueHandler);
			_lex_btn.x = _browse_btn.x + _browse_btn.width + _btnMargin;
			_menuContainer.addChild(_lex_btn);
			//
			//stage.nativeWindow.addEventListener(Event.CLOSING, _preventClosing);
			_nativeWindowMgr = new NativeWindowManager(stage.nativeWindow, true);
			_nativeWindowMgr.addEventListener(NativeWindowManager.PROMPT, _promptBeforeClosing);
			//
			_alert = AlertPrompt.getInstance();
			this.addChild(_alert);
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		/**
		 * Demande confirmation avant de quitter
		 * @param	evt
		 */
		private function _promptBeforeClosing(evt:Event) {
			_trace.debug("_promptBeforeClosing");
			var alert:AlertPopup = _alert.newAlert("Êtes-vous sûr de vouloir quitter ?", "Oui", "Non");
			alert.addEventListener(AlertPrompt.ACCEPT, function(evt:Event) {
				_nativeWindowMgr.close();
			}, false, 0, true);
		}
		/**
		 * 
		 * @param	evt
		 */
		private function _openFileHandler(evt:MouseEvent) {
			var fileToOpen:File = new File();
			try {
				fileToOpen.browseForOpen("Ouvrir une anthologie");
				fileToOpen.addEventListener(Event.SELECT, _fileSelected);
			}
			catch (error:Error)	{
				_trace.error("openFile Failed:" + error.message);
			}
		}
		/**
		 * 
		 * @param	event
		 */
		private function _fileSelected(event:Event):void {
			var file:File = event.target as File;
			// Découpe l'url du fichier pour retrouver la base de l'appli (2 dossiers au dessus).
			// Le fichier XML ouvert DOIT être dans son dossier "normal" (/appdata/fr/fichier.xml)
			var url:String = file.url;
			
			_appdataPath = url.substring(0, url.lastIndexOf("/")) + "/";
			_trace.debug("_appdataPath : " + _appdataPath);
			
			var truncateAt:int;
			for (var i:int = 0; i < 3; i++) {
				truncateAt = url.lastIndexOf("/");
				url = url.substring(0, truncateAt);
			}
			url += "/";
			_baseUrl.setBaseUrl(url);
			//
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.READ);
			var fileDataXML:XML = new XML(stream.readUTFBytes(stream.bytesAvailable));
			var ad:AnthoData = new AnthoData(fileDataXML, "fr");
			_mgr.init(ad);
			this._init();
		}
		/**
		 * 
		 */
		private function _init() {
			if(_isInit) _reset();
			//
			_usEditor = new USEditor();
			_usEditor.x = 5;
			_usEditor.y = _menuContainer.x + _menuContainer.height + 5;
			this.addChild(_usEditor);
			//
			_repBrowser = RepBrowser.getInstance();
			this.addChild(_repBrowser);
			_browse_btn.enabled = true;
			_saveAs_btn.enabled = true;
			//
			_mgr.openRepFirstUS(new RepData(_mgr.findNodeByPath([AnthoManager.COUCHANT])));
			//
			_initLexique();
			//
			_isInit = true;
			//
		}
		/**
		 * 
		 */
		private function _initLexique() {
			_xmlLoader = new XMLLiteLoader();
			_xmlLoader.addEventListener(Event.COMPLETE, _xmlLexiqueLoaded);
			//_xmlLoader.load(_baseUrl.BASE + "appdata/" + _translator.language + "/lexique.xml");
			//_xmlLoader.load(_baseUrl.BASE + "appdata/fr/lexique.xml");
			_xmlLoader.load(_appdataPath + "lexique.xml");
		}
		/**
		 * 
		 * @param	evt
		 */
		private function _xmlLexiqueLoaded(evt:Event) {
			_lexique = Lexique.getInstance();
			_lexique.init(_xmlLoader.xml);
			_lexBox = LexiqueBox.getInstance();
			_lex_btn.enabled = true;
			this.addChild(_lexBox);
			//
			this.addChild(_alert);
		}
		/**
		 * 
		 */
		private function _reset() {
			_browse_btn.enabled = false;
			_save_btn.enabled = false;
			_lex_btn.enabled = false;
			if (_usEditor && this.contains(_usEditor)) {
				_usEditor.reset();
				this.removeChild(_usEditor);
				_usEditor = null;
			}
			if (_repBrowser && this.contains(_repBrowser)) {
				this.removeChild(_repBrowser);
				_repBrowser = null;
			}
			if (_lexBox && this.contains(_lexBox)) {
				this.removeChild(_lexBox);
				_lexBox = null;
			}
		}
		/**
		 * 
		 * @param	evt
		 */
		private function _browseHandler(evt:MouseEvent) {
			_trace.debug("_browseHandler");
			_repBrowser.openCurrent();
		}
		
		private function _saveAsHandler(evt:MouseEvent) {
			_trace.debug("_saveAsHandler");
			_saveAs();
		}
		
		private function _saveHandler(evt:MouseEvent) {
			_trace.debug("_saveHandler");
			_saveData();
		}
		
		private function _lexiqueHandler(evt:MouseEvent) {
			_trace.debug("_lexiqueHandler");
			_lexBox.open();
		}
		
		/**
		 * Choix d'un fichier pour "enregistrer sous"
		 */
		private function _saveAs() {
			_currentDateStr();
			var docsDir:File = File.documentsDirectory;
			try	{
				docsDir.browseForSave("Enregistrer sous...");
				docsDir.addEventListener(Event.SELECT, _saveFileSelected);
				_save_btn.enabled = true;
			}
			catch (error:Error)	{
				_trace.debug("Erreur lors de la sélection du fichier : " + error.message);
			}
		}
		/**
		 * Appelé lorsque le fichier vers lequel enregistrer est sélectionné.
		 * @param	evt
		 */
		private function _saveFileSelected(evt:Event) {
			_saveFile = evt.target as File;
			_saveData();
			_save_btn.enabled = true;
		}
		/**
		 * 
		 * @param	event
		 */
		private function _saveData():void {
			_trace.info("Enregistrement...");
			try {
				var stream:FileStream = new FileStream();
				stream.open(_saveFile, FileMode.WRITE);
				stream.writeUTFBytes(_mgr.raw);
				stream.close();
				_trace.info("L'enregistrement est terminé. " + _currentDateStr());
				filename_tf.text = _saveFile.url + "\nDernier enregistrement : " + _currentDateStr();
			} catch (e:Error) {
				_trace.error("Erreur : l'enregistrement a échoué : " + e.message);
				_save_btn.enabled = false;
			}
		}
		
		/**
		 * 
		 */
		private function _currentDateStr():String {
			var d:Date = new Date();
			var str:String = String(d.fullYear) + String(d.month) + String(d.date) + "-" + d.hours + "h" + d.minutes + "m" + d.seconds + "s";
			//_trace.debug("CurrentDate : " + str);
			return str;
		}
		
	}
	
}