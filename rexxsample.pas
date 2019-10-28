{���������������������������������������������������������������������}
{�                                                                   �}
{�  REXX Sample Functions -                                          �}
{�  ���������������������������������������������������������������  �}
{�  Need to get this to compile to a .so library for Raspbian LINUX  �}
{�  using FreePascal and Open Object REXX.                           �}
{�                                                                   �}
{�  Currently compiles for OS/2 using Virtual Pascal                 �}
{�                                                                   �}
{���������������������������������������������������������������������}


Library RexxSample;

Uses Classes, SysUtils, Rexx, Strings, Internalfuncs, Dos;

{ ============================================================================= }

Function callrexx( Name  : PChar;
                   ArgC      : ULong;
                   Args      : pRxString;
                   QueueName : pChar;
                   Var Ret   : RxString ) : ULong; cdecl;
Const
  crlf = #13+#10;

var
  RexxReturnValue                            : ANSIString;
  rc, count                                 : Integer;
  rexxstartrc                                : Long;
  RexxRetVal                                 : RxString;
  rexxsourcefile, RexxReturnVar              : String;
  tmp                                        : pchar;
  RexxRC                                     : Word;
  Arg                                        : array [1..20] of RxString;

begin
   tmp := strings.stralloc(255);
   rc := 0;
   If ArgC < 2 then begin
      callrexx := 40; { 2 parameters minimum }
      exit;
   end;
   rexxsourcefile := trim(StrPas( Args[0].strptr ));
   if fileexists(rexxsourcefile) = false then rc := 1;
   rexxreturnvar := '';
   rexxreturnvalue := '';
   if ArgC >= 2 then begin
      inc(args);
      rexxreturnvar := trim(Uppercase(StrPas( Args[0].strptr )));
   end;
   if rexxreturnvar = '' then rexxreturnvar := 'ReturnVar';
   if rc = 0 then begin
      count := 0;
      if ArgC >= 3 then begin
         for count := 0 to (Argc-2) do begin
            inc(args);
            Arg[count].strlength := Args[0].strlength;
            Arg[count].strptr := Args[0].strptr;
         end;
      end;
      Arg[count+1].strlength := 0;
      Arg[count+1].strptr := nil;
      RexxRetVal.strlength := 0;
      strpcopy(tmp, rexxsourcefile);
      rexxstartrc := RexxStart(count, @Arg[0], tmp, nil, 'CMD', rxFunction, nil, RexxRC, RexxRetVal);
      if rexxstartrc <> 0 then rc := rexxstartrc;
      setstring(rexxreturnvalue,rexxretval.strptr, rexxretval.strlength);
      { Release storage allocated by REXX }
      if Assigned(RexxRetVal.strptr) then FreeMem(RexxRetVal.strptr);
   end;
   if rexxvarset(rexxreturnvar,RexxReturnValue) = FALSE then rc := 3;
   strpcopy(Ret.strptr,IntToStr(rc));
   Ret.strLength := strlen( Ret.StrPtr );
   callrexx := 0;
end;

{ ============================================================================= }

Function rexxwebversion( Name  : PChar;
                     ArgC      : ULong;
                     Args      : pRxString;
                     QueueName : pChar;
                     Var Ret   : RxString ) : ULong; cdecl;

var dummy : pchar;
begin
  dummy := 'REXXSample v0.1 build 1';
  Move (dummy^,Ret.StrPtr^,strlen(dummy));
  Ret.strLength := strlen( Ret.StrPtr );
  rexxwebversion := 0;
end;
exports
   callrexx,rexxwebversion;
end.