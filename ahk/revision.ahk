;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;   Ctrl-F12 : set search engine or later change it.
;;   F7 : insert empty timestamp, use for inserting new record.
;;   F11 : lists and opens all revision records (txt file).
;;   F9 : get record and run browser.
;;   F10 : inputs new interval.
;;
;;   !r : edit source
;;   !n : Open note to write annotation
;;   !b  browse note (not yet)
;;   ^F7 : Set index based on line number
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; modified from jackieku's code (http://www.autohotkey.com/forum/post-310959.html#310959)
UriEncode(Uri, Enc = "UTF-8")
{
   StrPutVar(Uri, Var, Enc)
   f := A_FormatInteger
   SetFormat, IntegerFast, H
   Loop
   {
      Code := NumGet(Var, A_Index - 1, "UChar")
      If (!Code)
         Break
      If (Code >= 0x30 && Code <= 0x39 ; 0-9
         || Code >= 0x41 && Code <= 0x5A ; A-Z
         || Code >= 0x61 && Code <= 0x7A) ; a-z
         Res .= Chr(Code)
      Else
         Res .= "%" . SubStr(Code + 0x100, -1)
   }
   SetFormat, IntegerFast, %f%
   Return, Res
}

UriDecode(Uri, Enc = "UTF-8")
{
   Pos := 1
   Loop
   {
      Pos := RegExMatch(Uri, "i)(?:%[\da-f]{2})+", Code, Pos++)
      If (Pos = 0)
         Break
      VarSetCapacity(Var, StrLen(Code) // 3, 0)
      StringTrimLeft, Code, Code, 1
      Loop, Parse, Code, `%
         NumPut("0x" . A_LoopField, Var, A_Index - 1, "UChar")
      StringReplace, Uri, Uri, `%%Code%, % StrGet(&Var, Enc), All
   }
   Return, Uri
}

StrPutVar(Str, ByRef Var, Enc = "")
{
   Len := StrPut(Str, Enc) * (Enc = "UTF-16" || Enc = "CP1200" ? 2 : 1)
   VarSetCapacity(Var, Len, 0)
   Return, StrPut(Str, &Var, Enc)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

CoordMode, ToolTip, Screen

help := "F9 get record`nF10 set revision`nM-r Show source`nC-F12 search"
ht := 0

^h::
if (ht == 0) {
    ht := 1
    ToolTip, %help%, 1020, 0
} else {
    ht := 0
    ToolTip
}
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set search engine
; setting nothing is default to google
;

^F12::
temp := clipboard
Send {Home}
Send +{End}
Send ^c
search_engine := clipboard
clipboard := temp
return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; auxiliary functions
;

Check(stamp)
{
    interval := SubStr(stamp, 10)
    old_date := SubStr(stamp, 1, 8) . "000000"
    new_date := old_date
    EnvAdd, new_date, interval, days
    if new_date <= %A_Now%
        return true ; do revision
    else
        return false
}

Update(interval) ; specified as number of days
{
    today := SubStr(A_Now, 1, 8)
    r := today . "|" . interval
    return r
}

Update2(stamp) ; specified as number of days
{
    old_interval := SubStr(stamp, 10)
    today := SubStr(A_Now, 1, 8)
    r := today . "|" . old_interval
    return r
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main function
; important
;

F9::
SetTitleMatchMode, 2
WinActivate, Rev_

Send {Home}
Send +{End}
Send ^c
Send {Home}

StringSplit, data_array, clipboard, %A_Tab%,

if not Check(data_array3) ; not need to revise
{
    Send {Down}{Home} ; go to next entry
    Send +{right 10}
    return
}

;count := data_array0
;Loop, %data_array0%
;{
;    next := count
;    previous := next - 1
;    data_array%next% := data_array%previous%
;    count--
;    if count = 2
;        break
;}

if ((SubStr(data_array1, 1, 7) = "http://") or (SubStr(data_array1, 1, 8) = "https://"))
{
    clipboard := data_array1
}
else if (SubStr(data_array1, 1, 13) = "mk:@MSITStore")
{
    temp := "HH.exe " . data_array1
    Run, %temp%
    return
}
else if (SubStr(data_array1, -3, 4) = ".pdf")
{
    temp := "F:\app\SumatraPDF.exe -reuse-instance -page " . data_array1
    Run, %temp%
    return
}
else
    clipboard := search_engine . UriEncode(data_array1)

SetTitleMatchMode, 2
IfWinExist, Opera
    WinActivate, Opera
IfWinExist, Pale Moon
    WinActivate, Pale Moon
Send ^t     ; Both Opera and Palemoon open new tab
Send ^v     ; copy url and surf
Send {Enter}

return

^F9::
SetTitleMatchMode, 2
WinActivate, Rev_

Send {Home}
Send +{End}
Send ^c
Send {Home}

StringSplit, data_array, clipboard, %A_Tab%,

SetWorkingDir, F:\app\Lynx\
Run, "F:\app\Lynx\Lynx.exe -accept_all_cookies=off" %data_array1%

return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; input new date
;

input_help = 
(
p: pass, alternating nothing
input 'empty' to set new datestamp(i.e. today) only without alternating interval.
)

F10::

WinActivate, Rev_
WinWaitActive, Rev_

temp := clipboard
Send {Home}
Send +{End}
Send ^c
Send {Home}
StringSplit, data_array, clipboard, %A_Tab%,
clipboard := temp

InputBox, new_interval, Input interval, input 'empty' to set date only,
if (SubStr(new_interval, 1, 1) = "p")
{
    SetTitleMatchMode, 2
    WinActivate, Rev_
    WinWaitActive, Rev_
    if not ErrorLevel
    {
        Send {Down}
    }
    return
}
else if (new_interval = "")
{
    n_data_array3 := Update2(data_array3)
}
else
{
    n_data_array3 := Update(new_interval)
}

if (data_array4 = "x")
{
    clipboard := data_array1 . A_Tab . data_array2 . A_Tab . n_data_array3 . A_Tab . "x"
} else {
    clipboard := data_array1 . A_Tab . data_array2 . A_Tab . n_data_array3 . A_Tab . data_array3 . A_Tab . data_array4 . A_Tab . data_array5 . A_Tab . data_array6 . A_Tab . data_array7 . A_Tab . data_array8 . A_Tab . data_array9
}

if not ErrorLevel
{
    Send {Home}
    Send +{End}
    Send ^v
    Send {Down}{Home}
}

return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Open note to write annotation

!n::

WinActivate, Rev_
WinWaitActive, Rev_

temp := clipboard
Send {Home}
Send +{End}
Send ^c
Send {Home}
StringSplit, data_array, clipboard, %A_Tab%,
clipboard := temp

WinGetActiveTitle, title
filename := SubStr(title, 5, -10) . "_" . data_array2 . ".txt"

IfExist, F:\Annotation\%filename%
{
    if not WinExist("ahk_exe emacs.exe")
    {
        Run % "notepad.exe F:\Annotation\" . filename
    } else {
        Run % "E:\emacs-24.2\bin\emacsclientw.exe F:\Annotation\" . filename
    }
}
IfNotExist, F:\Annotation\%filename%
{
    SetTitleMatchMode, 2
    if WinExist("ahk_exe opera.exe")
    {
        WinGetTitle, title, Opera
    } else {
        title := ""
    }
    FileAppend, Source: %data_array1%`nPage: `n`n#+TITLE: %title%`n`n`n`n* eof, F:\Annotation\%filename%
    Run % "notepad.exe F:\Annotation\" . filename
}

return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Open in browser

!b::

WinActivate, Rev_
WinWaitActive, Rev_

temp := clipboard
Send {Home}
Send +{End}
Send ^c
Send {Home}
StringSplit, data_array, clipboard, %A_Tab%,
clipboard := temp

WinGetActiveTitle, title
filename := SubStr(title, 5, -10) . "_" . data_array2 . ".txt"

IfExist, F:\Annotation\%filename%
{
    ;set environment
    clipboard := "F:\app\Lynx\Lynx.exe F:\Annotation\" . filename
    Run % "F:\app\Lynx\Lynx.bat F:\Annotation\" . filename
    ; opera.exe
}
IfNotExist, F:\Annotation\%filename%
{
    Send {Home}
    Send +{right 7}
}

return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Add empty stamp for new record

F7::
Send ^g
Send ^c
Send {Esc}
i := clipboard
Send {End}
Send {Tab}%i%
Loop, 8 {
    Send {Tab}0
}
Send {Down}
return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

F11::
filenames := Object()
filenames_txt := ""
Loop, F:\Rev_*.txt {
    filenames.Insert(A_LoopFileFullPath)
    filenames_txt .= A_Index . " " . A_LoopFileFullPath . "`n"
}
MsgBox, %filenames_txt%
InputBox, i,
if (i <> "") {
    Run % "notepad.exe " . filenames[i]
}
return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Add index
; same as line number
;

;^l::
;Loop, 2 {
;Send {Home}
;Send +{End}
;Send ^c
;StringSplit, data_array, clipboard, %A_Tab%,
;clipboard := data_array1 . A_Tab . A_Index . A_Tab . data_array2 . A_Tab . data_array3 . A_Tab . data_array4 . A_Tab . data_array5 . A_Tab . data_array6 . A_Tab . data_array7 . A_Tab . data_array8 . A_Tab . data_array9
;Send ^v
;Send {down}
;}
;return

^F7::
Send ^g
Send ^c
Send {Esc}
i := clipboard
Send {Home}
Send +{End}
Send ^c
StringSplit, data_array, clipboard, %A_Tab%,
clipboard := data_array1 . A_Tab . i . A_Tab . data_array2 . A_Tab . data_array3 . A_Tab . data_array4 . A_Tab . data_array5 . A_Tab . data_array6 . A_Tab . data_array7 . A_Tab . data_array8 . A_Tab . data_array9
Send ^v
Send {down}
return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; copy html title

;^d::
;WinActivate, Opera
;return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Edit source code

!r::
;Run % "notepad.exe f:\revision.ahk"
Edit
return

^r::
Reload
return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Close

^F4::
exit
return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Array := Object()

;F3::
;temp := clipboard
;Send {F8}
;Send ^c
;Array.Insert(clipboard)
;clipboard := temp
;return

;F4::
;for index, element in Array
;{
;    temp += element "`r`n"
;}
;clipboard := temp
;return

;;; eof ;;;