program raylib_worldspace_panning;

{$mode objfpc}{$H+}

uses cmem,
{uncomment if necessary}
raymath,
//ray_rlgl, 
raylib;

const
 screenWidth = 800;
 screenHeight = 450;

 var
  cam:TCamera2d;
  prevMousePos,mapDelta,thisPos,delta :Tvector2;
  mouseDelta,newZoom: Single;
  x,y,size:integer;

begin
 InitWindow(screenWidth, screenHeight, 'raylib [2d] example - world space paning');

  cam.zoom := 1;
  cam.offset.x := GetScreenWidth / 2.0;
  cam.offset.y := GetScreenHeight / 2.0;
  prevMousePos := GetMousePosition;
  SetTargetFPS(60);

 while not WindowShouldClose() do 
 begin
  //update
    Vector2Set(@mapDelta,0,0);//( 0,0 );
    mouseDelta := GetMouseWheelMove();
    newZoom := cam.zoom + mouseDelta * 0.01;

    if newZoom <= 0 then newZoom := 0.01;
    cam.zoom := newZoom;
    thisPos := GetMousePosition();
    delta := Vector2Subtract(prevMousePos, thisPos);
    prevMousePos := thisPos;

   if IsMouseButtonDown(0) then
        begin
            mapDelta := Vector2Scale(delta, 1.0/cam.zoom);
            cam.target := Vector2Add(cam.target, mapDelta);
        end;
  if IsKeyPressed(KEY_Space) then TakeScreenShot('prev.png');
  BeginDrawing();
    ClearBackground(RAYWHITE);

        BeginMode2D(cam);
        size := 5000;

        for x:=-size to size do //    (float x = -size; x <= size; x += 10)
        begin
            DrawLine(x*10, -size*10, x*10, size*10, GRAY);
        end;

	for y:=-size to size do// (float y = -size; y <= size; y += 10)
	begin
	  DrawLine(-size*10, y*10, size*10, y*10, GRAY);
	end;

        DrawLine(-size, 0, size, 0, RED);
        DrawLine(0, -size, 0, size, RED);
        EndMode2D();

        DrawText(TextFormat('%f %f', delta.x, delta.y),10, 10, 20, BLACK);
        DrawText(TextFormat('%f %f', mapDelta.x, mapDelta.y), 10, 30, 20, BLACK);

  EndDrawing(); 
 end;
CloseWindow(); 

end.

