unit ShapeUn;

interface

uses MorphUn;

type
  TShapes=(shTriangle1, shTriangle2, shTriangle3, shCube, shPyramideTri, shOct,
    shIco, shSphere1, shSphere2, shEgg, shDodecaedr, shPyramideCut, shCubeCut,
    shHeadAcke, shTor, shSpiral, shCube2);
const
  shCount=17;
  ShapesArr : array[0..shCount-1] of TShapes=
    (shTriangle1, shTriangle2, shTriangle3, shCube, shPyramideTri, shOct, shIco,
     shSphere1, shSphere2, shEgg, shDodecaedr, shPyramideCut, shCubeCut,  shHeadAcke,
     shTor, shSpiral, shCube2);
var
  ShapesSet : set of TShapes = [];
  ShapeInd  : Integer;

procedure InitShape(var CoordsArr : TCoords3DArr);
procedure CalcPos;

implementation

uses DrawUn;

procedure InitTriangle1(var CoordsArr : TCoords3DArr);
var
  n : Integer;
  ang, z : Single;
begin
  // кривая 1/ curve 1
  For n := 0 to (PointsCount div 3) do
  begin
    ang := n/PointsCount* 3 *pi*2; // pi*2 - полная окружность / full round
                                   // n/PointsCount - % круга / of then round
                                   // *_* - сколько точек за раз (div _) /
                                   // how much points at one time

    z := sin(2*ang);
    begin
      AddPoint(CoordsArr, XYZ(sin(ang), cos(ang), z));
      AddPoint(CoordsArr, XYZ(cos(ang), z, sin(ang)));
      AddPoint(CoordsArr, XYZ(z, sin(ang), cos(ang)));
    end;
  end;
end;

procedure InitTriangle2(var CoordsArr : TCoords3DArr);
var
  n : Integer;
  ang, z : Single;
begin
  // кривая 2 / curve 2
  For n := 0 to (PointsCount div 2) do
  begin
    ang := n/PointsCount* 2 *pi*2; // pi*2 - полная окружность / full round
                                   // n/PointsCount - % круга / of then round
                                   // *_* - сколько точек за раз (div _) /
                                   // how much points at one time

    z := sin(2*ang); // Очень круто ! / Very cool !
    begin
      AddPoint(CoordsArr, XYZ(sin(ang)*sqrt(1-z), cos(ang)*sqrt(1+z), z));
      AddPoint(CoordsArr, XYZ(sin(ang+pi/2)*sqrt(1-z), cos(ang+pi/2)*sqrt(1+z), z));
    end;
  end;
end;

procedure InitTriangle3(var CoordsArr : TCoords3DArr);
var
  n : Integer;
  ang, z : Single;
begin
  // кривая 3 / curve 3
  For n := 0 to (PointsCount div 2) do
  begin
    ang := n/PointsCount* 4 *pi*2; // pi*2 - полная окружность / full round
                                   // n/PointsCount - % круга / of then round
                                   // *_* - сколько точек за раз (div _) /
                                   // how much points at one time

    z := sin(2*ang); // Очень круто ! / Very cool !
    begin
      AddPoint(CoordsArr, XYZ(sin(ang)*sqrt(1-z), cos(ang)*sqrt(1+z), z));
      AddPoint(CoordsArr, XYZ(sin(ang+pi/2)*sqrt(1-z), cos(ang+pi/2)*sqrt(1+z), z));
      AddPoint(CoordsArr, XYZ(sin(ang)*sqrt(1+z), cos(ang)*sqrt(1-z), z));
      AddPoint(CoordsArr, XYZ(sin(ang+pi/2)*sqrt(1+z), cos(ang+pi/2)*sqrt(1-z), z));
    end;
  end;
end;

