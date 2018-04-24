//
//  VPOSView.swift
//  vPOSSample
//
//  Created by Mauricio on 4/24/18.
//  Copyright © 2018 Mauricio Cousillas. All rights reserved.
//

import UIKit
import WebKit

/**
 Enum that specifies all the available modes for a VPOSView

 - sandbox: Uses sandbox base URLs.
 - production: Uses production URLs.

 These modes only affect the services consumend by the view,
 all it's behaviour will stay the same between modes.
*/
public enum VPOSMode {
  case sandbox
  case production
}

/// Keys used for parameter decoding and encoding.
struct VPOSKeys {
  static let payload = "payload"
  static let paymentSuccess = "payment_success"
  static let creationSuccess = "add_new_card_success"
  static let returnURL = "return_url"
  static let details = "details"
  static let message = "message"
  static let processId = "process_id"
  static let styles = "styles"
}

/**
 Base class that implements common behaviour for communicating with VPOS.
 You should not need to use this class directly, but their sub-classes: `CardVPOSView` and `CheckoutVPOSView`.
*/
public class VPOSView: UIView {
  /// base URL used for production requests.
  open var productionBaseURL: String {
    return ""
  }
  /// base URL used for sandbox requests.
  open var sandboxBaseURL: String {
    return ""
  }
  /// mode used to define wether to use production or sandbox constants, production by default.
  public var mode: VPOSMode = .production
  /// Computed propperty that provides the service base URL depending on the currently active mode.
  public var baseURL: String {
    switch mode {
    case .production:
      return productionBaseURL
    case .sandbox:
      return sandboxBaseURL
    }
  }
  /// handler identifier used to register the WKMessageHandler and bridge from javascript to native
  public let handlerName = "callbackHandler"
  /// Script file name used to inject code into the frame when loaded.
  private let jsFileName = "EventHandler"
  /// File extension used to load javascript files.
  private let jsFileExtension = "js"

  /// Content controller configuration to use inside the WKWebView.
  private lazy var contentController: WKUserContentController = {
    let contentController = WKUserContentController()
    let script = WKUserScript(source: loadScriptFromJS(), injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    contentController.addUserScript(script)
    contentController.add(self, name: handlerName)
    return contentController
  }()
  /// WKWebView initialization.
  private lazy var webView: WKWebView = {
    let webConfig = WKWebViewConfiguration()
    webConfig.userContentController = contentController
    let webView = WKWebView(frame: .zero, configuration: webConfig)
    webView.translatesAutoresizingMaskIntoConstraints = false
    webView.uiDelegate = self
    webView.navigationDelegate = self
    return webView
  }()

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  public override func awakeFromNib() {
    super.awakeFromNib()
    setup()
  }

  public override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  /**
   Makes a load request for an specific process_id, loading it inside the VPOSView as a form.

   Parameters:
      - processId: The process_id of your transaction.
      - styles: Your custom styles for the form.
  */
  public func load(with processId: String, styles: [String: String] = [:]) {
    var urlComponents = URLComponents(string: "\(baseURL)\(processId)")
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    if let styleData = try? encoder.encode(styles), let styleString = String(data: styleData, encoding: .utf8) {
      urlComponents?.queryItems = [
        URLQueryItem(name: VPOSKeys.processId, value: processId),
        URLQueryItem(name: VPOSKeys.styles, value: styleString)
      ]
    }
    guard let url = urlComponents?.url else { return }
    webView.load(URLRequest(url: url))
  }
  /**
   Point of connection between the events that happen inside the VPOSView and the application.

   This method MUST be implemented by it's subclasses (as CardVPOSView and CheckoutVPOSView do) to define the specific behaviour for their form events.
  */
  open func handleMessage(_ message: WKScriptMessage) {
    assertionFailure("You must implement this handler in any VPOSView subclass")
  }
  /// Helper for view setup.
  private func setup() {
    addSubview(webView)
    translatesAutoresizingMaskIntoConstraints = false
    let constraints = [
      NSLayoutConstraint(item: webView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: webView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: webView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: webView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)
    ]
    NSLayoutConstraint.activate(constraints)
  }
  /// Helper for loading js files.
  private func loadScriptFromJS() -> String {
    guard
      let location = Bundle.main.path(forResource: jsFileName, ofType: jsFileExtension),
      let source = try? String(contentsOfFile: location)
    else {
      return ""
    }
    return source
  }
}

extension VPOSView: WKUIDelegate {}

extension VPOSView: WKNavigationDelegate {}

extension VPOSView: WKScriptMessageHandler {
  public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    handleMessage(message)
  }
}
