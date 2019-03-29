' Script for getting the location of the FS mod folder from gameSettings.xml
Dim oXml: Set oXml = CreateObject("Microsoft.XMLDOM")
oXml.Load WScript.Arguments.Item(0)
Dim oDoc: Set oDoc = oXml.documentElement

For Each node In oDoc.childNodes
    If (node.nodeName = "modsDirectoryOverride") And (node.getAttribute("active") = "true") Then
        WScript.Echo node.getAttribute("directory")
    End If
Next
Set oXml = Nothing
