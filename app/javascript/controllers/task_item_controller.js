import { Controller } from "stimulus";
export default class extends Controller {
  static targets = ["title", "completed"];
  connect() {
    const completedCheckBox = this.completedTarget;
    this.toggle_complete(completedCheckBox);
  }

  toggle_complete(checkbox) {
    if (!checkbox) {
      return;
    }
    checkbox.checked && this.titleTarget
      ? this.titleTarget.setAttribute("disabled", true)
      : this.titleTarget.removeAttribute("disabled");
  }

  handle_click(e) {
    const checkbox = e.target;
    this.toggle_complete(checkbox);
  }
}
