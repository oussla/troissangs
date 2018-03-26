package com.thequest.epist.antho {
	import adobe.utils.CustomActions;
	import com.nlgd.supertrace.SuperTrace;
	import com.thequest.epist.BasicFormat;
	import com.thequest.tools.baseurl.BaseUrl;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.events.Event;
	import caurina.transitions.Tweener;
	
	/**
	 * ...
	 * @author nlgd
	 */
	public class  MediaViewer extends MovieClip	{
		//--------------------------------------------------
		//
		//		Properties
		//
		//--------------------------------------------------
		private var _trace:SuperTrace;
		private var _pos:Point;
		private var _mediaDataArray:Array;
		private var _mediasArray:Array;		
		private var _miniArray:Array;
		private var _containerMedia:Sprite;
		private var _containerMini:Sprite;
		private var _idCurrentMedia:int = 0;
		private var _nbMediaData:int;
		private var _miniShown:Boolean = false;
		private var _posXMini:int;
		private var _posYMini:int;
		private var _nbLineMini:int;
		private var _posYLegend:int;
		private var _contour:Shape;
		private var _baseUrl:BaseUrl;
		private var _basicFormat:BasicFormat;
		
		public var legend_tf:TextField;
		//--------------------------------------------------
		//
		//		Constructor
		//
		//--------------------------------------------------
		public function MediaViewer() {
			_trace = SuperTrace.getTrace();
			_mediaDataArray = new Array();//tableau de mediadata
			_mediasArray = new Array(); //tableau de medias d'un mediaData
			_miniArray = new Array(); //tableau des miniatures
			_containerMedia = new Sprite();
			_containerMini = new Sprite();
			_contour = new Shape();
			_baseUrl = BaseUrl.getInstance();
			_basicFormat = BasicFormat.getInstance();
			legend_tf.styleSheet = _basicFormat.getBasicCSS();
		}
		//--------------------------------------------------
		//
		//		Methods
		//
		//--------------------------------------------------
		public function show() {
			this.visible = true;
			Tweener.removeTweens(this);
			Tweener.addTween(this, { alpha:1, time:0.8, transition:"easeOutQuart" } );
		}
		
		public function hide() {
			Tweener.removeTweens(this);
			Tweener.addTween(this, { alpha:0, time:0.8, transition:"easeOutQuart", onComplete:function() {
				visible = false;
			} } );
		}
		/**
		 * Ouvre une série de médias. Tableau de "MediaData".
		 * @param	p_medias
		 */
		public function openMediaList(p_medias:Array) {
			//_trace.debug("MediaViewer.openMediaList");
			this.reset();
			
			_nbMediaData = p_medias.length; //nombre de médias
			_mediaDataArray = p_medias;//tableau de mediadata
			//_trace.debug("nombre de médias = " + _nbMediaData);
			
			//créé les médiaObject dans _mediasArray
			var media:MediaObject;
			var urlMini:String;
			var miniTmp:MiniObject;
			var N:int = _mediaDataArray.length;
			for (var i = 0; i < N; i++) {
				var mdata:MediaData = _mediaDataArray[i];
				
				// CREATION DES MEDIAOBJECT
				if (mdata.typeMedia == "jpg") {
					media = new ImageObject();
				}
				if (p_medias[i].typeMedia == "flv")
					media = new VideoObject();
				
				if(media) {
					//media.SetContentUrl(_baseUrl.BASE + mdata.url); //n'est pas utilisé?
					media.setContentUrl(mdata.url);
					
					_mediasArray.push(media);
				
					// CHARGEMENT DE LA MINIATURE (SUIVI DE L'AFFICHAGE)
					var nameUrl:String = "";
					if (media is VideoObject) {
						//_trace.debug("url miniature de la video = " + _mediaDataArray[i].mediaName);
						//nameUrl = _baseUrl.BASE + _mediaDataArray[i].mediaName + "-poster.jpg";
						nameUrl = _mediaDataArray[i].mediaName + "-poster.jpg";
					}
					else {
						//nameUrl = _baseUrl.BASE + _mediaDataArray[i].url;
						nameUrl = _mediaDataArray[i].url;

					}
					miniTmp = new MiniObject(i, nameUrl);
					trace("miniature : " + nameUrl);
					miniTmp.addEventListener(MediaEvent.MEDIA_LOADED, displayMini);
					miniTmp.load();
					_miniArray.push(miniTmp);
				}
			}
			// CHARGEMENT DU PREMIER MEDIA SUIVI DE SON AFFICHAGE
			if (_mediasArray[_idCurrentMedia] != undefined) {
				_mediasArray[_idCurrentMedia].addEventListener(MediaEvent.MEDIA_LOADED, displayMedia);
				_mediasArray[_idCurrentMedia].load();
			}
			
			_containerMini.y = 500;
			this.addChild(_containerMini);
			// N'ajoute le _containerMini à la scène que s'il contient plus d'une miniature
			if(N > 1) {
				_containerMini.visible = true;
			} else {
				_containerMini.visible = false;
			}
		}
		
		public function displayMini(evt:MediaEvent) {
			//_trace.debug("MediaViewer.displayMini");
			var mini:MiniObject = evt.target as MiniObject;
			mini.removeEventListener(MediaEvent.MEDIA_LOADED, displayMini);
			
			/*
			mini.x = _posXMini;
			mini.y = _posYMini;
			mini.addEventListener(MouseEvent.CLICK, miniClick);
			mini.buttonMode = true;
			_containerMini.addChild(mini);
			_posXMini = _posXMini + mini.width + MiniObject.MARGE;
			if (_posXMini >= MediaObject.WIDTH_MAX_MEDIA-mini.width) {
				_posXMini = 0;
				_nbLineMini++;
				_posYMini = (MiniObject.HEIGHT_MAX_MINI +MiniObject.MARGE) * _nbLineMini;
			}
			
			//_miniArray.push(mini);
			
			*/
			_posXMini = 0;
			_posYMini = 0;
			_nbLineMini = 0;
			var N:int = _miniArray.length;
			
			for (var i = 0; i < N; i++) {
				_miniArray[i].x = _posXMini;
				_miniArray[i].y = _posYMini;
				_miniArray[i].addEventListener(MouseEvent.CLICK, _miniClick);
				_miniArray[i].addEventListener(MouseEvent.MOUSE_OVER, _miniOver);
				_miniArray[i].addEventListener(MouseEvent.MOUSE_OUT, _miniOut);
				_miniArray[i].buttonMode = true;
				
				_posXMini = _posXMini + _miniArray[i].width + MiniObject.MARGE;
				if (_posXMini >= MediaObject.WIDTH_MAX_MEDIA-mini.width) {
					_posXMini = 0;
					_nbLineMini++;
					_posYMini = (_nbLineMini * MiniObject.HEIGHT_MAX_MINI) + MiniObject.MARGE;
				}
				_miniArray[i].alpha = 0.5;
				_containerMini.addChild(_miniArray[i]);
			}
			
			
			this.traceContour();
		}
		
		public function _miniClick(evt:MouseEvent) {
			//_trace.debug("MediaViewer._miniClick");
			var mini:MiniObject = evt.target.parent as MiniObject;
			if (_idCurrentMedia != mini.id)
				openMedia(mini.id);
		}
		
		public function _miniOver(evt:MouseEvent) {
			//_trace.debug("MediaViewer._miniOver");
			var mini:MiniObject = evt.target.parent as MiniObject;
			//mini.alpha = 1;
			Tweener.addTween(mini, { alpha:1, time:0.3, transition:"easeOutQuart" } );
		}
		
		public function _miniOut(evt:MouseEvent) {
			//_trace.debug("MediaViewer._miniOut");
			var mini:MiniObject = evt.target.parent as MiniObject;
			//mini.alpha = 0.5;
			Tweener.addTween(mini, { alpha:0.5, time:0.3, transition:"easeOutQuart" } );
		}
		
		public function traceContour() {
			//_trace.debug("MediaViewer.traceContour");
			for (var i:int = 0; i<_miniArray.length; i++) {
				if (_idCurrentMedia == _miniArray[i].id) {
				_contour.graphics.lineStyle(1, 0x606060);
				_contour.graphics.drawRect(_miniArray[i].x, _miniArray[i].y, _miniArray[i].width, _miniArray[i].height);
				_containerMini.addChild(_contour);
				}
			}
		}
		
		public function deleteContour() {
			//_trace.debug("MediaViewer.deleteContour");
			_contour.graphics.clear();
			if (_containerMini.contains(_contour))
				_containerMini.removeChild(_contour);
		}
		
		public function openMedia(id:int) {
			//_trace.debug("\n"+"MediaViewer.openMedia, ouvrir id " + id);
			this.deleteContour();
			legend_tf.alpha = 0;
			_mediasArray[_idCurrentMedia].hide();
			_idCurrentMedia = id;
			_mediasArray[_idCurrentMedia].addEventListener(MediaEvent.MEDIA_LOADED, displayMedia);
			_mediasArray[_idCurrentMedia].load();
		}
		
		public function displayMedia(evt:MediaEvent) {
			//_trace.debug("MediaViewer.displayMedia");
			//_trace.debug("Hauteur de l'image = " + evt.target.hauteur);
			_posYLegend = evt.target.hauteur + 10;
			_mediasArray[_idCurrentMedia].removeEventListener(MediaEvent.MEDIA_LOADED, displayMedia);
			_containerMedia.addChild(_mediasArray[_idCurrentMedia]);
			this.addChild(_containerMedia);
			_mediasArray[_idCurrentMedia].show();
			this.traceContour();
			this.displayLegend();	
		}
		
		
		public function displayLegend() {
			//_trace.debug("MediaViewer.displayLegend");
			legend_tf.y = _posYLegend;
			legend_tf.htmlText = _basicFormat.transformItaTags(_mediaDataArray[_idCurrentMedia].legend);
			Tweener.addTween(legend_tf, { alpha:1, time:1, transition:"easeOutQuart" } );
		}


		
		/**
		 * Réinitialise le MediaViewer 
		 * (suppression de tous les médias, légendes, etc)
		 */
		public function reset() {
			//_trace.debug("\nMediaViewer.reset");
			
			//REINITIALISATION DES VARIABLES
			_idCurrentMedia = 0; //identifiant du média courant afffiché
			_posXMini = 0; // abcisse de départ des miniatures
			_posYMini = 0; // ordonnée de départ des miniatures
			_nbLineMini = 0; // numéro de ligne de miniatures
			legend_tf.alpha = 0;
			
			var i:int;
			var N:int;
			
			// VIDE LE TABLEAU DE MEDIAOBJECT
			N = _mediasArray.length;
			for (i = 0; i < N; i++) {
				var media:MediaObject = _mediasArray.shift();
				if (_containerMedia.contains(media))
					_containerMedia.removeChild(media);
				media = null;
			}
			
			//VIDE LE TABLEAU DE MINIOBJECT
			N = _miniArray.length;
			//_trace.debug("longueur du _miniArray à vider = "+ N);
			for (i = 0; i < N; i++) {
				var mini:MiniObject = _miniArray.shift();
				if (_containerMini.contains(mini))
					_containerMini.removeChild(mini);
				mini = null;
			}
			
			//VIDE LA LEGENDE
			legend_tf.text = "";
			
			//ENLEVE LE CONTOUR DE L'IMAGE ACTIVE
			this.deleteContour();
		}
		
		/**
		 * 
		 * @param	p_pos
		 */
		public function setPosition(p_pos:Point) {
			_pos = p_pos;
			this.x = _pos.x;
			this.y = _pos.y;
		}
		
	}
	
}