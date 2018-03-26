package com.thequest.epist.antho {

	
	import flash.events.Event;
	
	public class MediaEvent extends Event {
		public static const MEDIA_LOADED:String = "mediaLoaded";
		public static const SOUND_PLAYED:String = "soundPlayed";
		public static const SOUND_STOPPED:String = "soundStopped";
		public static const SOUND_LOADED:String = "soundLoaded";
		public static const MOVED_SEEK:String = "movedSeek";
		public static const SOUND_PLAYING:String = "soundPlaying";

		public function MediaEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false ) {
			super(type, bubbles, cancelable);
		}
	}
}