procedure InitPyramideTri(var CoordsArr : TCoords3dArr);
begin
  // тетраэдр / tetraedr
  AddPoint(CoordsArr, XYZ(1, 1, 1));    // 1
  AddPoint(CoordsArr, XYZ(-1,  -1, 1)); // 2
  AddPoint(CoordsArr, XYZ(1,  -1, -1)); // 3
  AddPoint(CoordsArr, XYZ(-1, 1, -1));  // 4

  AddPoint(CoordsArr, XYZ(1, 1, 1));    // 1
  AddPoint(CoordsArr, XYZ(-1,  -1, 1)); // 2
  AddPoint(CoordsArr, XYZ(1,  -1, -1)); // 3
  AddPoint(CoordsArr, XYZ(-1, 1, -1));  // 4

  AddPointsBetween(CoordsArr, 0, 1, 32);
  AddPointsBetween(CoordsArr, 1, 2, 32);
  AddPointsBetween(CoordsArr, 2, 3, 32);
  AddPointsBetween(CoordsArr, 0, 2, 32);
  AddPointsBetween(CoordsArr, 0, 3, 32);
  AddPointsBetween(CoordsArr, 1, 3, 32);
end;

procedure InitCube(var CoordsArr : TCoords3DArr);
begin
  // гексаэдр, куб / cube
  AddPoint(CoordsArr, XYZ( 1,  1,  1)); // 0
  AddPoint(CoordsArr, XYZ(-1,  1,  1)); // 1
  AddPoint(CoordsArr, XYZ( 1, -1,  1)); // 2
  AddPoint(CoordsArr, XYZ( 1,  1, -1)); // 3
  AddPoint(CoordsArr, XYZ(-1, -1,  1)); // 4
  AddPoint(CoordsArr, XYZ( 1, -1, -1)); // 5
  AddPoint(CoordsArr, XYZ(-1,  1, -1)); // 6
  AddPoint(CoordsArr, XYZ(-1, -1, -1)); // 7

  AddPointsBetween(CoordsArr, 0, 1, 16);
  AddPointsBetween(CoordsArr, 0, 2, 16);
  AddPointsBetween(CoordsArr, 0, 3, 16);
  AddPointsBetween(CoordsArr, 1, 4, 16);
  AddPointsBetween(CoordsArr, 1, 6, 16);
  AddPointsBetween(CoordsArr, 2, 4, 16);
  AddPointsBetween(CoordsArr, 2, 5, 16);
  AddPointsBetween(CoordsArr, 3, 5, 16);
  AddPointsBetween(CoordsArr, 3, 6, 16);
  AddPointsBetween(CoordsArr, 4, 7, 16);
  AddPointsBetween(CoordsArr, 5, 7, 16);
  AddPointsBetween(CoordsArr, 6, 7, 16);
end;

procedure InitCube2(var CoordsArr : TCoords3DArr);
var
  i : Integer;
  ang : Single;
