package com.thequest.epist.argu {
	import com.thequest.epist.EDMedia;
	import com.thequest.tools.baseurl.BaseUrl;
	import flash.display.MovieClip;
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.antho.SoundManager;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class MediaElement extends MovieClip	{
		
		protected var _ed:EDMedia;
		protected var _zoneWidth:Number = 610;
		protected var _zoneHeight:Number = 402;
		protected var _sndMgr:SoundManager;
		protected var _sndPlayer:MicroSoundPlayer;
		private var _trace:SuperTrace;
		private var _baseUrl:BaseUrl;
		
		
		public function MediaElement(p_ed:EDMedia) {
			_trace = SuperTrace.getTrace();
			_baseUrl = BaseUrl.getInstance();
			_ed = p_ed;
		}
		
		public function init() {
			_trace.debug("MediaElement.init");
			_sndMgr = SoundManager.getInstance();
			if (_ed.soundUrl) {
				trace("url élément = " + (_ed.soundUrl));
				_sndPlayer = new MicroSoundPlayer(_ed.soundUrl);
				this.addChild(_sndPlayer);
				//_sndMgr.loadIndeSound(_ed.soundUrl, false);
			}
		}
		
		public function clear() {
			if (_ed.soundUrl) {
				_sndPlayer.stopSound();
			}
		}
		
		public function set zoneHeight(h:Number):void {
			_zoneHeight = h;
		}
	}
	
}