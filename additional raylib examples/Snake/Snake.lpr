program Snake;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils, CustApp, RayLib;

const
  SNAKE_LENGTH = 256;  // Максимальная длина
  SQUARE_SIZE = 31;  // Размер поля
  ScreenWidth = 800;
  ScreenHeight = 450;

type

  TSnake = record
    position : TVector2;
    size : TVector2;
    speed : TVector2;
    color : TColorB;
  end;

  TFood = record
    position: TVector2;
    size: TVector2;
    active: Boolean;
    color: TColorB;
  end;

  { TRayApplication }
  TRayApplication = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    framesCounter: integer;
    gameOver: boolean;
    pause: boolean;
    fruit: TFood;
    snake: array[0..SNAKE_LENGTH] of TSnake;
    snakePosition: array [0..SNAKE_LENGTH] of TVector2;
    allowMove: boolean;
    offset: TVector2;
    counterTail: integer;
    counterScore: integer;
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure InitGame;         // Initialize game
    procedure UpdateGame;       // Update game (one frame)
    procedure DrawGame;         // Draw game (one frame)
    procedure UnloadGame;       // Unload game
    procedure UpdateDrawFrame;  // Update and Draw (one frame)
  end;





  const AppTitle = 'raylib - basic window';

{ TRayApplication }

constructor TRayApplication.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  InitWindow(ScreenWidth, ScreenHeight, AppTitle); // for window settings, look at example - window flags
  InitGame;
  SetTargetFPS(60); // Set our game to run at 60 frames-per-second
end;

procedure TRayApplication.DoRun;
begin

  while (not WindowShouldClose) do // Detect window close button or ESC key
  begin
    // Update your variables here
    UpdateDrawFrame;
  end;

  // Stop program loop
  Terminate;
end;

destructor TRayApplication.Destroy;
begin
  UnloadGame();         // Unload loaded data (textures, sounds, models...)
  CloseWindow(); // Close window and OpenGL context
  inherited Destroy;
end;

procedure TRayApplication.InitGame;
var  i: integer;
begin
  framesCounter := 0;
  gameOver := false;
  pause := false;

  counterScore := 10;

  counterTail := 1;
  allowMove := false;

  offset.x := screenWidth mod SQUARE_SIZE;
  offset.y := screenHeight mod SQUARE_SIZE;

  for i := 0 to SNAKE_LENGTH -1 do
  begin
    snake[i].position := Vector2Create( offset.x/2, offset.y/2 );
    snake[i].size := Vector2Create( SQUARE_SIZE, SQUARE_SIZE );
    snake[i].speed := Vector2Create( SQUARE_SIZE, 0 );

      if (i = 0) then snake[i].color := DARKBLUE
      else snake[i].color := BLUE;
  end;

  for i := 0 to SNAKE_LENGTH -1 do
  snakePosition[i] := Vector2Create( 0.0, 0.0 );


  fruit.size := Vector2Create( SQUARE_SIZE, SQUARE_SIZE );
  fruit.color := SKYBLUE;
  fruit.active := false;
end;

