unit DrawUn;

interface

uses  MorphUn, Types, raylib;

var
  SCX : Single=0; // Относительное смещение начала координат
  SCY : Single=0; // Moving of the beginning of the coordinates center
  SCZ : Single=0; //

  ScrX : Integer=400; // Абсолютные координаты относительного начала координат
  ScrY : Integer=300; // Absolute 2D-coordinates of coordinates center
   
  CoefX : Single; // Коэффициент умножения - перевод относительных
  CoefY : Single; // координат в абсолютные / Multiply coefficient for
                  // counting absolute coordinates
const
  VectX : Single= 0.00093; // Проекции вектора движения центра отсчета
  VectY : Single= 0.00111; // начала координат
  VectZ : Single= 0.00180;
  // Horizontal and vertical projections of the vector of moving 3D-center

  VectAX : Single=0.35; // Поворот (pi) фигуры за 1 секунду
  VectAY : Single=0.25; // Rotation (pi) of the figure per 1 second
  VectAZ : Single=0.00; //

  WaitPer : Integer=1000; // Период превращения фигур
                          // Time of the figure transformation
var
  xa, ya, za : Single; // Углы поворота вокруг начала координат
                       // Rotate angles around the beginning of the coordinates
  LastTickCount : Single;

  PCoords1, PCoords2, Points : TCoords3DArr;

  LastLeft : Integer=0;
  LastTop : Integer=0;
  LastRight : Integer=0;
  LastBottom : Integer=0;

const
  CamZ = 10;        // Положение камеры(точки свода лучей) - (0, 0, CamZ)
                    // Z-coordinate of camera - (X=0, Y=0, Z=CamZ)
  ColorZ0 = 1.732;  // 3^0.5 Координата для расчета цвета точки
                    // 3^0.5 Coordinate for the calculation of
                    // the color of the point
  FogCoef = 62;     // Коэффициент тумана / Fog coefficient

procedure DrawScreen;

implementation

uses ShapeUn;

procedure DrawPoint(Coords2D : TCoords2D; Color : TColor);
var
  Rect : TRect;
begin
  Rect.Left := Coords2d.X;
  Rect.Top  := Coords2d.Y;
  If not Preview then
  begin
    Rect.Right  := Coords2d.X+3;
    Rect.Bottom := Coords2d.Y+3;
  end else
  begin
    Rect.Right  := Coords2d.X+1;
    Rect.Bottom := Coords2d.Y+1;
  end;

  DrawPixel(Rect.Right,Rect.Bottom,BLUE);


  If Rect.Left<LastLeft then LastLeft := Rect.Left;
  If Rect.Right>LastRight then LastRight := Rect.Right;
  If Rect.Top<LastTop then LastTop := Rect.Top;
  If Rect.Bottom>LastBottom then LastBottom := Rect.Bottom;
end;

function GetCoords2D(Coords3D : TCoords3D) : TCoords2D;
// Движок скринсейвера / Screen Saver's engine
var
  ZNorm : Single;
begin
  ZNorm := 1-(Coords3D.Z+SCZ)/CamZ;
  If ZNorm <> 0 then
  begin
    Result.X := Round((Coords3D.X+SCX)/ZNorm*CoefX)+ScrX;
    Result.Y := Round((Coords3D.Y+SCY)/ZNorm*CoefY)+ScrY;
  end;
end;

function Rotate3D(Coords3D : TCoords3D) : TCoords3D;
var
  sina, cosa : Single;
begin
  If xa<>0 then
  begin
    sina := sin(xa);
    cosa := cos(xa);
    Result.X := Coords3D.X;
    Result.Y := Coords3D.Y*cosa-Coords3D.Z*sina;
    Result.Z := Coords3D.Y*sina+Coords3D.Z*cosa;

    Coords3D.X := Result.X;
    Coords3D.Y := Result.Y;
    Coords3D.Z := Result.Z;
  end;
  If ya<>0 then
  begin
    sina := sin(ya);
    cosa := cos(ya);
    Result.X := Coords3D.X*cosa+Coords3D.Z*sina;
    Result.Y := Coords3D.Y;
    Result.Z := -Coords3D.X*sina+Coords3D.Z*cosa;

    Coords3D.X := Result.X;
    Coords3D.Y := Result.Y;
    Coords3D.Z := Result.Z;
  end;
  If za<>0 then
  begin
    sina := sin(za);
    cosa := cos(za);
    Result.X := Coords3D.X*cosa-Coords3D.Y*sina;
    Result.Y := Coords3D.X*sina+Coords3D.Y*cosa;
    Result.Z := Coords3D.Z;

    Coords3D.X := Result.X;
    Coords3D.Y := Result.Y;
    Coords3D.Z := Result.Z;
  end;

  Result.X := Coords3D.X;
  Result.Y := Coords3D.Y;
  Result.Z := Coords3D.Z;
