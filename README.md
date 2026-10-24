# Windows-Classic-LockScreen
This lock screen offers a login box that mimics Windows 2000 login screen; this replaces the ugly native lock screen of Windows.

USAGE:
This works with Autohotkey v1.1; compile the script and generate *.exe as executable code which you can then run to lock your screen.
This code intercepts Win+L to lock the screen, yet you need to disable Win+L from launching the official/native lock screen; for this proceeds as follows:
1/ Press Win + R, type regedit, and hit Enter.   
2/ Navigate to:HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies
If a key named System does not exist under Policies, right-click Policies -> New -> Key and name it System.
3/ Inside the System key, right-click the empty space on the right -> New -> DWORD (32-bit) Value and name it DisableLockWorkstation.   
4/ Double-click DisableLockWorkstation and set its value data to 1. Click OK.
In addition, it has a timer for user inactivity to launch lock screen; you can tune it as you see fit.
NB: Ctl+Alt+Sup will trigger official/native lock screen; your choice if you want to work around it.
DISCLAIMER: Use at your own risk.
