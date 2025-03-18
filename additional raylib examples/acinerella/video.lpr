program video;

{$mode Delphi}{$H+}

uses raylib, rlGl, acinerella, epiktimer, etpackage, Classes, SysUtils;

const
 screenWidth = 800;
 screenHeight = 600;

var
  inst: PAc_instance;
  pack: PAc_package;
  info: TAc_stream_info;
  videodecoder: PAc_decoder;
  i, w, h: integer;
  texture: ttexture2d;
  fs: TFileStream;
  read_cnt: integer;

  oldTime: double;
  curFrame: integer;
  EpikTimer: TEpikTimer;



  function read_proc(sender: Pointer; buf: PChar; size: integer): integer; cdecl;
  begin
    inc(read_cnt);
    result := fs.Read(buf^, size);
  end;

begin
 InitWindow(screenWidth, screenHeight, 'raylib pascal - basic window');
 videodecoder := nil;
  fs := TFileStream.Create('data/orion.mpg', fmOpenRead);
  fs.Position := 0;
  inst := ac_init();
  {$IFDEF FPC}
  inst^.output_format := AC_OUTPUT_RGB24;
  {$ENDIF}

  ac_open(inst, nil,nil, @read_proc, nil, nil, nil);

  Writeln('Count of Datastreams: ', inst^.stream_count);
  Writeln('Length of the file: ', inst^.info.duration);
  Writeln('Title: ', PChar(@(inst^.info.title[0])));
  Writeln('Author: ', PChar(@(inst^.info.author[0])));
  Writeln('Album: ', PChar(@(inst^.info.album[0])));
  Writeln('Genre: ', PChar(@(inst^.info.genre[0])));

  EpikTimer:= TEpikTimer.Create(nil);
  EpikTimer.Clear;
  EpikTimer.StringPrecision:=2;

  EpikTimer.Start;

  for i := 0 to inst^.stream_count - 1 do
  begin
    Writeln;
    ac_get_stream_info(inst, i, @info);
    Writeln('Information about stream ', i, ':');

    case info.stream_type of
    AC_STREAM_TYPE_VIDEO:
      begin
        Writeln('Stream is an video stream.');
        Writeln('--------------------------');
        Writeln;
        Writeln(' * Width             : ', info.additional_info.video_info.frame_width, 'px');
        Writeln(' * Height            : ', info.additional_info.video_info.frame_height, 'px');
        Writeln(' * Pixel aspect      : ', FormatFloat('#.##', info.additional_info.video_info.pixel_aspect));
        Writeln(' * Frames per second : ', FormatFloat('#.##', info.additional_info.video_info.frames_per_second));

        if videodecoder = nil then
        begin
          videodecoder := ac_create_decoder(inst, i);
          h := videodecoder^.stream_info.additional_info.video_info.frame_height;
          w := videodecoder^.stream_info.additional_info.video_info.frame_width;
          Texture.width:=w;
          Texture.height:=h;
          Texture.mipmaps:=1;
          Texture.format:=PIXELFORMAT_UNCOMPRESSED_R8G8B8;
        end;
      end;
     end;
   end;

  if not inst^.opened then
   begin
    Writeln('No video/audio information found. Press return to leave.');
    Readln;
    exit;
   end;

  oldtime := GetTime;
  curFrame:= Round(info.additional_info.video_info.frames_per_second);

while not WindowShouldClose() do
begin
   if GetTime - oldtime * 1000 <= info.additional_info.video_info.frames_per_second  then
    begin
      // if curFrame < curFrame * 1000 then
      // begin
          pack := ac_read_package(inst);
          if (pack <> nil)  then
          if (videodecoder <> nil) and (videodecoder^.stream_index = pack^.stream_index) then
          if (ac_decode_package(pack, videodecoder) > 0) then
          begin
            h := videodecoder^.stream_info.additional_info.video_info.frame_height;
            w := videodecoder^.stream_info.additional_info.video_info.frame_width;
            Texture.id := rlLoadTexture(videodecoder^.buffer, W,H, PIXELFORMAT_UNCOMPRESSED_R8G8B8, 1);
            UpdateTexture(Texture, videodecoder^.buffer);
         end;
           ac_free_package(pack);
           Dec(CurFrame);
       // end else CurFrame := Round(info.additional_info.video_info.frames_per_second);
      end
        else
        begin
          oldtime := Round(GetTime);

        end;





  BeginDrawing();
    ClearBackground(BLACK);
    DrawTexturePro(texture, RectangleCreate(0,0, w, h), RectangleCreate(0,0, GetScreenWidth, GetScreenHeight), Vector2Create(0,0),0, WHITE);
  EndDrawing();
  end;


  if videodecoder <> nil then
  ac_free_decoder(videodecoder);

  ac_close(inst);
  ac_free(inst);
  fs.Free;
  CloseWindow();

end.

