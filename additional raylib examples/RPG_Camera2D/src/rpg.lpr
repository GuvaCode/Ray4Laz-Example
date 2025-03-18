program rpg;

{$mode objfpc}{$H+}

uses 
cmem, 
raylib;

const
  screenWidth = 800;
  screenHeight = 600;

type
  tree = record
   X: integer;
   Y: integer;
   end;

  pl = record
   x,y:integer;
   tex: TTexture;
  end;

var
  myGround: array [0..10] of array [0..10] of TTexture;
  myTree: array[0..5] of Tree;
  treeImg: TTexture;
  X,Y,T:Integer;
  Player:pl;
  camera:TCamera2D;

begin
  // Initialization
  InitWindow(screenWidth, screenHeight, 'raylib - simple project');
  SetTargetFPS(60);// Set our game to run at 60 frames-per-second

  for x:=0 to 10
  do for y:=0 to 10 do
  myGround[x][y]:=LoadTexture('data/grass.png');

  treeImg:= LoadTexture('data/tree.png');

  for T:=0 to 3 do begin
   myTree[t].X:=random(320);
   myTree[t].Y:=random(320);
  end;

  player.tex:=LoadTexture('data/m_d.png');
  // Main game loop
  while not WindowShouldClose() do
    begin

      // Update
      if IsKeyDown(KEY_DOWN) then player.y:=player.y + 1;
      if IsKeyDown(KEY_UP) then player.y:=player.y - 1;
      if IsKeyDown(KEY_LEFT) then player.x:=player.x - 1;
      if IsKeyDown(KEY_RIGHT) then player.x:=player.x + 1;



       Camera.target:=Vector2Create(Player.x,Player.y);
       Camera.offset:=Vector2Create(800 /2,600/2);

       Camera.zoom := 3;

      // Draw
      BeginDrawing();
      ClearBackground(RAYWHITE);

      BeginMode2D(camera);




        for x:=0 to 10
        do for y:=0 to 10 do
        DrawTextureEx(myGround[x][y],Vector2Create(x*32,Y*32),0,1,WHITE);

        DrawTextureEx(player.tex,Vector2Create(player.X,player.Y),0, 0.5 ,White);


        for t:=0 to 5 do
          begin
           DrawTextureEx(treeImg,Vector2Create(myTree[t].X,myTree[t].Y),0,1,White);
          end;



       EndMode2D;
        EndDrawing();
        DrawText('raylib in lazarus !!!', 20, 20, 10, DARKGRAY);
    end;

  // De-Initialization
  for x:=0 to 10
        do for y:=0 to 10 do  UnloadTexture(myGround[x][y]);
  CloseWindow();        // Close window and OpenGL context

end.

