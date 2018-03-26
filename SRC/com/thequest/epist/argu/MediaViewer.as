package com.thequest.epist.argu {
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.EDIllust;
	//import com.thequest.tools.baseurl.BaseUrl;
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class MediaViewer extends MovieClip {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _ed:EDIllust;
		private var _serie1:MediaSerie;
		private var _serie2:MediaSerie;
		
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function MediaViewer() {
			_trace = SuperTrace.getTrace();
			_trace.debug("Hello MediaViewer !");
			_serie1 = new MediaSerie();
			_serie2 = new MediaSerie();
			this.addChild(_serie1);
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		public function openIllust(p_ed:EDIllust) {
			_ed = p_ed;
			_trace.debug("MediaViewer.openIllust, type : " + _ed.typeSerie);
			switch(_ed.typeSerie) {
				case EDIllust.UNIQUE:
					_serie1.setAvailableHeight(450);
					_serie1.openSerie(new Array(_ed.getUniqueImage()));
					_serie2.reset();
					break;	
				case EDIllust.SERIE_SIMPLE:
					_serie1.setAvailableHeight(450);
					_serie1.openSerie(_ed.getSimpleMediaSerie());
					_serie2.reset();
					break;
				case EDIllust.SERIE_DOUBLE:
					_serie1.setAvailableHeight(225);
					_serie2.setAvailableHeight(225);
					_serie2.y = _serie1.y+225;
					_serie1.openSerie(_ed.getTopMediaSerie());
					_serie2.openSerie(_ed.getBottomMediaSerie());
					this.addChild(_serie1);
					this.addChild(_serie2);
					break;
				default:
					_serie1.reset();
					_serie2.reset();
					_trace.error("MediaViewer : rencontré type d'illustration inconnu (" + _ed.typeSerie + ")");
					break;
			}
		}
		
		public function close() {
			_serie1.reset();
			_serie2.reset();
		}
		
	}
	
}