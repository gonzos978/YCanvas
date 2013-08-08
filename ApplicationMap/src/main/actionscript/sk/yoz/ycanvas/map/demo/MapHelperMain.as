package sk.yoz.ycanvas.map.demo
{
    import flash.ui.Mouse;
    import flash.ui.Multitouch;
    
    import feathers.controls.Label;
    import feathers.core.PopUpManager;
    
    import sk.yoz.utils.GeoUtils;
    import sk.yoz.ycanvas.map.YCanvasMap;
    import sk.yoz.ycanvas.map.demo.mock.Maps;
    import sk.yoz.ycanvas.map.display.MapLayer;
    import sk.yoz.ycanvas.map.display.MarkerLayer;
    import sk.yoz.ycanvas.map.display.StrokeLayer;
    import sk.yoz.ycanvas.map.events.CanvasEvent;
    import sk.yoz.ycanvas.map.managers.AbstractTransformationManager;
    import sk.yoz.ycanvas.map.managers.MouseTransformationManager;
    import sk.yoz.ycanvas.map.managers.TouchTransformationManager;
    import sk.yoz.ycanvas.map.valueObjects.Limit;
    import sk.yoz.ycanvas.map.valueObjects.Transformation;
    
    import starling.core.Starling;
    import starling.display.Image;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;

    /**
    * Provides functionality for the main map.
    */
    public class MapHelperMain
    {
        public var map:YCanvasMap;
        public var polygonLayer:MapLayer;
        public var strokeLayer:StrokeLayer;
        public var markerLayer:MarkerLayer;
        public var transformationManager:AbstractTransformationManager;
        
        public function MapHelperMain()
        {
            var transformation:Transformation = new Transformation;
            transformation.centerX = GeoUtils.lon2x(7.75);
            transformation.centerY = GeoUtils.lat2y(45.53);
            transformation.rotation = 0;
            transformation.scale = 1 / 4096;
            
            var limit:Limit = new Limit;
            limit.minScale = 1;
            limit.maxScale = 1 / 65536;
            limit.minCenterX = 0;
            limit.maxCenterX = GeoUtils.lon2x(180);
            limit.minCenterY = GeoUtils.lat2y(85);
            limit.maxCenterY = GeoUtils.lat2y(-85);
            
            map = new YCanvasMap(Maps.ARCGIS_IMAGERY, transformation, 256);
            map.addEventListener(CanvasEvent.TRANSFORMATION_FINISHED, onMapTransformationFinished);
            transformationManager = Mouse.supportsCursor && !Starling.multitouchEnabled
                ? new MouseTransformationManager(map, limit)
                : new TouchTransformationManager(map, limit);
            
            polygonLayer = new MapLayer;
            polygonLayer.addEventListener(TouchEvent.TOUCH, onPolygonLayerTouch);
            map.addMapLayer(polygonLayer);
            
            strokeLayer = new StrokeLayer;
            strokeLayer.autoUpdateThickness = false;
            strokeLayer.addEventListener(TouchEvent.TOUCH, onStrokeLayerTouch);
            map.addMapLayer(strokeLayer);
            
            markerLayer = new MarkerLayer;
            markerLayer.addEventListener(TouchEvent.TOUCH, onMarkerLayerTouch);
            map.addMapLayer(markerLayer);
        }
        
        public function addMarkerAt(x:Number, y:Number):void
        {
            var marker:Image = new Image(Assets.MARKER_GREEN_TEXTURE);
            marker.x = x;
            marker.y = y;
            marker.pivotX = Assets.MARKER_GREEN_TEXTURE.width / 2;
            marker.pivotY = Assets.MARKER_GREEN_TEXTURE.height;
            markerLayer.add(marker);
        }
        
        private function showLabelPopup(message:String):void
        {
            var label:Label = new Label;
            label.text = message;
            PopUpManager.addPopUp(label);
            
            label.addEventListener(TouchEvent.TOUCH, function(event:TouchEvent):void
            {
                if(PopUpManager.isPopUp(label) && event.getTouch(label, TouchPhase.BEGAN))
                    PopUpManager.removePopUp(label);
            });
        }
        
        private function onMapTransformationFinished(event:CanvasEvent):void
        {
            if(!strokeLayer.autoUpdateThickness)
                strokeLayer.updateThickness();
        }
        
        private function onPolygonLayerTouch(event:TouchEvent):void
        {
            if(event.getTouch(map.display, TouchPhase.BEGAN))
                showLabelPopup("Polygon selected. Click here to close popup.");
        }
        
        private function onStrokeLayerTouch(event:TouchEvent):void
        {
            if(event.getTouch(map.display, TouchPhase.BEGAN))
                showLabelPopup("Stroke selected. Click here to close popup.");
        }
        
        private function onMarkerLayerTouch(event:TouchEvent):void
        {
            if(event.getTouch(map.display, TouchPhase.BEGAN))
                showLabelPopup("Marker selected. Click here to close popup");
        }
    }
}