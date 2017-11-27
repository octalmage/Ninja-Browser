import AppKit
let frontmostAppPID = NSWorkspace.shared().frontmostApplication?.processIdentifier

func getRole(element: AXUIElement) -> String {
  var axRole: AnyObject?
  AXUIElementCopyAttributeValue(element, "AXRole" as CFString, &axRole)

  var role: String = ""
  if axRole != nil  {
    role = axRole as! String
  }

  return role
}

func getSubRole(element: AXUIElement) -> String {
  var axSubRole: AnyObject?
  AXUIElementCopyAttributeValue(element, "AXSubrole" as CFString, &axSubRole)

  var subRole: String = ""
  if axSubRole != nil  {
    subRole = axSubRole as! String
  }

  return subRole
}

func getChildren(element: AXUIElement) -> [AXUIElement] {
  var axChildren: AnyObject?
  let _ = AXUIElementCopyAttributeValue(element, "AXChildren" as CFString, &axChildren)
  var children: [AXUIElement] = []

  if axChildren != nil {
    children = axChildren as! [AXUIElement]
  }
  return children
}

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
  if frame.height < 100 || frame.width < 100 {
    return [:]
  }

  let role = getRole(element: element)

  // Filter out roles that aren't useful.
  if role == "AXMenuItem" {
    return [:]
  }

  let responseDict: [String: Any] = [
    "x": Int(frame.minX),
    "y": Int(frame.minY),
    "width": Int(frame.width),
    "height": Int(frame.height),
    "role": role,
    "subRole": getSubRole(element: element),
  ]

  return responseDict
}

/**
 * TODO: Optimize this. I figured that a tail call optimization would work, but
 * apparently Swift doesn't guarantee tail call optimizations, so it will have
 * to be a solution that isn't recursive.
 */
func getBoundsForChildren(element: AXUIElement) -> [[String: Any]] {
  var allElementsBounds: [[String: Any]] = []

  let bounds = getBounds(element: element)
  var children: [AXUIElement] = []
  if !bounds.isEmpty {
    allElementsBounds.append(bounds)
    children = getChildren(element: element)
  }

  if !children.isEmpty {
    for child in children {
      var boundsforChildren = getBoundsForChildren(element: child)
      /**
       * Elements within a scroll area extend outside the standard frame of the
       * element. For example, if the scroll area is x0, y0, w100, h200 and it
       * contains a textarea, that textarea's y could be -1000 if the scroll
       * area is scrolled to the bottom. For now I'm just assigning the height
       * and y to the scroll area to the children, but this is just a hack.
       * TODO: Figure this out.
       *
       */
      if bounds["role"] != nil && bounds["role"] as! String == "AXScrollArea" {
        for index in 0..<boundsforChildren.count {
          boundsforChildren[index]["height"] = bounds["height"]
          boundsforChildren[index]["width"] = bounds["width"]
          boundsforChildren[index]["x"] = bounds["x"]
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
  options: []
) {
  let theJSONText = String(data: theJSONData, encoding: .ascii)
  print(theJSONText!)
}
