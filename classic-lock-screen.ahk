#NoEnv
#SingleInstance Force
SendMode Input
SetWorkingDir %A_ScriptDir%

#Persistent
Menu, Tray, Icon, shell32.dll, 47 

global Username := A_UserName

; Show lock screen immediately on startup
ShowLockScreen()

; Monitor inactivity for auto-locking (5 minutes = 300000 ms)
SetTimer, CheckIdle, 1000
return

CheckIdle:
    if (A_TimeIdle >= 300000) {
        if !WinExist("Logon to Windows") {
            ShowLockScreen()
        }
    }
return

; Intercept Win + L to trigger custom lock screen instead of native one
#l::
    ShowLockScreen()
return

ShowLockScreen() {
    global
    ; 1. Create a pitch-black fullscreen background overlay (Reverted to original: No AlwaysOnTop so clicking outside cannot hide the dialog)
    Gui, LockBG:New, -Caption +ToolWindow
    Gui, LockBG:Color, 000000
    Gui, LockBG:Show, x0 y0 w%A_ScreenWidth% h%A_ScreenHeight%

    ; 2. Create the authentic Windows 2000 style "Logon to Windows" dialog box with title banner
    Gui, Win2k:New, -Caption +AlwaysOnTop +ToolWindow, Logon to Windows
    Gui, Win2k:Color, C0C0C0

    ; Win2k Visual Elements (Classic Microsoft Sans Serif styling with banner)
    Gui, Win2k:Font, s9 Bold, MS Sans Serif
    Gui, Win2k:Add, Text, x12 y12 w370 h20 cNavy, Microsoft Windows Login
    
    Gui, Win2k:Font, s8 Norm, MS Sans Serif
    Gui, Win2k:Add, Text, x12 y32 w370 h30, Log on to this computer using your Windows account credentials.

    ; Authentic Classic Etched Horizontal Divider Line
    Gui, Win2k:Add, Text, x12 y55 w371 h2 +0x10

    ; Form Fields
    Gui, Win2k:Add, Text, x20 y81 w70 h20, User name:
    Gui, Win2k:Add, Edit, x100 y78 w175 h20 vUserVar ReadOnly, %Username%

    Gui, Win2k:Add, Text, x20 y111 w70 h20, Password:
    Gui, Win2k:Add, Edit, x100 y105 w175 h20 vPassVar +Password,

    Gui, Win2k:Add, Text, x20 y141 w70 h20, Log on to:
    Gui, Win2k:Add, Edit, x100 y138 w175 h20 vDomainVar ReadOnly, %A_ComputerName%

    ; Classic Win2k Buttons
    Gui, Win2k:Add, Button, x285 y78 w95 h25 Default gTryLogin, OK
    Gui, Win2k:Add, Button, x285 y108 w95 h25 gClearFields, Cancel
    Gui, Win2k:Add, Button, x285 y138 w95 h25 gShutDownPC, Shut Down...

    ; Center the dialog box perfectly on any resolution
    BoxWidth := 395
    BoxHeight := 178
    PosX := (A_ScreenWidth - BoxWidth) / 2
    PosY := (A_ScreenHeight - BoxHeight) / 2

    Gui, Win2k:Show, x%PosX% y%PosY% w%BoxWidth% h%BoxHeight%, Logon to Windows

    ; Intercept break-out keystrokes (Includes Win keys, Task Manager, and Alt+Tab)
    Hotkey, *Tab, BlockKey, On
    Hotkey, *Escape, BlockKey, On
    Hotkey, !F4, BlockKey, On
    Hotkey, LWin, BlockKey, On
    Hotkey, RWin, BlockKey, On
    Hotkey, ^+Esc, BlockKey, On
    Hotkey, !Tab, BlockKey, On
    Hotkey, ^!Tab, BlockKey, On
    
    ; Focus automatically on the password box
    ControlFocus, Edit2, Logon to Windows
}

BlockKey:
return

ClearFields:
GuiControl, Win2k:, PassVar,
WinActivate, Logon to Windows
ControlFocus, Edit2, Logon to Windows
return

TryLogin:
Gui, Win2k:Submit, NoHide

; Secure check against Windows kernel via advapi32.dll
if VerifyWindowsCredentials(Username, PassVar) {
    HotkeysOff()
    Gui, Win2k:Destroy
    Gui, LockBG:Destroy
} else {
    ; Play authentic Windows error sound instead of breaking focus
    DllCall("MessageBeep", "UInt", 16)
    GuiControl, Win2k:, PassVar,
    WinActivate, Logon to Windows
    ControlFocus, Edit2, Logon to Windows
}
return

ShutDownPC:
Shutdown, 1 
return

VerifyWindowsCredentials(user, pass) {
    hToken := 0
    ; LOGON32_LOGON_INTERACTIVE = 2, LOGON32_PROVIDER_DEFAULT = 0
    result := DllCall("advapi32\LogonUserW", "WStr", user, "WStr", ".", "WStr", pass, "UInt", 2, "UInt", 0, "Ptr*", hToken)
    if (result) {
        DllCall("kernel32\CloseHandle", "Ptr", hToken)
        return true
    }
    return false
}

HotkeysOff() {
    Hotkey, *Tab, Off
    Hotkey, *Escape, Off
    Hotkey, !F4, Off
    Hotkey, LWin, Off
    Hotkey, RWin, Off
    Hotkey, ^+Esc, Off
    Hotkey, !Tab, Off
    Hotkey, ^!Tab, Off
}
