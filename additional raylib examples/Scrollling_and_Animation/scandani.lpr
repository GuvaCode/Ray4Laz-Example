program scandani;

{$mode objfpc}{$H+}

uses
 cthreads,
 Classes, SysUtils, CustApp, raylib;

type
  { TRayApplication }
  TRayApplication = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    LogoAlpha, TextureAlpha: Byte;
    MyFont: TFont;
    FontPosition1, FontPosition2, FontPosition3, FontPosition4: TVector2;
    TextureLayer: array [1..8] of TTexture2D;
    SpeedLayer: array [1..8] of Single;
    Image: TImage;
    Soul: TTexture2D;
    FrameRec: TRectangle;
    CurrentFrame: Integer;
    FramesCounter, FramesSpeed: Single;
    Music: TMusic;
    isScroll: Boolean;
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
  end;

  const AppTitle = 'raylib - basic window';
        msg1: string = 'Welcome to the dark forest.';
        msg2: string = 'Music: Peach of Harmonic';
        msg3: string = 'Graphics: Shiroze and Eddie''s Workshop';
        msg4: string = 'Code: Guvacode';

{ TRayApplication }
constructor TRayApplication.Create(TheOwner: TComponent);
var i: integer;
begin
  inherited Create(TheOwner);

  InitWindow(GetMonitorWidth(GetCurrentMonitor), GetMonitorHeight(GetCurrentMonitor), AppTitle); // for window settings, look at example - window flags
  SetWindowState (FLAG_MSAA_4X_HINT or FLAG_FULLSCREEN_MODE);

  for i := 1 to 8 do
  begin   // Load image and resize to desctop size
  Image := LoadImage(PChar('resources/Starry_night_Layer_'+ inttostr(i) + '.png'));
  ImageResize(@Image, GetScreenWidth, GetScreenHeight);
  TextureLayer[i] := LoadTextureFromImage(Image);
  UnloadImage(Image);
  end;

  Soul := LoadTexture('resources/Soul_move.png');
  FrameRec := RectangleCreate(0.0, 0.0, Soul.Width , Soul.Height / 8);
  CurrentFrame := 0;
  FramesCounter := 0;

  InitAudioDevice(); // Initialize audio device
  Music := LoadMusicStream('resources/forest_walk.xm');
  Music.looping:=True;
  PlayMusicStream(music);

  MyFont := LoadFont('resources/FREAKSOFNATUREMASSIVE.ttf');
  isScroll := false;

end;

procedure TRayApplication.DoRun;
var i: integer; FrameDest: TRectangle;
    TexColor: TColorB;