begin
  // Игральный кубик / Play cube
  For i := 0 to 15 do
  begin
    ang := i/16*2*pi;

    AddPoint(CoordsArr, XYZ(1, 0.75*cos(ang), 0.75*sin(ang)));
    AddPoint(CoordsArr, XYZ(-1, 0.75*cos(ang), 0.75*sin(ang)));

    AddPoint(CoordsArr, XYZ(0.75*cos(ang), 1, 0.75*sin(ang)));
    AddPoint(CoordsArr, XYZ(0.75*cos(ang), -1, 0.75*sin(ang)));

    AddPoint(CoordsArr, XYZ(0.75*cos(ang), 0.75*sin(ang), 1));
    AddPoint(CoordsArr, XYZ(0.75*cos(ang), 0.75*sin(ang), -1));
  end;

  For i := 0 to 11 do
  begin
    ang := i/12*2*pi;

    AddPoint(CoordsArr, XYZ(0.875, 0.875*cos(ang), 0.875*sin(ang)));
    AddPoint(CoordsArr, XYZ(-0.875, 0.875*cos(ang), 0.875*sin(ang)));

    AddPoint(CoordsArr, XYZ(0.875*cos(ang), 0.875, 0.875*sin(ang)));
    AddPoint(CoordsArr, XYZ(0.875*cos(ang), -0.875, 0.875*sin(ang)));

    AddPoint(CoordsArr, XYZ(0.875*cos(ang), 0.875*sin(ang), 0.875)); // 7/8
    AddPoint(CoordsArr, XYZ(0.875*cos(ang), 0.875*sin(ang), -0.875));
  end;

  AddPoint(CoordsArr, XYZ(0.725, 0.725, 0.725));
  AddPoint(CoordsArr, XYZ(-0.725, 0.725, 0.725));
  AddPoint(CoordsArr, XYZ(0.725, -0.725, 0.725));
  AddPoint(CoordsArr, XYZ(0.725, 0.725, -0.725));
  AddPoint(CoordsArr, XYZ(-0.725, -0.725, 0.725));
  AddPoint(CoordsArr, XYZ(0.725, -0.725, -0.725));
  AddPoint(CoordsArr, XYZ(-0.725, 0.725, -0.725));
  AddPoint(CoordsArr, XYZ(-0.725, -0.725, -0.725));

  AddPoint(CoordsArr, XYZ(0, 0, 1));

  AddPoint(CoordsArr, XYZ(0.25, 1, 0.25));
  AddPoint(CoordsArr, XYZ(-0.25, 1, -0.25));

  AddPoint(CoordsArr, XYZ(-1, -0.25, 0.25));
  AddPoint(CoordsArr, XYZ(-1, 0, 0));
  AddPoint(CoordsArr, XYZ(-1, 0.25, -0.25));

  AddPoint(CoordsArr, XYZ(0.25, 0.25, -1));
  AddPoint(CoordsArr, XYZ(-0.25, 0.25, -1));
  AddPoint(CoordsArr, XYZ(0.25, -0.25, -1));
  AddPoint(CoordsArr, XYZ(-0.25, -0.25, -1));

  AddPoint(CoordsArr, XYZ(1, 0.25, 0.25));
  AddPoint(CoordsArr, XYZ(1, -0.25, 0.25));
  AddPoint(CoordsArr, XYZ(1, 0.25, -0.25));
  AddPoint(CoordsArr, XYZ(1, -0.25, -0.25));
  AddPoint(CoordsArr, XYZ(1, 0, 0));

  AddPoint(CoordsArr, XYZ(0, -1, 0.4));
  AddPoint(CoordsArr, XYZ(-0.2, -1, 0.2));
  AddPoint(CoordsArr, XYZ(-0.4, -1, 0));
  AddPoint(CoordsArr, XYZ(0.4, -1, 0));
  AddPoint(CoordsArr, XYZ(0.2, -1, -0.2));
  AddPoint(CoordsArr, XYZ(0, -1, -0.4));

  For i := 0 to 2 do DupPoint(CoordsArr, i);
end;

procedure InitOctaedr(var CoordsArr : TCoords3dArr);
begin
  // октаэдр / octaedr
  AddPoint(CoordsArr, XYZ(0,  0,  1)); // 2
  AddPoint(CoordsArr, XYZ(1,  0,  0)); // 0
  AddPoint(CoordsArr, XYZ(0,  1,  0)); // 1
  AddPoint(CoordsArr, XYZ(-1, 0,  0)); // 3
  AddPoint(CoordsArr, XYZ(0, -1,  0)); // 4
  AddPoint(CoordsArr, XYZ(0,  0, -1)); // 5

  AddPoint(CoordsArr, XYZ(0, 0, 1));
  AddPoint(CoordsArr, XYZ(0, 0, -1));

  AddPointsBetween(CoordsArr, 0, 1, 16);
  AddPointsBetween(CoordsArr, 0, 2, 16);
  AddPointsBetween(CoordsArr, 0, 3, 16);
  AddPointsBetween(CoordsArr, 0, 4, 16);
  AddPointsBetween(CoordsArr, 1, 2, 16);
  AddPointsBetween(CoordsArr, 2, 3, 16);

  AddPointsBetween(CoordsArr, 3, 4, 16);
  AddPointsBetween(CoordsArr, 4, 1, 16);
  AddPointsBetween(CoordsArr, 5, 1, 16);
  AddPointsBetween(CoordsArr, 5, 2, 16);
  AddPointsBetween(CoordsArr, 5, 3, 16);
  AddPointsBetween(CoordsArr, 5, 4, 16);
