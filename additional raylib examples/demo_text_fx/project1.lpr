program project1;
{$mode objfpc}{$H+}
uses {$IFDEF UNIX}cthreads,{$ENDIF} Classes, SysUtils, CustApp, RayLib, RayMath, Math;

const  screenWidth = 800;  screenHeight = 450; AppTitle = 'raylib - text fx#1';

type
  { TRayApplication }
  TRayApplication = class(TCustomApplication)
  protected
    message : Array[0..9] Of Pchar;
    MyFont: TFont;
    Texture, LogoTexture: TTexture2D;
    Music: TMusic; Shader: TShader;
    line_message :Array of PChar;
    angle, line_angle, xPos, LineXpos, yPos, LineYpos, FreqX, FreqY, AmpX, AmpY, SpeedX, SpeedY, Seconds : Single;
    xStart, yStart, lineXstart, LineYstart, SecondsLoc, FreqXLoc,
    FreqYLoc, AmpXLoc, AmpYLoc, SpeedXLoc, SpeedYLoc, frameCounter, logorotate: Integer;
    ScreenSize: array [0..1] of Single;
    LineColor: TColorB;
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
  end;

var  alpha, logoalpha: byte;
constructor TRayApplication.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);

  InitWindow(800, 450, AppTitle); // for window settings, look at example - window flags
  SetWindowState(FLAG_MSAA_4X_HINT or FLAG_VSYNC_HINT);

  MyFont:= LoadFont('Phased.ttf');
  angle   := 0; xPos := 0; yPos    := 0;  xStart  := 80; yStart  := 40;
  LinexStart  := 800; LineyStart  := 380;  LineXPos := 800;
  message[0] := '                           ';  message[1] := '     GIGATRON AND GUVA     ';
  message[2] := '                           ';  message[3] := '     PRESENTS TEXT FX 1    ';
  message[4] := '                           ';  message[5] := '       160 LINE CODE       ';
  message[6] := ' ------------------------- ';  message[7] := '       RAYLIB RULEZ  !!!   ';
  message[8] := ' ------------------------- ';  message[9] := '                           ';

  SetLength(line_message, 1);
  line_message[0] := TextToUpper('raylib is a simple and easy-to-use library to enjoy videogames programming. Thanks to Ramon Santamarina and the raylib community for a great product');
  // Load texture texture to apply shaders
  Texture := LoadTexture('space.png');
  LogoTexture := LoadTexture('raylib_logo.png');
  // Load shader and setup location points and values
  Shader := LoadShader(nil, 'wave.fs');
  secondsLoc := GetShaderLocation(shader, 'seconds');
  freqXLoc := GetShaderLocation(shader, 'freqX');
  freqYLoc := GetShaderLocation(shader, 'freqY');
  ampXLoc := GetShaderLocation(shader, 'ampX');
  ampYLoc := GetShaderLocation(shader, 'ampY');
  speedXLoc := GetShaderLocation(shader, 'speedX');
  speedYLoc := GetShaderLocation(shader, 'speedY');
  // Shader uniform values that can be updated at any time
  freqX := 25.0;  freqY := 25.0;  ampX := 5.0;  ampY := 5.0;  speedX := 8.0;  speedY := 8.0;
  ScreenSize[0] := GetScreenWidth();  ScreenSize[1] := GetScreenHeight();
  SetShaderValue(shader, GetShaderLocation(shader, 'size'), @screenSize, SHADER_UNIFORM_VEC2);
  SetShaderValue(shader, freqXLoc, @freqX, SHADER_UNIFORM_FLOAT);
  SetShaderValue(shader, freqYLoc, @freqY, SHADER_UNIFORM_FLOAT);
  SetShaderValue(shader, ampXLoc, @ampX, SHADER_UNIFORM_FLOAT);
  SetShaderValue(shader, ampYLoc, @ampY, SHADER_UNIFORM_FLOAT);
  SetShaderValue(shader, speedXLoc, @speedX, SHADER_UNIFORM_FLOAT);
  SetShaderValue(shader, speedYLoc, @speedY, SHADER_UNIFORM_FLOAT);
  Seconds := 0.0;
  SetTargetFPS(60); // Set our game to run at 60 frames-per-second
  InitAudioDevice();                  // Initialize audio device
  Music := LoadMusicStream('gowest.mod');
  Music.looping:=True;
  PlayMusicStream(music);
  SeekMusicStream(music,0.5);
