
import luxe.Rectangle;
import luxe.tilemaps.tiled.TiledObjectGroup;
import luxe.Vector;
import luxe.Input;
import luxe.Color;

import luxe.tilemaps.TiledMap;
import luxe.tilemaps.Tilemap;

class Main extends luxe.Game {

        //A hand made ortho Tilemap
    var small_tiles : Tilemap;
        //A tiled ortho map from a tmx/json
    var tiled_ortho : TiledMap;
        //A tiled iso map from a tmx
    var tiled_iso : TiledMap;

    public function ready() {
        
        Luxe.renderer.clear_color = new Color().rgb(0xaf663a);

        Luxe.camera.zoom = 0.5;

            //we create a custom tilemap 
        create_small_handmade_tilemap();        

            //now we load a few tiled maps from the Tiled editor 
        load_ortho_tiledmap();
        load_isometric_tiledmap();

    } //ready

    function load_isometric_tiledmap() {
        
        tiled_iso = new TiledMap( { file:'assets/isotiles.tmx' } );
        tiled_iso.display({scale:1});

    }

    function load_ortho_tiledmap() {
        
            //create from xml file, with various encodings, or from JSON
        tiled_ortho = new TiledMap( { file:'assets/tiles.json', format:'json', pos : new Vector(512,0) } );
        // tiled_ortho = new TiledMap( { file:'assets/tiles_base64_zlib.tmx'} );
        // tiled_ortho = new TiledMap( { file:'assets/tiles_base64.tmx'} );
        // tiled_ortho = new TiledMap( { file:'assets/tiles_csv.tmx'} );

            //tell the map to display 
        tiled_ortho.display({ scale:4 });

            //draw the additional objects
        draw_tiled_object_groups();

    }

    function create_small_handmade_tilemap() {

        var small_tiles_grid = [
            [29,29,29,29,29,29,29,29],
            [29,29,29,29,29,29,29,29],
            [29,29,29,29,29,29,29,29],
            [29,29,29,29,29,29,29,29],
            [29,29,29,29,29,29,29,29],
            [29,29,29,29,29,29,29,29],
            [29,29,29,29,29,29,29,29],
            [29,29,29,29,29,29,29,29],
        ];

            //manually create ourselves an ortho tilemap
        small_tiles = new Tilemap({
                //world x/y position
            x           : 0, 
            y           : 10, 
                //tilemap width/height
            w           : 8,  
            h           : 8, 
                //tiles width/height
            tile_width  : 16, 
            tile_height : 16,   
                //orientation of map
            orientation : TilemapOrientation.ortho
        });

            //create a tileset for the map
        small_tiles.add_tileset('tiles', Luxe.loadTexture('assets/tileset.png'));

            //create some layers to add tiles in
            //note we add them out of order with the index, just for testing that
        small_tiles.add_layer('fg', 1);
        small_tiles.add_layer('bg', 0);

            //create some tiles from a grid specified above
        small_tiles.add_tiles_from_grid( 'bg', small_tiles_grid );
            //create them by filling the layer with a fixed id, in this case 38
        small_tiles.add_tiles_fill_by_id( 'fg', 38 );

            //finally, tell it to display
        small_tiles.display({ scale:3 });

    }
  
    public function onkeyup(e) {
        
        if(e.value == Input.Keys.escape) {
            Luxe.shutdown();
        }

        if(e.key == KeyValue.key_1) { Luxe.camera.zoom = 1.0; }
        if(e.key == KeyValue.key_2) { Luxe.camera.zoom = 2.0; }
        if(e.key == KeyValue.key_3) { Luxe.camera.zoom = 0.5; }

        if(e.key == KeyValue.key_A || e.key == KeyValue.left) {
            left_down = false;
        }

        if(e.key == KeyValue.key_D || e.key == KeyValue.right) {
            right_down = false;
        }

    } //onkeyup

    var left_down = false;
    var right_down = false;

    public function onkeydown(e:KeyEvent) {

        if(e.key == KeyValue.key_A || e.key == KeyValue.left) {
            left_down = true;
        }

        if(e.key == KeyValue.key_D || e.key == KeyValue.right) {
            right_down = true;
        }

    } //onkeydown

    public function update(dt:Float) {

        if(left_down) {
            Luxe.camera.pos.x -= 150 / Luxe.camera.zoom * dt;
        } //left_down

        if(right_down) {
            Luxe.camera.pos.x += 150 / Luxe.camera.zoom * dt;
        } //right_down

    } //update

    function draw_tiled_object_groups() {

            //now we can look at the objects layers in the tilemap and draw them
        for(group in tiled_ortho.tiledmap_data.object_groups) {
            
            for(object in group.objects) {
                Luxe.draw.text({ text:object.name, size:14, pos:object.pos.clone().multiplyScalar(4).add(tiled_ortho.pos) });
                switch(object.object_type) {

                    case TiledObjectType.polyline: {

                        var last = new Vector(0,0);
                        for(p in object.polyobject.points) {
                            Luxe.draw.line({
                                p0 : last.clone().add(object.pos).multiplyScalar(4).add(tiled_ortho.pos),
                                p1 : p.clone().add(object.pos).multiplyScalar(4).add(tiled_ortho.pos),
                                depth : 2
                            });
                            last = p.clone();
                        } //each point

                    } //polyline 

                    case TiledObjectType.polygon: {

                        var last = new Vector(0,0);
                        for(p in object.polyobject.points) {
                            Luxe.draw.line({
                                p0 : last.clone().add(object.pos).multiplyScalar(4).add(tiled_ortho.pos),
                                p1 : p.clone().add(object.pos).multiplyScalar(4).add(tiled_ortho.pos),
                                depth : 2
                            });
                            last = p.clone();
                        } //each point

                        Luxe.draw.line({
                            p0 : last.clone().add(object.pos).multiplyScalar(4).add(tiled_ortho.pos),
                            p1 : new Vector().clone().add(object.pos).multiplyScalar(4).add(tiled_ortho.pos),
                            depth : 2
                        });

                    } //polygon

                    case TiledObjectType.ellipse:{

                            //cirle is top left for some reason
                        var _r = (object.width/2)*4;
                        Luxe.draw.ring({
                            x : (object.pos.x*4) + tiled_ortho.pos.x,
                            y : (object.pos.y*4) + tiled_ortho.pos.y, 
                            r : _r, 
                            depth : 2  
                        });

                    } //ellipse

                    case TiledObjectType.rectangle: {


                        Luxe.draw.rectangle({
                            x : (object.pos.x*4) + tiled_ortho.pos.x, y : (object.pos.y*4) + tiled_ortho.pos.y, 
                            w : object.width*4, h:object.height*4, 
                            depth : 2
                        });

                    } //rectangle

                } //switch type
            } //for each object
        }        
    }
}


