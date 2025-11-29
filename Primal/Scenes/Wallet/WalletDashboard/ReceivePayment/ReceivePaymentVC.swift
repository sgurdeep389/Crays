//
//  ReceivePaymentVC.swift
//  Crays
//
//  Created by Gurdeep Singh  on 26/11/25.
//

import UIKit

class ReceivePaymentVC: UIViewController {
    
    // MARK: - Top Header
    @IBOutlet weak var titleLabel: UILabel!                  // Mq5-96-70h
    @IBOutlet weak var closeButton: UIButton!                // Lf8-VW-N8M
    @IBOutlet weak var mainView: UIView!                     // 3pq-Px-KlY


    // MARK: - Segmented Control
    @IBOutlet weak var segmentControl: UISegmentedControl!   // PGR-9J-h5D

    // MARK: - StackView Container
    @IBOutlet weak var containerStackView: UIStackView!      // uor-PH-Lrx

    // MARK: - Bitcoin Deposit View
    @IBOutlet weak var btcView: UIView!                      // sMF-iw-Lze
    @IBOutlet weak var btcQRImageView: UIImageView!          // UeC-1C-rgm
    @IBOutlet weak var btcDescriptionLabel: UILabel!         // qiq-r5-6av
    @IBOutlet weak var btcAddressContainer: UIView!          // Oqr-C5-r5d
    @IBOutlet weak var btcAddressInnerView: UIView!          // uWB-jg-oGI
    @IBOutlet weak var btcAddressLabel: UILabel!             // VX2-7g-QEr
    @IBOutlet weak var btcCopyButton: UIButton!              // jFT-uO-JOg
    @IBOutlet weak var btcQRView: UIView!          // UeC-1C-rgm

    // MARK: - Lightning View
    @IBOutlet weak var lightningView: UIView!                // mtH-fh-zKV
    @IBOutlet weak var lightningQRImageView: UIImageView!    // xZu-pA-Xoc
    @IBOutlet weak var lightningDescriptionLabel: UILabel!   // lkr-On-Qj2
    @IBOutlet weak var lightningAddressContainer: UIView!    // lWE-5Z-box
    @IBOutlet weak var lightningAddressInnerView: UIView!    // g30-6U-3Di
    @IBOutlet weak var lightningAddressLabel: UILabel!       // QjP-Ck-US2
    @IBOutlet weak var lightningCopyButton: UIButton!        // w5x-8I-RpD
    @IBOutlet weak var lightningQRView: UIView!
    
    
    // MARK: - Create Lightning Address View
    @IBOutlet weak var createAddressView: UIView!            // mmC-PU-hk4
    @IBOutlet weak var createAddressTitle: UILabel!          // mxA-Cx-PV8
    @IBOutlet weak var createAddressSubtitle: UILabel!       // Xz6-S3-eQh
    @IBOutlet weak var usernameTextFieldContainer: UIView!   // b5g-gF-SKa
    @IBOutlet weak var usernameTextField: UITextField!       // 8nb-Dn-fNA
    @IBOutlet weak var createAddressButtonsStack: UIStackView! // 4Me-hG-mr1
    @IBOutlet weak var cancelButton: UIButton!               // Mgc-69-1m0
    @IBOutlet weak var createAddressButton: UIButton!
    @IBOutlet weak var createErrorMsgLbl: UILabel!
    var editingAddress:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainView.layer.cornerRadius = 10
        self.lightningAddressInnerView.layer.cornerRadius = 10
        self.lightningAddressContainer.layer.cornerRadius = 10
        self.lightningAddressContainer.layer.borderWidth = 1
        self.lightningAddressContainer.layer.borderColor = #colorLiteral(red: 0.8857043386, green: 0.9106176496, blue: 0.9402578473, alpha: 1)
        self.btcAddressInnerView.layer.cornerRadius = 10
        self.btcAddressContainer.layer.cornerRadius = 10
        self.btcAddressContainer.layer.borderWidth = 1
        self.btcAddressContainer.layer.borderColor = #colorLiteral(red: 0.8857043386, green: 0.9106176496, blue: 0.9402578473, alpha: 1)

        self.lightningQRView.layer.borderWidth = 1
        self.lightningQRView.layer.borderColor = #colorLiteral(red: 0.8857043386, green: 0.9106176496, blue: 0.9402578473, alpha: 1)
        self.lightningQRView.layer.cornerRadius = 10

        self.btcQRView.layer.borderWidth = 1
        self.btcQRView.layer.borderColor = #colorLiteral(red: 0.8857043386, green: 0.9106176496, blue: 0.9402578473, alpha: 1)
        self.btcQRView.layer.cornerRadius = 10

