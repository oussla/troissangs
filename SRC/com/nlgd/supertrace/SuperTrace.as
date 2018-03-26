/**
*
*
*	SuperTrace
*	
*	@author	NLGD - Nicolas Lagarde - www.oucelavatil.net
*	@version	0.1
*
*/

package com.nlgd.supertrace {
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.EventDispatcher;
	
	public class SuperTrace extends EventDispatcher {
		
		public static const FATAL:uint = 0;
		public static const ERROR:uint = 1;
		public static const AVERT:uint = 2;
		public static const INFO:uint = 3;
		public static const DEBUG:uint = 4;
		
		public var lastMessage:TraceMessage;
		public var currentLevel:uint = DEBUG;
		
		private static var _trace:SuperTrace = null;
		
		public function SuperTrace() {
			
		}
		
		public static function getTrace():SuperTrace {
			if(_trace == null) {
				_trace = new SuperTrace();
			}
			return _trace;
		}
		
		public function fatal(p_msg:String):void {
			processMessage(p_msg, FATAL);
		}
		
		public function error(p_msg:String):void {
			processMessage(p_msg, ERROR);
		}

		public function avert(p_msg:String):void {
			processMessage(p_msg, AVERT);
		}
		
		public function info(p_msg:String):void {
			processMessage(p_msg, INFO);
		}
		
		public function debug(p_msg:String):void {
			processMessage(p_msg, DEBUG);
		}
		
		private function processMessage(p_msg:String, p_lvl:uint):void {
			lastMessage = new TraceMessage(p_msg, p_lvl);
			if(p_lvl <= currentLevel) {
				trace(p_msg);
				dispatchEvent(new SuperTraceEvent(SuperTraceEvent.MESSAGE));
			}
		}
		
		public function getMessage():String {
			return lastMessage.msg;
		}
		
		public function getMessageLevel():uint {
			return lastMessage.lvl;
		}
		
		public function setLevel(p_lvl:uint):void {
			if(p_lvl <= 5) {
				currentLevel = p_lvl;
			}
		}
		
	}
	
}