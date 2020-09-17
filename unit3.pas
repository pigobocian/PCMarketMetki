unit Unit3;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, FileUtil, DateTimePicker, Forms, Controls, Graphics,
  Dialogs, ExtCtrls, Buttons, ComCtrls, StdCtrls, LConvEncoding;

type

  { TForm3 }

  TForm3 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Button1: TButton;
    dtp_start: TDateTimePicker;
    dtp_stop: TDateTimePicker;
    GroupBox1: TGroupBox;
    lv_dokum: TListView;
    Panel1: TPanel;
    Panel2: TPanel;
    sqlq: TSQLQuery;
    sqlt: TSQLTransaction;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }

    function GetAsortList:TStringList;
  end;

var
  Form3: TForm3;

implementation

{$R *.lfm}

{ TForm3 }

procedure TForm3.FormShow(Sender: TObject);
begin
  dtp_start.Date:=Now() -7;
  dtp_stop.Date:=Now();
  // odswiezenie zawartosci okna
  Button1Click(nil);
end;

function TForm3.GetAsortList: TStringList;
var
  sl      : TStringList;
  doklist : string;
  i,x     : integer;
  l       : TListItem;
begin
  sl:=TStringList.Create;

  // utworzenie listy ID zaznaczonych dokumentów
  for i:=0 to lv_dokum.Items.Count - 1 do
  begin
    l:=lv_dokum.Items[i];
    if l.Checked then doklist:=doklist+','+l.SubItems[3];
  end;
  if doklist <> '' then delete(doklist,1,1); // skasowanie pierwszego przecinka

  try
    if sqlt.Active then sqlt.Rollback;
    sqlq.SQL.Clear;
    sqlq.SQL.Add('SELECT distinct tw.Nazwa, tw.TowId');
    sqlq.SQL.Add('FROM Dok a');
    sqlq.SQL.Add('inner join PozDok pd on pd.DokId = a.DokId');
    sqlq.SQL.Add('inner join Towar tw on tw.TowId = pd.TowId');
    sqlq.SQL.Add('where a.DokId in ('+doklist+')');
    sqlq.SQL.Add('order by tw.Nazwa');
    sqlt.StartTransaction;
    sqlq.Open;
    sqlq.First;
    while not sqlq.EOF do
    begin
      x:=sl.Add(CP1250ToUTF8(sqlq.FieldByName('nazwa').AsString));
      sl.Objects[x]:=TObject(sqlq.FieldByName('TowId').AsInteger);
      sqlq.Next;
    end;
  finally
    GetAsortList:=sl;
  end;
end;

procedure TForm3.Button1Click(Sender: TObject);
var
  l : TListItem;
begin
  try
    lv_dokum.BeginUpdate;
    lv_dokum.Clear;
    if sqlt.Active then sqlt.Rollback;
    sqlq.SQL.Clear;
    sqlq.SQL.Add('SELECT a.DokId, a.Data, a.Razem, a.NrDok, kn.Nazwa, (select count(*) from PozDok pd where pd.DokId = a.DokId) as "Poz"');
    sqlq.SQL.Add('FROM Dok a');
    sqlq.SQL.Add('inner join DokKontr dk on dk.DokId = a.DokId');
    sqlq.SQL.Add('inner join Kontrahent kn on kn.KontrId = dk.KontrId');
    sqlq.SQL.Add('where a.NrDok like :dok and (a.Data between :dtstart and :dtstop)');
    sqlq.SQL.Add('order by a.NrDok, a.Data desc');
    sqlq.ParamByName('dok').AsString:='%/PZ/%';
    sqlq.ParamByName('dtstart').AsDate:=dtp_start.Date;
    sqlq.ParamByName('dtstop').AsDate:=dtp_stop.Date;
    sqlt.StartTransaction;
    sqlq.Open;
    sqlq.First;
    while not sqlq.EOF do
    begin
      l:=lv_dokum.Items.Add;
      l.Caption:=DateToStr(sqlq.FieldByName('data').AsDateTime);
      l.SubItems.Add(CP1250ToUTF8(sqlq.FieldByName('nazwa').AsString));  // 0
      l.SubItems.Add(IntToStr(sqlq.FieldByName('poz').AsInteger));  // 1
      l.SubItems.Add(FloatToStr( sqlq.FieldByName('razem').AsFloat)); // 2
      l.SubItems.Add(IntToStr(sqlq.FieldByName('DokId').AsInteger)); // 3
      sqlq.Next
    end;
  finally
    lv_dokum.EndUpdate;
  end;

end;

procedure TForm3.FormCreate(Sender: TObject);
begin
  dtp_start.Date:=Now() -7;
  dtp_stop.Date:=Now();
  // odswiezenie zawartosci okna
  Button1Click(nil);
end;



end.

