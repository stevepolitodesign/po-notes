import { Controller } from "stimulus";
import Sortable from "sortablejs";

export default class extends Controller {
  static targets = ["position"];

  connect() {
    this.updatePosition = this.updatePosition.bind(this);
    this.sortable = Sortable.create(this.element, {
      animation: 150,
      onEnd: this.updatePosition,
      handle: ".task-handle",
    });
  }

  updatePosition() {
    this.positionTargets.forEach(
      (positionTarget, index) => (positionTarget.value = index + 1)
    );
  }
}
