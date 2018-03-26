package com.thequest.epist.antho {
	import caurina.transitions.Tweener;
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.AscenseurCommand;
	import com.thequest.epist.CustomTextButton;
	import com.thequest.epist.NavEvent;
	import com.thequest.epist.Translator;
	import com.thequest.epist.Window;
	import com.thequest.epist.Windows;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.SharedObjectFlushStatus;
	import flash.text.TextField;
	import com.thequest.tools.ascenseur.Ascenseur;
	import com.thequest.tools.ascenseur.AscenseurEvent;
	import flash.geom.Rectangle;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	/**
	 * ...
	 * @author nlgd
	 */
	public class RepBrowser extends Window {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		//
		private static var _instance:RepBrowser;
		//
		private var _trace:SuperTrace;
		private var _mgr:AnthoManager;
		private var _rootNode:XML; 
		private var _arboContainer:MovieClip;
		private var _arbos:Array;
		//
		private var _sunsetAsc:Ascenseur;
		private var _sunriseAsc:Ascenseur;
		private var _sunsetAscCmd:AscenseurCommand;
		private var _sunriseAscCmd:AscenseurCommand;
		private var _sunAscs:Array;
		
		private var _commandAscenseur:AscenseurCommand;
		private var _maskArea:Rectangle;
		private var _usList:USList;
		private var _ascUsList:Ascenseur;
		private var _maskUsList:Rectangle;
		private var _cmdAscUsList:AscenseurCommand;
		
		private var _repDetails:RepDetails;
		private var _repDetails_btn:CustomTextButton;
		private var _usList_btn:CustomTextButton;
		private var _btnBarre:Shape;
		
		private var _activeRepBtn:RepButton;
		
		//		
		public var corpusHeader:WindowCorpusHeader;
		public var ombrageAscBas:MovieClip;
		public var us_ct:SimpleButton;
		public var desc_ct:SimpleButton;
		//--------------------------------------------------
		//
		//		Singleton
		//
		//--------------------------------------------------
		public static function getInstance():RepBrowser {
			if (_instance == null) {
				_instance = new RepBrowser(new SingletonBlocker());
			}
			return _instance;
		}
		//
		public function RepBrowser(p_key:SingletonBlocker) {
			if (p_key == null) {
				throw new Error("Error : Instantiation failed : Use RepBrowser.getInstance() instead of new.");
			} else {
				_trace = SuperTrace.getTrace();
				_trace.debug("Hello RepBrowser !");
				this._init();

			}
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		private function _init() {
			_trace.debug("RepBrowser._init");
			_mgr = AnthoManager.getInstance();
			// Ecoute les changements de langue
			_mgr.addEventListener(Event.CHANGE, _mgrChangeLanguage);
			
			this._positionType = 1;
			this._windowHeight = 563;
			
			_arboContainer = new MovieClip();
			
			corpusHeader.addEventListener(Event.CHANGE, _corpusHeaderChange);
			corpusHeader.activateMouseInteractions();
			
			//
			//	Gestion des listes d'US			
			_usList = new USList();
			_usList.x = 340;
			_usList.y = 75;
			this.addChild(_usList);
			_usList.addEventListener(NavEvent.OPEN_US, _openUs);
			//construction de l'ascenseur pour la liste d'US
			_maskUsList = new Rectangle(_usList.x, _usList.y, 525, 440);			
			_ascUsList = new Ascenseur(_usList, _maskUsList);
			this.addChild(_ascUsList);
			//construction de la commande de l'ascenseur de la liste d'US
			_cmdAscUsList = new AscenseurCommand(_ascUsList);
			_cmdAscUsList.x = _maskUsList.x + _maskUsList.width - 25;
			_cmdAscUsList.y = _maskUsList.y + _maskUsList.height + 15;
			this.addChild(_cmdAscUsList);
			//
			//	Gestion des descriptions de répertoires
			_repDetails = new RepDetails();
			_repDetails.x = 340;
			_repDetails.y = 40;
			this.addChild(_repDetails);
			//			
			_versionInit();
		}
		/**
		 * Initialise tout ce qui est suceptible de changer avec la langue
		 */
		private function _versionInit() {
			_arbos = new Array();
			_arbos[AnthoManager.LEVANT] = new RepArbo(AnthoManager.LEVANT);
			_arbos[AnthoManager.COUCHANT] = new RepArbo(AnthoManager.COUCHANT);
			_arbos[AnthoManager.LEVANT].addEventListener(NavEvent.OPEN_US, _openRepFirstUS);
			_arbos[AnthoManager.COUCHANT].addEventListener(NavEvent.OPEN_US, _openRepFirstUS);
			_arboContainer.x = 1;
			_arboContainer.y = 75;
			_arboContainer.addChild(_arbos[AnthoManager.LEVANT]);
			_arboContainer.addChild(_arbos[AnthoManager.COUCHANT]);
			this.addChild(_arboContainer);
			
			// Un ascenseur pour chaque arborescence. Les ascenseurs et masques sont créés dans _arboContainer
			_maskArea = new Rectangle(0, 0, 339, 440);	
			_sunsetAsc = new Ascenseur(_arbos[AnthoManager.COUCHANT], _maskArea);
			_sunriseAsc = new Ascenseur(_arbos[AnthoManager.LEVANT], _maskArea);
			_arboContainer.addChild(_sunsetAsc);
			_arboContainer.addChild(_sunriseAsc);
			// Ecoute l'event OPEN sur tous les boutons de toutes les arbos
			_arboContainer.addEventListener(Event.OPEN, _repButtonOpening);
			
			_sunsetAscCmd = new AscenseurCommand(_sunsetAsc);
			_sunriseAscCmd = new AscenseurCommand(_sunriseAsc);
			_sunsetAscCmd.x = _maskArea.x + _maskArea.width - 25;
			_sunsetAscCmd.y = _arboContainer.y + _maskArea.y + _maskArea.height + 15;
			_sunriseAscCmd.x = _maskArea.x + _maskArea.width - 25;
			_sunriseAscCmd.y = _arboContainer.y + _maskArea.y + _maskArea.height + 15;
			this.addChild(_sunsetAscCmd);
			this.addChild(_sunriseAscCmd);
			_sunAscs = new Array();
			_sunAscs[AnthoManager.COUCHANT] = _sunsetAsc;
			_sunAscs[AnthoManager.LEVANT] = _sunriseAsc;
			
			title_tf.text = _translator.translate("répertoires").toUpperCase();
			
			_btnBarre = new Shape();
			_btnBarre.graphics.lineStyle(1, 0x545454);
			_btnBarre.graphics.moveTo(0, 0);
			_btnBarre.graphics.lineTo(0, 9);
			_btnBarre.y = 5;
			
			_repDetails_btn = new CustomTextButton(_translator.translate("description").toUpperCase(), TextFieldAutoSize.LEFT, 0x7D7D7D, 0xFFFFFF, 0xFFFFFF);
			_usList_btn = new CustomTextButton(_translator.translate("unite_son").toUpperCase(), TextFieldAutoSize.LEFT, 0x7D7D7D, 0xFFFFFF, 0xFFFFFF);
			_repDetails_btn.y = 525;
			_usList_btn.y = _repDetails_btn.y;
			_repDetails_btn.x = 365;
			_usList_btn.x = _repDetails_btn.x + _repDetails_btn.width + 10;
			_btnBarre.y = _repDetails_btn.y;
			_btnBarre.x = _repDetails_btn.x + 5;
			
			_repDetails_btn.addEventListener(MouseEvent.CLICK, _changeForRepDetails);
			_usList_btn.addEventListener(MouseEvent.CLICK, _changeForUsList);
			
			this.addChild(_repDetails_btn);
			this.addChild(_usList_btn);
			this.addChild(_btnBarre);
			
		}
		/**
		 * 
		 */
		public function openLevant() {
			_trace.debug("RepBrowser.openLevant");
			corpusHeader.setCorpus(AnthoManager.LEVANT);
			_arbos[AnthoManager.COUCHANT].hide();
			_arbos[AnthoManager.LEVANT].show();
			_sunsetAscCmd.visible = false;
			_sunriseAscCmd.visible = true;
			this._open();
			
		}
		/**
		 * 
		 */
		public function openCouchant() {
			_trace.debug("RepBrowser.openCouchant");
			corpusHeader.setCorpus(AnthoManager.COUCHANT);
			_arbos[AnthoManager.COUCHANT].show();
			_arbos[AnthoManager.LEVANT].hide();
			_sunsetAscCmd.visible = true;
			_sunriseAscCmd.visible = false;
			this._open();
		}
		/**
		 * 
		 * @param	p_id
		 */
		public function openByCorpusId(p_id:int) {
			_trace.debug("RepBrowser.openByCorpusId");
			switch(p_id) {
				case AnthoManager.COUCHANT:
					openCouchant();
					break;
				case AnthoManager.LEVANT:
					openLevant();
					break;
			}
		}
		/**
		 * Ouvre le monde en cours
		 */
		public function openCurrent() {
			_trace.debug("RepBrowser.openCurrent");
			var currentCorpus:int = _mgr.currentCorpus;
			currentCorpus == AnthoManager.COUCHANT ? this.openCouchant() : this.openLevant();
		}
		/**
		 * 
		 */
		private function _open() {
			_trace.debug("RepBrowser._open");
			_usList.cleanList();
			//_repDetails.clear();
			if (!_isOpen) {
				_isOpen = true;
				// Passe par "Windows" pour ouvrir la fenêtre
				var windows:Windows = Windows.getInstance();
				windows.openWindow(this);
				
			}
			
		}
		
		/**
		 * Intercepte l'event OPEN déclenché par un RepButton
		 * @param	evt
		 */
		private function _repButtonOpening(evt:Event) {
			trace("RepBrowser._repButtonOpening");
			var repBtn:RepButton = evt.target as RepButton;
			var rd:RepData = repBtn.repData;
			
			if (_activeRepBtn) {
				_activeRepBtn.setNormal();
			}
			_activeRepBtn = repBtn;
			repBtn.setActive();
			
			/* 
			 * ##### si le bouton est développé, demande le placement visible de la position Y calculée
			 */ 
			if (repBtn.isDevelopped) {
				var posY:Number = repBtn.y + repBtn.actualHeight;
				//_sunAscs[rd.corpus].setYVisible(posY);
			}
						
			// Dans tous les cas, demande l'affichage d'une description en rapport avec ce RepData
			_openRepDetails(rd);
			// Si le RD contient une liste d'US, demande l'ouverture de la liste
			if (rd.hasUS) {
				_openUsList(rd);
				// ####
				_repDetails.hide();
			} else {
				_cleanUsList();
			}
		}
		/**
		 * Affiche la description du répertoire rd, ou du premier répertoire parent en ayant une.
		 * @param	evt
		 */
		private function _openRepDetails(rd:RepData) {
			_trace.debug("RepBrowser._openRepDetails");
			
			// update the repDetails in every case, no matter what we found in the datas.
			_repDetails.update(rd);
			_changeForRepDetails();
			
			/*
			var nothing:Boolean = false;
			// Si ce répertoire n'a pas de description, trouve le premier rép parent qui en a une.
			var displayRd:RepData;
			if (!rd.desc) {
				_trace.debug("---> rd n'a pas de description.");
				//displayRd = _mgr.getParentWithDesc(rd); //désactivé à la demande de Dana #jenny 101012
				displayRd = rd;//ajout suite à desactivation ligne précédente
				nothing = true; //ajouté suite ) la ligne précédente #jenny
			} else {
				//_trace.debug("---> rd a bien une description");
				displayRd = rd;
			}
			
			if (displayRd) {
				_repDetails.update(displayRd);
				_changeForRepDetails();
				if (nothing)
					_repDetails.clear();
			} else {
				// Aucune description de répertoire n'a été trouvée.
				trace("Aucune description de répertoire n'a été trouvée");
				_repDetails.clear();
			}
			*/
		}
		
		/**
		 * Intercepte le clic sur un bouton "play", et demande l'ouverture de la première unité de son du répertoire cliqué
		 * @param	evt
		 */
		private function _openRepFirstUS(evt:NavEvent) {
			//_trace.debug("RepBrowser entend event OPEN_US");
			var btn:RepButton = evt.target as RepButton;
			_mgr.openRepFirstUS(btn.repData);
			this.close();
		}
		/**
		 * 
		 * @param	evt
		 */
		private function _openUs(evt:NavEvent) {
			//_trace.debug("evt.target.usdata = " + evt.target.usdata);
			_mgr.openUS(evt.target.usdata);
			this.close();
		}
		
		/**
		 * Ouvre la liste d'US du répertoire rd
		 * @param	rd
		 */
		private function _openUsList(rd:RepData) {
			//_trace.debug("RepBrowser._openUsList entend event OPEN_USLIST");
			_cleanUsList();
			_usList.update(rd);
			_changeForUsList();
		}	
		/**
		 * 
		 */
		private function _cleanUsList() {
			//_trace.debug("RepBrower entend CLEAN_USLIST");
			_usList.cleanList();
			_ascUsList.resetPosition();
			//_descUsSwitch.desactiveUs();
		}
		/**
		 * 
		 * @param	evt
		 */
		private function _descUsChangeHandler(evt:Event) {
			/*
			if (_descUsSwitch.selected == DescUsSwitch.DESC) {
				_repDetails.show();
				_usList.hide();
			} else {
				_repDetails.hide();
				_usList.show();
			}
			*/
		}
		
		private function _changeForRepDetails(evt:MouseEvent = null) {
			_repDetails.show();
			_usList.hide();
			_cmdAscUsList.visible = false;
			_repDetails_btn.setActive();
			_usList_btn.setNormal();
		}
		
		private function _changeForUsList(evt:MouseEvent = null) {
			_repDetails.hide();
			_usList.show();
			_repDetails_btn.setNormal();
			_usList_btn.setActive();
			this.addChild(_cmdAscUsList);
			_cmdAscUsList.checkHeights();
		}
		/**
		 * Nettoyage
		 */
		private function _clear() {
			trace("RepBrowser._clear");
			_arboContainer.removeChild(_sunsetAsc);
			_arboContainer.removeChild(_sunriseAsc);
			_arboContainer.removeChild(_arbos[AnthoManager.LEVANT]);
			_arboContainer.removeChild(_arbos[AnthoManager.COUCHANT]);
			//this.removeChild(_arboContainer);
			this.removeChild(_sunsetAscCmd);
			this.removeChild(_sunriseAscCmd);
			//this.removeChild(_usList);
			//this.removeChild(_ascUsList);
			//this.removeChild(_cmdAscUsList);
			//this.removeChild(_descUsSwitch);
			//_descUsSwitch.removeEventListener(Event.CHANGE, _descUsChangeHandler);
			_repDetails.clear();
			//this.removeChild(_repDetails);
			//corpusHeader.removeEventListener(Event.CHANGE, _corpusHeaderChange);
			_repDetails_btn.removeEventListener(MouseEvent.CLICK, _changeForRepDetails);
			_usList_btn.removeEventListener(MouseEvent.CLICK, _changeForUsList);
			this.removeChild(_repDetails_btn);
			this.removeChild(_usList_btn);
			this.removeChild(_btnBarre);
			
			this.close();
		}
		/**
		 * 
		 * @param	evt
		 */
		private function _corpusHeaderChange(evt:Event) { 
			//_trace.debug("RepBrowser entend CHANGE sur CorpusHeader");
			openByCorpusId(corpusHeader.selectedCorpus);
		} 
		/**
		 * 
		 * @param	evt
		 */
		private function _mgrChangeLanguage(evt:Event) {
			this._clear();
			this._versionInit();
		}
	}
	
}

internal class SingletonBlocker {}