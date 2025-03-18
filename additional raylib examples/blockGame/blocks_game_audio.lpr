{*******************************************************************************************
*
*   PROJECT:        BLOCKS GAME
*   LESSON 07:      audio
*   DESCRIPTION:    Sounds and music loading and playing
*
*   Example originally created with raylib 2.0, last time updated with raylib 4.2

*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2017-2022 Ramon Santamaria (@raysan5)
*   Pascal translation 2022 Vadim Gunko (@guvacode)
*
********************************************************************************************}

program blocks_game_audio;

{$mode objfpc}{$H+}
{$define LESSON02_SHAPES}
uses 
cmem, raylib;

{.$DEFINE LESSON02_SHAPES} // Alternative: LESSON02_SHAPES

// LESSON 01: Window initialization and screens management
type
  TGameScreen = (LOGO, TITLE, GAMEPLAY, ENDING);

  // Player structure
  TPlayer = record
    position : TVector2;
    speed    : TVector2;
    size     : TVector2;
    bounds   : TRectangle;
    lifes    : Integer;
  end;

 // Ball structure
 TBall = record
   position : TVector2;
   speed    : TVector2;
   radius   : Single;
   active   : Boolean;
 end;

 // Bricks structure
 TBrick = record
   position : TVector2;
   size     : TVector2;
   bounds   : TRectangle;
   active   : Boolean;
end;

const
  screenWidth = 800;
  screenHeight = 450;
  PLAYER_LIFES = 5;
  BRICKS_LINES = 5;
  BRICKS_PER_LINE = 20;
  BRICKS_POSITION_Y = 50;

var
  screen: TGameScreen;
  framesCounter,
  gameResult: Integer;
  gamePaused: Boolean;
  player: TPlayer;
  ball: TBall;
  bricks: array [0..BRICKS_LINES, 0..BRICKS_PER_LINE] of TBrick;
  texLogo, texBall, texPaddle, texBrick: TTexture2D;
  fxStart, fxBounce, fxExplode: TSound;
  music: TMusic;
  font: TFont;
  i,j : integer;


