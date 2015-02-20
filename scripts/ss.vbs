Dim WshShell
Set WshShell = WScript.CreateObject("WScript.Shell")
Do While True
        WshShell.SendKeys("{F15}")
        WScript.Sleep(55000)
Loop