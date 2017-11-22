type element = {
  .
  height: int, width: int, x: int, y: int, role: string, subRole: string
};

type elements = array(element);

let getLargestElement = (elements) => {
  Js.log(elements);
  let bestElement = ref(None);
  let bestArea: ref(int) = ref(0);
  let elementsLength: int = Array.length(elements);
  let elementsToSkip = [
    "",
    "AXWindow",
    "AXMenu",
    "AXMenuBar",
    "AXMenuBarItem",
    "AXSplitGroup"
  ];
  for (i in 0 to elementsLength - 1) {
    let element = elements[i];
    let filteredElements = Js.Array.filter((element) => Js.Array.includes())
    if Js.Arrayfilter(()) {
      let newArea = element##height * element##width;
      Js.log(newArea);
      if (newArea > bestArea^) {
        bestElement := Some(element);
        bestArea := newArea;
        ()
      }
    }
  };
  /* if !bestElement || bestElement##width < 100 || bestElement##height < 100) {
       ([bestElement] = elements.filter(element => ["AXWindow", "AXStandardWindow"].includes(element.role)));
       bestElement##y += 20;
       bestElement##height -= 20;
     } */
  switch bestElement^ {
  | None => Js.Obj.empty()
  | Some(element) => element
  }
};
