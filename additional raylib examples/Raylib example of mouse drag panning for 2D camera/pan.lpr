program pan;

{$mode objfpc}{$H+}

uses cmem,raylib, raymath, math;

const
 screenWidth = 800;
 screenHeight = 450;

var
  cam : TCamera2D;
  prevMousePos : TVector2;
  thisPos : TVector2;
  delta : TVector2;
  mapGrid: TVector2;
  mouseDelta : single;
  newZoom : single;
  size:integer;

  i,step:integer;

begin
 InitWindow(screenWidth, screenHeight, 'raylib [2d] example - world space panning');

  cam.zoom := 1;
  cam.offset.x := GetScreenWidth / 2.0;
  cam.offset.y := GetScreenHeight / 2.0;

  prevMousePos := GetMousePosition;
  SetTargetFPS(60);

 while not WindowShouldClose() do 
 begin
  //update
   mouseDelta := GetMouseWheelMove;

        newZoom := cam.zoom + mouseDelta * 0.01;
        if newZoom <= 0 then newZoom := 0.01;
        cam.zoom := newZoom;

        thisPos := GetMousePosition;

        delta := Vector2Subtract(prevMousePos, thisPos);
        prevMousePos := thisPos;

        if IsMouseButtonDown(0)  then
            cam.target := GetScreenToWorld2D(Vector2Add(cam.offset, delta),cam);

        if IsKeyPressed(KEY_LEFT) then
            cam.rotation += 10
        else if IsKeyPressed(KEY_RIGHT) then
            cam.rotation -= 10;



 //draw
 BeginDrawing();
  ClearBackground(RAYWHITE);
  BeginMode2D(cam);
  size := 5000;

  for i := -size to size do
     begin
        DrawLine(i*10, -size, i*10, size, GRAY);
        DrawLine(-size, i*10, size, i*10, GRAY);
     end;

       DrawLine(-size, 0, size, 0, RED);
       DrawLine(0, -size, 0, size, RED);

       mapGrid := GetScreenToWorld2D(GetMousePosition(), cam);
       mapGrid.x := Floor(mapGrid.x / 10) * 10.0;
       mapGrid.y := Floor(mapGrid.y / 10) * 10.0;

       DrawRectangle(Round(mapGrid.x), Round(mapGrid.y), 10, 10, BLUE);

       EndMode2D();

       DrawText(TextFormat('%4.0f %4.0f', mapGrid.x, mapGrid.y),10, 10, 20, BLACK);
  EndDrawing(); 
 end;
CloseWindow(); 

end.

