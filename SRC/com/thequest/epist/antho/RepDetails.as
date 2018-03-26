package com.thequest.epist.antho {
	import caurina.transitions.Tweener;
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.AscenseurCommand;
	import com.thequest.epist.BasicFormat;
	import com.thequest.epist.Translator;
	import com.thequest.tools.ascenseur.Ascenseur;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class RepDetails extends MovieClip {
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _rd:RepData;
		private var _imgContainer:Sprite;
		private var _imgMask:Sprite;
		private var _imgFilename:String;
		private var _imgLoader:Loader;
		private var _image_bm:Bitmap;
		private var _translator:Translator;
		private var _isOpen:Boolean;
		private var _basicFormat:BasicFormat;
		private var _css:StyleSheet;
		private var _mask:Rectangle;
		private var _asc:Ascenseur;
		private var _ascCmd:AscenseurCommand;
		//
		public var name_tf:TextField;
		public var infos_tf:TextField;
		public var desc_tf:TextField;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function RepDetails() {
			_trace = SuperTrace.getTrace();
			_translator = Translator.getInstance();
			this._isOpen = false;
			this.visible = false;
			this.alpha = 0;
			_imgContainer = new Sprite();
			_imgContainer.x = 24;
			_imgContainer.y = 35;
			_imgMask = new Sprite();
			_imgMask.graphics.beginFill(0x00FF00);
			_imgMask.graphics.drawRect(0, 0, 250, 250);
			_imgMask.graphics.endFill();
			_imgMask.x = _imgContainer.x;
			_imgMask.y = _imgContainer.y;
			this.addChild(_imgContainer);
			this.addChild(_imgMask);
			_imgContainer.mask = _imgMask;
			//
			infos_tf.autoSize = TextFieldAutoSize.LEFT;
			name_tf.autoSize = TextFieldAutoSize.LEFT;
			desc_tf.autoSize = TextFieldAutoSize.LEFT;
			//
			_basicFormat = BasicFormat.getInstance();
			_css = _basicFormat.getBasicCSS();
			
			infos_tf.styleSheet = _css;
			desc_tf.styleSheet = _css;
			
			
			//création de l'ascenseur
			_mask = new Rectangle(desc_tf.x, desc_tf.y, desc_tf.width, 170);
			_asc = new Ascenseur(desc_tf, _mask);
			this.addChild(_asc);
			_ascCmd = new AscenseurCommand(_asc);
			_ascCmd.x = 500;
			_ascCmd.y = 490;
			this.addChild(_ascCmd);
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		public function update(rd:RepData) {
			_trace.debug("RepDetails.update");
			
			if(!_rd || rd.raw != _rd.raw) {
				_rd = rd;
				//_trace.debug("--- Nouveau RD");
				this.clear();
				
				name_tf.height = 1;
				name_tf.styleSheet = _css;
				name_tf.htmlText = rd.vernaculaire;
				
				infos_tf.text = "";
				infos_tf.height = 1;
				infos_tf.styleSheet = _css;
				infos_tf.htmlText = this._mefInfos(rd.rawTitle, rd.repLength, rd.totalVerses, rd.date, rd.place, rd.cast);
				//infos_tf.y = 285 - infos_tf.height
				
				infos_tf.y = name_tf.y + name_tf.height;
				
				desc_tf.htmlText = rd.desc;
				_asc.resetPosition();
				_ascCmd.checkHeights();
				
				if (rd.imageUrl != null) {
					infos_tf.x = 280;
					name_tf.x = 280;
					this._loadImage(rd.imageUrl);
				} else {
					infos_tf.x = 22;
					name_tf.x = 22;
				}
				
			}
			
			this.show();
			
		}
		/**
		 * 
		 */
		public function show() {
			if (!_isOpen) {
				_isOpen = true;
				this.alpha = 0;
				this.visible = true;
				Tweener.addTween(this, { alpha:1, time:1, transition:"easeOutQuart" } );
			}
		}
		/**
		 * 
		 */
		public function hide() {
			this.visible = false;
			this.alpha = 0;
			_isOpen = false;
		}
		/**
		 * 
		 * @param	name
		 * @param	length
		 * @param	totalVerses
		 * @param	date
		 * @param	place
		 * @param	cast
		 */
		private function _mefInfos(name:String, length:Number, totalVerses:int, date:String, place:String, cast:String):String {
			var str:String = "";
			
			if (name) {
				str += '<span class="title">' + _basicFormat.transformItaTags(name) + "</span>\n";
			}
			if (length > 0) {
				var lenStr:String;// = String(length);
				var secondes:Number = Math.floor(length % 60);
				var minutes:Number = Math.floor((length / 60) % 60);
				var heures:Number = Math.floor(length / (60 * 60));
				
				lenStr = heures + "h " + minutes + "m " + secondes + " s.";
				
				str += _translator.translate("Durée") + " : " + lenStr + "\n";
			}
			if (totalVerses > 0) {
				str += _translator.translate("Taille") + " : " + String(totalVerses) + " " + _translator.translate("vers") + "\n";
			}
			if (date) {
				str += _translator.translate("Date") + " : " + date + "\n";
			}
			if (place) {
				str += _translator.translate("Lieu") + " : " + place + "\n";
			}
			if (cast) {
				str += cast + "\n";
			}
			return str;
		}
		/**
		 * 
		 * @param	filename
		 */
		private function _loadImage(filename:String) {
			_imgFilename = filename;
			var imgURL = new URLRequest(filename);
			_imgLoader = new Loader();
			_imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, _imgLoaded);
			_imgLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, _imgLoadError);
			_imgLoader.load(imgURL);
		}
		/**
		 * 
		 * @param	evt
		 */
		private function _imgLoaded(evt:Event) {
			_image_bm = Bitmap(_imgLoader.content);
			_image_bm.smoothing = true;
			_image_bm.x = 0;
			_image_bm.y = 0;
			_image_bm = _resizeBitmap(_image_bm, 250, 250);
			_imgContainer.addChild(_image_bm);
			//infos_tf.y = _imgContainer.y + _image_bm.height - infos_tf.height;
			//name_tf.y = _imgContainer.y + _image_bm.height - infos_tf.height- name_tf.height;
		}
		/**
		 * 
		 * @param	evt
		 */
		private function _imgLoadError(evt:IOErrorEvent) {
			_trace.error("Erreur chargement image " + _imgFilename);
		}
		/**
		 * 
		 */
		public function clear() {
			if (_image_bm) {
				if(_imgContainer.contains(_image_bm))
					_imgContainer.removeChild(_image_bm);
				_image_bm.bitmapData.dispose();
			}
			infos_tf.text = "";
			desc_tf.text = "";
		}
		/**
		 * 
		 * @param	bm
		 * @param	maxWidth
		 * @param	maxHeight
		 * @return
		 */
		private function _resizeBitmap(bm:Bitmap, maxWidth:Number, maxHeight:Number):Bitmap {
			var ratio:Number = bm.width / bm.height;
			if (ratio > 1) {
				bm.width = maxWidth;
				bm.scaleY = bm.scaleX;	
			} else {
				bm.height = maxHeight;
				bm.scaleX = bm.scaleY;
			}
			
			return bm;
		}
		
				
	}
	
}