unit idle; // from DPMI32 package (c) Veit.Kannegieser@gmx.de

interface

procedure give_up_cpu_time;

implementation

uses
  (*$IFDEF DPMI32*)
  dpmi32df,dpmi32,
  (*$ENDIF*)
  VpSysLow;

procedure give_up_cpu_time;
  begin
    (*$IFDEF DPMI32*)

    if os2 then
      asm (*$ALTERS EAX,EDX*)
        sub edx,edx
        sub eax,eax
        inc eax
        hlt     // OS/2: Sleep(DX:AX)
        db $35,$ca
      end;
    if IsMultiThread then
      SysCtrlSleep(1);

      asm (*$ALTERS EAX*)
        // DPMI: release current time slice
        mov ax,$1680
        int $2f
        int $28
      end;

    (*$ELSE*)
    SysCtrlSleep(1);
    (*$ENDIF*)

  end;


end.