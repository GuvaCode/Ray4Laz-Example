program game;

{$mode objfpc}{$H+}

uses 
cmem, 
{uncomment if necessary}
raymath, math,
collider,
raylib, lighting;

const
  screenWidth = 800;
  screenHeight = 450;
  M_PI=	3.1415926;

type
  TRigidBody = record
  model: TModel;
  collider: TCollider;
  end;

var
  Camera: TCamera;
  plane, player, block, ramp: TRigidBody;
  dim,min,max,pos,axis,playerVel,playerDisp, corr, playerPos, cameraOffset: TVector3;
  ang: single;
  speed, dt: single;
begin
  // Initialization
  InitWindow(screenWidth, screenHeight, 'Oriented bounding box collisions');

  DisableCursor();
  SetTargetFPS(60);// Set our game to run at 60 frames-per-second


  // Setup 3rd person camera
  camera.projection := CAMERA_PERSPECTIVE;
  camera.fovy := 45;
  camera.position := Vector3Create ( -5.0, 2.0, 5.0 );
  camera.target := Vector3Create ( 0.0, 1.0, 0.0 );
  camera.up := Vector3Create (0.0, 1.0, 0.0 );

  // Create plane
  dim := Vector3Create( 100.0, 1.0, 100.0 );
  min := Vector3Create( -dim.x/2, -dim.y/2, -dim.z/2 );
  max := Vector3Create( dim.x/2, dim.y/2, dim.z/2 );
  pos := Vector3Create( 0.0, 0.0, 0.0 );
  axis := Vector3Create( 0.0, 1.0, 0.0 );
  ang := 0.0;
  plane.collider := CreateCollider(min, max);
  plane.model := LoadModelFromMesh(GenMeshCube(dim.x, dim.y, dim.z));
  SetColliderRotation(@plane.collider, axis, ang);
  SetColliderTranslation(@plane.collider, pos);
  plane.model.transform := GetColliderTransform(@plane.collider);

  // Create player
  dim := Vector3Create ( 1.0, 1.0, 1.0 );
  min := Vector3Create ( -dim.x/2, -dim.y/2, -dim.z/2 );
  max := Vector3Create ( dim.x/2, dim.y/2, dim.z/2 );
  pos := Vector3Create ( 0.0, 1.0, 0.0 );
  axis := Vector3Create ( 0.0, 1.0, 0.0 );
  ang := 0.0;
  player.collider := CreateCollider(min, max);
  player.model := LoadModelFromMesh(GenMeshCube(dim.x, dim.y, dim.z));
  SetColliderRotation(@player.collider, axis, ang);
  SetColliderTranslation(@player.collider, pos);
  player.model.transform := GetColliderTransform(@player.collider);
  playerVel := Vector3Zero();

  // Create block
  dim := Vector3Create ( 5.0, 5.0, 5.0 );
  min := Vector3Create ( -dim.x/2, -dim.y/2, -dim.z/2 );
  max := Vector3Create ( dim.x/2, dim.y/2, dim.z/2 );
  pos := Vector3Create ( 10.0, 1.0, 10.0 );
  axis := Vector3Create ( 0.0, 1.0, 0.0 );
  ang := 0.9;
  block.collider := CreateCollider(min, max);
  block.model := LoadModelFromMesh(GenMeshCube(dim.x, dim.y, dim.z));
  SetColliderRotation(@block.collider, axis, ang);
  SetColliderTranslation(@block.collider, pos);
  block.model.transform := GetColliderTransform(@block.collider);

  // Create ramp
  dim := Vector3Create ( 5.0, 1.0, 20.0 );
  min := Vector3Create ( -dim.x/2, -dim.y/2, -dim.z/2 );
  max := Vector3Create ( dim.x/2, dim.y/2, dim.z/2 );
  pos := Vector3Create ( -10.0, 0.0, 0.0 );
  axis := Vector3Create ( 1.0, 0.0, 0.0 );
  ang := M_PI/3;
  ramp.collider := CreateCollider(min, max);
  ramp.model := LoadModelFromMesh(GenMeshCube(dim.x, dim.y, dim.z));
  SetColliderRotation(@ramp.collider, axis, ang);
  SetColliderTranslation(@ramp.collider, pos);
  ramp.model.transform := GetColliderTransform(@ramp.collider);

  // Setup lighting handler
  InitLighting();    // TODO create light shader
  SetLightPosition(Vector3Create ( 30.0, 40.0, 20.0 ));
  SetLightTarget(Vector3Create ( 0.0, 0.0, 0.0 ));
  LightingAddModel(@player.model);
  LightingAddModel(@plane.model);
  LightingAddModel(@block.model);
  LightingAddModel(@ramp.model);

  // Main game loop
  while not WindowShouldClose() do
    begin
      // Update
      // Using built-in camera controller because I am lazy
      UpdateCamera(@camera, CAMERA_THIRD_PERSON);

      // Translate and rotate player collider to follow camera target
      SetColliderTranslation(@player.collider, camera.target);
      ang := arctan2(camera.position.x - camera.target.x, camera.position.z - camera.target.z);
      axis := Vector3Create ( 0.0, 1.0, 0.0 );
      SetColliderRotation(@player.collider, axis, ang);

      // Apply gravity:
      speed:= 0.5;
      dt := Clamp(GetFrameTime(), 0.0, 1.0/30.0);
      playerVel.x := 0.0;
      playerVel.z := 0.0;
      playerVel.y := math.max(-20.0, playerVel.y);

      playerVel.y:= IfThen(IsKeyPressed(KEY_SPACE), 20.0, playerVel.y - 0.8);

      playerDisp := Vector3Scale(playerVel, dt);
      AddColliderTranslation(@player.collider, playerDisp);

      // Calculate the correction needed to resolve collisions between the player and all other colliders
      // Then add the correction to the position of the player
      // The order in which the corrections are applied can change the results

      corr := GetCollisionCorrection(@player.collider, @block.collider);
      AddColliderTranslation(@player.collider, corr);

      corr := GetCollisionCorrection(@player.collider, @ramp.collider);
      AddColliderTranslation(@player.collider, corr);

      corr := GetCollisionCorrection(@player.collider, @plane.collider);
      AddColliderTranslation(@player.collider, corr);

      // Move camera to follow player collider
      // (only translation, rotation and distance stay the same here)
      playerPos := Vector3Transform(Vector3Zero(), player.collider.matTranslate);
      cameraOffset := Vector3Subtract(camera.position, camera.target);
      camera.target := playerPos;
      camera.position := Vector3Add(camera.target, cameraOffset);
      player.model.transform := GetColliderTransform(@player.collider);

      // Render lighting depth map
      BeginDepthMode();
      DrawModel(plane.model, Vector3Zero(), 1.0, RED);
      DrawModel(player.model, Vector3Zero(), 1.0, BLUE);
      DrawModel(block.model, Vector3Zero(), 1.0, GREEN);
      DrawModel(ramp.model, Vector3Zero(), 1.0, YELLOW);
      EndDepthMode();

      // Draw
      // Render scene
      BeginDrawing();
      ClearBackground(BLACK);
      BeginViewMode(camera);
      DrawModel(plane.model, Vector3Zero(), 1.0, RED);
      DrawModel(player.model, Vector3Zero(), 1.0, BLUE);
      DrawModel(block.model, Vector3Zero(), 1.0, GREEN);
      DrawModel(ramp.model, Vector3Zero(), 1.0, YELLOW);
      DrawModelWires(plane.model, Vector3Zero(), 1.0, WHITE);
      DrawModelWires(player.model, Vector3Zero(), 1.0, WHITE);
      DrawModelWires(block.model, Vector3Zero(), 1.0, WHITE);
      DrawModelWires(ramp.model, Vector3Zero(), 1.0, WHITE);
      EndViewMode();
      DrawFPS(10, 10);
      EndDrawing();
    end;

  // De-Initialization
  CloseWindow();        // Close window and OpenGL context
end.

