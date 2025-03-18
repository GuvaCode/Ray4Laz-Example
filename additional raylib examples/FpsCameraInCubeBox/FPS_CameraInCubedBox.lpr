program FPS_CameraInCubedBox;

{$mode objfpc}{$H+}

uses cmem,
raylib;

const
 screenWidth  = 800;
 screenHeight = 450;
 mapwidth     = 30;
 mapheight    = 10;
 mapdepth     = 30;

var
 checked,checked2  :TImage;
 texture,texture2  :TTexture2D;
 model,model2      :TModel;
 camera            :TCamera;
 oldCamPos         :TVector3;
 position          :TVector3;
 moveSpeed         :integer;
 z,x,y,i           :integer;

begin

 InitWindow(screenWidth, screenHeight, 'raylib example');

 // We generate a checked image for texturing
 checked := GenImageChecked(2, 2, 1, 1, ColorCreate(10,10,10,255), ColorCreate(50,50,50,255));
 texture := LoadTextureFromImage(checked);
 UnloadImage(checked);

 checked2 := GenImageChecked(2, 2, 1, 1, ColorCreate(40,10,10,255), ColorCreate(90,50,50,255));
 texture2 := LoadTextureFromImage(checked2);
 UnloadImage(checked2);

 model  := LoadModelFromMesh(GenMeshCube(1.0, 1.0, 1.0));
 model2 := LoadModelFromMesh(GenMeshCube(1.0, 1.0, 1.0));

 // Set checked texture as default diffuse component for all models material
 model.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture  := texture;
 model2.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture := texture2;

 // Define the camera to look into our 3d world
 Camera3DSet(@Camera,Vector3Create(5.0,5.0,5.0),
                      Vector3Create(0.0,0.0,0.0),
                      Vector3Create(0.0,1.0,0.0),
                      45.0,0);


 SetTargetFPS(60); // Set our game to run at 60 frames-per-second

 // Main game loop
 while not WindowShouldClose() do // Detect window close button or ESC key
 begin
 // Update
 //----------------------------------------------------------------------------------
 // Here we store the old camera position and then check if the camera hits the edge
 // and if that happens we restore it to the old position. We check x and z different
 // so we get sliding in stead of complete stop when hitting an edge.
 //
 oldCamPos:= camera.position;    // Store old camera position

 // Default walking speed
 moveSpeed:=1;
 // Sprint speed
 if IsKeyDown(KEY_LEFT_SHIFT) then moveSpeed:=6;
 // We check collision and movement x amount of times.
    for i:=0 to moveSpeed do
    begin
      UpdateCamera(@camera,CAMERA_FIRST_PERSON);      // Update internal camera and our camera
      if (camera.position.x<1) or (camera.position.x>mapwidth-2)
      then camera.position.x := oldCamPos.x;
      if (camera.position.z<1) or (camera.position.z>mapdepth-2)
      then camera.position.z := oldCamPos.z;
    end;
  // Draw
  BeginDrawing();
  ClearBackground(RAYWHITE);
  BeginMode3D(camera);
  //Our player box!!
  //We create our box by creating a tripple for loop and drawing cubes there
  // on the edges.
  for x:=0 to mapwidth do
  begin
   for y:=0 to mapheight do
    begin
     for z:=0 to mapdepth do
      begin
       if (x=0) or (y=0) or (x=mapwidth-1) or (y=mapheight-1) or (z=0) or (z=mapdepth-1)
       then
        begin
         Vector3Set(@position,x,y,z);
         if (y=0) or (y=9 ) then
          DrawModel(model, position, 1.0, WHITE)
          else
          DrawModel(model2, position, 1.0, WHITE);
        end;
      end;
    end;
  end;

   EndMode3D();
   DrawFPS(0,0);

  EndDrawing(); 
 end;
  // De-Initialization
    UnloadTexture(texture); // Unload texture
    UnloadTexture(texture2); // Unload texture
    // Unload models data (GPU VRAM)
    UnloadModel(model);
    UnloadModel(model2);
 //// Close window and OpenGL context
 CloseWindow();

end.