procedure TRayApplication.UpdateGame;
var i: integer;
begin
  if (not gameOver) then
  begin
      if (IsKeyPressed(KEY_P)) then pause := not pause;

      if (not pause) then
      begin
          // Player control
          if (IsKeyPressed(KEY_RIGHT) and (snake[0].speed.x = 0) and allowMove) then
          begin
              snake[0].speed := Vector2Create( SQUARE_SIZE, 0 );
              allowMove := false;
          end;
          if (IsKeyPressed(KEY_LEFT) and (snake[0].speed.x = 0) and allowMove) then
          begin
              snake[0].speed := Vector2Create( -SQUARE_SIZE, 0 );
              allowMove := false;
          end;
          if (IsKeyPressed(KEY_UP) and (snake[0].speed.y = 0) and allowMove) then
          begin
            snake[0].speed := Vector2Create(0, -SQUARE_SIZE );
            allowMove := false;
          end;
          if (IsKeyPressed(KEY_DOWN) and (snake[0].speed.y = 0) and allowMove) then
          begin
              snake[0].speed := Vector2Create(  0, SQUARE_SIZE );
              allowMove := false;
          end;

          // Snake movement
          for i := 0 to counterTail -1 do  snakePosition[i] := snake[i].position;
          if ((framesCounter mod counterScore) = 0) then // speed ??
          begin
              for i :=0 to counterTail -1 do // (int i = 0; i < counterTail; i++)
              begin
                  if (i = 0) then
                  begin
                      snake[0].position.x += snake[0].speed.x;
                      snake[0].position.y += snake[0].speed.y;
                      allowMove := true;
                  end
                  else snake[i].position := snakePosition[i-1];
              end;
          end;

          // Wall behaviour
          if (((snake[0].position.x) > (screenWidth - offset.x)) or
              ((snake[0].position.y) > (screenHeight - offset.y)) or
              (snake[0].position.x < 0) or (snake[0].position.y < 0)) then
          begin
              gameOver := true;
          end;

          // Collision with yourself
          for i:= 1 to counterTail -1 do // (int i = 1; i < counterTail; i++)
          begin
              if ((snake[0].position.x = snake[i].position.x) and (snake[0].position.y = snake[i].position.y)) then gameOver := true;
          end;

          // Fruit position calculation
          if (not fruit.active) then
          begin
              fruit.active := true;
              fruit.position := Vector2Create( GetRandomValue(0, (screenWidth div SQUARE_SIZE) - 1) *
              SQUARE_SIZE + offset.x / 2, GetRandomValue(0, (screenHeight div SQUARE_SIZE) - 1)*SQUARE_SIZE + offset.y / 2);


            i := 0;
            while i < counterTail -1 do
            begin
             while (fruit.position.x = snake[i].position.x) and (fruit.position.y = snake[i].position.y) do
             begin
               fruit.position := Vector2Create(GetRandomValue(0, (screenWidth div SQUARE_SIZE) - 1)*SQUARE_SIZE + offset.x/2,
               GetRandomValue(0, (screenHeight div SQUARE_SIZE) - 1)*SQUARE_SIZE + offset.y/2 );
               i := 0;
             end;
              inc(i);
            end;
          end;

          // Collision
          if ((snake[0].position.x < (fruit.position.x + fruit.size.x)) and
              ((snake[0].position.x + snake[0].size.x) > fruit.position.x) and
              (snake[0].position.y < (fruit.position.y + fruit.size.y)) and
              ((snake[0].position.y + snake[0].size.y) > fruit.position.y)) then
          begin
              snake[counterTail].position := snakePosition[counterTail - 1];
              counterTail += 1;
              fruit.active := false;
              if counterScore > 5 then Dec(counterScore);
          end;
          inc(framesCounter);
      end;
  end
  else
  begin
      if (IsKeyPressed(KEY_ENTER)) then
      begin
          InitGame();
          gameOver := false;
      end;
  end;
end;

procedure TRayApplication.DrawGame;
var i: integer;
begin
  BeginDrawing();

        ClearBackground(RAYWHITE);

        if ( not gameOver) then
        begin
            // Draw grid lines
            for i :=0 to screenWidth div SQUARE_SIZE + 1 do
             DrawLineV(Vector2Create(SQUARE_SIZE*i + offset.x/2, offset.y/2),
                       Vector2Create(SQUARE_SIZE*i + offset.x/2, screenHeight - offset.y/2), LIGHTGRAY);


            for i := 0 to  screenHeight div SQUARE_SIZE + 1 do
            DrawLineV(Vector2Create(offset.x/2, SQUARE_SIZE*i + offset.y/2),
                      Vector2Create(screenWidth - offset.x/2, SQUARE_SIZE*i + offset.y/2), LIGHTGRAY);


            // Draw snake
            for i := 0 to counterTail -1 do
            DrawRectangleV(snake[i].position, snake[i].size, snake[i].color);

            // Draw fruit to pick
            DrawRectangleV(fruit.position, fruit.size, fruit.color);

            if (pause) then DrawText('GAME PAUSED', screenWidth div 2 - MeasureText('GAME PAUSED', 40) div 2, screenHeight div 2 - 40, 40, GRAY);
        end
        else DrawText('PRESS [ENTER] TO PLAY AGAIN', GetScreenWidth() div 2 - MeasureText('PRESS [ENTER] TO PLAY AGAIN', 20) div 2, GetScreenHeight() div 2 - 50, 20, GRAY);

    EndDrawing();
end;

procedure TRayApplication.UnloadGame;
begin

end;

procedure TRayApplication.UpdateDrawFrame;
begin
   UpdateGame();
    DrawGame();
end;

var
  Application: TRayApplication;
begin
  Application:=TRayApplication.Create(nil);
  Application.Title:=AppTitle;
  Application.Run;
  Application.Free;
end.

