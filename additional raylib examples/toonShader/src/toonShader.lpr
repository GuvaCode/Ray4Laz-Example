program toonShader;

{$mode objfpc}{$H+}

uses 
cmem, raylib, raymath, rlights;

const
  screenWidth = 800;
  screenHeight = 600;

var
  model,edMod,tank: TModel;
  xza  : array[0..6] of TVector3;
  camera: TCamera;
  normShader, outline, shader: TShader;
  light: Tlight;
  ca: single;
  target:TRenderTexture2D;
  ShowToon:boolean;

// set the models shader for each material
procedure  setModelShader(m: PModel; s: PShader);
  var i: Integer;
begin
  for  i:=0 to m^.materialCount -1 do m^.materials[i].shader := S^;
end;

// each snowman has a position on the ground plane with
// z component used for Y axis rotation.
procedure drawScene;
  var i: Integer;
begin
  DrawModel(edMod, Vector3Create( -1, 0, 1 ), 0.5, WHITE);
  DrawModel(tank,  Vector3Create( 2, 0, -1 ), 2, WHITE);
   for i:=0 to 6 do //(int i=0; i<7; i++)
   begin
        model.transform := MatrixRotateY(xza[i].z);
        DrawModel(model, Vector3Create(xza[i].x,0,xza[i].y), 0.5, WHITE);
    end;
end;

begin
  // Initialization
  InitWindow(screenWidth, screenHeight, 'raylib - simple project');
  SetTargetFPS(60);// Set our game to run at 60 frames-per-second

  showToon:=False;

  Vector3Set(@xza[0],0,0,0);
  Vector3Set(@xza[1],-4,-2,-0.5);
  Vector3Set(@xza[2],-3,3,-1);
  Vector3Set(@xza[3],-2,-3,0.5);
  Vector3Set(@xza[4],2,-4,2);
  Vector3Set(@xza[5],2,2,1);
  Vector3Set(@xza[6],4.5,0.5,0.2);

  // Define the camera to look into our 3d world
  camera.position := Vector3Create( 0.0, 4.0, 8.0 );
  camera.target := Vector3Create( 0.0, 1.0, 0.0 );
  camera.up := Vector3Create( 0.0, 1.0, 0.0 );
  camera.fovy := 45.0;

  model := LoadModel('data/snowman.obj');
  edMod := LoadModel('data/ed.obj');
  edMod.transform := MatrixRotateY(-135*DEG2RAD);
  tank := LoadModel('data/tank.gltf');

  // normal shader
  normShader := LoadShader('data/norm.vs', 'data/norm.fs');
  normShader.locs[SHADER_LOC_MATRIX_MODEL] := GetShaderLocation(normShader, 'matModel');

  // outline shader
  outline := LoadShader(nil, 'data/outline.fs');

  // lighting shader
  shader := LoadShader('data/toon.vs', 'data/toon.fs');
  shader.locs[SHADER_LOC_MATRIX_MODEL] := GetShaderLocation(shader, 'matModel');

  // make a light (max 4 but we're only using 1)
  light := CreateLight(LIGHT_POINT, Vector3Create( 2,4,4 ), Vector3Zero(), WHITE, shader);

  // camera orbit angle
  ca := 0;

  target := LoadRenderTexture(screenWidth, screenHeight);

  // Main game loop
  while not WindowShouldClose() do
    begin
      // Update
      // manually orbiting the camera but slower than the
      // raylib camera does.
      ca += 0.025;
      camera.position.x := cos(-ca/11)*8.0;
      camera.position.z := sin(-ca/11)*8.0;

      UpdateCamera(@camera,CAMERA_ORBITAL);

      if IsKeyPressed(KEY_SPACE) then
      if ShowToon then ShowToon:=false else ShowToon:=true;

      // you can move the light around if you want
      light.position.x := 12.0 * cos(ca);
      light.position.z := 12.0 * sin(ca);

      // update the light shader with the camera view position
      SetShaderValue(shader, shader.locs[SHADER_LOC_VECTOR_VIEW], @camera.position.x, SHADER_UNIFORM_VEC3);
      SetShaderValue(normShader, shader.locs[SHADER_LOC_VECTOR_VIEW], @camera.position.x, SHADER_UNIFORM_VEC3);
      UpdateLightValues(shader, light);
      UpdateLightValues(normShader, light);

      // Draw
      BeginDrawing();
        // render first to the normals texture for outlining
            // to a texture
            BeginTextureMode(target);
                ClearBackground(ColorCreate(255,255,255,255));
                BeginMode3D(camera);
                    setModelShader(@model, @normShader);
                    setModelShader(@edMod, @normShader);
                    setModelShader(@tank, @normShader);
                    drawScene();
                EndMode3D();
            EndTextureMode();

            // draw the scene but with banded light effect
            ClearBackground(ColorCreate(32,64,255,255));
            BeginMode3D(camera);
                setModelShader(@model, @shader);
                setModelShader(@edMod, @shader);
                setModelShader(@tank, @shader);
                drawScene();
                DrawGrid(10, 1.0);        // Draw a grid
            EndMode3D();

            // show the modified normals texture
            DrawTexturePro(target.texture,
                    RectangleCreate( 0, 0, target.texture.width, -target.texture.height ),
                    RectangleCreate( 0, 0, target.texture.width/4.0, target.texture.height/4.0 ),
                    Vector2Create(0,0), 0, WHITE);

            // outline shader uses the normal texture to overlay outlines
            if showToon then
            begin
              BeginShaderMode(outline);

              DrawTexturePro(target.texture,
                        RectangleCreate( 0, 0, target.texture.width, -target.texture.height ),
                        RectangleCreate( 0, 0, target.texture.width, target.texture.height ),
                        Vector2Create(0,0), 0, WHITE);

              EndShaderMode();
            end;
            DrawText('Press space to On/Off toon shader',250,10,20,RED);
            DrawFPS(10, 10);
      EndDrawing();
    end;

  // De-Initialization
  UnloadShader(shader);
  UnloadShader(outline);
  UnloadShader(normShader);
  UnloadModel(model);
  UnloadModel(edMod);
  UnloadRenderTexture(target);

  CloseWindow();        // Close window and OpenGL context
end.

