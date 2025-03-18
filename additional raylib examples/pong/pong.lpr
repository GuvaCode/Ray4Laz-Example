{*******************************************************************************************
*
*   raylib pong
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2022 Ramon Santamaria (@raysan5)
*   Pascal translation 2022 Vadim Gunko
*
********************************************************************************************}
program pong;

{$mode objfpc}{$H+}

uses 
cmem, raylib;

type
  TGameScreen = (SCREEN_LOGO, SCREEN_TITLE, SCREEN_GAMEPLAY, SCREEN_ENDING);

const
  screenWidth = 800;
  screenHeight = 450;

var
  ballPosition : TVector2;
  ballRadius, playerSpeed, enemySpeed, alphaLogo: Single;
  ballSpeedX, ballSpeedY, playerScore, enemyVisionRange,
  enemyScore, logoState, framesCounter: Integer;
  player, enemy: TRectangle;
  texLogo: TTexture2D;
  fntTitle: TFont;
  fxStart, fxPong: TSound;
  ambient: TMusic;
  pause, finishGame: Boolean;
  currentScreen: TGameScreen;

begin
  // Initialization
  //--------------------------------------------------------------------------------------
  InitWindow(screenWidth, screenHeight, 'raylib [core] example - basic window');

  InitAudioDevice();

  // Ball
  ballPosition := Vector2Create( screenWidth/2, screenHeight/2 );
  ballRadius := 20.0;
  ballSpeedX := 6;
  ballSpeedY := -4;

  // Player
  player := RectangleCreate( 10, screenHeight/2 - 50, 25, 100 );
  playerSpeed := 8.0;
  playerScore := 0;

  // Enemy
  enemy := RectangleCreate( screenWidth - 10 - 25, screenHeight/2 - 50, 25, 100 );
  enemySpeed := 3.0;
  enemyVisionRange := screenWidth div 2;
  enemyScore := 0;

  // Resources loading
  texLogo := LoadTexture('resources/logo_raylib.png');
  alphaLogo := 0.0;
  logoState := 0;          // 0-FadeIn, 1-Wait, 2-FadeOut

  //Font fntTitle = LoadFont("resources/pixantiqua.ttf");     // Font size: 32px default
  fntTitle := LoadFontEx('resources/pixantiqua.ttf', 12, nil, 0); // Font size: pixel-perfect
  SetTextureFilter(fntTitle.texture, TEXTURE_FILTER_POINT);

  fxStart := LoadSound('resources/start.wav');
  fxPong := LoadSound('resources/pong.wav');

  ambient := LoadMusicStream('resources/qt-plimp.xm');
  PlayMusicStream(ambient);

  // General variables
  pause := false;
  finishGame := false;
  framesCounter := 0;
  currentScreen := SCREEN_LOGO; // 0-LOGO, 1-TITLE, 2-GAMEPLAY, 3-ENDING

  SetTargetFPS(60);// Set our game to run at 60 frames-per-second
  //--------------------------------------------------------------------------------------
  // Main game loop
  while not WindowShouldClose() do
    begin
      // Update
      //----------------------------------------------------------------------------------
      UpdateMusicStream(ambient);

      case currentScreen of
      SCREEN_LOGO:
          begin
              if logoState = 0 then
              begin
                  alphaLogo +=  (1.0/180);
                  if (alphaLogo > 1.0) then
                  begin
                      alphaLogo := 1.0;
                      logoState := 1;
                  end;
              end
              else if logoState = 1 then
              begin
                  Inc(framesCounter);
                  if (framesCounter >= 200) then
                  begin
                      framesCounter := 0;
                      logoState := 2;
                  end;
              end
              else if (logoState = 2) then
              begin
                  alphaLogo -=  (1.0/180);
                  if (alphaLogo < 0.0) then
                  begin
                      alphaLogo := 0.0;
                      currentScreen := SCREEN_TITLE;
                  end;
              end;
          end;

          SCREEN_TITLE:
          begin
              Inc(framesCounter);

              // Update TITLE screen
              if (IsKeyPressed(KEY_ENTER)) then
              begin
                  PlaySound(fxStart);
                  currentScreen := SCREEN_GAMEPLAY;
              end;
          end;
          SCREEN_GAMEPLAY:
          begin
              // Update GAMEPLAY screen
              if (not pause) then
              begin
                  // Ball movement logic
                  ballPosition.x += ballSpeedX;
                  ballPosition.y += ballSpeedY;

                  if (((ballPosition.x + ballRadius) > screenWidth) or ((ballPosition.x - ballRadius) < 0)) then
                  begin
                      PlaySound(fxPong);
                      ballSpeedX *= -1;
                  end;

                  if (((ballPosition.y + ballRadius) > screenHeight) or ((ballPosition.y - ballRadius) < 0)) then
                  begin
                      PlaySound(fxPong);
                      ballSpeedY *= -1;
                  end;

                  if ((ballPosition.x - ballRadius) <= 0) then enemyScore += 1000
                  else if ((ballPosition.x + ballRadius) > GetScreenWidth()) then playerScore += 1000;

                  // Player movement logic
                  if (IsKeyDown(KEY_UP)) then player.y -= playerSpeed
                  else if (IsKeyDown(KEY_DOWN)) then player.y += playerSpeed;

                  if (player.y <= 0) then player.y := 0
                  else if ((player.y + player.height) >= screenHeight) then player.y := screenHeight - player.height;

                  if (CheckCollisionCircleRec(ballPosition, ballRadius, player)) then
                  begin
                      PlaySound(fxPong);
                      ballSpeedX *= -1;
                  end;

                  // Enemy movement logic
                  if (ballPosition.x > enemyVisionRange) then
                  begin
                      if (ballPosition.y > (enemy.y + enemy.height/2)) then enemy.y += enemySpeed
                      else if (ballPosition.y < (enemy.y + enemy.height/2)) then enemy.y -= enemySpeed;
                  end;

                  if (CheckCollisionCircleRec(ballPosition, ballRadius, enemy)) then
                  begin
                      PlaySound(fxPong);
                      ballSpeedX *= -1;
                  end;

                  if (IsKeyDown(KEY_RIGHT)) then Inc(enemyVisionRange)
                  else if (IsKeyDown(KEY_LEFT)) then Dec(enemyVisionRange);
              end;

              if (IsKeyPressed(KEY_P)) then pause := not pause;

              if (IsKeyPressed(KEY_ENTER)) then currentScreen := SCREEN_ENDING;
          end;
          SCREEN_ENDING:
          begin
              // Update ENDING screen
              if (IsKeyPressed(KEY_ENTER)) then
              begin
                  //currentScreen = 1;
                  finishGame := true;
              end;
          end;

      end;

      // Draw
      //----------------------------------------------------------------------------------
      BeginDrawing();
      ClearBackground(RAYWHITE);

      case  currentScreen of
      SCREEN_LOGO:
          begin
              // Draw LOGO screen
              //DrawRectangle(0, 0, screenWidth, screenHeight, BLUE);
              //DrawText("SCREEN LOGO", 10, 10, 30, DARKBLUE);
              DrawTexture(texLogo, GetScreenWidth div 2 - texLogo.width div 2,
                                   GetScreenHeight div 2 - texLogo.height div 2 - 40,
                                   Fade(WHITE, alphaLogo));
          end;

      SCREEN_TITLE:
          begin
              // Draw TITLE screen
              //DrawRectangle(0, 0, screenWidth, screenHeight, GREEN);
              //DrawText("SCREEN TITLE", 10, 10, 30, DARKGREEN);
              DrawTextEx(fntTitle, 'SUPER PONG', Vector2Create( 200, 100 ), fntTitle.baseSize*6, 4, LIME);
              if ((framesCounter div 30) mod 2 = 0) then DrawText('PRESS ENTER to START', 200, 300, 30, BLACK);
          end;
          SCREEN_GAMEPLAY:
          begin
              DrawCircleV(ballPosition, ballRadius, RED);
              DrawRectangleRec(player, BLUE);
              DrawRectangleRec(enemy, DARKGREEN);
              DrawLine(enemyVisionRange, 0, enemyVisionRange, screenHeight, GRAY);

              // Draw hud
              DrawText(TextFormat('%04i', playerScore), 100, 10, 30, BLUE);
              DrawText(TextFormat('%04i', enemyScore), screenWidth - 200, 10, 30, DARKGREEN);

              if (pause) then
              begin
                  DrawRectangle(0, 0, GetScreenWidth(), GetScreenHeight(), Fade(WHITE, 0.8));
                  DrawText('GAME PAUSED', 320, 200, 30, RED);
              end;
          end;
          SCREEN_ENDING:
          begin
              // Draw ENDING screen
              DrawRectangle(0, 0, screenWidth, screenHeight, RED);
              DrawText('SCREEN ENDING', 10, 10, 30, MAROON);
          end;
      end;
     EndDrawing();
    end;
  // De-Initialization
  //--------------------------------------------------------------------------------------
  UnloadTexture(texLogo);
  UnloadFont(fntTitle);

  UnloadSound(fxStart);
  UnloadSound(fxPong);
  UnloadMusicStream(ambient);

  CloseAudioDevice();

  CloseWindow();        // Close window and OpenGL context
  //--------------------------------------------------------------------------------------
end.