end;

procedure InitIcosaedr(var CoordsArr : TCoords3dArr);
var
  n : Integer;
  ang : Single;

  function GM9(num : Integer) : Integer;
  begin
    Result := num;
    While Result>9 do Dec(Result, 10);
  end;
begin
  // икосаэдр / icosaedr

  For n := 0 to 4 do //0-9
  begin
    ang := n/5*2*pi; // 5 делений / 5 divisions
    AddPoint(CoordsArr, XYZ(sin(ang), cos(ang), 0.5));
    AddPoint(CoordsArr, XYZ(sin(ang+pi/5), cos(ang+pi/5), -0.5));
  end;

  AddPoint(CoordsArr, XYZ(0, 0, sqrt(5)/2));  // 10
  AddPoint(CoordsArr, XYZ(0, 0, -sqrt(5)/2)); // 11

  For n := 0 to 9 do
  begin
    AddPointsBetween(CoordsArr, n, GM9(n+1), 6);
    AddPointsBetween(CoordsArr, n, GM9(n+2), 6);
    AddPointsBetween(CoordsArr, n, 10+(n mod 2), 6);
  end;

  For n := 0 to 7 do
  begin
    DupPoint(CoordsArr, n);
  end;
end;

procedure InitDodecaedr(var CoordsArr : TCoords3DArr);
var
  IcoPoints : array[0..11] of TCoords3D;
  n : Integer;
  ang : Single;

  function GM9(num : Integer) : Integer;
  begin
    Result := num;
    While Result>9 do Dec(Result, 10);
  end;
begin
  // додекаэдр / dodecaedr
  For n := 0 to 4 do //0-9
  begin
    ang := n/5*2*pi; // 5 делений / 5 divisions
    IcoPoints[2*n]   := XYZ(sin(ang), cos(ang), 0.5);
    IcoPoints[2*n+1] := XYZ(sin(ang+pi/5), cos(ang+pi/5), -0.5);
  end;

  IcoPoints[10] := XYZ(0, 0, sqrt(5)/2);  // 10
  IcoPoints[11] := XYZ(0, 0, -sqrt(5)/2); // 11

  For n := 0 to 9 do
  begin
    AddPointBetween3(CoordsArr, IcoPoints[n],
      IcoPoints[GM9(n+1)], IcoPoints[GM9(n+2)]);
  end;
  For n := 0 to 4 do
  begin
    AddPointBetween3(CoordsArr, IcoPoints[10],
      IcoPoints[2*n], IcoPoints[GM9(2*n+2)]);
    AddPointBetween3(CoordsArr, IcoPoints[11],
      IcoPoints[2*n+1], IcoPoints[GM9(2*n+3)]);
  end;

  For n := 0 to 9 do
  begin
    AddPointsBetween(CoordsArr, n, GM9(n+1), 6);
  end;
  For n := 0 to 4 do
  begin
    AddPointsBetween(CoordsArr, 2*n+10, GM9(2*n+2)+10, 6);
    AddPointsBetween(CoordsArr, 2*n+11, GM9(2*n+2)+11, 6);
  end;
  For n := 0 to 9 do
    AddPointsBetween(CoordsArr, n, n+10, 6);
end;

procedure InitPyramideCut(var CoordsArr : TCoords3dArr);
var
  i : Integer;
