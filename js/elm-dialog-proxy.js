// SPDX-License-Identifier: BSD-3-Clause
// Copyright (c) 2025 curtissimo, llc. All Rights Reserved.

class ElmDialogProxy extends HTMLElement {
  static observedAttributes = ["open", "for", "debug"];

  constructor() {
    super();
    this._open = false;
    this._for = "";
    this._inProperty = false;
    this._canceled = false;
    this._handleCancel = this._handleCancel.bind(this);
    this._handleClose = this._handleClose.bind(this);
    this._debug = false;
    document.addEventListener("DOMContentLoaded", () => this._subscribeFor());
  }

  attributeChangedCallback(name, _, newValue) {
    if (this._inProperty) {
      return;
    }

    if (name === "debug") {
      this._debug = newValue !== null;
    }

    if (name === "open") {
      this._open = newValue === null;
    }

    if (name === "for") {
      this._unsubscribeFor();
      this._for = newValue;
      this._subscribeFor();
    }
  }

  connectedCallback() {
    const _for = this.getAttribute("for");
    if (this._for === "" && _for) {
      this._for = _for;
    }

    const _open = this.getAttribute("open");
    if (this._open === false && _open) {
      this._open = true;
    }
  }

  get debug() {
    return this._debug;
  }

  set debug(value) {
    this._debug = value;
  }

  get open() {
    return this._open;
  }

  set open(value) {
    this._open = value;

    if (this._open) {
      this._getElement()?.showModal();
    } else {
      this._getElement()?.close();
    }

    this._inProperty = true;
    if (value) {
      this.setAttribute("open", "");
    } else {
      this.removeAttribute("open");
    }
    this._inProperty = false;
  }

  get htmlFor() {
    return this._for;
  }

  set htmlFor(value) {
    this._unsubscribeFor();

    this._for = value;
    this._inProperty = true;
    this.setAttribute("for", value);
    this._inProperty = false;

    this._subscribeFor();
  }

  _getElement() {
    let element = null;
    if (this._for !== "") {
      element = document.getElementById(this._for);
      if (element === null && this._debug) {
        console.error("Cannot find element with id", this._for);
      }
      else if (!(element instanceof HTMLDialogElement) && this._debug) {
        console.error("Found non-HTMLDialogElement with id", this._for);
        element = null;
      }
    }
    return element;
  }

  _handleCancel(e) {
    this._canceled = true;
    const event = new CustomEvent("cancel", { bubbles: false, cancelable: true });
    this.dispatchEvent(event);
    if (event.defaultPrevented) {
      e.preventDefault();
      this._canceled = false;
    } else {
      this.open = false;
    }
  }

  _handleClose() {
    this.open = false;
    if (!this._canceled) {
      const event = new CustomEvent("close", { bubbles: false, cancelable: false });
      this.dispatchEvent(event);
    }
    this._canceled = false;
  }

  _subscribeFor() {
    this._getElement()?.addEventListener("cancel", this._handleCancel);
    this._getElement()?.addEventListener("close", this._handleClose);
  }

  _unsubscribeFor() {
    this._getElement()?.close();
    this._getElement()?.removeEventListener("cancel", this._handleCancel);
    this._getElement()?.removeEventListener("close", this._handleClose);
  }
}

window.customElements.define("elm-dialog-proxy", ElmDialogProxy);
