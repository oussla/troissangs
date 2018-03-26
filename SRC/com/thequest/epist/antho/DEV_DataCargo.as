package com.thequest.epist.antho {
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class DEV_DataCargo {
		private var _vnb:int = 0;
		private var _len:Number = 0;
		
		public function DEV_DataCargo() {
			
		}
		
		public function set vnb(p_vnb:int) {
			_vnb = p_vnb;
		}
		
		public function get vnb():int {
			return _vnb;
		}
		
		public function set len(p_len:Number) {
			_len = p_len;
		}
		
		public function get len():Number {
			return _len;
		}
		
	}
	
}