begin
  AddPoint(CoordsArr, XYZ(0.33, 0.33, 1));   // 0
  AddPoint(CoordsArr, XYZ(1, 0.33, 0.33));   // 1
  AddPoint(CoordsArr, XYZ(0.33, 1, 0.33));   // 2

  AddPoint(CoordsArr, XYZ(1, -0.33, -0.33)); // 3
  AddPoint(CoordsArr, XYZ(0.33, -1, -0.33)); // 4
  AddPoint(CoordsArr, XYZ(0.33, -0.33, -1)); // 5

  AddPoint(CoordsArr, XYZ(-0.33, -1, 0.33)); // 6
  AddPoint(CoordsArr, XYZ(-1, -0.33, 0.33)); // 7
  AddPoint(CoordsArr, XYZ(-0.33, -0.33, 1)); // 8

  AddPoint(CoordsArr, XYZ(-1, 0.33, -0.33)); // 9
  AddPoint(CoordsArr, XYZ(-0.33, 1, -0.33)); // 10
  AddPoint(CoordsArr, XYZ(-0.33, 0.33, -1)); // 11

  For i := 0 to 3 do
  begin
    AddPointsBetween(CoordsArr, i*3+0, i*3+1, 10);
    AddPointsBetween(CoordsArr, i*3+1, i*3+2, 10);
    AddPointsBetween(CoordsArr, i*3+0, i*3+2, 10);
  end;

  AddPointsBetween(CoordsArr, 0, 8, 10);
  AddPointsBetween(CoordsArr, 1, 3, 10);
  AddPointsBetween(CoordsArr, 2, 10, 10);
  AddPointsBetween(CoordsArr, 4, 6, 10);
  AddPointsBetween(CoordsArr, 7, 9, 10);
  AddPointsBetween(CoordsArr, 5, 11, 10);

  DupPoint(CoordsArr, 0);
  DupPoint(CoordsArr, 1);
  DupPoint(CoordsArr, 3);
  DupPoint(CoordsArr, 4);
  DupPoint(CoordsArr, 6);
  DupPoint(CoordsArr, 7);
  DupPoint(CoordsArr, 9);
  DupPoint(CoordsArr, 10);
end;

procedure InitCubeCut(var CoordsArr : TCoords3dArr);
var
  i : Integer;