end;

function GetColor(Coords3D : TCoords3D) : TColor;
var
  Len : Single;
  R, G, B, Gr : Integer;
begin
  Len := sqrt(sqr(Coords3D.X-0)+sqr(Coords3D.Y-0)+
    sqr(Coords3D.Z-ColorZ0));
  Gr := Trunc(255-Len*FogCoef);
  If Gr<0 then Gr := 0;   

  R := Random(Gr);
  G := Random(Gr);
  B := Random(Gr);

  Result :=ColorCreate(R,G,B,255);
  // Перевод RGB в оттенок серого  // Translation RGB to the hue of gray
end;

procedure DrawScreen; // прорисовка экрана / procedure of screen drawing
var
  n : Integer;
  Point : TCoords3D;
  Color : TColor;
  TimeDelta : Single;
const
  MinTimeDelta = 10;
  MaxTimeDelta = 200;
begin
  TimeDelta := GetFrameTime-LastTickCount;

  If TimeDelta>MaxTimeDelta then TimeDelta := MaxTimeDelta;
  If TimeDelta<MinTimeDelta then TimeDelta := MinTimeDelta;

  LastTickCount := GetFrameTime;

  If Wait>0 then Wait := (Wait-(TimeDelta)) else
  begin
    If DoUp then
    begin
      Percent := (Percent + (TimeDelta/10));
      If Percent >= 100 then
      begin
        Percent := 100;

        DoUp := False;
        Wait := WaitPer;
        InitShape(PCoords1);
      end;
    end else
    begin
      Percent := (Percent - (TimeDelta/10));
      If Percent <= 0 then
      begin
        Percent := 0;

        DoUp := True;
        Wait := WaitPer;
        InitShape(PCoords2);
      end;
    end;
    CalcPos;
  end;

  xa := xa+TimeDelta*pi*VectAX/1000;
  ya := ya+TimeDelta*pi*VectAY/1000;
  za := za-TimeDelta*pi*VectAZ/1000;

  SCX := SCX+VectX*TimeDelta;
  If (SCX>3.5-SCZ/2.5) or ((SCX>2.75) and (not Move3D)) then
  begin
    VectX := -abs(VectX);
    VectAY := -abs(Random/3+0.25);
  end;
  If (SCX<-3.5+SCZ/2.5) or ((SCX<-2.75) and (not Move3D)) then
  begin
    VectX := abs(VectX);
    VectAY := abs(Random/3+0.25);
  end;

  SCY := SCY+VectY*TimeDelta;
  If (SCY>3-SCZ/3) or ((SCY>1.8) and (not Move3D)) then
  begin
    VectY := -abs(VectY);
    VectAX := -abs(Random/3+0.25);
  end;
  If (SCY<-3+SCZ/3) or ((SCY<-1.8) and (not Move3D)) then
  begin
    VectY := abs(VectY);
    VectAX := abs(Random/3+0.25);
  end;

  If Move3D then
  begin
    SCZ := SCZ+VectZ*TimeDelta;
    If (SCZ>4) then
    begin
      VectZ := -abs(VectZ);
      VectAX := -abs(Random/3+0.25);
      VectAY := -abs(Random/3+0.25);
    end;
    If (SCZ<-10) then
    begin
      VectZ := abs(VectZ);
      VectAX := abs(Random/3+0.25);
      VectAY := abs(Random/3+0.25);
    end;
  end;

  for n := 0 to PointsCount-1 do
  begin
    Point := Rotate3D(Points[n]);
    Color := GetColor(Point);
    DrawPoint(GetCoords2D(Point), Color);

  end;
end;

end.
