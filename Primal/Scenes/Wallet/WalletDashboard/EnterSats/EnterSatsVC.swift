//
//  EnterSatsVC.swift
//  Crays
//
//  Created by Gurdeep Singh  on 29/11/25.
//

import UIKit
import BreezSdkSpark

class EnterSatsVC: UIViewController {

    // MARK: - Views
    @IBOutlet weak var containerView: UIView!          // id="ioY-7o-Fjc"
    @IBOutlet weak var lightningAddressLabel: UILabel! // id="OJp-YL-pdt"
    @IBOutlet weak var satsLabel: UILabel!            // id="E6h-8E-4KV"
    
    // TextField
    @IBOutlet weak var satsTextField: UITextField!    // id="0Zb-vk-Ga5"
    @IBOutlet weak var textContainerView: UIView!
    
    
    // Warning Label (hidden)
    @IBOutlet weak var warningLabel: UILabel!         // id="BmR-nx-Cc3"
    
    // Buttons
    @IBOutlet weak var deleteButton: UIButton!        // id="vkR-cb-fIg"
    @IBOutlet weak var backButton: UIButton!          // id="2ZA-iD-mWm"
    @IBOutlet weak var continueButton: UIButton!
    
    @IBOutlet weak var enterSatStackView: UIStackView!
    @IBOutlet weak var paymentConfirmStackView: UIStackView!
    
    @IBOutlet weak var enterSatView: UIStackView!
    @IBOutlet weak var paymentConfirmView: UIStackView!
    
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var paymentAddressLbl: UILabel!

    
    
    
    
    var back:(String) -> Void = { _ in}
    var address:String = ""
    var inputType:InputType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.satsTextField.delegate = self
        self.satsTextField.keyboardType = .numberPad
        self.containerView.layer.cornerRadius = 10
        self.continueButton.layer.cornerRadius = 10
        self.backButton.layer.borderWidth = 1
        self.backButton.layer.borderColor = #colorLiteral(red: 0.8857043386, green: 0.9106176496, blue: 0.9402578473, alpha: 1)
        self.backButton.layer.cornerRadius = 10
        
        self.textContainerView.layer.borderWidth = 1
        self.textContainerView.layer.borderColor = #colorLiteral(red: 0.8857043386, green: 0.9106176496, blue: 0.9402578473, alpha: 1)
        self.textContainerView.layer.cornerRadius = 10
        if self.inputType == .bitcoinAddress(.init(address: self.address, network: .bitcoin, source: .init(bip21Uri: nil, bip353Address: nil))){
            self.lightningAddressLabel.text = "Bitcoin Address"
        }
        else{
            self.lightningAddressLabel.text = "Lightning Address"
        }
    }


    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        dismiss(animated: false)
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: false) {
            self.back(self.address)
        }
    }

    @IBAction func continueButtonTapped(_ sender: UIButton) {
        if (Int(self.satsTextField.text ?? "0") ?? 0) > 0{
            self.warningLabel.isHidden = true
            Task{
              let response = await BreezViewModel.shared.preparingPayment(invoice: self.address, sats: (self.satsTextField.text ?? "0"))
                if response.2 != nil{
                    self.warningLabel.text = response.2
                    self.warningLabel.isHidden = false
                }
            }
        }
        else{
            self.warningLabel.text = "Please enter a valid amount"
            self.warningLabel.isHidden = false
        }
    }

}

extension EnterSatsVC:UITextFieldDelegate{
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        // Allow only digits (0–9)
        let allowed = CharacterSet.decimalDigits
        return string.rangeOfCharacter(from: allowed.inverted) == nil
    }
}