begin
  AddPoint(CoordsArr, XYZ(1, 0.4, 1));   // 0
  AddPoint(CoordsArr, XYZ(0.4, 1, 1));   // 1
  AddPoint(CoordsArr, XYZ(-0.4, 1, 1));  // 2
  AddPoint(CoordsArr, XYZ(-1, 0.4, 1));  // 3
  AddPoint(CoordsArr, XYZ(-1, -0.4, 1)); // 4
  AddPoint(CoordsArr, XYZ(-0.4, -1, 1)); // 5
  AddPoint(CoordsArr, XYZ(0.4, -1, 1));  // 6
  AddPoint(CoordsArr, XYZ(1, -0.4, 1));  // 7
  AddPoint(CoordsArr, XYZ(1, 1, 0.4));    // 8
  AddPoint(CoordsArr, XYZ(1, 1, -0.4));   // 9
  AddPoint(CoordsArr, XYZ(0.4, 1, -1));   // 10
  AddPoint(CoordsArr, XYZ(-0.4, 1, -1));  // 11
  AddPoint(CoordsArr, XYZ(-1, 1, -0.4));  // 12
  AddPoint(CoordsArr, XYZ(-1, 1, 0.4));   // 13
  AddPoint(CoordsArr, XYZ(1, -1, 0.4));  // 14
  AddPoint(CoordsArr, XYZ(1, -1, -0.4)); // 15
  AddPoint(CoordsArr, XYZ(1, -0.4, -1)); // 16
  AddPoint(CoordsArr, XYZ(1, 0.4, -1));  // 17
  AddPoint(CoordsArr, XYZ(-1, 0.4, -1));   // 18
  AddPoint(CoordsArr, XYZ(-1, -0.4, -1));  // 19
  AddPoint(CoordsArr, XYZ(-0.4, -1, -1));  // 20
  AddPoint(CoordsArr, XYZ(0.4, -1, -1));   // 21
  AddPoint(CoordsArr, XYZ(-1, -1, 0.4));  // 22
  AddPoint(CoordsArr, XYZ(-1, -1, -0.4)); // 23

  AddPointsBetween(CoordsArr, 0, 1, 4);
  AddPointsBetween(CoordsArr, 1, 8, 4);
  AddPointsBetween(CoordsArr, 8, 0, 4);
  AddPointsBetween(CoordsArr, 2, 3, 4);
  AddPointsBetween(CoordsArr, 3, 13, 4);
  AddPointsBetween(CoordsArr, 13, 2, 4);
  AddPointsBetween(CoordsArr, 4, 5, 4);
  AddPointsBetween(CoordsArr, 5, 22, 4);
  AddPointsBetween(CoordsArr, 22, 4, 4);
  AddPointsBetween(CoordsArr, 6, 7, 4);
  AddPointsBetween(CoordsArr, 7, 14, 4);
  AddPointsBetween(CoordsArr, 14, 6, 4);
  AddPointsBetween(CoordsArr, 11, 12, 4);
  AddPointsBetween(CoordsArr, 12, 18, 4);
  AddPointsBetween(CoordsArr, 18, 11, 4);
  AddPointsBetween(CoordsArr, 19, 23, 4);
  AddPointsBetween(CoordsArr, 23, 20, 4);
  AddPointsBetween(CoordsArr, 20, 19, 4);
  AddPointsBetween(CoordsArr, 15, 16, 4);
  AddPointsBetween(CoordsArr, 16, 21, 4);
  AddPointsBetween(CoordsArr, 21, 15, 4);
  AddPointsBetween(CoordsArr, 9, 17, 4);
  AddPointsBetween(CoordsArr, 17, 10, 4);
  AddPointsBetween(CoordsArr, 10, 9, 4);

  AddPointsBetween(CoordsArr, 1, 2, 5);
  AddPointsBetween(CoordsArr, 5, 6, 5);
  AddPointsBetween(CoordsArr, 20, 21, 5);
  AddPointsBetween(CoordsArr, 10, 11, 5);
  AddPointsBetween(CoordsArr, 3, 4, 5);
  AddPointsBetween(CoordsArr, 7, 0, 5);
  AddPointsBetween(CoordsArr, 16, 17, 5);
  AddPointsBetween(CoordsArr, 18, 19, 5);
  AddPointsBetween(CoordsArr, 12, 13, 5);
  AddPointsBetween(CoordsArr, 22, 23, 5);
  AddPointsBetween(CoordsArr, 14, 15, 5);
  AddPointsBetween(CoordsArr, 8, 9, 5);

  For i := 0 to 19 do
    DupPoint(CoordsArr, i);
end;

procedure InitHeadAcke(var CoordsArr : TCoords3dArr);
var
  i : Integer;
