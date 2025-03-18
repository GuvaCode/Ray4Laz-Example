program game;

{$mode objfpc}{$H+}

uses 
{uncomment if necessary}
//ray_math, 
//ray_rlgl, 
cmem, raylib, MorphUn, DrawUn, ShapeUn;

type
  { TStar }
  TStar = class
  private
    X: Single;//Integer;
    Y: Single;//Integer;
    StarLayer: Byte;
  public
    procedure Moved(Speed: Integer; Rect: TRectangle);
  end;

  { TStarField }
  TStarField = class
  private
    Stars: array of TStar;
    StarCount: Integer;
    ClientRect: TRectangle;

  public
    constructor Create(StarCnt: Integer; Rect: TRectangle);
    destructor Destroy; override;
    procedure Move(Speed: Integer);
    procedure Render;
  end;



procedure TStar.Moved(Speed: Integer; Rect: TRectangle);
begin
  case StarLayer of
    1: X := X + Speed;
    2: X := X + Speed * 2;
    3: X := X + Speed * 4;
 end;
 if (X > Rect.Width) then
 begin
    X:= Rect.x;
    Y:= Rect.y + Random(Round(Rect.Height));
 end;
end;

constructor TStarField.Create(StarCnt: Integer; Rect: TRectangle);
var
  Loop: Integer;
  Layer: Byte;
begin


  ClientRect := Rect;
  StarCount := StarCnt;
  SetLength(Stars, StarCount);
  Layer := 1;
  for Loop := 0 to StarCount - 1 do begin
    Stars[Loop] := TStar.Create;
    with Stars[Loop] do begin
      StarLayer := Layer;
       X := Random(Round(ClientRect.Width));
       Y := Rect.y + (2 * ClientRect.Height);
       Inc(Layer);
       if Layer > 3 then
         Layer := 1;
     end;
   end;

end;

destructor TStarField.Destroy;
var
  Loop: Integer;
begin
  for Loop := 0 to StarCount - 1 do
    Stars[Loop].Free;
  inherited Destroy;
end;

procedure TStarField.Move(Speed: Integer);
var Loop: Integer;
begin
  for Loop := 0 to StarCount - 1 do Stars[Loop].Moved(Speed, ClientRect);
end;

procedure TStarField.Render;
var Loop: Integer;

begin


 for Loop := 0 to StarCount - 1 do
    DrawPixel(Round(Stars[Loop].X),Round(Stars[Loop].Y),ColorCreate($FF, $FF, $FF, {Random($FF) or $70} 200));
end;



 var Star:TStarField;
     Rect:TRectangle;
     MVS:Integer;
     music:TMusic;
     LogoRec:TRectangle;
     display:integer;
    // const
  screenWidth: integer;// = 800;
  screenHeight: integer;// = 450;

begin
  // Initialization
  //--------------------------------------------------------------------------------------

  SecStart := Round(GetFrameTime);
  InitShape(PCoords1);
  CalcPos;

  InitWindow(GetMonitorWidth(0), GetMonitorHeight(0), 'raylib - morphing');

  screenWidth:=GetMonitorWidth(0) ;
  screenHeight:=GetMonitorHeight(0);

  if not IsWindowFullscreen then ToggleFullscreen;

  InitAudioDevice();                  // Initialize audio device
  music := LoadMusicStream('aws_aq16.xm');
  music.looping := true;
  PlayMusicStream(music);


  WndRect.Top:=0;
  WndRect.Left:=0;
  WndRect.Right:=screenWidth;
  WndRect.Bottom:=screenHeight;

  ScrX := (screenWidth div 2);
  ScrY := (screenHeight div 2);

  CoefX :=ScrX div 6 ;// (WndRect.Right div 8);
  CoefY :=ScrY div 4;// (WndRect.Bottom div 6);

  LastTickCount := GetFrameTime;

  Rect.X := 0;
  Rect.Y := 0;
  Rect.Width := screenWidth;
  Rect.Height := screenHeight - (2 * Rect.Y);


  Star:=TStarField.Create(200,Rect);


  SetTargetFPS(60);// Set our game to run at 60 frames-per-second

  for MVS:=0 to screenWidth+100 do
  Star.Move(1);

  //--------------------------------------------------------------------------------------
  // Main game loop
  while not WindowShouldClose() do
    begin
      // Update
       // check for alt + enter
  if (IsKeyPressed(KEY_ENTER) and (IsKeyDown(KEY_LEFT_ALT) or IsKeyDown(KEY_RIGHT_ALT))) then
            begin
            // see what display we are on right now
            display := GetCurrentMonitor();


            if (IsWindowFullscreen()) then
            begin
                // if we are full screen, then go back to the windowed size
                SetWindowSize(800, 450);
                ToggleFullscreen();
            end
            else
            begin
                // if we are not full screen, set the window size to match the monitor we are on
              //  SetWindowSize(GetMonitorPhysicalWidth(display),GetMonitorPhysicalHeight(display));
              SetWindowSize(GetMonitorWidth(display), GetMonitorHeight(display));
                ToggleFullscreen();
            end;

            // toggle the state

            end;




      UpdateMusicStream(music);      // Update music buffer with new stream data
      Star.Move(1);
      //----------------------------------------------------------------------------------
      // Draw
      //----------------------------------------------------------------------------------
      BeginDrawing();
        ClearBackground(BLACK);
        // LogoRec:=RectangleCreate(screenWidth div 2 - 128, screenHeight div 2 - 128, 256,256);
  LogoRec:=RectangleCreate(screenWidth - 130, screenHeight - 130, 128,128);
  DrawRectangleLinesEx(LogoRec,6, RAYWHITE);
  DrawText('raylib', screenWidth - 95, screenHeight - 60, 30, RAYWHITE);
  DrawText('4.2', screenWidth -37 , screenHeight -35, 20, RAYWHITE);
        //
        Star.Render;
        UpdateDisplay;
        DrawText('music by Victor Vergara', 10, screenHeight-20, 10, RAYWHITE);
        DrawFPS(10,10);
      EndDrawing();
    end;
  // De-Initialization
  //--------------------------------------------------------------------------------------
  UnloadMusicStream(music);  // Unload music stream buffers from RAM
  CloseAudioDevice();       // Close audio device (music streaming is automatically stopped)
  CloseWindow();        // Close window and OpenGL context
  //--------------------------------------------------------------------------------------
end.

