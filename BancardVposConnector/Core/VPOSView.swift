//
//  VPOSView.swift
//  vPOSSample
//
//  Created by Mauricio on 4/24/18.
//  Copyright © 2018 Mauricio Cousillas. All rights reserved.
//

import UIKit
import WebKit

public enum VPOSMode {
  case sandbox
  case production
}

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

public class VPOSView: UIView {
  open var productionBaseURL: String {
    return ""
  }

  open var sandboxBaseURL: String {
    return ""
  }

  public var mode: VPOSMode = .production

  public var baseURL: String {
    switch mode {
    case .production:
      return productionBaseURL
    case .sandbox:
      return sandboxBaseURL
    }
  }

  public let handlerName = "callbackHandler"
  private let jsFileName = "EventHandler"
  private let jsFileExtension = "js"

  private lazy var contentController: WKUserContentController = {
    let contentController = WKUserContentController()
    let script = WKUserScript(source: loadScriptFromJS(), injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    contentController.addUserScript(script)
    contentController.add(self, name: handlerName)
    return contentController
  }()

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

  open func handleMessage(_ message: WKScriptMessage) {
    assertionFailure("You must implement this handler in any VPOSView subclass")
  }

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