begin
  //--------------------------------------------------------------------------------------
  // Initialization
  //--------------------------------------------------------------------------------------

  // LESSON 01: Window initialization and screens management
  InitWindow(screenWidth, screenHeight, 'PROJECT: BLOCKS GAME');

  // LESSON 05: Textures loading and drawing
  texLogo   := LoadTexture('resources/raylib_logo.png');
  texBall   := LoadTexture('resources/ball.png');
  texPaddle := LoadTexture('resources/paddle.png');
  texBrick  := LoadTexture('resources/brick.png');

  // LESSON 06: Fonts loading and text drawing
  font := LoadFont('resources/setback.png');

  // LESSSON 07: Sounds and music loading and playing
  InitAudioDevice();              // Initialize audio system

  fxStart := LoadSound('resources/start.wav');
  fxBounce := LoadSound('resources/bounce.wav');
  fxExplode := LoadSound('resources/explosion.wav');

  music := LoadMusicStream('resources/blockshock.mod');

  PlayMusicStream(music);         // Start music streaming

  // Game required variables
  screen := LOGO;       // Current game screen state

  framesCounter := 0;          // General pourpose frames counter
  gameResult := -1;            // Game result: 0 - Loose, 1 - Win, -1 - Not defined
  gamePaused := false;         // Game paused state toggle

  // Initialize player
  player.position := Vector2Create( screenWidth/2, screenHeight*7/8 );
  player.speed := Vector2Create( 8.0, 0.0 );
  player.size := Vector2Create( 100, 24 );
  player.lifes := PLAYER_LIFES;

  // Initialize ball
  ball.radius := 10;
  ball.active := false;
  ball.position := Vector2Create( player.position.x + player.size.x/2, player.position.y - ball.radius*2 );
  ball.speed := Vector2Create( 4.0, 4.0 );

  // Initialize bricks
  for  j:= 0 to BRICKS_LINES -1 do
     for i:=0 to BRICKS_PER_LINE - 1 do
      begin
          bricks[j][i].size := Vector2Create( screenWidth/BRICKS_PER_LINE, 20 );
          bricks[j][i].position := Vector2Create( i*bricks[j][i].size.x, j*bricks[j][i].size.y + BRICKS_POSITION_Y );
          bricks[j][i].bounds := RectangleCreate( bricks[j][i].position.x, bricks[j][i].position.y, bricks[j][i].size.x, bricks[j][i].size.y );
          bricks[j][i].active := true;
      end;

  SetTargetFPS(60);            // Set desired framerate (frames per second)

  //--------------------------------------------------------------------------------------

  // Main game loop
  while not WindowShouldClose() do  // Detect window close button or ESC key
    begin
      // Update
      case screen of
        LOGO:
          begin
          // Update LOGO screen data here!
            Inc(framesCounter);
            if framesCounter > 180 then
              begin
                screen := TITLE;    // Change to TITLE screen after 3 seconds
                framesCounter := 0;
              end;
          end;

        TITLE:
          begin
          // Update TITLE screen data here!
            Inc(framesCounter);
            // LESSON 03: Inputs management (keyboard, mouse)
            if IsKeyPressed(KEY_ENTER) then screen := GAMEPLAY;
            PlaySound(fxStart);
          end;

        GAMEPLAY:
          begin
          // Update GAMEPLAY screen data here!
            begin
              if IsKeyPressed(KEY_P) then gamePaused := not gamePaused;    // Pause button logic
              if not gamePaused then
              begin
                // LESSON 03: Inputs management (keyboard, mouse)

                // Player movement logic
                if IsKeyDown(KEY_LEFT) then player.position.x -= player.speed.x;
                if IsKeyDown(KEY_RIGHT) then player.position.x += player.speed.x;

                if (player.position.x) <= 0 then player.position.x := 0;
                if (player.position.x + player.size.x) >= screenWidth then player.position.x := screenWidth - player.size.x;

                player.bounds := RectangleCreate( player.position.x, player.position.y, player.size.x, player.size.y );


              if ball.active then
              begin
                  // Ball movement logic
                  ball.position.x += ball.speed.x;
                  ball.position.y += ball.speed.y;

                  // Collision logic: ball vs screen-limits
                  if (((ball.position.x + ball.radius) >= screenWidth) or  ((ball.position.x - ball.radius) <= 0))  then ball.speed.x *= -1;
                  if ((ball.position.y - ball.radius) <= 0) then ball.speed.y *= -1;

                  // LESSON 04: Collision detection and resolution

                  // NOTE: For collisions we consider elements bounds parameters,
                  // that's independent of elements drawing but they should match texture parameters

                  // Collision logic: ball vs player
                  if (CheckCollisionCircleRec(ball.position, ball.radius, player.bounds)) then
                  begin
                      ball.speed.y *= -1;
                      ball.speed.x := (ball.position.x - (player.position.x + player.size.x/2))/player.size.x*5.0;
                      PlaySound(fxBounce);
                  end;

                  // Collision logic: ball vs bricks
                  for j:=0 to BRICKS_LINES -1 do
                    for i:=0 to BRICKS_PER_LINE -1 do
                      begin
                          if bricks[j][i].active and (CheckCollisionCircleRec(ball.position, ball.radius, bricks[j][i].bounds)) then
                          begin
                              bricks[j][i].active := false;
                              ball.speed.y *= -1;
                              PlaySound(fxExplode);
                          end;
                      end;

                  // Game ending logic
                  if ((ball.position.y + ball.radius) >= screenHeight) then
                  begin
                      ball.position.x := player.position.x + player.size.x/2;
                      ball.position.y := player.position.y - ball.radius - 1.0;
                      ball.speed := Vector2Create( 0, 0 );
                      ball.active := false;
                      Dec(player.lifes);
                  end;

                  if (player.lifes <= 0) then
                  begin
                      screen := ENDING;
                      player.lifes := 5;
                      framesCounter := 0;
                  end;
              end
                else
                begin
                    // Reset ball position
                    ball.position.x := player.position.x + player.size.x/2;

                    // LESSON 03: Inputs management (keyboard, mouse)
                    if (IsKeyPressed(KEY_SPACE)) then
                    begin
                        // Activate ball logic
                        ball.active := true;
                        ball.speed := Vector2Create( 0, -5.0 );
                    end;

                end;
             end;
          end;
        end;

        ENDING:
          begin
            // Update END screen data here!
             Inc(framesCounter);
             // LESSON 03: Inputs management (keyboard, mouse)
             if (IsKeyPressed(KEY_ENTER)) then
             // Replay / Exit game logic
             screen := TITLE;
          end;
      end;

      // LESSSON 07: Sounds and music loading and playing
      // NOTE: Music buffers must be refilled if consumed
      UpdateMusicStream(music);

      // Draw
      //----------------------------------------------------------------------------------
      BeginDrawing();
        ClearBackground(RAYWHITE);

        case screen of

          LOGO:
            begin
              // TODO: Draw LOGO screen here!
              // LESSON 05: Textures loading and drawing
              DrawTexture(texLogo, screenWidth div 2 - texLogo.width div 2, screenHeight div 2 - texLogo.height div 2, WHITE);
            end;

          TITLE:
            begin
              // LESSON 06: Fonts loading and text drawing
              DrawTextEx(font, 'BLOCKS', Vector2Create( 100, 80 ), 160, 10, MAROON);   // Draw Title

              if ((framesCounter div 30) mod 2 = 0) then DrawText('PRESS [ENTER] to START',
              GetScreenWidth div 2 - MeasureText('PRESS [ENTER] to START', 20) div 2, GetScreenHeight div 2 + 60, 20, DARKGRAY);
            end;

          GAMEPLAY:
            begin
              // Draw GAMEPLAY screen here!
              {$IFDEF LESSON02_SHAPES}
              // LESSON 02: Draw basic shapes (circle, rectangle)
              DrawRectangle(Round(player.position.x), Round(player.position.y),
                            Round(player.size.x), Round(player.size.y), BLACK);   // Draw player bar

              DrawCircleV(ball.position, ball.radius, MAROON);    // Draw ball

              // Draw bricks
              for j:=0 to BRICKS_LINES -1 do
                for i:=0 to BRICKS_PER_LINE -1 do
                  begin
                      if (bricks[j][i].active) then
                        begin
                          if (i + j) mod 2 = 0 then
                            DrawRectangle(Round(bricks[j][i].position.x),
                                          Round(bricks[j][i].position.y),
                                          Round(bricks[j][i].size.x),
                                          Round(bricks[j][i].size.y), GRAY)
                          else
                            DrawRectangle(Round(bricks[j][i].position.x),
                                          Round(bricks[j][i].position.y),
                                          Round(bricks[j][i].size.x),
                                          Round(bricks[j][i].size.y), DARKGRAY);
                        end;
                  end;
              {$ELSE}
              // LESSON 05: Textures loading and drawing
              DrawTextureEx(texPaddle, player.position, 0.0, 1.0, WHITE);   // Draw player
              DrawTexture(texBall,
              Trunc(ball.position.x - ball.radius / 2),Trunc( ball.position.y - ball.radius / 2) , MAROON);    // Draw ball

              // Draw bricks
              for j:=0 to BRICKS_LINES -1 do
                for i:=0 to BRICKS_PER_LINE -1 do
                  begin
                      if (bricks[j][i].active) then
                      begin
                          // NOTE: Texture is not scaled, just using original size
                          if ((i + j) mod 2 = 0) then DrawTextureEx(texBrick, bricks[j][i].position, 0.0, 1.0, GRAY)
                          else DrawTextureEx(texBrick, bricks[j][i].position, 0.0, 1.0, DARKGRAY);
                      end;
                  end;
              {$IFEND}

              // Draw GUI: player lives
              for i:=0 to player.lifes -1 do DrawRectangle(20 + 40*i, screenHeight - 30, 35, 10, LIGHTGRAY);

              // Draw pause message when required
              if gamePaused then DrawText('GAME PAUSED', screenWidth div 2 - MeasureText('GAME PAUSED', 40) div 2, screenHeight div 2 + 60, 40, GRAY);
            end;

          ENDING:
            begin
            // LESSON 06: Fonts loading and text drawing
            // Draw ending message
            DrawTextEx(font, 'GAME FINISHED', Vector2Create( 80, 100 ), 80, 6, MAROON);
            if ((framesCounter div 30) mod 2 = 0) then
            DrawText('PRESS [ENTER] TO PLAY AGAIN', GetScreenWidth div 2 - MeasureText('PRESS [ENTER] TO PLAY AGAIN', 20) div 2,
            GetScreenHeight div 2 + 80, 20, GRAY);
            end;
        end;

      EndDrawing();
    end;

  // De-Initialization

  // NOTE: Unload any loaded resources (texture, fonts, audio)

  // LESSON 05: Textures loading and drawing
  UnloadTexture(texBall);
  UnloadTexture(texPaddle);
  UnloadTexture(texBrick);

  // LESSON 06: Fonts loading and text drawing
  UnloadFont(font);

  // LESSSON 07: Sounds and music loading and playing
  UnloadSound(fxStart);
  UnloadSound(fxBounce);
  UnloadSound(fxExplode);

  CloseWindow();        // Close window and OpenGL context

end.


