' Script for getting mod version from moddesc.xml
Dim oXml: Set oXml = CreateObject("Microsoft.XMLDOM")
oXml.Load WScript.Arguments.Item(0)
Dim oDoc: Set oDoc = oXml.documentElement

For Each node In oDoc.childNodes
    If node.nodeName = "version" Then
        WScript.Echo node.text
    End If
Next
Set oXml = Nothing
