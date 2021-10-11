unit Lap01;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
  TFMain = class(TForm)
    Jardin: TImage;
    Balle: TShape;
    Bt_Nouveau: TButton;
    Lap1: TImage;
    Timer1: TTimer;
    Lap2: TImage;
    PnCtr: TPanel;
    PnRec: TPanel;
    Bt_Quitter: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Tir;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Bt_NouveauClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Lap1Click(Sender: TObject);
    procedure FinJeu;
    procedure Bt_QuitterClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  FMain: TFMain;

implementation

uses mmsystem;              

{$R *.dfm}

const
  finom = 'Data\Firec.dat';

var
  pas : integer = 10;
  bx,by,tim,rec,
  px,py : integer;
  bmap,bsav,fleur,
  trou : TBitmap;
  but,ctr,
  eta : byte;
  firec : file of integer;

procedure TFMain.FormCreate(Sender: TObject);
begin
  Randomize;
  trou := TBitmap.Create;
  trou.LoadFromFile('Data\Trou.bmp');
  trou.Transparent := true;
  fleur := TBitmap.Create;
  fleur.LoadFromFile('Data\Fleur.bmp');
  fleur.Transparent := true;
  bmap := TBitmap.Create;
  bx := Clientwidth div 2;
  by := ClientHeight - 30;
  rec := 0;
  if FileExists(finom) then
  begin
    AssignFile(firec,finom);
    Reset(firec);
    Read(firec,rec);
    CloseFile(firec);
    PnRec.Caption := 'Record : '+ IntToStr(rec);
  end;
end;

procedure TFMain.Bt_NouveauClick(Sender: TObject);
begin
  bmap.LoadFromFile('Data\Jardin.bmp');
  Jardin.Canvas.Draw(0,0,bmap);
  MessageDlg('Etes-vous prêt?', mtConfirmation, [mbOk], 0);
  eta := 0;
  but := 0;
  ctr := 0;
  tim := random(300)+300;
  Timer1.Interval := tim;
  Timer1.Enabled := true;
end;

procedure TFMain.Timer1Timer(Sender: TObject);
begin
  if ctr = 100 then FinJeu;
  case eta of
    0 : begin
          inc(ctr);
          PnCtr.Caption := IntToStr(but)+' / '+IntToStr(ctr);
          eta := 1;
          px := random(800)+1;
          py := random(600)+1;
          Lap1.Left := px;
          Lap1.Top := py;
          Lap1.Visible := true;
          Lap1.Repaint;
        end;
    1 : begin
          eta := 2;
          Lap1.Visible := false;
          Lap2.Left := px;
          Lap2.Top := py;
          Lap2.Visible := true;
          Lap2.Repaint;
        end;
    2 : begin
          eta := 0;
          Lap2.Visible := false;
          Jardin.Canvas.Draw(px,py,trou);
          tim := random(300)+300;
          Timer1.Interval := tim;
        end;
    3 : begin
          eta := 0;
          Lap1.Visible := false;
          Lap2.Visible := false;
          Jardin.Canvas.Draw(px,py,fleur);
          tim := random(300)+300;
          Timer1.Interval := tim;
        end;
  end;
end;

procedure TFMain.Tir;
var  ecx,ecy,
     xa,ya,xd,yd,p : integer;
begin
  xa := px+30;      // position finale
  ya := py+30;
  xd := bx;          // position initiale de la pièce
  yd := by;
  p := pas;
  repeat
    ecx := (xa-xd) div p;    // longueur d'un pas
    ecy := (ya-yd) div p;
    xd := xd+ecx-5;
    yd := yd+ecy-5;
    Balle.Left := xd;
    Balle.Top := yd;
    Balle.Repaint;
    dec(p);
    sleep(30);
  until p = 0;
end;

procedure TFMain.Lap1Click(Sender: TObject);
  var  i : byte;
begin
  SndPlaySound('Data\Plop.wav',snd_nodefault or snd_async);
  Balle.Left := bx;
  Balle.Top := by;
  Balle.Visible := true;
  Tir;
  if eta in[1,2] then
  begin
    Timer1.Enabled := false;
    Balle.Visible := false;
    inc(but);
    PnCtr.Caption := IntToStr(but)+' / '+IntToStr(ctr);
    eta := 3;
    Timer1.Enabled := true;
  end;
  Balle.Visible := false;
end;

procedure TFMain.FinJeu;
begin
  Timer1.Enabled := false;
  if but > rec then
  begin
    rec := but;
    PnRec.Caption := 'Record : '+ IntToStr(rec);
    MessageDlg('Nouveau record !', mtInformation, [mbOk], 0);
  end
  else MessageDlg('Peut mieux faire...', mtInformation, [mbOk], 0);
end;

procedure TFMain.Bt_QuitterClick(Sender: TObject);
begin
  AssignFile(firec,finom);
  Rewrite(firec);
  Write(firec,rec);
  CloseFile(firec);
  Close
end;

procedure TFMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  trou.Free;
  bmap.Free;
  fleur.Free;
end;

end.

