import AppKit
let frontmostAppPID = NSWorkspace.shared().frontmostApplication?.processIdentifier

let app = AXUIElementCreateApplication(frontmostAppPID!);

var focused: CFTypeRef?
AXUIElementCopyAttributeValue(app, "AXFocusedUIElement" as CFString, &focused)

var axPosition: CFTypeRef?
AXUIElementCopyAttributeValue(focused as! AXUIElement, "AXPosition" as CFString, &axPosition)
var axSize: CFTypeRef?
AXUIElementCopyAttributeValue(focused as! AXUIElement, "AXSize" as CFString, &axSize)

var position = CGPoint()
var size = CGSize()
if #available(OSX 10.11, *) {
  AXValueGetValue(axPosition as! AXValue,  AXValueType.cgPoint, &position)
  AXValueGetValue(axSize as! AXValue,  AXValueType.cgSize, &size)
} else {
  print("OS Not supported.")
}

let responseDict: [String: Int] = [
  "x": Int(position.x),
  "y": Int(position.y),
  "width": Int(size.width),
  "height": Int(size.height),
]

// print(responseDict)


if let theJSONData = try? JSONSerialization.data(
  withJSONObject: responseDict,
  options: [.prettyPrinted]
) {
  let theJSONText = String(data: theJSONData, encoding: .ascii)
  print(theJSONText!)
}

// print(size)



// AXValueGetValue(mem as! AXValue, AXValueType.CGSize, &val)

// var names2: CFArray?
// let error2 = AXUIElementCopyAttributeNames(focused as! AXUIElement, &names2)
// print(names2!)

// let count = CFArrayGetCount(elements);
//
