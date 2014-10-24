local myname, ns = ...


local title = "|cFF33FF99".. GetAddOnMetadata(myname, "Title").. "|r:"
function ns.Print(...) print(title, ...) end
function ns.Printf(...) ns.Print(string.format(...)) end
