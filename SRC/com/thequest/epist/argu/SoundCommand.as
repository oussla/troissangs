package com.thequest.epist.argu {
	import com.thequest.epist.antho.MediaEvent;
	import com.thequest.epist.antho.SoundManager;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class SoundCommand extends MovieClip	{
		private var _sndMgr:SoundManager;
		private var vol_ct:SimpleButton;
		private var volSlider_mc:MovieClip;
		private var _volWidth:Number = 23;
		private var _soundUrl:String;
		//
		public var volumeControl_mc:MovieClip;
		public var play_btn:SimpleButton;
		public var pause_btn:SimpleButton;
		public var playedTime_tf:TextField;
		
		
		public function SoundCommand(p_soundUrl:String) {
			_soundUrl = p_soundUrl;
			
			_sndMgr = SoundManager.getInstance();
			_sndMgr.addEventListener(MediaEvent.SOUND_PLAYED, _soundPlayed);
			_sndMgr.addEventListener(MediaEvent.SOUND_STOPPED, _soundStopped);
			_sndMgr.addEventListener(Event.SOUND_COMPLETE, _soundStopped);
			
			vol_ct = volumeControl_mc.vol_ct;
			volSlider_mc = volumeControl_mc.volSlider_mc;
			vol_ct.addEventListener(MouseEvent.CLICK, volumeClick);
			vol_ct.addEventListener(MouseEvent.MOUSE_DOWN, volumeStartDrag);
			vol_ct.addEventListener(MouseEvent.MOUSE_UP, volumeStopDrag);
			vol_ct.addEventListener(MouseEvent.MOUSE_OUT, volumeStopDrag);
			
			pause_btn.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent) { 
				_sndMgr.stopSound();
			} );
			play_btn.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent) { 
				_sndMgr.playSound();
				//_sndMgr.loadIndeSound(_soundUrl, true);
			} );
			
			// Etat initial : en pause.
			this._soundStopped();
		}
		
		/**
		 * 
		 * @param	event
		 */
		private function _soundPlayed(evt:Event = null) {
			pause_btn.visible = true;
			play_btn.visible = false;
		}
		/**
		 * 
		 * @param	event
		 */
		private function _soundStopped(evt:Event = null) {
			pause_btn.visible = false;
			play_btn.visible = true;
		}
		
		//--------------------------------------------------
		//
		//		Volume management
		//
		//--------------------------------------------------
		private function volumeClick(evt:MouseEvent) {
			var dX:Number = Math.round((vol_ct.mouseX / _volWidth)*100)/100;
			setVolume(dX);
		}
		
		private function volumeStartDrag(evt:MouseEvent) {
			this.addEventListener(MouseEvent.MOUSE_MOVE, volumeDrag);
		}
		
		private function volumeDrag(evt:MouseEvent) {
			var dX:Number = Math.round((vol_ct.mouseX / _volWidth)*100)/100;
			setVolume(dX);
		}
		
		private function volumeStopDrag(evt:MouseEvent) {
			this.removeEventListener(MouseEvent.MOUSE_MOVE, volumeDrag);
		}
		
		public function setVolume(p_vol:Number) {
			var vol:Number = p_vol;
			if(vol < 0.05) vol = 0;
			if (vol > 1) vol = 1;
			_sndMgr.setVolume(vol);
			volSlider_mc.x = 3 + (1 - vol) * -35;
		}
		
		
		
		/**
		 * 
		 * @param	tt
		 * @return
		 */
		private function _timeToString(tt:Number):String {
			// Conversion des secondes en minutes:secondes du temps joué
			tt = Math.floor(tt);
			
			var mm:Number = Math.floor( tt / 60 );
			var time:String = "";
			if ( mm < 10 ){
				time = "0" + mm;
			} else {
				time = time + mm;
			}
			
			var ss:Number = tt % 60;
			
			if ( ss < 10 ){
				time = time+":0" + ss;
			} else {
				time = time+":" + ss;
			}
			//_trace.debug("calcul du temps joué = "+time);
			return time;
		}
		
	}
	
}