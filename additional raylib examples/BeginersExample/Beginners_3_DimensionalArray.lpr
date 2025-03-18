program Beginners_3_DimensionalArray;

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
  // We set up our 3 dimensional array here. It is a int array.
  map : array [0..9] of array [0..9] of array [0..9] of integer;
  boolmap:array [0..9] of array [0..9] of array [0..9]  of boolean;




begin
 InitWindow(screenWidth, screenHeight, 'raylib pascal - basic window');

     // Here we put some values inside the array.
    map[0][0][0] := 10;
    map[9][0][0] := 20; // With a setup size of 10 the maximum slot to be used is 9!
    map[0][0][9] := 30;
    map[9][0][9] := 40;

    // Boolean map. Only true or false.
    boolmap[9][9][9] := false;
    boolmap[1][1][2] := true;

 SetTargetFPS(60);

 while not WindowShouldClose() do 
 begin
  BeginDrawing();
  ClearBackground(RAYWHITE);

            // Here we show the contents of the 3 dimensional array on the screen.
            DrawText(TextFormat('map[0][0][0]: %i',map[0][0][0]),100,100,20,BLACK);
            DrawText(TextFormat('map[9][0][0]: %i',map[9][0][0]),100,120,20,BLACK);
            DrawText(TextFormat('map[0][0][9]: %i',map[0][0][9]),100,140,20,BLACK);
            DrawText(TextFormat('map[9][0][9]: %i',map[9][0][9]),100,160,20,BLACK);
            DrawText(TextFormat('default :=0 slot of map[1][1][1]: %i',map[1][1][1]),100,180,20,BLACK);

            // Check if boolmap[1][1][2] = true or false.
            if boolmap[1][1][2] = true then
             DrawText('boolmap[1][1][2] set to true.',100,200,20,BLACK)
            else
             DrawText('boolmap[1][1][2] set to false.',100,200,20,BLACK);



  EndDrawing(); 
 end;
CloseWindow(); 

end.

