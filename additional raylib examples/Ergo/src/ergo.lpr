program ergo;

{$mode objfpc}{$H+}

uses 
cmem, raymath,
raylib, actor, MathUtils, math, SpaceShip,GameCamera, SpaceDust;

const
  screenWidth = 800;
  screenHeight = 600;

var player, other: TShip;
    cameraFlight: TGameCamera;
    crosshairNear, crosshairFar: TCrosshair;
    deltaTime: single;
    Dust: TSpaceDust;
    texture: TTexture2D;
    stationModel:TModel;


 procedure ApplyInputToShip(ship: TShip);
 var triggerRight,triggerLeft:single;
 begin
   ship.InputForward := 0;
   if (IsKeyDown(KEY_W)) then ship.InputForward += 1;
   if (IsKeyDown(KEY_S)) then ship.InputForward -= 1;

   ship.InputForward -= GetGamepadAxisMovement(0, GAMEPAD_AXIS_LEFT_Y);
   ship.InputForward := Clamp(ship.InputForward, -1, 1);

   ship.InputLeft := 0;
   if (IsKeyDown(KEY_D)) then ship.InputLeft -= 1;
   if (IsKeyDown(KEY_A)) then ship.InputLeft += 1;

   ship.InputLeft -= GetGamepadAxisMovement(0, GAMEPAD_AXIS_LEFT_X);
   ship.InputLeft := Clamp(ship.InputLeft, -1, 1);

   ship.InputUp := 0;
   if (IsKeyDown(KEY_SPACE)) then ship.InputUp += 1;
   if (IsKeyDown(KEY_LEFT_CONTROL)) then ship.InputUp -= 1;

   triggerRight := GetGamepadAxisMovement(0, GAMEPAD_AXIS_RIGHT_TRIGGER);
   triggerRight := Remap(triggerRight, -1, 1, 0, 1);

   triggerLeft := GetGamepadAxisMovement(0, GAMEPAD_AXIS_LEFT_TRIGGER);
   triggerLeft := Remap(triggerLeft, -1, 1, 0, 1);

   ship.InputUp += triggerRight;
   ship.InputUp -= triggerLeft;
   ship.InputUp := Clamp(ship.InputUp, -1, 1);

   ship.InputYawLeft := 0;
   if (IsKeyDown(KEY_RIGHT)) then ship.InputYawLeft -= 1;
   if (IsKeyDown(KEY_LEFT)) then ship.InputYawLeft += 1;

   ship.InputYawLeft -= GetGamepadAxisMovement(0, GAMEPAD_AXIS_RIGHT_X);
   ship.InputYawLeft := Clamp(ship.InputYawLeft, -1, 1);

   ship.InputPitchDown := 0;
   if (IsKeyDown(KEY_UP)) then ship.InputPitchDown += 1;
   if (IsKeyDown(KEY_DOWN)) then ship.InputPitchDown -= 1;

   ship.InputPitchDown += GetGamepadAxisMovement(0, GAMEPAD_AXIS_RIGHT_Y);
   ship.InputPitchDown := Clamp(ship.InputPitchDown, -1, 1);

   ship.InputRollRight := 0;
   if (IsKeyDown(KEY_Q)) then ship.InputRollRight -= 1;
   if (IsKeyDown(KEY_E)) then ship.InputRollRight += 1;
 end;

begin
  // Initialization
  InitWindow(screenWidth, screenHeight, 'raylib - simple project');
  SetTargetFPS(60);// Set our game to run at 60 frames-per-second

  Player:=TShip.Create('data/ship.gltf', 'data/a16.png', RAYWHITE);
  Other:=TShip.Create('data/ship.gltf', 'data/a16.png', RAYWHITE);
  other.TrailColor := RED;
  other.Position := Vector3Create( 10, 2, 10 );

  dust := TSpaceDust.Create(25, 255);

  cameraFlight := TGameCamera.Create(true, 50);

  crosshairNear := TCrosshair.Create('data/crosshair2.gltf');
  crosshairFar := TCrosshair.Create('data/crosshair2.gltf');

  // Main game loop
  while not WindowShouldClose() do
    begin
      // Update
      deltaTime := GetFrameTime();
      // // Capture input
      ApplyInputToShip(player);
      ApplyInputToShip(other);

      // Gameplay updates
      player.Update(deltaTime);
      other.Update(deltaTime);

      // Test station.
      texture := LoadTexture('data/a16.png');
      texture.mipmaps := 0;
      SetTextureFilter(texture, TEXTURE_FILTER_POINT);
      stationModel := LoadModel('data/station.gltf');
      stationModel.materials[0].maps[MATERIAL_MAP_ALBEDO].texture := texture;
      stationModel.transform := MatrixTranslate(0, 5, 50);

      crosshairNear.PositionCrosshairOnShip(player, 10);
      crosshairFar.PositionCrosshairOnShip(player, 30);

      cameraFlight.FollowShip(player, deltaTime);
      dust.UpdateViewPosition(cameraFlight.GetPosition());

      // Draw
      BeginDrawing();
        ClearBackground(ColorCreate(32, 32, 64, 255));
       // ClearBackground(black);
        cameraFlight.Begin3DDrawing();
          // Opaques
          DrawGrid(10, 10);

	  player.Draw(TRUE);
	  other.Draw(false);
          DrawModel(stationModel, Vector3Zero(), 1, WHITE);

          // Transparencies
          player.DrawTrail();
	  other.DrawTrail();

	  crosshairNear.DrawCrosshair();
	  crosshairFar.DrawCrosshair();

	dust.Draw(cameraFlight.GetPosition(), player.Velocity, false);
        cameraFlight.EndDrawing();

        DrawFPS(10,10);
      EndDrawing();
    end;

  // De-Initialization
  unloadModel(stationModel);
  UnloadTexture(texture);
  CloseWindow();// Close window and OpenGL context

end.

