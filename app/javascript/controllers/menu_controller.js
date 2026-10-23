import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = ["button", "panel"]
  toggle() {
    const open = this.buttonTarget.getAttribute("aria-expanded") !== "true"
    this.buttonTarget.setAttribute("aria-expanded", String(open))
    this.panelTarget.hidden = !open
  }
}
