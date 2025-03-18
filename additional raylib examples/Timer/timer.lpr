program timer;

{$mode objfpc}{$H+}

uses
cmem,
raymath,
raylib;

const
  screenWidth = 800;
  screenHeight = 450;

type
  TTimer = record
    Lifetime: single;
  end;
  PTimer = ^TTimer;

  // start or restart a timer with a specific lifetime
  procedure StartTimer(timer:PTimer; lifetime: single);
  begin
    if timer <> nil then  timer^.Lifetime:=lifetime;
  end;

  // update a timer with the current frame time
  procedure UpdateTimer(timer: PTimer);
  begin
    // subtract this frame from the timer if it's not allready expired
    if (timer <> nil) and (timer^.Lifetime > 0) then
        timer^.Lifetime -= GetFrameTime;
  end;

  // check if a timer is done.
  function TimerDone(timer: PTimer): boolean;
  begin
    if timer <> nil then
        result:= timer^.Lifetime <= 0 else
    result:= false;
  end;

var radius,speed,ballLife: single;
    pos,dir: TVector2;
    ballTimer: TTimer;

begin
  // Initialization
  InitWindow(screenWidth, screenHeight, 'Raylib Timer Example');
  SetTargetFPS(60);

  // setup ball info
  radius := 20;
  speed := 400;
  pos := Vector2Create(radius,400);
  dir := Vector2Create(1,0);
  ballLife := 2.2;

  // Main game loop
  while not WindowShouldClose() do
  begin
  // check to see if the user clicked
    if IsMouseButtonPressed(MOUSE_BUTTON_LEFT) then
    begin
      // if they did, move the ball to the current position and restart the timer
      pos := GetMousePosition();
      StartTimer(@ballTimer, ballLife);
    end;

  // tick our timer
  UpdateTimer(@ballTimer);

  // if the timer hasn't expired, move the ball
  if not TimerDone(@ballTimer) then
  begin
  // move the ball based on the speed and the frame time
    pos := Vector2Add(pos, Vector2Scale(dir, GetFrameTime() * speed));
    if pos.x > GetScreenWidth() - radius then // check if we have gone over the right edge, and if so, bounce us
     begin
       pos.x := GetScreenWidth() - radius;
       dir.x := -1;
     end
     else
     if pos.x < radius then  // check if we have gone over the left edge
     begin
       pos.x := radius;
       dir.x := 1;
     end;
  end;

  // drawing
  BeginDrawing();
  ClearBackground(BLACK);

  // draw the ball where it is if the timer is alive
  if not TimerDone(@ballTimer) then
  DrawCircleV(pos, radius, RED);

  EndDrawing;
  end;

  CloseWindow(); // Close window and OpenGL context

end.
