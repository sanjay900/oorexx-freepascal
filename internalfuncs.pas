{���������������������������������������������������������}
{�                                                       �}
{�      REXXsample                                       �}
{�      Internal Functions                               �}
{�      ���������������������������������������������    �}
{�      Used by REXXsample                               �}
{�                                                       �}
{���������������������������������������������������������}


{$S-,R-,Q-,I-,Cdecl-,OrgName-,AlignRec-,H+,Use32+}

unit internalfuncs;

interface
uses strings, rexx, Classes, SysUtils, Math;

//TYPE
//  TTriplet = ARRAY[0..2] OF Byte;
//  TKwartet = ARRAY[0..3] OF Byte;

 function IsInteger(stringin: String): Boolean;
 function StrRight(stringin: String; stringlen: Integer): String;
 function StrLeft(stringin: String; stringlen: Integer): String;
// function substr(stringin: String; stringstart: Integer; stringlength: Integer): String;
// function subint(integerin: Integer; integerstart: Integer; integerlength: Integer): integer;
// function validatestring(stringin: ANSIString; validatetype: Char; validateoption: Char): Boolean;
 function rexxvarset(rxvarname: String; rxvardata: ANSIString): Boolean;
 function rexxvarget(rxvarname: String): ANSIString;
 function rexxvarbgetsize(rxvarname: String): ULong;
 function rexxvarexists(rxvarname: String): Boolean;
 function rexxvarbget(rxvarname: String; buffer: Pointer; buffersize: Ulong): ULong;
 function rexxvarbset(rxvarname: String; buffer: Pointer; buffersize: ULong): Boolean;
 function rexxvarsubstitution(stringdata: ANSIString; option: String; varmarker: String; prefix: String): ANSIString;

implementation


{ ============================================================================= }

function IsInteger(stringin: String): Boolean;
var
   i : Integer;

begin
   IsInteger := TRUE;
   if length(stringin) = 0 then stringin := #32;
   if (stringin[1] = '-') and (length(stringin) = 1) then stringin := #32;
   for i := 1 to length(stringin) do begin
      if pos(stringin[i],'1234567890-+') = 0 then IsInteger := FALSE;
      if (i > 1) and (stringin[i] = '-') then IsInteger := FALSE;
      if (i > 1) and (stringin[i] = '+') then IsInteger := FALSE;
   end;
end;

{ ============================================================================= }

{ String Right function for string types }

function StrRight(stringin: String; stringlen: Integer): String;
   begin
   if (stringlen > length(stringin)) or (stringlen < 1) then stringlen := length(stringin);
   strright := copy(stringin,(length(stringin)-stringlen)+1,stringlen);
 end;

{ String Left function for string types }

function StrLeft(stringin: String; stringlen: Integer): String;
   begin
   if (stringlen > length(stringin)) or (stringlen < 1) then stringlen := length(stringin);
   strleft := copy(stringin,1,stringlen);
 end;

{ ============================================================================= }

{ Substr function for String Types }

function substr(stringin: String; stringstart: Integer; stringlength: Integer): String;
begin
   if (stringin <> '') and (stringstart > 0) and (stringstart <= length(stringin)) and ((stringstart + stringlength-1) <= length(stringin)) and (stringlength > 0) then
      begin
         substr := copy(stringin,stringstart,stringlength);
      end;
end;
{ ============================================================================= }

{ Substr function for Integer Types }

 function subint(integerin: Integer; integerstart: Integer; integerlength: Integer): integer;
 var
    p             : Integer;
    integerstring : String;
    subintout     : String;
 begin
    subint := 0;
    subintout := '';
    integerstring := InttoStr(integerin);

    if (integerstart > 0) and (integerstart <= length(integerstring)) and ((integerstart + integerlength-1) <= length(integerstring)) and (integerlength > 0) then begin
       for p := integerstart to (integerstart+integerlength-1) do begin
          subintout := subintout + integerstring[p];
       end;
       subint := StrtoInt(subintout);
    end;
 end;

{ ============================================================================= }

function rexxvarset(rxvarname: String; rxvardata: ANSIString): Boolean;
Var
  rxdata        : SHVBlock;
  rxvarchar     : array[0..255] of char;
  pname         : Pchar;
  varlength     : ULong;

begin
  if rxvardata = '' then begin
     rxvardata := chr(0);
     varlength := 0;
  end
  else varlength := length(rxvardata);

  //pName := rxvarchar;
  //pName := strpcopy(pName, uppercase(rxpoolvar));

  pname := rxvarchar;
  pname := StrPCopy(pname, uppercase(rxvarname));
  rxdata.shvnext := NIL;
  rxdata.shvname.strptr := pname;
  rxdata.shvvalue.strptr := pointer(rxvardata);
  rxdata.shvname.strlength := Length(rxvarname);
  rxdata.shvvalue.strlength := varlength;
  rxdata.shvcode := RXSHV_SET;
  rxdata.shvret := 0;
  RexxVariablePool(rxdata);
  if ((rxdata.shvret = $00) or (rxdata.shvret = $01)) then rexxvarset := TRUE else rexxvarset := FALSE;