begin

  while (not WindowShouldClose) do // Detect window close button or ESC key
  begin
    UpdateMusicStream(music);      // Update music buffer with new stream data

    // Update your variables here
    FramesCounter := FramesCounter + 10.0 * GetFrameTime;

    if FramesCounter >= 1.0 then
    begin
      FramesCounter := 0;
      Inc(CurrentFrame);

      if CurrentFrame > 7 then
      CurrentFrame := 0;

      FrameRec.Y := CurrentFrame * Soul.Height / 8;
    end;

    FrameDest := RectangleCreate(TextureLayer[8].width / 2 - 96, TextureLayer[8].height / 2 +  192, 192, 192 );

    if isScroll then
    begin
      SpeedLayer[7] := SpeedLayer[7] - 10.0 * GetFrameTime;
      SpeedLayer[6] := SpeedLayer[6] - 20.0 * GetFrameTime;
      SpeedLayer[5] := SpeedLayer[5] - 30.0 * GetFrameTime;
      SpeedLayer[4] := SpeedLayer[4] - 40.0 * GetFrameTime;
      SpeedLayer[3] := SpeedLayer[3] - 50.0 * GetFrameTime;
      SpeedLayer[2] := SpeedLayer[2] - 60.0 * GetFrameTime;
      SpeedLayer[1] := SpeedLayer[1] - 100.0 * GetFrameTime;
    end;

    for i :=  7 downto 2 do
    if (SpeedLayer[i] <= - TextureLayer[i].width) then SpeedLayer[i] := 0;

    if (SpeedLayer[1] <= - TextureLayer[i].width*3) then SpeedLayer[1] := 0;

   if (GetMusicTimePlayed(Music) > 1) and (GetMusicTimePlayed(Music) < 8) and (LogoAlpha < 255)
   then Inc(LogoAlpha) else
   if LogoAlpha > 0 then Dec(LogoAlpha);

   if (GetMusicTimePlayed(Music) > 1) and (TextureAlpha < 255)
   then Inc(TextureAlpha);

   if (GetMusicTimePlayed(Music) > 8) then isScroll := true;

   texColor := ColorCreate(255,255,255,TextureAlpha);

   FontPosition1 := Vector2Create(GetScreenWidth / 2.0 - MeasureTextEx(MyFont, PChar(Msg1), MyFont.BaseSize, -2.0).X / 2,
                                  GetScreenHeight / 2.0 - MyFont.BaseSize / 2.0 - 80);

   FontPosition2 := Vector2Create(GetScreenWidth / 2.0 - MeasureTextEx(MyFont, PChar(Msg2), MyFont.BaseSize - 10.0, -2.0).X / 2,
                                  GetScreenHeight / 2.0 - MyFont.BaseSize / 2.0 - 20);

   FontPosition3 := Vector2Create(GetScreenWidth / 2.0 - MeasureTextEx(MyFont, PChar(Msg3), MyFont.BaseSize - 10.0, -2.0).X / 2,
                                  GetScreenHeight / 2.0 - MyFont.BaseSize / 2.0 + 20);

   FontPosition4 := Vector2Create(GetScreenWidth / 2.0 - MeasureTextEx(MyFont, PChar(Msg4), MyFont.BaseSize - 10.0, -2.0).X / 2,
                                  GetScreenHeight / 2.0 - MyFont.BaseSize / 2.0 + 60);

     // Draw
    BeginDrawing();
      ClearBackground(DARKGRAY);

      DrawTextureEx(TextureLayer[8], Vector2Create(SpeedLayer[8],0),0.0, 1.0, texColor);

      for i := 6 downto 2 do
      begin
        DrawTextureEx(TextureLayer[i], Vector2Create(SpeedLayer[i],0), 0.0, 1.0, texColor);

        DrawTextureEx(TextureLayer[i], Vector2Create(SpeedLayer[i] + TextureLayer[i].width ,0), 0.0, 1.0, texColor);
      end;

      BeginBlendMode(BLEND_ADDITIVE);
      DrawTexturePro(Soul, FrameRec, FrameDest ,Vector2Create(0,0), 0, WHITE);
      EndBlendMode;

      DrawTextureEx(TextureLayer[1], Vector2Create(SpeedLayer[1],0), 0.0, 1.0, texColor);
      DrawTextureEx(TextureLayer[1], Vector2Create(SpeedLayer[1] + TextureLayer[1].width * 3 ,0), 0.0, 1.0, texColor);


      DrawTextEx(MyFont, PChar(Msg1), FontPosition1, MyFont.BaseSize, 0, ColorCreate(255,255,255,LogoAlpha));
      DrawTextEx(MyFont, PChar(Msg2), FontPosition2, MyFont.BaseSize -10.0, 0, ColorCreate(255,255,255,LogoAlpha));
      DrawTextEx(MyFont, PChar(Msg3), FontPosition3, MyFont.BaseSize -10.0, 0, ColorCreate(255,255,255,LogoAlpha));
      DrawTextEx(MyFont, PChar(Msg4), FontPosition4, MyFont.BaseSize -10.0, 0, ColorCreate(255,255,255,LogoAlpha));

      //DrawFps(10,10);
    EndDrawing();
  end;

  // Stop program loop
  Terminate;
end;

destructor TRayApplication.Destroy;
var i: Integer;
begin
  // De-Initialization
  for i := 1 to 8 do UnloadTexture(TextureLayer[1]);
  UnloadTexture(Soul);

  StopMusicStream(Music);
  UnloadMusicStream(Music);

  CloseWindow(); // Close window and OpenGL context
  inherited Destroy;
end;

var
  Application: TRayApplication;
begin
  Application:=TRayApplication.Create(nil);
  Application.Title:=AppTitle;
  Application.Run;
  Application.Free;
end.

