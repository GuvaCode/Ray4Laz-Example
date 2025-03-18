program happynewyear;

{$mode objfpc}{$H+}

uses
 cthreads,
 Classes, SysUtils, CustApp, raylib, math;

type

  // TSnowflake - структура снежинки
  TSnowflake = record
    X: Single;// координата X
    Y: Single;// координата Y
    Speed: Single;// скорость падения
    Size: Single;// размер
    Time: Single;// локальное время
    TimeDelta: Single;// дельта изменения времени
    Rotation: Single;
  end;

  { TRayApplication }
  TRayApplication = class(TCustomApplication)
  protected
    LogoPositionX: Integer;
    LogoPositionY: Integer;
    FramesCounter: Integer;
    LettersCount: Integer;
    TopSideRecWidth: Integer;
    LeftSideRecHeight: Integer;
    BottomSideRecWidth: Integer;
    RightSideRecHeight: Integer;
    State: Integer;
    Alpha: Single;
    TextureAlpha: Single;
    SnowAlpha: Single;
    FontAlpha: Single;
    message : Array[0..2] Of Pchar;
    Music: TMusic;
    BgTexture: TTexture2D;
    Snowflake: TTExture2D;
    TextureLayer: array [1..7] of TTexture2D;
    SpeedLayer: array [1..7] of Single;
    MyFont: TFont;
    angle: single;
    xPos, yPos, xStart, yStart: single;
    line_message :Array of PChar;
    line_angle, LineXpos, LineYpos, LineStart: single;
    LineColor: TColorB;

    procedure DoRun; override;
  public
    Snow: array [0..600 - 1] of TSnowflake;
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    function MakeSnowflake: TSnowflake;
    procedure SnowUpdate;
    procedure SnowDraw(aSnowAlpha: Single);
  end;

  const AppTitle = 'raylib - happy new year !!!';
        screenWidth = 1440;
        screenHeight = 900;


{ TRayApplication }

constructor TRayApplication.Create(TheOwner: TComponent);
var i: integer;
begin
  inherited Create(TheOwner);

  InitWindow(screenWidth, screenHeight, AppTitle); // for window settings, look at example - window flags

  SetWindowState(FLAG_VSYNC_HINT or FLAG_FULLSCREEN_MODE);

  if ChangeDirectory(PChar(GetApplicationDirectory + 'resources')) then
  TraceLog(LOG_INFO, GetWorkingDirectory); // change to work dir

  LogoPositionX := ScreenWidth div 2 - 128;
  LogoPositionY := ScreenHeight div 2 - 128;

  FramesCounter := 0;
  LettersCount := 0;

  TopSideRecWidth := 16;
  LeftSideRecHeight := 16;

  BottomSideRecWidth := 16;
  RightSideRecHeight := 16;

  State := 0; // Tracking animation states (State Machine)
  Alpha := 1.0; // Useful for fading

  TexTureAlpha := 0.0;
  SnowAlpha := 0.0;

  InitAudioDevice(); // Initialize audio device

  Music := LoadMusicStream(PChar(GetWorkingDirectory +  PathDelim + 'jinglebells.xm'));

  PlayMusicStream(music);

  //BgTexture := LoadTexture(PChar(GetWorkingDirectory + PathDelim + 'snowforest.png'));
  TextureLayer[1] := LoadTexture(PChar(GetWorkingDirectory + PathDelim + 'Sky.png'));
  TextureLayer[2] := LoadTexture(PChar(GetWorkingDirectory + PathDelim + 'Moon.png'));
  TextureLayer[3] := LoadTexture(PChar(GetWorkingDirectory + PathDelim + 'BG.png'));
  TextureLayer[4] := LoadTexture(PChar(GetWorkingDirectory + PathDelim + 'Middle.png'));
  TextureLayer[5] := LoadTexture(PChar(GetWorkingDirectory + PathDelim + 'Foreground.png'));
  TextureLayer[6] := LoadTexture(PChar(GetWorkingDirectory + PathDelim + 'Ground_01.png'));
  TextureLayer[7] := LoadTexture(PChar(GetWorkingDirectory + PathDelim + 'Ground_02.png'));

  Snowflake := LoadTexture(PChar(GetWorkingDirectory + PathDelim + 'snowflake.png'));

  for I := 0 to High(Snow) do
    Snow[I] := MakeSnowflake;

  message[0] := '      MERRY CHRISTMAS      ';
  message[1] := '            AND            ';
  message[2] := '       HAPPY NEW YEAR      ';

  angle   := 0;
  xPos    := 0;
  yPos    := 0;
  xStart  := 280;
  yStart  := 800;
  MyFont:= LoadFont(PChar(GetWorkingDirectory + PathDelim + 'beear1.png'));
  FontAlpha:= 0.0;
  SetLength(line_message, 1);
  line_message[0] := TextToUpper('raylib is a simple and easy-to-use library to enjoy videogames programming. Thanks to Ramon Santamarina and the raylib community for a great product');

  SetTargetFPS(60); // Set our game to run at 60 frames-per-second
