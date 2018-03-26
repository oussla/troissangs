/**
*
*
*	TraceMessage
*	
*	@author	NLGD
*	@version	0.1
*
*/

package com.nlgd.supertrace {
	
	public class TraceMessage {
		
		public var msg:String;
		public var lvl:uint;
		
		public function TraceMessage(p_msg:String, p_lvl:uint) {
			msg = p_msg;
			lvl = p_lvl;			
		}
		
	}
	
}