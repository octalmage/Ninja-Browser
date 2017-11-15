import AppKit
let frontmostAppPID = NSWorkspace.shared().frontmostApplication?.processIdentifier

func getBounds(element: AXUIElement) -> [String: Any] {
  var axFrame: AnyObject?
  AXUIElementCopyAttributeValue(element, "AXFrame" as CFString, &axFrame)
  if axFrame == nil {
    return [:]
  }

  var frame = CGRect()
  if #available(OSX 10.11, *) {
    AXValueGetValue(axFrame as! AXValue,  AXValueType.cgRect, &frame)

  } else {
    // TODO: Fix this.
    print("OS Not supported.")
  }

  // Filter out small items.
  if frame.height == 0 || frame.width == 0 {
    return [:]
  }

  var axRole: AnyObject?
  AXUIElementCopyAttributeValue(element, "AXRole" as CFString, &axRole)

  var role: String = ""
  if axRole != nil  {
    role = axRole as! String
  }

  // Filter out roles that aren't useful.
  if role == "AXMenuItem" {
    return [:]
  }

  let responseDict: [String: Any] = [
    "x": Int(frame.minX),
    "y": Int(frame.minY),
    "width": Int(frame.width),
    "height": Int(frame.height),
    "role": role
  ]

  return responseDict
}

func getBoundsForChildren(element: AXUIElement) -> [[String: Any]] {
  var allElementsBounds: [[String: Any]] = []

  var axChildren: AnyObject?
  let _ = AXUIElementCopyAttributeValue(element, "AXChildren" as CFString, &axChildren)
  var children: [AXUIElement] = []

  if axChildren != nil {
    children = axChildren as! [AXUIElement]
  }

  let bounds = getBounds(element: element)
  if !bounds.isEmpty {
    allElementsBounds.append(bounds)
  }

  if !children.isEmpty {
    for child in children {
      var boundsforChildren = getBoundsForChildren(element: child)
      if bounds["role"] != nil && bounds["role"] as! String == "AXScrollArea" {
        for index in 0..<boundsforChildren.count {
          boundsforChildren[index]["height"] = bounds["height"]
          boundsforChildren[index]["y"] = bounds["y"]
        }
      }
      if !boundsforChildren.isEmpty {
        allElementsBounds += boundsforChildren
      }
    }
  }

  return allElementsBounds
}

let app = AXUIElementCreateApplication(frontmostAppPID!);

var axWidnow: AnyObject?
let _ = AXUIElementCopyAttributeValue(app, "AXFocusedWindow" as CFString, &axWidnow)

let responseDict = getBoundsForChildren(element: axWidnow as! AXUIElement)

if let theJSONData = try? JSONSerialization.data(
  withJSONObject: responseDict,
  options: [.prettyPrinted]
) {
  let theJSONText = String(data: theJSONData, encoding: .ascii)
  print(theJSONText!)
}