end;

procedure TRayApplication.DoRun;
var i, j: integer;
begin

  while (not WindowShouldClose) do // Detect window close button or ESC key
  begin
    // Update your variables here
    UpdateMusicStream(music); // Update music buffer with new stream data

    SnowUpdate;

    if State = 0 then // State 0: Small box blinking
    begin
      Inc(FramesCounter);

      if FramesCounter = 120 then
      begin
        State := 1;
        FramesCounter := 0; // Reset counter... will be used later...
      end;

       TexTureAlpha := TexTureAlpha + 0.01;

      if TexTureAlpha >= 1.0 then
      begin
         TexTureAlpha := 1.0;
      end;
    end
    else if State = 1 then // State 1: Top and left bars growing
    begin
      Inc(TopSideRecWidth, 4);
      Inc(LeftSideRecHeight, 4);

      if TopSideRecWidth = 256 then
        State := 2;
    end
    else if State = 2 then // State 2: Bottom and right bars growing
    begin
      Inc(BottomSideRecWidth, 4);
      Inc(RightSideRecHeight, 4);
      Inc(FramesCounter, 8);

      if FramesCounter div 22 <> 0 then // Every 12 frames, one more letter!
      begin
        Inc(LettersCount);
        FramesCounter := 0;
      end;

      if BottomSideRecWidth = 256 then
      begin
        LettersCount := 0;
        State := 3;
      end;

    end
    else if State = 3 then // State 3: Letters appearing (one by one)
    begin
      Inc(FramesCounter);

      if FramesCounter div 12 <> 0 then // Every 12 frames, one more letter!
      begin
        Inc(LettersCount);
        FramesCounter := 0;
      end;


      if LettersCount >= 15 then // When all letters have appeared, just fade out everything
      begin
        Alpha := Alpha - 0.005;

        if Alpha <= 0.0 then
        begin
          Alpha := 0.0;
          State := 4;
          FramesCounter :=0;
          LinexPos := ScreenWidth + 100;
          LineYPos := ScreenHeight - 60;
        end;

        SnowAlpha := SnowAlpha + 0.02;

      if SnowAlpha >= 1.0 then
      begin
        SnowAlpha := 1.0;
      end;
      end;
    end
    else if State = 4 then // State 4: Reset and Replay
    begin
     Inc(FramesCounter);

    if FramesCounter div 12 <> 0 then // Every 12 frames, one more letter!
      begin
        FontAlpha := FontAlpha + 0.01;
        FramesCounter := 0;
      end;


      if SnowAlpha >= 1.0 then
      begin
         SnowAlpha := 1.0;
      end;


      If YStart > 100 then
      YStart := YStart - 0.5;

      //if isScroll then
      //begin
        SpeedLayer[7] := SpeedLayer[7] - 50.0 * GetFrameTime;
        SpeedLayer[6] := SpeedLayer[6] - 40.0 * GetFrameTime;
        SpeedLayer[5] := SpeedLayer[5] - 30.0 * GetFrameTime;
        SpeedLayer[4] := SpeedLayer[4] - 20.0 * GetFrameTime;
        SpeedLayer[3] := SpeedLayer[3] - 10.0 * GetFrameTime;
      //  SpeedLayer[2] := SpeedLayer[2] - 60.0 * GetFrameTime;
      //  SpeedLayer[1] := SpeedLayer[1] - 100.0 * GetFrameTime;
      //end;

       for i :=3 to 7 do
       if (SpeedLayer[i] <= - SCreenwidth) then SpeedLayer[i] := 0;

    end;

    // Draw
    BeginDrawing();

    ClearBackground(RAYWHITE);




     //Draw Sky
     DrawTexturePro(Self.TextureLayer[1], RectangleCreate(0,0, TextureLayer[1].width, TextureLayer[1].height),
                                          RectangleCreate(0,0, ScreenWidth, ScreenHeight),
                                          Vector2Create(0,0), 0, Fade(WHITE, TextureAlpha));

     DrawTexturePro(Self.TextureLayer[2], RectangleCreate(0,0, TextureLayer[2].width, TextureLayer[2].height),
                                          RectangleCreate(0,0, ScreenWidth, ScreenHeight),
                                          Vector2Create(0,0), 0, Fade(WHITE, TextureAlpha));




      for i := 3 to 7 do
      begin
        DrawTexturePro(Self.TextureLayer[i], RectangleCreate(0,0, TextureLayer[i].width, TextureLayer[i].height),
                                              RectangleCreate(0,0, ScreenWidth, ScreenHeight),
                                              Vector2Create(SpeedLayer[i],0), 0, Fade(WHITE, TextureAlpha));

        DrawTexturePro(Self.TextureLayer[i], RectangleCreate(0,0, TextureLayer[i].width, TextureLayer[i].height),
                                              RectangleCreate(0,0, ScreenWidth, ScreenHeight),
                                              Vector2Create(SpeedLayer[i] + ScreenWidth,0), 0, Fade(WHITE, TextureAlpha));
      end;

    SnowDraw(SnowAlpha);

    if State = 0 then
    begin
      if (framesCounter div 15) mod 2 <> 0 then
        DrawRectangle(LogoPositionX, LogoPositionY, 16, 16, BLACK);
    end
    else if State = 1 then
    begin
      DrawRectangle(LogoPositionX, LogoPositionY, TopSideRecWidth, 16, BLACK);
      DrawRectangle(LogoPositionX, LogoPositionY, 16, LeftSideRecHeight, BLACK);

    end
    else if State = 2 then
    begin
      DrawRectangle(LogoPositionX, LogoPositionY, TopSideRecWidth, 16, BLACK);
      DrawRectangle(LogoPositionX, LogoPositionY, 16, LeftSideRecHeight, BLACK);

      DrawRectangle(LogoPositionX + 240, LogoPositionY, 16, RightSideRecHeight, BLACK);
      DrawRectangle(LogoPositionX, LogoPositionY + 240, BottomSideRecWidth, 16, BLACK);

      DrawText(TextSubtext('powered by', 0, LettersCount ), GetScreenWidth() div 2 - 100, GetScreenHeight() div 2 - 98, 20, Fade(BLACK, Alpha));

    end
    else if State = 3 then
    begin
      DrawRectangle(LogoPositionX, LogoPositionY, TopSideRecWidth, 16, Fade(BLACK, Alpha));
      DrawRectangle(LogoPositionX, LogoPositionY + 16, 16, LeftSideRecHeight - 32, Fade(BLACK, Alpha));

      DrawRectangle(LogoPositionX + 240, LogoPositionY + 16, 16, RightSideRecHeight - 32, Fade(BLACK, Alpha));
      DrawRectangle(LogoPositionX, LogoPositionY + 240, BottomSideRecWidth, 16, Fade(BLACK, Alpha));



      //DrawRectangle(GetScreenWidth() div 2 - 112, GetScreenHeight() div 2 - 112, 224, 224, Fade(RAYWHITE, Alpha));

      DrawText('powered by', GetScreenWidth() div 2 - 100, GetScreenHeight() div 2 - 98, 20, Fade(BLACK, Alpha));

      DrawText(TextSubtext('raylib', 0, LettersCount), GetScreenWidth() div 2 - 44, GetScreenHeight() div 2 + 48, 50, Fade(BLACK, Alpha));

    end
    else if State = 4 then
    begin
    SetTextureFilter(MyFont.texture, TEXTURE_FILTER_BILINEAR);

    for i:=0 to 26 do
    for j:=0 to 2 do
     begin
       angle := angle + 0.001;
       // left to right movement
       xPos := (xStart + 2) + 10 * Sin(angle - j * 0.004) ;
       // up and down movement
       yPos := (yStart + i * 15) + 4 * Cos(angle - j * 0.004 - i) * 2;

     case i mod 7 of
       0: LineColor := LIME;
       1: LineColor := PINK;
       2: LineColor := BLUE;
       3: LineColor := YELLOW;
       4: LineColor := SKYBLUE;
       5: LineColor := ORANGE;
       6: LineColor := RED;
     end;

       if message[j][i] = 'I' then
       DrawTextCodepoint(MyFont,Integer(message[j][i]), Vector2Create(i * 35 + xPos+ 4,  (j*60 + yPos - i *15 )  ), MyFont.baseSize, Fade(LineColor, FontAlpha))
       else
       DrawTextCodepoint(MyFont,Integer(message[j][i]), Vector2Create(i * 35 + xPos,  (j*60 + yPos - i *15 )  ), MyFont.baseSize, Fade(LineColor, FontAlpha));
     end;

   for  i := 0 to  Length(line_message[0])-1 do
    begin
     line_angle := line_angle + 0.0007;
     if LinexPos < -Length(line_message[0]) * 32  then LinexPos := ScreenWidth;
     LinexPos := LineXPos - 0.01;
     LineyPos := 800 + (LineStart + i * 15) + 10 * Cos(line_angle - 0 * 0.004 - i) * 2;

    // DrawTextCodepoint(MyFont,Integer(line_message[0][i]), Vector2Create(i * 24 + LinexPos,  (0*32 + LineYPos - i *15 ) + 3), 50, Black);

     case i mod 7 of
     0: LineColor := LIME;   1: LineColor := PINK; 2: LineColor := BLUE;   3: LineColor := YELLOW;
     4: LineColor := SKYBLUE; 5: LineColor := ORANGE; 6: LineColor := RED;
     end;

     if line_message[0][i] = 'I' then
      DrawTextCodepoint(MyFont,Integer(line_message[0][i]), Vector2Create(i * 24 + LinexPos + 4,  (0*32 + LineYPos - i *15 ) ), 50, Fade(LineColor, FontAlpha))
      else
     DrawTextCodepoint(MyFont,Integer(line_message[0][i]), Vector2Create(i * 24 + LinexPos,  (0*32 + LineYPos - i *15 ) ), 50, Fade(LineColor, FontAlpha));
    end;



    end;




   // DrawFps(10,10);
    EndDrawing();
  end;

  // Stop program loop
  Terminate;