begin
  AddPoint(CoordsArr, XYZ(1, 0.4, 0.2));    // 0
  AddPoint(CoordsArr, XYZ(-1, 0.4, 0.2));   // 1
  AddPoint(CoordsArr, XYZ(-1, -0.4, 0.2));  // 2
  AddPoint(CoordsArr, XYZ(1, -0.4, 0.2));   // 3
  AddPoint(CoordsArr, XYZ(1, 0.4, -0.2));   // 4
  AddPoint(CoordsArr, XYZ(-1, 0.4, -0.2));  // 5
  AddPoint(CoordsArr, XYZ(-1, -0.4, -0.2)); // 6
  AddPoint(CoordsArr, XYZ(1, -0.4, -0.2));  // 7
  AddPoint(CoordsArr, XYZ(0.4, 0.2, 1));     // 8
  AddPoint(CoordsArr, XYZ(0.4, 0.2, -1));    // 9
  AddPoint(CoordsArr, XYZ(-0.4, 0.2, -1));   // 10
  AddPoint(CoordsArr, XYZ(-0.4, 0.2, 1));    // 11
  AddPoint(CoordsArr, XYZ(0.4, -0.2, 1));    // 12
  AddPoint(CoordsArr, XYZ(0.4, -0.2, -1));   // 13
  AddPoint(CoordsArr, XYZ(-0.4, -0.2, -1));  // 14
  AddPoint(CoordsArr, XYZ(-0.4, -0.2, 1));   // 15
  AddPoint(CoordsArr, XYZ(0.2, 1, 0.4));    // 16
  AddPoint(CoordsArr, XYZ(0.2, -1, 0.4));   // 17
  AddPoint(CoordsArr, XYZ(0.2, -1, -0.4));  // 18
  AddPoint(CoordsArr, XYZ(0.2, 1, -0.4));   // 19
  AddPoint(CoordsArr, XYZ(-0.2, 1, 0.4));   // 20
  AddPoint(CoordsArr, XYZ(-0.2, -1, 0.4));  // 21
  AddPoint(CoordsArr, XYZ(-0.2, -1, -0.4)); // 22
  AddPoint(CoordsArr, XYZ(-0.2, 1, -0.4));  // 23

  For i := 0 to 5 do
  begin
    AddPointsBetween(CoordsArr, 4*i+0, 4*i+1, 8);
    AddPointsBetween(CoordsArr, 4*i+1, 4*i+2, 4);
    AddPointsBetween(CoordsArr, 4*i+2, 4*i+3, 8);
    AddPointsBetween(CoordsArr, 4*i+3, 4*i+0, 4);
  end;

  For i := 0 to 2 do
  begin
    AddPointsBetween(CoordsArr, 8*i+0, 8*i+4, 2);
    AddPointsBetween(CoordsArr, 8*i+1, 8*i+5, 2);
    AddPointsBetween(CoordsArr, 8*i+2, 8*i+6, 2);
    AddPointsBetween(CoordsArr, 8*i+3, 8*i+7, 2);
  end;

  For i := 0 to 7 do DupPoint(CoordsArr, i);
end;

procedure InitSphere1(var CoordsArr : TCoords3dArr);
var
  nokr, nang : Integer;
  Ango, anga, z : Single;
begin
  For nang := -9 to 10 do
  begin
    anga := (nang-0.5)/19 *pi;
    z := sin(anga);
    For nokr := 0 to 9 do
    begin
      ango := nokr/10*pi*2;
      AddPoint(CoordsArr, XYZ(sin(ango)*sqrt(1-z*z), cos(ango)*sqrt(1-z*z), z));
    end;
  end;
end;

procedure InitSphere2(var CoordsArr : TCoords3dArr);
var
  nokr, nang : Integer;
  Ango, anga, z : Single;
begin
  For nang := -4 to 5 do
  begin
    anga := (nang-0.5)/10 *pi;
    z := sin(anga);
    For nokr := 0 to 19 do
    begin
      ango := nokr/20*pi*2;
      AddPoint(CoordsArr, XYZ(sin(ango)*sqrt(1-z*z), cos(ango)*sqrt(1-z*z), z));
    end;
  end;
end;

procedure InitEgg(var CoordsArr : TCoords3dArr);
var
  nokr, nsl : Integer;
  Ango, angs, z, R : Single;
begin
  // Яйцо / Egg
  For nsl := -10 to 9 do
  begin
    If nsl<=-4 then
    begin
      angs := (nsl+4)/6*pi/2;
      z := sin(angs)/2-0.5;
      R := cos(angs);
    end else
    begin
      angs := (nsl+4)/14*pi/2;
      z := sin(angs)*1.5-0.5;
      R := cos(angs);
    end;


    For nokr := 0 to 9 do
    begin
      ango := nokr/10*pi*2;
      AddPoint(CoordsArr, XYZ(sin(ango)*R/1.5, cos(ango)*R/1.5, z));
    end;
  end;
end;

