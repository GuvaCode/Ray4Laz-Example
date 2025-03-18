unit cam_unt;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin,
  ExtCtrls, raylib;

type
   { TMyThread }
   TMyThread = class(TThread)
    private
      cam:TCamera;
      FCamFOVY: Single;
      FCamPosition: TVector3;
      FCamTarget: TVector3;
      FCamUp: TVector3;
      FPosX: longint;
      FPosY: longint;
      fStatusText : string;
      procedure SetPosX(AValue: longint);
      procedure SetPosY(AValue: longint);
      procedure ShowStatus;
    protected
      procedure Execute; override;
    public
      Constructor Create(CreateSuspended : boolean);
      property PosX: longint read FPosX write SetPosX;
      property PosY: longint read FPosY write SetPosY;
      property CamPosition: TVector3 read FCamPosition write FCamPosition;
      property CamTarget: TVector3 read FCamTarget write FCamTarget;
      property CamUp: TVector3 read FCamUp write FCamUp;
      property CamFOVY: Single read FCamFOVY write FCamFOVY;
    end;

  { TcamFrm }
  TcamFrm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    CamPosXSpin: TFloatSpinEdit;
    Edit1: TEdit;
    CamFOVYSpin: TFloatSpinEdit;
    CamPosYSpin: TFloatSpinEdit;
    CamPosZSpin: TFloatSpinEdit;
    camTargetXSpin: TFloatSpinEdit;
    camTargetYSpin: TFloatSpinEdit;
    camTargetZSpin: TFloatSpinEdit;
    camUpXSpin: TFloatSpinEdit;
    camUpYSpin: TFloatSpinEdit;
    camUpZSpin: TFloatSpinEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox7: TGroupBox;
    Label1: TLabel;
    Panel1: TPanel;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure SpinChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private

  public

  end;

var
  camFrm: TcamFrm;
  MyThread : TMyThread;

implementation

{$R *.lfm}

{ TMyThread }

procedure TMyThread.ShowStatus;
begin
   CamFrm.Caption := fStatusText;
end;

procedure TMyThread.SetPosX(AValue: longint);
begin
  if FPosX=AValue then Exit;
  FPosX:=AValue;
end;

procedure TMyThread.SetPosY(AValue: longint);
begin
  if FPosY=AValue then Exit;
  FPosY:=AValue;
end;

procedure TMyThread.Execute;
var
  checked:TImage;
  texture:TTexture2D;
  model:TModel;
 begin
    InitWindow(384, 288, '');
    SetWindowState(FLAG_VSYNC_HINT or FLAG_WINDOW_UNDECORATED);

    // We generate a checked image for texturing
    checked := GenImageChecked(4, 4, 1, 1, RED, GREEN);
    texture := LoadTextureFromImage(checked);
    UnloadImage(checked);
    // Create model from mesh cube
    model := LoadModelFromMesh(GenMeshCube(1.0, 1.0, 1.0));
   // Set checked texture as default diffuse component for all models material
   model.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture := texture;

    SetExitKey(0);
    SetTargetFPS(60);
   //  if IsWindowReady then
    while (not Terminated)  and (not WindowShouldClose) do
      begin
      // update
      cam.position := Vector3Create(FCamPosition.x, FCamPosition.y, FCamPosition.z);
      cam.target := Vector3Create(FCamTarget.x, FCamTarget.y, FCamTarget.z);
      cam.up := Vector3Create(FCamUp.x, FCamUp.y, FCamUp.z);
      cam.fovy := FCamFOVY;
      cam.projection := CAMERA_PERSPECTIVE;

      UpdateCamera(@cam,CAMERA_CUSTOM); // Update camera
      SetWindowPosition(FPosx,FPosY);
      // draw
      BeginDrawing();
       ClearBackground(ColorCreate(17,22,44,255));
        BeginMode3d(cam);
         //DrawModel(dwarf, position, 2.0, WHITE); // Draw 3d model with texture
         DrawModel(model, Vector3Create(0,0,0), 0.5, WHITE);
         DrawGrid(10, 0.5); // Draw a grid
        EndMode3d();
        DrawFPS(4,4);
      EndDrawing();
       end;
    UnloadTexture(texture);
    UnloadModel(model);
    CloseWindow;
  end;


constructor TMyThread.Create(CreateSuspended: boolean);
begin
   inherited Create(CreateSuspended);
    FreeOnTerminate := True;

end;

{ TcamFrm }

procedure TcamFrm.FormCreate(Sender: TObject);
begin
   MyThread := TMyThread.Create(True); // This way it doesn't start automatically
end;

procedure TcamFrm.Timer1Timer(Sender: TObject);
begin
  MyThread.PosX:=camFrm.Left+ camFrm.Width;
  MyThread.PosY:=camFrm.Top;
  if not Focused then SetFocus;
end;

procedure TcamFrm.SpinChange(Sender: TObject);
begin
  MyThread.CamPosition:= Vector3Create(CamPosXSpin.Value,CamPosYSpin.Value,CamPosZSpin.Value);
  MyThread.CamTarget:= Vector3Create(CamTargetXSpin.Value,CamTargetYSpin.Value,CamTargetZSpin.Value);
  MyThread.CamUp:= Vector3Create(CamUpXSpin.Value,CamUpYSpin.Value,CamUpZSpin.Value);
  MyThread.CamFOVY:=CamFOVYSpin.Value;
end;

procedure TcamFrm.Button1Click(Sender: TObject);
begin
  close;
end;

procedure TcamFrm.FormActivate(Sender: TObject);
begin
  MyThread.PosX:=camFrm.Left+ camFrm.Width;
  MyThread.PosY:=camFrm.Top;
  MyThread.CamPosition:= Vector3Create(CamPosXSpin.Value,CamPosYSpin.Value,CamPosZSpin.Value);
  MyThread.CamTarget:= Vector3Create(CamTargetXSpin.Value,CamTargetYSpin.Value,CamTargetZSpin.Value);
  MyThread.CamUp:= Vector3Create(CamUpXSpin.Value,CamUpYSpin.Value,CamUpZSpin.Value);
  MyThread.CamFOVY:=CamFOVYSpin.Value;
  MyThread.Start;
end;


end.