end;

{ ============================================================================= }

{ Get a REXX variable from the REXX Variable Pool }

function rexxvarget(rxvarname: String): ANSIString;
Var
  rxdata         : SHVBlock;
  rexxdata       : ANSIString;
  rxvarchar      : array[0..255] of char;
  pName          : Pchar;

begin
   rexxvarget := '';
   pName := rxvarchar;
   pName := StrPCopy(pName, uppercase(rxvarname));
   rxdata.shvnext := NIL;
   rxdata.shvname.strptr := pName;
   rxdata.shvvalue.strptr := NIL;
   rxdata.shvname.strlength := length(rxvarname);
   rxdata.shvvalue.strlength := 0;
   rxdata.shvcode := RXSHV_FETCH;
   rxdata.shvret := 0;
   RexxVariablePool(rxdata);  { Get REXX Variable }
   if ((rxdata.shvret = $00) or (rxdata.shvret = $04)) then begin
      rexxdata := rxdata.shvvalue.strptr;
      setlength(rexxdata, rxdata.shvvaluelen);
      rexxvarget := rexxdata;
   end;
   if Assigned(rxdata.shvvalue.strptr) then FreeMem(rxdata.shvvalue.strptr);

end;

{ ============================================================================= }

{ Get size of REXX variable in the REXX Varaiable Pool }

function rexxvarbgetsize(rxvarname: String): ULong;
Var
  rxdata         : SHVBlock;
  rxvarchar      : array[0..255] of char;
  pName          : Pchar;

begin
   rexxvarbgetsize := 0;
   pName := rxvarchar;
   pName := StrPCopy(pName, uppercase(rxvarname));
   rxdata.shvnext := NIL;
   rxdata.shvname.strptr := pName;
   rxdata.shvvalue.strptr := NIL;
   rxdata.shvname.strlength := length(rxvarname);
   rxdata.shvvalue.strlength := 0;
   rxdata.shvcode := RXSHV_FETCH;
   rxdata.shvret := 0;
   RexxVariablePool(rxdata);  { Get REXX Variable }
   if ((rxdata.shvret = $00) or (rxdata.shvret = $04)) then rexxvarbgetsize := rxdata.shvvalue.strlength;
   if Assigned(rxdata.shvvalue.strptr) then FreeMem(rxdata.shvvalue.strptr);
end;

{ ============================================================================= }

{ Check to see if REXX variable exists in the REXX Variable Pool }

function rexxvarexists(rxvarname: String): Boolean;
Var
  rxdata         : SHVBlock;
  rxvarchar      : array[0..255] of char;
  pName          : Pchar;

begin
   rexxvarexists := TRUE;
   pName := rxvarchar;
   pName := StrPCopy(pName, uppercase(rxvarname));
   rxdata.shvnext := NIL;
   rxdata.shvname.strptr := pName;
   rxdata.shvvalue.strptr := NIL;
   rxdata.shvname.strlength := length(rxvarname);
   rxdata.shvvalue.strlength := 0;
   rxdata.shvcode := RXSHV_FETCH;
   rxdata.shvret := 0;
   RexxVariablePool(rxdata);  { Get REXX Variable }
   if rxdata.shvret = $01 then rexxvarexists := FALSE;
   if Assigned(rxdata.shvvalue.strptr) then FreeMem(rxdata.shvvalue.strptr);
end;

{ ============================================================================= }

{ Get a REXX variable from REXX Variable Pool that holds Binary data }

function rexxvarbget(rxvarname: String; Buffer: Pointer; buffersize: Ulong): ULong;
Var
  rxdata         : SHVBlock;
  rxvarchar      : array[0..255] of char;
  pName          : Pchar;

begin
   rexxvarbget := 0;
   pName := rxvarchar;
   pName := strpcopy(pName, uppercase(rxvarname));
   rxdata.shvnext := NIL;
   rxdata.shvname.strptr := pName;
   rxdata.shvvalue.strptr := buffer;
   rxdata.shvname.strlength := length(rxvarname);
   rxdata.shvvalue.strlength := buffersize;
   rxdata.shvcode := RXSHV_FETCH;
   rxdata.shvret := 0;
   RexxVariablePool(rxdata);  { Get REXX Variable }
   if ((rxdata.shvret = $00) or (rxdata.shvret = $04)) then rexxvarbget := rxdata.shvvaluelen;
   if Assigned(rxdata.shvvalue.strptr) then FreeMem(rxdata.shvvalue.strptr);
end;

