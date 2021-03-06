unit main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView, FMX.Edit,
  IPPeerClient, REST.Client, Data.Bind.Components, Data.Bind.ObjectScope, System.JSON,
  System.Sensors, System.Sensors.Components, FMX.WebBrowser, System.Actions,
  FMX.ActnList;

type
  TForm1 = class(TForm)
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    TabControl2: TTabControl;
    TabItem3: TTabItem;
    TabItem4: TTabItem;
    ToolBar1: TToolBar;
    Label1: TLabel;
    ToolBar2: TToolBar;
    Label2: TLabel;
    Edit1: TEdit;
    ListView1: TListView;
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    Timer1: TTimer;
    ListView2: TListView;
    LocationSensor1: TLocationSensor;
    Timer2: TTimer;
    ActionList1: TActionList;
    settings: TChangeTabAction;
    weather: TChangeTabAction;
    ToolBar3: TToolBar;
    Label3: TLabel;
    WebBrowser1: TWebBrowser;
    SpeedButton1: TSpeedButton;
    Timer3: TTimer;
    procedure Edit1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure LocationSensor1LocationChanged(Sender: TObject; const OldLocation,
      NewLocation: TLocationCoord2D);
    procedure Timer2Timer(Sender: TObject);
    procedure ListView1ItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure SpeedButton1Click(Sender: TObject);
    procedure ListView2ItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure Timer3Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  oldSearchBoxText: string;

implementation

{$R *.fmx}
{$R *.SmXhdpiPh.fmx ANDROID}

procedure setRESTRequestParam(name, value: string);
begin
  try
    Form1.RESTRequest1.Params.ParameterByName(name).Value := value;
  except
    Form1.RESTRequest1.AddParameter(name, value);
  end;
  Form1.RESTRequest1.AddParameter(name, value);
end;

procedure getCityData(ListView: TListView);
var jValue: TJSONValue;
    jArray: TJSONArray;
    json, json1: TJSONObject;
    ListViewItem: TListViewItem;
    region, municipal: string;
    function getStr(json: TJSONObject; value: string): string;
    begin
      try
         Result := json.Get(value).JsonValue.value;
      except
         Result := '';
      end;
    end;
begin
  with Form1 do begin
    RESTRequest1.Execute;
    ListView.Items.Clear;
    //AniIndicator2.Visible := false;
   // AniIndicator3.Visible := false;
    jValue:=RESTResponse1.JSONValue;
    if (jValue is TJSONObject) then begin
      json :=  TJSONObject(jValue);
      jArray := json.GetValue('items') as TJSONArray;
      for jValue in jArray do
      begin
        json1 :=  TJSONObject(jValue);
        ListViewItem := ListView.Items.Add;
        region := getStr(json1, 'd_name');
        if (region<>'') then  region := ', '+region;
        municipal := getStr(json1, 'mun_name');
        if (municipal<>'') then  municipal := ', '+municipal;
        ListViewItem.Detail := getStr(json1, 'c_name') + region + municipal;
        ListViewItem.Text := json1.Get('name').JsonValue.value;
        ListViewItem.Tag := strToIntDef(getStr(json1, 'id'), 0);
      end;
    end;
  end;
end;

procedure TForm1.Edit1Click(Sender: TObject);
begin
  Edit1.Text := '';
  oldSearchBoxText := Edit1.Text;
end;

procedure TForm1.ListView1ItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
  //WebBrowser1.Visible := false;
  //AniIndicator1.Visible := true;
  weather.ExecuteTarget(self);
  WebBrowser1.URL := 'http://m.meteonova.ru/frc/'+intToStr(AItem.Tag)+'.html';
end;

procedure TForm1.ListView2ItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
  weather.ExecuteTarget(self);
  WebBrowser1.URL := 'http://m.meteonova.ru/frc/'+intToStr(AItem.Tag)+'.html';
end;

procedure TForm1.LocationSensor1LocationChanged(Sender: TObject;
  const OldLocation, NewLocation: TLocationCoord2D);
begin
  try
    RESTRequest1.Params.Clear;
    setRESTRequestParam('searchby', 'cities');
    setRESTRequestParam('lat', Format('%2.6f', [NewLocation.Latitude]));
    setRESTRequestParam('lng', Format('%2.6f', [NewLocation.Longitude]));
    setRESTRequestParam('mcntcities', '10');
    Timer2.Enabled := true;
  finally
  end;

end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
  settings.ExecuteTarget(self);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
    if  (oldSearchBoxText<>edit1.Text) then
    begin
      oldSearchBoxText := edit1.Text;
      if edit1.Text = '' then exit;
      //AniIndicator3.Visible := true;
      setRESTRequestParam('fchar', edit1.Text);
      setRESTRequestParam('mcntcities', '10');
      getCityData(ListView1);
    end;
end;

procedure TForm1.Timer2Timer(Sender: TObject);
begin
  getCityData(ListView2);
  if ListView2.Items.Count > 0 then
    LocationSensor1.Active := false;
  Timer2.Enabled := false;
end;

procedure TForm1.Timer3Timer(Sender: TObject);
begin
  LocationSensor1.Active := true;
end;

end.
