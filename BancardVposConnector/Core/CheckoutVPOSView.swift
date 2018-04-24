//
//  CheckoutVPOSView.swift
//  vPOSSample
//
//  Created by Mauricio on 4/24/18.
//  Copyright © 2018 Mauricio Cousillas. All rights reserved.
//

import Foundation
import UIKit
import WebKit

public protocol CheckoutVPOSDelegate: class {
  func paymentSuccess(with returnURL: String)
  func paymentFailed(with returnURL: String)
}

public final class CheckoutVPOSView: VPOSView {
  public weak var delegate: CheckoutVPOSDelegate?

  override public var productionBaseURL: String {
    return "https://vpos.infonet.com.py/checkout/new?"
  }

  override public var sandboxBaseURL: String {
    return "https://vpos.infonet.com.py:8888/checkout/new?"
  }

  override public func handleMessage(_ message: WKScriptMessage) {
    guard
      message.name == handlerName,
      let body = message.body as? [String: Any],
      let payload = body[VPOSKeys.payload] as? [String: Any],
      let result = payload[VPOSKeys.message] as? String,
      let returnURL = payload[VPOSKeys.returnURL] as? String
      else { return }
    switch result {
    case VPOSKeys.paymentSuccess:
      delegate?.paymentSuccess(with: returnURL)
    default:
      delegate?.paymentFailed(with: returnURL)
    }
  }
}
