// I took this from a example source and slapped it together.
// It kind of works... I am going to need to study this more though.
program FPS_50x50CubeGround;
{$mode objfpc}{$H+}

uses cmem,
raylib;

const
 screenWidth = 800;
 screenHeight = 450;

var
  checked:TImage;
  texture:TTexture2D;
  model:TModel;
  camera:TCamera;
  x,z:integer;

begin
 // Initialization
 InitWindow(screenWidth, screenHeight, 'raylib pascal - FPS_50x50CubeGround');
 // We generate a checked image for texturing

 checked := GenImageChecked(2, 2, 1, 1, RED, GREEN);
 texture := LoadTextureFromImage(checked);
 UnloadImage(checked);
 // Create model from mesh cube
 model := LoadModelFromMesh(GenMeshCube(1.0, 1.0, 1.0));

 // Set checked texture as default diffuse component for all models material
 model.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture := texture;


 // Define the camera to look into our 3d world
 Camera3DSet(@camera,Vector3Create(5.0,5.0,5.0),
                      Vector3Create(0.0,0.0,0.0),
                      Vector3Create(0.0,1.0,0.0),
                      45.0,0);


 SetTargetFPS(60);    // Set our game to run at 60 frames-per-second

 // Main game loop
 while not WindowShouldClose() do  // Detect window close button or ESC key
 begin
   // Update
   UpdateCamera(@camera, CAMERA_FIRST_PERSON);      // Update internal camera and our camera

   // Draw
  BeginDrawing();
  ClearBackground(RAYWHITE);

  BeginMode3D(camera);

  for x:=0 to 50 do
  for z:=0 to 50 do
  DrawModel(model, Vector3Create(x,0,z), 1.0, WHITE);

   EndMode3D();

   DrawFPS(0,0);
   EndDrawing();
 end;
     // De-Initialization
   UnloadTexture(texture); // Unload texture
    // Unload models data (GPU VRAM)
    UnloadModel(model);
    // Close window and OpenGL context
    CloseWindow();
end.

