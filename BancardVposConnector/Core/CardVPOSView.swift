//
//  CardVPOSView.swift
//  vPOSSample
//
//  Created by Mauricio on 4/24/18.
//  Copyright © 2018 Mauricio Cousillas. All rights reserved.
//

import Foundation
import UIKit
import WebKit

public protocol CardVPOSDelegate: class {
  func cardCreationSuccess(with returnURL: String)
  func cardCreationFailed(with details: String, and returnURL: String)
}

public final class CardVPOSView: VPOSView {
  public weak var delegate: CardVPOSDelegate?

  override public var productionBaseURL: String {
    return "https://vpos.infonet.com.py/checkout/register_card/new?"
  }

  override public var sandboxBaseURL: String {
    return "https://vpos.infonet.com.py:8888/checkout/register_card/new?"
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
    case VPOSKeys.creationSuccess:
      delegate?.cardCreationSuccess(with: returnURL)
    default:
      let details = payload[VPOSKeys.details] as? String ?? ""
      delegate?.cardCreationFailed(with: details, and: returnURL)
    }
  }
}
