import { Controller } from "stimulus";
export default class extends Controller {
  static targets = ["template", "fields"];

  add_association(e) {
    e.preventDefault();
    const newField = this.templateTarget.innerHTML.replace(
      /NEW_RECORD/g,
      new Date().getTime()
    );
    this.fieldsTarget.insertAdjacentHTML("beforeend", newField);
  }

  remove_association(e) {
    e.preventDefault();
    const fieldsWrapper = e.target.closest(".fields-wrapper");
    if (!fieldsWrapper) {
      return;
    }
    const destroyField = fieldsWrapper.querySelector("input[name*='_destroy']");
    if (fieldsWrapper && fieldsWrapper.dataset.new_record == "true") {
      fieldsWrapper.remove();
    } else {
      fieldsWrapper.style.display = "none";
      destroyField && (destroyField.value = 1);
    }
  }
}