{ ============================================================================= }

{ Set a REXX variable that holds Binary data to the REXX Variable Pool}

function rexxvarbset(rxvarname: String; buffer: Pointer; buffersize: ULong): Boolean;
Var
  rxdata         : SHVBlock;
  rxvarchar      : array[0..255] of char;
  pName          : Pchar;

begin
  pName := rxvarchar;
  pName := strpcopy(pName, uppercase(rxvarname));
  rxdata.shvnext := NIL;
  rxdata.shvname.strptr := pName;
  rxdata.shvvalue.strptr := buffer;
  rxdata.shvname.strlength := Length(rxvarname);
  rxdata.shvvalue.strlength := buffersize;
  rxdata.shvcode := RXSHV_SET;
  rxdata.shvret := 0;
  RexxVariablePool(rxdata);
  if ((rxdata.shvret = $00) or (rxdata.shvret = $01)) then rexxvarbset := TRUE else rexxvarbset := FALSE;
end;

{ ============================================================================= }

{ Subsitute REXX variables in a string }

function rexxvarsubstitution(stringdata: ANSIString; option: String; varmarker: String; prefix: String): ANSIString;

Const
    crlf = chr(13)+chr(10);

var
    bigstring, stringresult                  : ANSIString;
    rexxvar, c                               : String;
    justify                                  : Char;
    startmarker, endmarker, i, p, count, rc  : Integer;

begin
   if length(varmarker) > 1 then varmarker := varmarker[1];
   if varmarker = '' then varmarker := '#';
   stringresult := '';

   rc := 1;

   if stringdata <> '' then begin { change string data here }
      i := 0;
      startmarker := 0;
      endmarker := 0;
      while (i <= (length(stringdata)-1)) and (length(stringdata) > 0 ) do begin { watchout for null terminate strings!!!! }
         inc(i);
         if (startmarker > 0) and (stringdata[i] <> varmarker) and ((pos(stringdata[i],' ">'+crlf) > 0) or (i = length(stringdata))) then begin
            stringresult := stringresult + copy(stringdata,startmarker, i-startmarker);
            startmarker := 0;
            endmarker := 0;
         end;
//writeln('<br>Marker');
         if (stringdata[i] = varmarker) and (startmarker > 0) then begin
            if i - startmarker > 1 then endmarker := i;
            if i - startmarker = 1 then begin
               startmarker := i;
               stringresult := stringresult+'#';
            end;
         end;
         if (stringdata[i] = varmarker) and (startmarker = 0) then startmarker := i;
         if startmarker = 0 then stringresult := stringresult + stringdata[i];
         if (startmarker > 0) and (endmarker > 0) then begin
            rexxvar := uppercase(copy(stringdata,startmarker+1, (endmarker-1)-startmarker));
               p := pos(':',rexxvar);
               if (p > 2) and (p < length(rexxvar)) then begin
                     justify := #32;
                     if rexxvar[1] = 'L' then justify := 'L';
                     if rexxvar[1] = 'R' then justify := 'R';
                     if justify <> #32 then begin
                        c := copy(rexxvar,2,(p-2));
                        rexxvar := copy(rexxvar,p+1,length(rexxvar)-p);
//writeln('<br>Aligned - Prefix: '+prefix+'  REXXVar: '+rexxvar);
                        if (prefix = '') or (strleft(rexxvar, length(prefix)) = prefix) then begin
                           if (rexxvarexists(rexxvar) = TRUE) then begin
//writeln('<br>'+rexxvar+' found');
                              if IsInteger(c) = FALSE then c:= '10';
                              if p = 0 then c := '10';
                              if justify = 'L' then stringresult := stringresult + format( '%-'+c+'.'+c+'s', [rexxvarget(rexxvar)]);
                              if justify = 'R' then stringresult := stringresult + format( '%'+c+'.'+c+'s', [rexxvarget(rexxvar)]);
                           end
                           else if option = 'SHOW' then stringresult := stringresult + varmarker + rexxvar + varmarker
                        end;
                     end;
               end
               else begin
//writeln('<br>Normal - Prefix: '+prefix+'  REXXVar: '+rexxvar);
                  if (prefix = '') or (strleft(rexxvar, length(prefix)) = prefix) then begin
//writeln('<br>'+rexxvar+' found');
                     if (rexxvarexists(rexxvar) = TRUE) then begin
                        stringresult := stringresult + rexxvarget(rexxvar);
                        //stringresult := stringresult + 'REXXVALUE';
//writeln('<br>Got rexxvar value');
                     end
                     else begin
                        if option = 'SHOW' then stringresult := stringresult + varmarker + rexxvar + varmarker;
                     end;
                  end;
               end;
            startmarker := 0;
            endmarker := 0;
         end;
      end;
   end;
   rexxvarsubstitution := StringResult;
end;


end.
