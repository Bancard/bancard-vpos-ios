//
//  ViewController.swift
//  BancardVposConnector
//
//  Created by Mauricio Cousillas on 04/24/2018.
//  Copyright (c) 2018 Mauricio Cousillas. All rights reserved.
//

import UIKit
import WebKit
import BancardVposConnector

class ViewController: UIViewController {
  @IBOutlet weak var vPOSContainer: UIView!
  @IBOutlet weak var processIdField: UITextField!

  lazy var vPView: VPOSView = {
    let vpView = CheckoutVPOSView()
    vpView.delegate = self
    vpView.mode = .sandbox
    return vpView
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    vPOSContainer.addSubview(vPView)
    vPView.attach(to: vPOSContainer)
  }

  @IBAction func loadFormTapped(_ sender: UIButton) {
    vPView.load(with: processIdField.text ?? "", styles: ["form-background-color": "#12d431"])
  }
}

extension ViewController: CheckoutVPOSDelegate {
  func paymentFailed(with returnURL: String) {
    print("Received fail message data")
    print(returnURL)
  }

  func paymentSuccess(with returnURL: String) {
    print("Received success message data")
    print(returnURL)
  }
}

extension UIView {
  public func attach(to container: UIView, topMargin: CGFloat = 0.0, rightMargin: CGFloat = 0.0, bottomMargin: CGFloat = 0.0, leftMargin: CGFloat = 0.0) {
    translatesAutoresizingMaskIntoConstraints = false
    let constraints = [
      NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: container, attribute: .width, multiplier: 1.0, constant: -(rightMargin + leftMargin)),
      NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: container, attribute: .height, multiplier: 1.0, constant: -(topMargin + bottomMargin)),
      NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: container, attribute: .centerX, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: container, attribute: .centerY, multiplier: 1.0, constant: 0.0)
    ]
    NSLayoutConstraint.activate(constraints)
  }
}
