/**
*
*
*	SuperTraceEvent
*	
*	@author	NLGD
*	@version	0.1
*
*/

package com.nlgd.supertrace {
	
	import flash.events.Event;
	
	public class SuperTraceEvent extends Event {
		
		//--------------------------------------------------
		//
		//		Static
		//
		//--------------------------------------------------
		
		public static const FATAL:String = "FATAL";
		public static const ERROR:String = "ERROR";
		public static const AVERT:String = "AVERT";
		public static const INFO:String = "INFO";
		public static const DEBUG:String = "DEBUG";
		
		public static const MESSAGE:String = "message";
		
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		
		public function SuperTraceEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false){
			super (type,bubbles,cancelable);
		}
		
	}
	
}