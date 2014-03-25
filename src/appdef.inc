type
  PMP3Searcher = ^TMP3Searcher;
  TMP3Searcher = object(TApplication)
    StatusWindow: PStatusWindow;
    MP3ListDialog: PMP3List;
    constructor Init;
    procedure Idle; virtual;
    procedure InitMenuBar; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    destructor Done; virtual;
  private
    Clock: PClockView;
    Heap: PHeapView;
    mp3s: PCollection;
    function ReadConfig: Boolean;
  end;

