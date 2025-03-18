program Beginners_Array_Of_Strings;

{$mode objfpc}{$H+}

uses cmem,
{uncomment if necessary}
//ray_math, 
//ray_rlgl, 
raylib, Strings;

const
 screenWidth = 800;
 screenHeight = 450;
 MAX_ITEMS = 9;

var myitems: array [0..MAX_ITEMS] of PChar = ('Sworld','Shield','Axe','Helmet','End','','','','','');
    i:integer;
begin

 InitWindow(screenWidth, screenHeight, 'raylib example');
 SetTargetFPS(60);


 while not WindowShouldClose() do
 begin
  BeginDrawing();
  ClearBackground(RAYWHITE);

  // Draw the items on the screen and exit if the item is "End"
  DrawText('Inventory:',70,80,20,BLACK);
  for i:=0  to  MAX_ITEMS do
  begin
  DrawText(TextFormat('%i',i),70,100+i*20,20,BLACK);
  DrawText(myitems[i],100,100+i*20,20,BLACK);
  if strcomp(myitems[i+1],'End') = 0 then break;
  end;


  EndDrawing(); 
 end;
CloseWindow(); 

end.

