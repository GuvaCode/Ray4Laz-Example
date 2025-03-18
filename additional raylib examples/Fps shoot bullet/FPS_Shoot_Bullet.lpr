program FPS_Shoot_Bullet;

{$mode objfpc}{$H+}

uses cmem,
{uncomment if necessary}
//ray_math, 
//ray_rlgl, 
raylib;

const
 screenWidth = 800;
 screenHeight = 450;
var
 checked      :TImage;
 texture      :TTexture2D;
 model,
 bullet       :TModel;
 camera       :TCamera;
 position,
 bulletpos,
 bulletinc    :TVector3;
 x,z          :integer;
 x1,y1,z1,
 y2,x2,z2,
 delta_x,
 delta_y,
 delta_z,len  :Single;


begin
 // Initialization
 InitWindow(screenWidth, screenHeight, 'raylib pascal - basic window');

 // We generate a checked image for texturing
 checked := GenImageChecked(2, 2, 1, 1, BLACK, DARKGRAY);
 texture := LoadTextureFromImage(checked);
 UnloadImage(checked);

 model := LoadModelFromMesh(GenMeshCube(1.0, 1.0, 1.0));

 // Set checked texture as default diffuse component for all models material
 model.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture := texture;

 // Define the camera to look into our 3d world
 Camera3DSet(@camera,Vector3Create(5.0,5.0,5.0),
                      Vector3Create(0.0,0.0,0.0),
                      Vector3Create(0.0,1.0,0.0),
                      45.0,0);

 bulletpos   := camera.position;
 bulletinc.x := 0.05;
 bulletinc.y := 0.00;
 bulletinc.z := 0.0;

 bullet := LoadModelFromMesh(GenMeshCube(1.0, 1.0, 1.0));

 // Set checked texture as default diffuse component for all models material
 bullet.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture := texture;

 SetTargetFPS(60);// Set our game to run at 60 frames-per-second

 // Main game loop
 while not WindowShouldClose() do
 begin
 // Update
 UpdateCamera(@camera, CAMERA_FIRST_PERSON);      // Update internal camera and our camera

 // Shoot the bullet.
        if IsKeyDown(KEY_SPACE) then
        begin
            bulletpos := camera.position;
            // Get the direction of where to shoot the bullet at.
             x1 := camera.position.x;
             y1 := camera.position.y;
             z1 := camera.position.z;
             x2 := camera.target.x;
             y2 := camera.target.y;
             z2 := camera.target.z;
             delta_x := x2 - x1;
             delta_y := y2 - y1;
             delta_z := z2 - z1;

            len := sqrt(delta_x*delta_x+delta_y*delta_y+delta_z*delta_z);
            delta_x := delta_x / len;
            delta_y := delta_y / len;
            delta_z := delta_z / len;
            bulletinc.x := delta_x;
            bulletinc.y := delta_y;
            bulletinc.z := delta_z;
        end;

        // update the bullet.
        bulletpos.x += bulletinc.x;
        bulletpos.y += bulletinc.y;
        bulletpos.z += bulletinc.z;

   // Draw
  BeginDrawing();

  ClearBackground(RAYWHITE);

  BeginMode3D(camera);

  // Draw a floor.
  for x:=0 to 50 do
  begin
   for z:=0 to 50 do
     begin
      Vector3Set(@Position,x,0,z);
      DrawModel(model, position, 1.0, WHITE);
     end;
  end;

  // Draw our bullet.
  DrawModel(bullet, bulletpos, 1.0, WHITE);
  EndMode3D();
  DrawText('Press space and aim to shoot bullet.',100,100,30,YELLOW);
  DrawFPS(0,0);

  EndDrawing(); 
 end;
     // De-Initialization
   UnloadTexture(texture); // Unload texture

    // Unload models data (GPU VRAM)
    UnloadModel(model);
    UnloadModel(bullet);

 // Close window and OpenGL context
 CloseWindow();

end.





