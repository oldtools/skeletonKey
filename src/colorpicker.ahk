ChooseColor(pRGB := 0, hOwner := 0, DlgX := 0, DlgY := 0, Palette*)
{
    static CustColors
    static SizeOfCustColors := VarSetCapacity(CustColors, 64, 0)
    static StructSize := VarSetCapacity(ChooseColor, 9 * A_PtrSize, 0)
    CustData := (DlgX << 16) | DlgY
    for Index, Value in Palette
        NumPut(BGR2RGB(Value), CustColors, (Index - 1) * 4, "UInt")
    NumPut(StructSize, ChooseColor, 0, "UInt")
    NumPut(hOwner, ChooseColor, A_PtrSize, "UPtr")
    NumPut(BGR2RGB(pRGB), ChooseColor, 3 * A_PtrSize, "UInt")
    NumPut(&CustColors, ChooseColor, 4 * A_PtrSize, "UPtr")
    NumPut(0x113, ChooseColor, 5 * A_PtrSize, "UInt")
    NumPut(CustData, ChooseColor, 6 * A_PtrSize, "UInt")
    NumPut(RegisterCallback("ColorWindowProc"), ChooseColor, 7 * A_PtrSize, "UPtr")
    ErrorLevel := ! DllCall("comdlg32\ChooseColor", "UPtr", &ChooseColor, "UInt")
    if not ErrorLevel
        Loop 16
            Palette[A_Index] := BGR2RGB(NumGet(CustColors, (A_Index - 1) * 4, "UInt"))
    return BGR2RGB(NumGet(ChooseColor, 3 * A_PtrSize, "UINT"))
}
ColorWindowProc(hwnd, msg, wParam, lParam)
{
    static WM_INITDIALOG := 0x0110
    if (msg <> WM_INITDIALOG)
        return 0
    hOwner := NumGet(lParam+0, A_PtrSize, "UPtr")
    if (hOwner)
        return 0
    DetectSetting := A_DetectHiddenWindows
    DetectHiddenWindows On
    CustData := NumGet(lParam+0, 6 * A_PtrSize, "UInt")
    DlgX := CustData >> 16, DlgY := CustData & 0xFFFF
    WinMove ahk_id %hwnd%, , %DlgX%, %DlgY%
    DetectHiddenWindows %DetectSetting%
    return 0
}
BGR2RGB(Color)
{
    return  (Color & 0xFF000000)
         | ((Color & 0xFF0000) >> 16)
         |  (Color & 0x00FF00)
         | ((Color & 0x0000FF) << 16)
}