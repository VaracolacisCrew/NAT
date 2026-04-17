;...............................................................................;
;                                                                               ;
; app ...........:  NETWORK ADAPTER TOGGLER     		                        ;
; version .......: 1.0.0                                                        ;
;                                                                               ;
;...............................................................................;
;                                                                               ;
; author ........: obsessedDesigns Studios                                      ;
; language ......: AutoHotkey V2                                                ;
; github repo ...: https://github.com/VaracolacisCrew/NAT                       ;
; download EXE ..: https://github.com/VaracolacisCrew/NAT/releases              ;
; license .......: https://github.com/VaracolacisCrew/NAT?tab=MIT-1-ov-file		;
;                                                                               ;
;...............................................................................;
; [CHANGE LOG], [PENDING] and [REMARKS] @ bottom of script                      ;
;...............................................................................;

#Requires AutoHotkey v2.0
#SingleInstance Force

; Request administrator privileges to manage network interfaces
if !A_IsAdmin {
    Run('*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"')
    ExitApp
}

; --- Network Adapter Toggler UI ---
MainGui := Gui("-MaximizeBox", "Network Adapter Toggler")
MainGui.SetFont("s9", "Segoe UI")

MainGui.Add("Text", , "Select a network adapter to manage:")

; Table with 3 columns: Windows Name, Hardware, and Status
LV := MainGui.Add("ListView", "h100 w400 vAdapterList +Grid -Multi", ["Windows Name", "Hardware Device", "Current Status"])

; Compact button row
BtnEnable  := MainGui.Add("Button", "w100 h30", "Enable")
BtnDisable := MainGui.Add("Button", "x+5 w100 h30", "Disable")
BtnRefresh := MainGui.Add("Button", "x+95 w100 h30", "Refresh List")

; Events
BtnEnable.OnEvent("Click", (*) => SetAdapterStatus("enabled"))
BtnDisable.OnEvent("Click", (*) => SetAdapterStatus("disabled"))
BtnRefresh.OnEvent("Click", (*) => RefreshList())

; Initial data load
RefreshList()
MainGui.Show()

; --- Functions ---

RefreshList() {
    LV.Delete() ; Clear current list
    
    ; WMI Query to get all network adapters
    objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
    colAdapters := objWMIService.ExecQuery("Select * from Win32_NetworkAdapter")

    for objAdapter in colAdapters {
        ; Only list adapters with a valid Windows connection name
        if (objAdapter.NetConnectionID != "") {
            statusText := GetStatusText(objAdapter.NetConnectionStatus)
            LV.Add(, objAdapter.NetConnectionID, objAdapter.Name, statusText)
        }
    }
    
    ; Auto-adjust columns
    LV.ModifyCol(1, "AutoHdr")
    LV.ModifyCol(2, 180) 
    LV.ModifyCol(3, "AutoHdr")
}

SetAdapterStatus(mode) {
    row := LV.GetNext()
    if (row == 0) {
        MsgBox("Please select an adapter from the list first.", "No Selection", "Icon!")
        return
    }

    adapterName := LV.GetText(row, 1)
    MainGui.Opt("+Disabled") ; Lock UI during operation
    
    try {
        ; Execute netsh command
        RunWait(A_ComSpec ' /c netsh interface set interface name="' . adapterName . '" admin=' . mode, , "Hide")
        
        ; Short pause for Windows to update the hardware state
        Sleep(1200)
        RefreshList()
    } catch Error as e {
        MsgBox("Error trying to change adapter state:`n" . e.Message, "Error", "Iconx")
    }
    
    MainGui.Opt("-Disabled")
}

GetStatusText(code) {
    ; Mapping Windows status codes to English text
    statusMap := Map(
        0, "Disabled",
        1, "Connecting",
        2, "Connected",
        3, "Disconnecting",
        4, "Hardware Not Present",
        5, "Disabled",
        6, "Hardware Error",
        7, "Media Disconnected",
        8, "Authenticating",
        9, "Auth. Failed",
        10, "Invalid Address"
    )
    return statusMap.Has(code) ? statusMap[code] : "Unknown"
}

; Close script when GUI is closed
MainGui.OnEvent("Close", (*) => ExitApp())