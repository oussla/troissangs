package com.thequest.epist.editor {
	import com.thequest.epist.antho.*;
	import com.thequest.epist.BasicFormat;
	import com.thequest.epist.NavEvent;
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.antho.AnthoManager;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class USEditor extends MovieClip {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _mgr:AnthoManager;
		private var _usCommand:USCommand;
		private var _strophe:TEStrophe;
		private var _comment:TEComment;
		private var _mediaViewer:MediaViewer;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function USEditor() {
			_trace = SuperTrace.getTrace();
			_mgr = AnthoManager.getInstance();
			_mgr.addEventListener(NavEvent.OPEN_US, _openUS);
			
			_strophe = new TEStrophe();
			_strophe.x = 0;
			_strophe.y = 0;
			this.addChild(_strophe);
			_strophe.addEventListener(Event.COMPLETE, _stropheUpdate);
			
			_comment = new TEComment();
			_comment.x = 841;
			_comment.y = 0;
			this.addChild(_comment);
			_comment.addEventListener(Event.COMPLETE, _commentUpdate);
			
			_mediaViewer = new MediaViewer();
			_mediaViewer.setPosition(new Point(_strophe.x + _strophe.width + 5, 0));
			this.addChild(_mediaViewer);
			
			_usCommand = new USCommand();
			_usCommand.x = 400;
			_usCommand.y = 570;
			this.addChild(_usCommand);
			_usCommand.init();
			
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		private function _openUS(evt:NavEvent) {
			_trace.debug("USEditor._openUS");
			var ud:USData = _mgr.currentUD;
			_strophe.setText(ud.getRawStrophe());
			_comment.setText(ud.getRawComment());
			_mediaViewer.openMediaList(ud.getMediaList());
		}
		
		private function _stropheUpdate(evt:Event) {
			_trace.debug("USEditor._stropheUpdate");
			var ud:USData = _mgr.currentUD;
			ud.saveStrophe(_strophe.text);
		}
		
		private function _commentUpdate(evt:Event) {
			_trace.debug("USEditor._commentUpdate");
			var ud:USData = _mgr.currentUD;
			ud.saveComment(_comment.text);
		}
		
		public function reset() {
			_mgr.removeEventListener(NavEvent.OPEN_US, _openUS);
			_strophe.removeEventListener(Event.COMPLETE, _stropheUpdate);
			_comment.removeEventListener(Event.COMPLETE, _commentUpdate);
		}
		
	}
	
}