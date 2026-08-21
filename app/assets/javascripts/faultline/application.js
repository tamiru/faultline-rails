class FaultlineController {
  static targets = ["activity"]

  connect() {
    this.showActivity = this.showActivity.bind(this)
    this.hideActivity = this.hideActivity.bind(this)

    document.addEventListener("turbo:before-fetch-request", this.showActivity)
    document.addEventListener("turbo:before-fetch-response", this.hideActivity)
    document.addEventListener("turbo:submit-end", this.hideActivity)
  }

  disconnect() {
    document.removeEventListener("turbo:before-fetch-request", this.showActivity)
    document.removeEventListener("turbo:before-fetch-response", this.hideActivity)
    document.removeEventListener("turbo:submit-end", this.hideActivity)
  }

  submit() {
    this.showActivity()
  }

  showActivity() {
    this.activityTarget?.classList.remove("hidden")
  }

  hideActivity() {
    this.activityTarget?.classList.add("hidden")
  }

  closeDetails(event) {
    event.preventDefault()
    const details = document.getElementById("exception-details")
    if (details) details.innerHTML = ""
  }
}

if (window.Stimulus) {
  window.Stimulus.register("faultline", FaultlineController)
}

export default FaultlineController