procedure InitTor(var CoordsArr : TCoords3DArr);
var
  n, k : Integer;
  r, xa, ya, za, ang : Single;
begin
  // тор / torus
  For n := 0 to (PointsCount div 10)-1 do
  begin
    ang := n/PointsCount * 10* 2 *pi;

    For k := 0 to 9 do
    begin
      r  := 1+0.33*cos(k/10*2*pi);
      za := 0.33*sin(k/10*2*pi);

      xa := r*cos(ang);
      ya := r*sin(ang);

      AddPoint(CoordsArr, XYZ(xa, ya, za));
    end;
  end;
end;

procedure InitSpiral(var CoordsArr : TCoords3DArr);
var
  n : Integer;
  angm, ang, r, xa, ya, za : Single;
begin
  // кривая 2 / curve 2
  For n := 0 to (PointsCount-1) do
  begin
    angm := n/PointsCount * 2*pi;
    ang := angm*16;
    za := 0.33*sin(ang);

    r := 1+0.33*cos(ang);
    xa := r*cos(angm);
    ya := r*sin(angm);

    AddPoint(CoordsArr, XYZ(xa, ya, za));
  end;
end;

procedure UnSort(var CoordsArr : TCoords3DArr);
var
  Temp : TCoords3D;
  i, k, l : Integer;
begin
  For i := 1 to 1024 do
  begin
    k := Random(PointsCount);
    l := Random(PointsCount);

    Temp := CoordsArr[k];
    CoordsArr[k] := CoordsArr[l];
    CoordsArr[l] := Temp;
  end;
end;

procedure InitShape(var CoordsArr : TCoords3dArr);
var
  n, OldShInd : Integer;
  Ok : Boolean;
begin
  FillChar(CoordsArr, SizeOf(TCoords3DArr), 0);

  Ok := False;
  PIndex := 0;

  OldShInd := ShapeInd;
  For n := 0 to shCount-1 do
    if not (ShapesArr[n] in ShapesSet) then Ok := True;
  If not Ok then ShapesSet := [];
  repeat
    ShapeInd := Trunc(Random(100)) mod shCount;
  until not (ShapesArr[ShapeInd] in ShapesSet) and (ShapeInd<>OldShInd);
  ShapesSet := ShapesSet+[ShapesArr[ShapeInd]];

  Case ShapesArr[ShapeInd] of
    shCube        : InitCube(CoordsArr);
    shTriangle1   : InitTriangle1(CoordsArr);
    shTriangle2   : InitTriangle2(CoordsArr);
    shTriangle3   : InitTriangle3(CoordsArr);
    shOct         : InitOctaedr(CoordsArr);
    shIco         : InitIcosaedr(CoordsArr);
    shPyramideTri : InitPyramideTri(CoordsArr);
    shSphere1     : InitSphere1(CoordsArr);
    shSphere2     : InitSphere2(CoordsArr);
    shEgg         : InitEgg(CoordsArr);
    shDodecaedr   : InitDodecaedr(CoordsArr);
    shPyramideCut : InitPyramideCut(CoordsArr);
    shCubeCut     : InitCubeCut(CoordsArr);
    shHeadAcke    : InitHeadAcke(CoordsArr);
    shTor         : InitTor(CoordsArr);
    shSpiral      : InitSpiral(CoordsArr);
    else InitCube2(CoordsArr); //shCube2
  end;

  If UnSortPoints then UnSort(CoordsArr); // перемешать точки / mix points
end;

procedure CalcPos;
var
  n : Integer;
begin
  For n := 0 to PointsCount-1 do
  begin
    Points[n].X := PCoords1[n].X+(PCoords2[n].X-PCoords1[n].X)*Percent/100;
    Points[n].Y := PCoords1[n].Y+(PCoords2[n].Y-PCoords1[n].Y)*Percent/100;
    Points[n].Z := PCoords1[n].Z+(PCoords2[n].Z-PCoords1[n].Z)*Percent/100;
  end;
end;

end.
