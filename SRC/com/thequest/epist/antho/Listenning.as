package com.thequest.epist.antho {
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.Window;
	import flash.display.MovieClip;
	import caurina.transitions.Tweener;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import com.thequest.epist.antho.AnthoManager;
	import com.thequest.epist.antho.USData;
	import flash.text.TextField;
	import com.thequest.epist.NavEvent;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.Event;
	
	public class Listenning extends Window {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private static var _instance:Listenning;
		
		private var _trace:SuperTrace;
		private var _mgr:AnthoManager;
		private var _containerPath:Sprite;
		private var _mcArray:Array;
		private var _sndMgr:SoundManager;
		private var _pourcentage:Number;
		
		public var usName:MovieClip;
		public var bg:MovieClip;
		public var soundPlaying:MovieClip;
		public var info_tf:TextField;
		public var corpusHeader:WindowCorpusHeader;
		//--------------------------------------------------
		//
		//		Singleton
		//
		//--------------------------------------------------
		public static function getInstance():Listenning {
			if (_instance == null) {
				_instance = new Listenning(new SingletonBlocker());
			}
			return _instance;
		}
		//
		public function Listenning(p_key:SingletonBlocker) {
			if (p_key == null) {
				throw new Error("Error : Instantiation failed : Use Listenning.getInstance() instead of new.");
			} else {
				_trace = SuperTrace.getTrace();
				_trace.info("Hello Listenning !");
				this.init();
			}
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		/**
		 * 
		 */
		private function init() {
			this._positionType = 2;
			this._windowHeight = 180;
			
			this.x = 0;
			this.y = -_windowHeight;
			
			_translator.addEventListener(Event.CHANGE, _changeLanguage);
			title_tf.text = _translator.translate("en_ecoute").toUpperCase();
			_mgr = AnthoManager.getInstance();
			_containerPath = new Sprite();
			_containerPath.x = 28;
			_containerPath.y = 60;
			_mcArray = new Array();
			usName.alpha = 0;
			bg.height = 139;
			
			_mgr.addEventListener(NavEvent.OPEN_US, _update);
			_sndMgr = SoundManager.getInstance();
			_sndMgr.addEventListener(MediaEvent.MOVED_SEEK, _updatePositions);
			_sndMgr.addEventListener(MediaEvent.SOUND_PLAYING, _updatePositions);
			
			soundPlaying.visible = false;
			soundPlaying.toolbar.seekbar.ct.visible = false;
			usName.visible = false;
		}
		/**
		 * 
		 * @param	evt
		 */
		override public function open(evt:MouseEvent = null) {
			super.open();
			corpusHeader.setCorpus(_mgr.currentCorpus);
			//
			// Ne déclenche la suite que si le AnthoManager a une unité de son en cours de lecture.
			if(_mgr.currentUD) {
				this.displayLocation();
			} else {
				info_tf.visible = true;
				info_tf.text = _translator.translate("no_current_play");
			}
		}
		/**
		 * 
		 * @param	evt
		 */
		override public function close(evt:MouseEvent = null) {
			super.close();
			//
			this._clean();
		}
		/**
		 * 
		 */
		private function displayLocation() {
			_trace.debug("Listenning.displayLocation");
			corpusHeader.setCorpus(_mgr.currentCorpus);
			info_tf.visible = false;
			var pathArray:Array = new Array();
			var margeX, margeY, nbRepSup:int;
			var repPath:RepPath;
			//pathArray = _mgr.getPathSup(_mgr.currentUD.raw);	
			pathArray = _mgr.getCurrentPathSup();	
			nbRepSup = pathArray.length;
			margeY = -5;
			margeX = 5;
			var i:int;
			for (i = 0; i < nbRepSup; i++) {
				var rd:RepData = pathArray[i] as RepData;
				repPath = new RepPath(rd);
				repPath.x = margeX * i;
				trace("repPath" + i +"+x = " + repPath.x);
				repPath.y = (repPath.height + margeY)*i;
				_containerPath.alpha = 0;
				_containerPath.addChild(repPath);
				repPath.init();
				_mcArray.push(repPath);
				//_trace.debug("repPath.y = "+repPath.y);
			}
			
			//_trace.debug("containerPath.y = " + _containerPath.y);
			this.addChild(_containerPath);
			usName.title_tf.autoSize = TextFieldAutoSize.LEFT;
			//usName.title_tf.htmlText = _mgr.currentUD.getBegin();
			var verse:String = _mgr.currentUD.getBegin();
			if (verse.length > 50) {
				verse = verse.substr(0, 50) + "...";
			}
			usName.title_tf.htmlText = verse;
			
			usName.title_tf.width = usName.title_tf.textWidth;
			usName.x = i * margeX + margeX+usName.title_tf.x;
			trace("usName.x = " + usName.x);
			usName.y = _containerPath.y + _containerPath.height + margeY;
			_containerPath.alpha = 1;
			usName.line.x = usName.title_tf.x + usName.title_tf.width;
			usName.line.width = 650 - usName.line.x;
			usName.degrade.x = usName.line.x+usName.line.width;
			usName.alpha = 1;
			soundPlaying.y = usName.y + 10;
			//
			usName.visible = true;
			soundPlaying.visible = true;
		}
		/**
		 * 
		 */
		private function _clean() {
			_trace.debug("Listenning.clean");
			usName.alpha = 0;
			var nb:int = _mcArray.length;
			for (var i:int = 0; i < nb; i++) {
				if (_containerPath.contains(_mcArray[i]))
					_containerPath.removeChild(_mcArray[i]);
			}
			_containerPath.alpha = 0;
			if (this.contains(_containerPath))
				this.removeChild(_containerPath);
		}
		/**
		 * 
		 * @param	evt
		 */
		private function _update(evt:NavEvent) {
			if (_isOpen) {
				this._clean();
				this.displayLocation();
			}
		}
		/**
		 * 
		 * @param	evt
		 */
		private function _updatePositions(evt:Event = null) {
			//_trace.debug("Listenning._updatePositions");
			// TOOLBAR
			var position:Number;
			if (_sndMgr.isPlaying)
				_pourcentage = ((_sndMgr.soundPosition * 100) / _sndMgr.soundLength);
			else
				_pourcentage = ((_sndMgr.pausePosition * 100) / _sndMgr.soundLength);
			position = ((_pourcentage / 100) * (soundPlaying.toolbar.width));
			soundPlaying.toolbar.seekbar.fullness.width = position;
			//TEMPS LU
			soundPlaying.playedTime_tf.text = _sndMgr.getPlayedTime();
			soundPlaying.totalTime_tf.text = _sndMgr.getTotalTime();
		}
		/**
		 * 
		 * @param	evt
		 */
		private function _changeLanguage(evt:Event) {
			title_tf.text = _translator.translate("en_ecoute");
		}
	}
	
}
internal class SingletonBlocker {}