        self.btcCopyButton.layer.cornerRadius = 10
        self.lightningCopyButton.layer.cornerRadius = 10
        
        self.cancelButton.layer.cornerRadius = 10
        self.createAddressButton.layer.cornerRadius = 10
        
        self.cancelButton.layer.borderWidth = 1
        self.cancelButton.layer.borderColor = #colorLiteral(red: 0.8857043386, green: 0.9106176496, blue: 0.9402578473, alpha: 1)

        self.usernameTextFieldContainer.layer.borderWidth = 1
        self.usernameTextFieldContainer.layer.borderColor = #colorLiteral(red: 0.8857043386, green: 0.9106176496, blue: 0.9402578473, alpha: 1)
        self.usernameTextFieldContainer.layer.cornerRadius = 10
        self.setDefaultView()
    }

    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
    
    
    func setDefaultView(){
        Task{
            if let address = await BreezViewModel.shared.gettingLightningAddress(){
                self.createAddressView.isHidden = true
                self.lightningView.isHidden = false
                self.lightningQRImageView.image = BreezViewModel.shared.generateQRCode(from: address.0)
                self.lightningAddressLabel.text = address.0
                self.btcView.isHidden = true
                self.segmentControl.selectedSegmentIndex = 0
            }
            else{
                self.segmentControl.selectedSegmentIndex = 1
                self.createAddressView.isHidden = true
                self.lightningView.isHidden = true
                self.btcView.isHidden = false
                Task{
                    if let address =  await BreezViewModel.shared.createBitcoinAddress(){
                        self.btcQRImageView.image = BreezViewModel.shared.generateQRCode(from: address)
                        self.btcAddressLabel.text = address
                    }
                }
            }
        }
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            Task{
                if let address = await BreezViewModel.shared.gettingLightningAddress(){
                    self.createAddressView.isHidden = true
                    self.lightningView.isHidden = false
                    self.lightningQRImageView.image = BreezViewModel.shared.generateQRCode(from: address.0)
                    self.lightningAddressLabel.text = address.0
                }
                else{
                    self.createAddressView.isHidden = false
                    self.lightningView.isHidden = true
                }
                self.btcView.isHidden = true
            }
        }
        else{
            self.createAddressView.isHidden = true
            self.lightningView.isHidden = true
            self.btcView.isHidden = false
            Task{
                if let address =  await BreezViewModel.shared.createBitcoinAddress(){
                    self.btcQRImageView.image = BreezViewModel.shared.generateQRCode(from: address)
                    self.btcAddressLabel.text = address
                }
            }
        }
    }

    @IBAction func btcCopyAddressTapped(_ sender: UIButton) {
        UIPasteboard.general.string = self.btcAddressLabel.text
    }

    @IBAction func lightningCopyAddressTapped(_ sender: UIButton) {
        UIPasteboard.general.string = self.lightningAddressLabel.text
    }

    @IBAction func cancelCreateAddressTapped(_ sender: UIButton) {
        if self.editingAddress == true{
            self.createAddressView.isHidden = true
            self.lightningView.isHidden = false
        }
        else{
            self.usernameTextField.text = ""
        }
    }

    @IBAction func createAddressTapped(_ sender: UIButton) {
        if (self.usernameTextField.text?.trimmingCharacters(in: .whitespaces).count ?? 0) < 3{
            self.createErrorMsgLbl.text = "Username must be at least 3 characters"
            self.createErrorMsgLbl.isHidden = false
        }
        else{
            if let address = self.usernameTextField.text?.trimmingCharacters(in: .whitespaces){
                self.createErrorMsgLbl.isHidden = true
                Task{
                    let response = await BreezViewModel.shared.createLightningAddress(username: address)
                    if let invoice = response.invoice{
                        self.lightningQRImageView.image = BreezViewModel.shared.generateQRCode(from: invoice)
                        self.lightningAddressLabel.text = invoice
                        self.createAddressView.isHidden = true
                        self.lightningView.isHidden = false
                    }
                    else{
                        self.createErrorMsgLbl.isHidden = false
                        self.createErrorMsgLbl.text = response.error?.localizedDescription
                    }
                }
            }
        }
    }
    @IBAction func editLightningAddressTapped(_ sender: UIButton) {
        Task{
            if let address = await BreezViewModel.shared.gettingLightningAddress(){
                self.createAddressView.isHidden = false
                self.lightningView.isHidden = true
                self.usernameTextField.text = address.1
                self.editingAddress = true
            }
        }
    }
}
