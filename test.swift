import AppKit
let frontmostAppPID = NSWorkspace.shared().frontmostApplication?.processIdentifier
let options = CGWindowListOption(arrayLiteral: CGWindowListOption.excludeDesktopElements, CGWindowListOption.optionOnScreenOnly)
let windowListInfo = CGWindowListCopyWindowInfo(options, CGWindowID(0))
let infoList = windowListInfo as NSArray? as? [[String: AnyObject]]
// print(infoList)

let app = AXUIElementCreateApplication(frontmostAppPID!);

var names: CFArray?
let error = AXUIElementCopyAttributeNames(app, &names)


let namesAsStrings = names! as [AnyObject] as! [String]
// print(namesAsStrings)


// var elements: CFArray?
// AXUIElementCopyAttributeValues(app, "AXChildren" as CFString, 0, 100, &elements)
var focused: CFTypeRef?
AXUIElementCopyAttributeValue(app, "AXFocusedUIElement" as CFString, &focused)

var axPosition: CFTypeRef?
AXUIElementCopyAttributeValue(focused as! AXUIElement, "AXPosition" as CFString, &axPosition)
var axSize: CFTypeRef?
AXUIElementCopyAttributeValue(focused as! AXUIElement, "AXSize" as CFString, &axSize)

if #available(OSX 10.11, *) {
	var position = CGPoint()
	AXValueGetValue(axPosition as! AXValue,  AXValueType.cgPoint, &position)
	var size = CGSize()
	AXValueGetValue(axSize as! AXValue,  AXValueType.cgSize, &size)
	print(position)
	print(size)
} else {
	print("NOPE")
}



// AXValueGetValue(mem as! AXValue, AXValueType.CGSize, &val)

// var names2: CFArray?
// let error2 = AXUIElementCopyAttributeNames(focused as! AXUIElement, &names2)
// print(names2!)

// let count = CFArrayGetCount(elements);
//