end;

destructor TRayApplication.Destroy;
begin
  // De-Initialization
  CloseWindow(); // Close window and OpenGL context

  // Show trace log messages (LOG_DEBUG, LOG_INFO, LOG_WARNING, LOG_ERROR...)
  TraceLog(LOG_INFO, 'your first window is close and destroy');

  inherited Destroy;
end;
      function RandomBetween(a, b: Double): Double;
    begin
      Result := a + Random * (b - a);
    end;
function TRayApplication.MakeSnowflake: TSnowflake;
const
  MaxSpeed = 5;
  MaxSize = 0.1;
  Bounds = 30;
  MaxTimeDelta =  0.0015;
begin
  // задаем случайную координату по X
  Result.X := RandomRange(-Bounds, ScreenWidth + Bounds);
  // обнуляем Y
  Result.Y := -MaxSize;
  // задаем случайную скорость падения
  Result.Speed := 0.5 + Random * MaxSpeed;
  // задаем случайный размер
  Result.Size := RandomBetween(0.01, MaxSize);
  // задем время
  Result.Time := Random * 2 * Pi;
  // задаем величину приращивания времени
  Result.TimeDelta := Random * MaxTimeDelta;
end;

procedure TRayApplication.SnowUpdate;
var
  I: Integer;
begin
  for I := 0 to High(Snow) do
  begin
    // приращиваем координату по Y
    Snow[I].Y := Snow[I].Y + Snow[I].Speed;
    // увеличиваем время
    Snow[I].Time := Snow[I].Time + Snow[I].TimeDelta;
    // пересоздаем снежинку, если она упала за границы формы
    if Snow[I].Y > ScreenHeight then
      Snow[I] := MakeSnowflake;
    Snow[I].Rotation:=Snow[I].Rotation+ 0.2;
  end;

end;

procedure TRayApplication.SnowDraw(aSnowAlpha: Single);
var
  I: Integer;
  T, DeltaX: Single;
  Size, X, Y: Single;
  Rot: Single;
begin
  for I := 0 to High(Snow) do
  begin
    // получаем размер
    Size := Snow[I].Size;
    T := Snow[I].Time;

    // вычисляем смещение
    DeltaX := Sin(T * 27) + Sin(T * 21.3) + 3 * Sin(T * 18.75) +
    7 * Sin(T * 7.6) + 10 * Sin(T * 5.23);

    DeltaX := DeltaX * 10;

    // получаем X
    X := Trunc(Snow[I].X + DeltaX);
    // получаем Y
    Y := Trunc(Snow[I].Y);

    Rot := Snow[I].Rotation;
    // рисуем круг по координатам X, Y, с диаметром Size
   // DrawCircle(X, Y, Size, Fade(WHITE, aSnowAlpha));
    DrawTextureEx(SnowFlake, Vector2Create(X,Y), Rot , Size, Fade(WHITE, aSnowAlpha));
  end;


end;

var
  Application: TRayApplication;
begin
  Application:=TRayApplication.Create(nil);
  Application.Title:=AppTitle;
  Application.Run;
  Application.Free;
end.

