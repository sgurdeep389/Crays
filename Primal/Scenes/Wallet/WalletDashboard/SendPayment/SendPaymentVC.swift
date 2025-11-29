//
//  SendPaymentVC.swift
//  Crays
//
//  Created by Gurdeep Singh  on 27/11/25.
//

import UIKit
import BreezSdkSpark

class SendPaymentVC: UIViewController {
    @IBOutlet weak var mainContainerView: UIView!                // haT-6t-d6J
    @IBOutlet weak var titleLabel: UILabel!                      // yVD-Tk-pCr
    @IBOutlet weak var closeButton: UIButton!                    // RCP-mU-Uc1

    @IBOutlet weak var mainStackView: UIStackView!               // gxr-ZQ-fDe

    @IBOutlet weak var inputContainerView: UIView!               // sOh-L9-agd
    @IBOutlet weak var descriptionLabel: UILabel!                // mr4-fi-o3X

    @IBOutlet weak var textAreaBackgroundView: UIView!           // MjU-nF-Mvq
    @IBOutlet weak var invoiceTextView: UITextView!            // yE0-1y-8md

    @IBOutlet weak var continueButtonContainer: UIStackView!     // Ck7-nc-CjB
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var createErrorMsgLbl: UILabel!
    @IBOutlet weak var viewQRCodeScaner: QRScannerView!

    
    var sendSats:(String,InputType) -> Void = {_,_ in}
    var address:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainContainerView.layer.cornerRadius = 10
        self.continueButton.layer.cornerRadius = 10
        self.textAreaBackgroundView.layer.borderWidth = 1
        self.textAreaBackgroundView.layer.borderColor = #colorLiteral(red: 0.8857043386, green: 0.9106176496, blue: 0.9402578473, alpha: 1)
        self.textAreaBackgroundView.layer.cornerRadius = 10
        self.viewQRCodeScaner.delegate = self
        self.viewQRCodeScaner.startScanning()
        self.invoiceTextView.text = self.address
    }

    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: false)
    }

    @IBAction func continueButtonTapped(_ sender: UIButton) {
        self.checkAddressValid(address: self.invoiceTextView.text ?? "")
    }
    
    func checkAddressValid(address:String){
        if address.trimmingCharacters(in: .whitespaces) != ""{
            self.createErrorMsgLbl.isHidden = true
            Task{
                let isValid = await BreezViewModel.shared.isValidAddress(address)
                if isValid.0{
                    self.dismiss(animated: false) {
                        self.sendSats(address,isValid.1!)
                    }
                }
                else{
                    self.createErrorMsgLbl.text = "invalid input"
                    self.createErrorMsgLbl.isHidden = false
                }
            }
        }
    }
    
}

extension SendPaymentVC:QRScannerViewDelegate{
    func didScan(code: String) {
        self.checkAddressValid(address: code)
    }
}
