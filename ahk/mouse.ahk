;NumPadDiv::
;NumPadMult::
NumPad8::
Click
return

;NumPadMult::
;NumPadSub::
NumPad9::
Click right
return

^NumPadAdd::
Send {Home}
Send +{End}
Send ^c
StringSplit, OutputArray, clipboard, |
l := SubStr(OutputArray1, 2)
p := SubStr(OutputArray2, 1, -1)
return

+NumPadAdd::
If l =
{
    MsgBox, Get login & password first
    return
}
Send %l%
Sleep, 1000
Send {Tab}
Sleep, 1000
Send %p%
clipboard := ""
;l := ""
;p := ""
return

;;;;; ;;;;;
;;; Open file with emacs
!e::

if not WinExist("ahk_exe emacs.exe")
{
    Run, E:\emacs-24.2\bin\runemacs.exe --execute=(server-start)
    return
}

WinWait, ahk_exe emacs.exe
WinActivate, ahk_exe emacs.exe

;Send {F2}
;Send ^c
;Send {Esc}
;WinGetActiveTitle, OutputVar
;Sleep, 1000
;Run, E:\emacs-24.2\bin\emacsclientw.exe %OutputVar%\%clipboard%

return

;^p::
;Send <pre>{Enter}
;Send ^v
;Send {Enter}</pre>
;return

!t::
Click, 492 558
Sleep, 500
Click, 495 590
Sleep, 2000
Click, 700 390
return

;^Del::
;Send +{Home}
;return

;NumPadSub::
;Click
;Send +{Home}
;; ;;;;; ;;;;;
;; Click right
;; Send s
;return

; DVD
;^NumPadSub::
;Drive, Eject, I:,
;return

^F4::ExitApp

/* eof */