end;

procedure TRayApplication.DoRun;
var i,j,n: integer;
begin
  while (not WindowShouldClose) do // Detect window close button or ESC key
  begin
   // update
   UpdateMusicStream(music);      // Update music buffer with new stream data
   Inc(frameCounter);
   seconds += GetFrameTime();
   SetShaderValue(shader, secondsLoc, @seconds, SHADER_UNIFORM_FLOAT);

   if GetMusicTimePlayed(Music) > 6 then
   if alpha <> 255 then Inc(Alpha);

   if GetMusicTimePlayed(Music) > 18 then
   if LogoAlpha <> 255 then Inc(LogoAlpha);

   if GetMusicTimePlayed(Music) > 38 then
   Inc(logorotate);

   // draw
    BeginDrawing();
    ClearBackground(WHITE);

    BeginShaderMode(Shader);
      DrawTexture(Texture, 0, 0, WHITE);
      DrawTexture(Texture, Texture.Width, 0, WHITE);
    EndShaderMode();

    DrawTextureEx(LogoTexture, Vector2Create(
    ((screenWidth/2.0) + cos((framecounter+80)/301.45) * ( screenWidth / 2.2)),
    ((screenHeight/2.0) + sin((frameCounter+80)/17.87) *( screenHeight/4.2))), logorotate , 0.4, ColorCreate(255,255,255,LogoAlpha));

    for i:=0 to 26 do
    for j:=0 to 9 do
     begin
       angle := angle + 0.0004;
       xPos := (xStart + 2) + 10 * Sin(angle - j * 0.005); // left to right movement
       yPos := (yStart + i * 15) + 4 * Cos(angle - j * 0.004 - i) * 2; // up and down movement
       DrawTextCodepoint(MyFont,Integer(message[j][i]), Vector2Create(i * 24 + xPos,  (j*32 + yPos - i *15 ) + 3), 30, ColorCreate(0,0,0,Alpha));

       case j mod 7 of
         0: LineColor := ColorCreate(0,158,47, alpha) ;
         1: LineColor := ColorCreate(255,109,194,Alpha);
         2: LineColor := ColorCreate(0,121,241,Alpha);
         3: LineColor := ColorCreate(253,249,0,Alpha);
         4: LineColor := ColorCreate(102,191,255,Alpha);
         5: LineColor := ColorCreate(255,161,0,Alpha);
         6: LineColor := ColorCreate(230,41,55,Alpha);
       end;
       DrawTextCodepoint(MyFont,Integer(message[j][i]), Vector2Create(i * 24 + xPos,  (j*32 + yPos - i *15 )), 30, LineColor);
     end;
     if GetMusicTimePlayed(Music) > 24 then
    for  i := 0 to  Length(line_message[0])-1 do
    begin
     line_angle := line_angle + 0.0007;
     if LinexPos < -Length(line_message[0]) * 32  then LinexPos := 800;
     LinexPos := LineXPos - 0.01;
     LineyPos := (LineyStart + i * 15) + 10 * Cos(line_angle - 0 * 0.004 - i) * 2;
     DrawTextCodepoint(MyFont,Integer(line_message[0][i]), Vector2Create(i * 24 + LinexPos,  (0*32 + LineYPos - i *15 ) + 3), 50, Black);
     case i mod 7 of
     0: LineColor := LIME;   1: LineColor := PINK; 2: LineColor := BLUE;   3: LineColor := YELLOW;
     4: LineColor := SKYBLUE; 5: LineColor := ORANGE; 6: LineColor := RED;
     end;
     DrawTextCodepoint(MyFont,Integer(line_message[0][i]), Vector2Create(i * 24 + LinexPos,  (0*32 + LineYPos - i *15 ) ), 50, LineColor);
    end;
    EndDrawing();
  end;
  Terminate;
end;

destructor TRayApplication.Destroy;
begin
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

