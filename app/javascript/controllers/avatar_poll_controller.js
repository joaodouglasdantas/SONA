import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["elapsed"]

  connect() {
    this.startedAt = Date.now()
    this.frame     = this.element.closest("turbo-frame")
    this.pollTimer  = setInterval(() => this.reload(), 4000)
    this.clockTimer = setInterval(() => this.updateClock(), 1000)
  }

  disconnect() {
    clearInterval(this.pollTimer)
    clearInterval(this.clockTimer)
  }

  reload() {
    if (this.frame) this.frame.reload()
  }

  updateClock() {
    if (!this.hasElapsedTarget) return
    const elapsed = Math.floor((Date.now() - this.startedAt) / 1000)
    const mins    = Math.floor(elapsed / 60)
    const secs    = elapsed % 60
    this.elapsedTarget.textContent = mins > 0
      ? `${mins}m ${String(secs).padStart(2, "0")}s`
      : `${secs}s`
  }
}
