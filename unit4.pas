unit Unit4;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Buttons, ComCtrls, PairSplitter, StdCtrls;

type

  { TForm4 }

  TForm4 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    CheckBox1: TCheckBox;
    lv_harm: TListView;
    lv_harm_asort: TListView;
    PairSplitter1: TPairSplitter;
    PairSplitterSide1: TPairSplitterSide;
    PairSplitterSide2: TPairSplitterSide;
    Panel1: TPanel;
    Panel2: TPanel;
    sqlq: TSQLQuery;
    sqlt: TSQLTransaction;
    procedure CheckBox1Change(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lv_harmClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }

    procedure InitWindow;
    function  GetAsortList:TStringList;
  end;

var
  Form4: TForm4;

implementation

{$R *.lfm}

{ TForm4 }

procedure TForm4.lv_harmClick(Sender: TObject);
var
  idx : string;
  l   : TListItem;
begin
  if lv_harm.ItemIndex < 0 then exit;
  idx:=lv_harm.Items[lv_harm.ItemIndex].SubItems[2];

  try
    lv_harm_asort.BeginUpdate;
    lv_harm_asort.Clear;

    if sqlt.Active then sqlt.Rollback;
    sqlq.SQL.Clear;
    sqlq.SQL.Add('select a.TowID, a.Nazwa, a.Kod,');
    sqlq.SQL.Add('ROUND(hc.CenaDet*(1+(CAST( a.Stawka AS DECIMAL))/10000),2) as CENA_HARM');
    sqlq.SQL.Add('from Towar a');
    sqlq.SQL.Add('inner join JM b on b.JMId = a.JMId');
    sqlq.SQL.Add('inner join HarmCeny hc on hc.TowId = a.TowId and hc.HarmId = '+idx);
    sqlq.SQL.Add('order by upper(a.Nazwa)');
    sqlt.StartTransaction;
    sqlq.Open;
    sqlq.First;
    while not sqlq.EOF do
    begin
      l:=lv_harm_asort.Items.Add;
      l.Caption:=sqlq.FieldByName('nazwa').AsString;
      l.SubItems.Add(FloatToStr(sqlq.FieldByName('cena_harm').AsFloat));
      l.SubItems.Add(sqlq.FieldByName('kod').AsString);
      l.SubItems.Add(IntToStr(sqlq.FieldByName('TowId').AsInteger));
      sqlq.Next;
    end;
  finally
    sqlt.Commit;
    lv_harm_asort.EndUpdate;
  end;
end;

procedure TForm4.FormShow(Sender: TObject);
begin
  InitWindow;
end;

procedure TForm4.CheckBox1Change(Sender: TObject);
begin
  InitWindow;
end;

procedure TForm4.InitWindow;
var
  l : TListItem;
begin
  try
    lv_harm.BeginUpdate;
    lv_harm_asort.BeginUpdate;
    lv_harm.Clear;
    lv_harm_asort.Clear;

    if sqlt.Active then sqlt.Commit;
    sqlq.SQL.Clear;
    sqlq.SQL.Add('select hw.Nazwa, hw.WaznyOd, hw.WaznyDo, hw.HarmId');
    sqlq.SQL.Add('from HarmWpis hw');
    if CheckBox1.Checked then sqlq.SQL.Add('where hw.WaznyOd <= CURRENT_TIMESTAMP and CURRENT_TIMESTAMP <= hw.WaznyDo and hw.Aktywny = 1');
    sqlq.SQL.Add('order by hw.WaznyOd, upper(hw.Nazwa)');
    sqlt.StartTransaction;
    sqlq.Open;
    sqlq.First;
    while not sqlq.EOF do
    begin
      l:=lv_harm.Items.Add;
      l.Caption:=DateToStr(sqlq.FieldByName('WaznyOd').AsDateTime);
      l.SubItems.Add(DateToStr(sqlq.FieldByName('WaznyDo').AsDateTime));
      l.SubItems.Add(sqlq.FieldByName('Nazwa').AsString);
      l.SubItems.Add(IntToStr(sqlq.FieldByName('HarmId').AsInteger));

      sqlq.Next;
    end;


  finally
    sqlt.Commit;
    lv_harm.EndUpdate;
    lv_harm_asort.EndUpdate;
  end;
end;

function TForm4.GetAsortList: TStringList;
var
  sl : TStringList;
  i  : integer;
begin
  sl:=TStringList.Create;
  for i:=0 to lv_harm_asort.Items.Count-1 do sl.Add(lv_harm_asort.Items[i].SubItems[2]);
  GetAsortList:=sl;
end;

end.

