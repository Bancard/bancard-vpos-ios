
window.addEventListener("message", function(event) {
  window.webkit.messageHandlers.callbackHandler.postMessage(
    {
      payload: event.data
    }
  );
});
