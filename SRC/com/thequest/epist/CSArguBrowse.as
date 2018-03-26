package com.thequest.epist {
	import caurina.transitions.Tweener;
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.Translator;
	import com.thequest.epist.argu.*;
	import com.thequest.tools.baseurl.BaseUrl;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.system.Capabilities;
	import mdm.*;
	import flash.net.URLRequest;
	import flash.net.*;
	import flash.system.*;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class CSArguBrowse extends ContentScreen {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _mgr:NavManager;
		private var _translator:Translator;
		private var _menuArticles:MenuColumn;
		private var _menuEtapes:MenuColumn;
		private var _menuPropals:MenuColumn;
		private var _propalViewer:PropalViewer;
		private var _menuPropalContainer:Sprite;
		private var _baseUrl:BaseUrl;
		//
		public var lectureRapide_tf:TextField;
		public var flutesBtn:MovieClip;
	
		//--------------------------------------------------
		//
		//		Contstructor
		//
		//--------------------------------------------------
		public function CSArguBrowse() {
			_trace = SuperTrace.getTrace();
			_baseUrl = BaseUrl.getInstance();
			_context = ContentScreen.ARGU;
			_trace.debug("Hello CSArguBrowse !");
			_mgr = NavManager.getMgr();
			_mgr.addEventListener(Event.COMPLETE, _mgrComplete);
			_translator = Translator.getInstance();
			lectureRapide_tf.text = _translator.translate("lecture_rapide");
			_trace.debug("trad : " + _translator.translate("lecture_rapide"));
			//
			_menuArticles = new MenuColumn();
			_menuArticles.setPosition(new Point(330, 165));//190
			_menuArticles.addEventListener(Event.CHANGE, _articleChange);
			_menuArticles.createBtns(_mgr.getArticles(), EBArticle);
			this.addChild(_menuArticles);
			
			flutesBtn.label_tf.text = _translator.translate("flutes");
			flutesBtn.buttonMode = true;
			flutesBtn.mouseChildren = false;
			flutesBtn.useHandCursor = true;
			//flutesBtn.y = _menuArticles.y + _menuArticles.height;
			flutesBtn.addEventListener(MouseEvent.ROLL_OVER, rollOverFlutes);
			flutesBtn.addEventListener(MouseEvent.ROLL_OUT, rollOutFlutes);
			flutesBtn.addEventListener(MouseEvent.CLICK, clickFlutes);
			// Le bouton "flûtes" n'est plus affiché ici.
			flutesBtn.visible = false;
			//
			_menuEtapes = new MenuColumn();
			_menuEtapes.setPosition(new Point(355, 165));
			_menuEtapes.addEventListener(Event.CHANGE, _etapeChange);
			this.addChild(_menuEtapes);
			//
			_menuPropals = new MenuColumn();
			_menuPropals.setPosition(new Point(690, 165));
			_menuPropals.addEventListener(Event.CHANGE, _propalChange);
			this.addChild(_menuPropals);
			//
			_propalViewer = new PropalViewer();
			_propalViewer.addEventListener(Event.CLOSE, _showPropalContainer);
			_propalViewer.addEventListener(Event.OPEN, _onPropalViewerOpen);
			this.addChild(_propalViewer);
			
			_menuPropalContainer = new Sprite();
			
			if (_appNav.subNavId > 0) _menuArticles.change(_appNav.subNavId);
			
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		private function _articleChange(evt:Event) {
			_trace.debug("Article change : " + _menuArticles.activeData.id);
			_mgr.changeArticle(_menuArticles.activeData.id);
		}
		
		private function _mgrComplete(evt:Event) {
			var etapes:Array = _mgr.getEtapes();
			_menuPropalContainer.graphics.clear();
			_menuPropals.reset();
			_menuEtapes.reset();
			_menuEtapes.createBtns(etapes, ElementButton);
			_menuEtapes.replaceEtaps(etapes);
		}
		
		private function _etapeChange(evt:Event) {
			_trace.debug("Etape change : " + _menuEtapes.activeData.id);
			var propals:Array = _mgr.getPropals(_menuEtapes.activeData.id);
			
			_menuPropalContainer.graphics.clear();
			_menuPropals.reset();
			_menuPropals.createBtns(propals, EBPropal, 3);
			_menuPropalContainer.addChild(_menuPropals);
			_menuPropalContainer.graphics.lineStyle(1, 0xFFCC40, 1);

			//vertical gauche
			_menuPropalContainer.graphics.moveTo(_menuPropals.x-9, _menuPropals.y-3);
			_menuPropalContainer.graphics.lineTo(_menuPropals.x - 9, _menuPropals.y + _menuPropals.height);
			
			//vertical droite
			_menuPropalContainer.graphics.lineGradientStyle("linear", [0x655119, 0x857032], [100,100], [50,50]);
			_menuPropalContainer.graphics.moveTo(_menuPropals.x - 9 + _menuPropals.width , _menuPropals.y - 3);
			_menuPropalContainer.graphics.lineTo(_menuPropals.x - 9+_menuPropals.width, _menuPropals.y + _menuPropals.height);

			//horizontal bas
			_menuPropalContainer.graphics.lineGradientStyle("linear", [0xFFCC40, 0x857032], [100,100], [50,50]);
			_menuPropalContainer.graphics.moveTo(_menuPropals.x - 9, _menuPropals.y + _menuPropals.height);
			_menuPropalContainer.graphics.lineTo(_menuPropals.x - 9 + _menuPropals.width, _menuPropals.y + _menuPropals.height);
			
			_menuPropalContainer.visible = true;
			this.addChild(_menuPropalContainer);
		}
		
		private function _propalChange(evt:Event) {
			_trace.debug("Propal change : " + _menuPropals.activeData.id);
			this._hidePropalContainer();
			var propal:EDPropal = _menuPropals.activeData as EDPropal;
			_propalViewer.open(propal);
		}
		
		private function _showPropalContainer(evt:Event=null) {
			_menuPropalContainer.visible = true;
			lectureRapide_tf.visible = true;
		}
		
		private function _hidePropalContainer() {
			_menuPropalContainer.visible = false;
			lectureRapide_tf.visible = false;
		}
		
		
		//bouton des flutes
		public function rollOverFlutes(evt:MouseEvent):void {
			Tweener.removeTweens(flutesBtn.label_tf);
			Tweener.addTween(flutesBtn.label_tf, {_color:0xFFFFFF, time:0.3, transition:"easeOutQuart" } );
		}
		
		public function rollOutFlutes(evt:MouseEvent):void {
			Tweener.removeTweens(flutesBtn.label_tf);
			Tweener.addTween(flutesBtn.label_tf, {_color:0x7D7D7D, time:0.3, transition:"easeOutQuart" } );
		}
		
		public function clickFlutes(evt:MouseEvent):void {
			//recherche de l'OS
			var os:String = Capabilities.os;
			os = os.substr(0, 3).toLowerCase();
			_trace.debug("ClickFlutes. OS:" + os + ", language:" + _translator.language);
			_appNav.setWindowed();
			var langSuffix:String = "";
			if (_translator.language == "en") langSuffix = "_us";
			if (os == "mac") {
				//mdm.System.exec(_baseUrl.BASE + "data:fscommand:flutes4.1e" + langSuffix + ".app");
				//mdm.System.exec(mdm.Application.path + "data\\fscommand\\flutes4.1e" + langSuffix + ".app");
				mdm.System.exec(mdm.Application.path + "flutes4.1e" + langSuffix + ".app");
			} else {
				//mdm.System.exec(_baseUrl.BASE + "data\\fscommand\\flutes4.1e" + langSuffix + ".exe");
				//mdm.System.exec(mdm.Application.path + "data\\fscommand\\flutes4.1e" + langSuffix + ".exe");
				mdm.System.exec(mdm.Application.path + "flutes4.1e" + langSuffix + ".exe");
			}
			
		}
		
		
		
		private function _onPropalViewerOpen(evt:Event):void {
			var ed:EDPropal = _propalViewer.openedEDPropal;
			//trace("CSArguBrowse : capte _onPropalViewerOpen, ed : " + ed.P + " listIndex : " + ed.listIndex);
			
			_menuPropals.change(ed.listIndex + 1, false);
		}
		
		
	}
	
}