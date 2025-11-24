//
//  CreateWalletViewController.swift
//  Crays
//
//  Created by Gurdeep Singh  on 22/11/25.
//

import UIKit
import Bip39

class CreateWalletViewController: UIViewController {
    @IBOutlet weak var lblMnemonic1: UILabel!
    @IBOutlet weak var lblMnemonic2: UILabel!
    @IBOutlet weak var lblMnemonic3: UILabel!
    @IBOutlet weak var lblMnemonic4: UILabel!
    @IBOutlet weak var lblMnemonic5: UILabel!
    @IBOutlet weak var lblMnemonic6: UILabel!
    @IBOutlet weak var lblMnemonic7: UILabel!
    @IBOutlet weak var lblMnemonic8: UILabel!
    @IBOutlet weak var lblMnemonic9: UILabel!
    @IBOutlet weak var lblMnemonic10: UILabel!
    @IBOutlet weak var lblMnemonic11: UILabel!
    @IBOutlet weak var lblMnemonic12: UILabel!
    @IBOutlet weak var viewMnemonic1: UIView!
    @IBOutlet weak var viewMnemonic2: UIView!
    @IBOutlet weak var viewMnemonic3: UIView!
    @IBOutlet weak var viewMnemonic4: UIView!
    @IBOutlet weak var viewMnemonic5: UIView!
    @IBOutlet weak var viewMnemonic6: UIView!
    @IBOutlet weak var viewMnemonic7: UIView!
    @IBOutlet weak var viewMnemonic8: UIView!
    @IBOutlet weak var viewMnemonic9: UIView!
    @IBOutlet weak var viewMnemonic10: UIView!
    @IBOutlet weak var viewMnemonic11: UIView!
    @IBOutlet weak var viewMnemonic12: UIView!
    @IBOutlet weak var viewMnemonic: UIView!
    @IBOutlet weak var btnHideUnHide: UIButton!
    @IBOutlet weak var btnCopy: UIButton!
    @IBOutlet weak var btnVerification: UIButton!
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var viewBottom: UIView!
    var isHiden:Bool = true
    var mnemonicString:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.title = "Create Wallet"
        
        self.viewTop.layer.cornerRadius = 15
        self.viewBottom.layer.cornerRadius = 15
        self.viewMnemonic1.layer.cornerRadius = 15
        self.viewMnemonic2.layer.cornerRadius = 15
        self.viewMnemonic3.layer.cornerRadius = 15
        self.viewMnemonic4.layer.cornerRadius = 15
        self.viewMnemonic5.layer.cornerRadius = 15
        self.viewMnemonic6.layer.cornerRadius = 15
        self.viewMnemonic7.layer.cornerRadius = 15
        self.viewMnemonic8.layer.cornerRadius = 15
        self.viewMnemonic9.layer.cornerRadius = 15
        self.viewMnemonic10.layer.cornerRadius = 15
        self.viewMnemonic11.layer.cornerRadius = 15
        self.viewMnemonic12.layer.cornerRadius = 15
        self.btnCopy.layer.cornerRadius = 15
        self.btnVerification.layer.cornerRadius = 15
        self.btnHideUnHide.layer.cornerRadius = 15
        self.viewMnemonic.layer.cornerRadius = 15

        
        self.viewTop.layer.borderWidth = 1
        self.viewBottom.layer.borderWidth = 1
        self.viewMnemonic1.layer.borderWidth = 1
        self.viewMnemonic2.layer.borderWidth = 1
        self.viewMnemonic3.layer.borderWidth = 1
        self.viewMnemonic4.layer.borderWidth = 1
        self.viewMnemonic5.layer.borderWidth = 1
        self.viewMnemonic6.layer.borderWidth = 1
        self.viewMnemonic7.layer.borderWidth = 1
        self.viewMnemonic8.layer.borderWidth = 1
        self.viewMnemonic9.layer.borderWidth = 1
        self.viewMnemonic10.layer.borderWidth = 1
        self.viewMnemonic11.layer.borderWidth = 1
        self.viewMnemonic12.layer.borderWidth = 1
        self.viewMnemonic.layer.borderWidth = 1
        self.btnCopy.layer.borderWidth = 1

        
        self.viewTop.layer.borderColor = #colorLiteral(red: 0.9864426255, green: 0.5066009164, blue: 0.5072095394, alpha: 1)
        self.viewBottom.layer.borderColor = #colorLiteral(red: 0.8857043386, green: 0.9106176496, blue: 0.9402578473, alpha: 1)
        self.viewMnemonic1.layer.borderColor = #colorLiteral(red: 0.8857043386, green: 0.9106176496, blue: 0.9402578473, alpha: 1)
        self.viewMnemonic2.layer.borderColor = #colorLiteral(red: 0.8857043386, green: 0.9106176496, blue: 0.9402578473, alpha: 1)
        self.viewMnemonic3.layer.borderColor = #colorLiteral(red: 0.8857043386, green: 0.9106176496, blue: 0.9402578473, alpha: 1)
        self.viewMnemonic4.layer.borderColor = #colorLiteral(red: 0.8857043386, green: 0.9106176496, blue: 0.9402578473, alpha: 1)
        self.viewMnemonic5.layer.borderColor = #colorLiteral(red: 0.8857043386, green: 0.9106176496, blue: 0.9402578473, alpha: 1)
        self.viewMnemonic6.layer.borderColor = #colorLiteral(red: 0.8857043386, green: 0.9106176496, blue: 0.9402578473, alpha: 1)
        self.viewMnemonic7.layer.borderColor = #colorLiteral(red: 0.8857043386, green: 0.9106176496, blue: 0.9402578473, alpha: 1)
        self.viewMnemonic8.layer.borderColor = #colorLiteral(red: 0.8857043386, green: 0.9106176496, blue: 0.9402578473, alpha: 1)
        self.viewMnemonic9.layer.borderColor = #colorLiteral(red: 0.8857043386, green: 0.9106176496, blue: 0.9402578473, alpha: 1)
        self.viewMnemonic10.layer.borderColor = #colorLiteral(red: 0.8857043386, green: 0.9106176496, blue: 0.9402578473, alpha: 1)
        self.viewMnemonic11.layer.borderColor = #colorLiteral(red: 0.8857043386, green: 0.9106176496, blue: 0.9402578473, alpha: 1)
        self.viewMnemonic12.layer.borderColor = #colorLiteral(red: 0.8857043386, green: 0.9106176496, blue: 0.9402578473, alpha: 1)
        self.viewMnemonic.layer.borderColor = #colorLiteral(red: 0.8857043386, green: 0.9106176496, blue: 0.9402578473, alpha: 1)
        self.btnCopy.layer.borderColor = #colorLiteral(red: 0.8857043386, green: 0.9106176496, blue: 0.9402578473, alpha: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let phrase = try? Mnemonic().mnemonic(),phrase.count > 11{
            self.mnemonicString = phrase.joined(separator: " ")
            self.lblMnemonic1.text = phrase[0]
            self.lblMnemonic2.text = phrase[1]
            self.lblMnemonic3.text = phrase[2]
            self.lblMnemonic4.text = phrase[3]
            self.lblMnemonic5.text = phrase[4]
            self.lblMnemonic6.text = phrase[5]
            self.lblMnemonic7.text = phrase[6]
            self.lblMnemonic8.text = phrase[7]
            self.lblMnemonic9.text = phrase[8]
            self.lblMnemonic10.text = phrase[9]
            self.lblMnemonic11.text = phrase[10]
            self.lblMnemonic12.text = phrase[11]
        }
    }
    
    @IBAction func btnActionHide(_ sender: UIButton) {
        self.isHiden.toggle()
        if self.isHiden{
            self.btnHideUnHide.setTitle("Reveal", for: .normal)
            self.btnHideUnHide.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        }
        else{
            self.btnHideUnHide.setTitle("Hide", for: .normal)
            self.btnHideUnHide.setImage(UIImage(systemName: "eye"), for: .normal)
        }
    }
    
    
    @IBAction func btnActionCopy(_ sender: UIButton) {
        UIPasteboard.general.string = self.mnemonicString
        self.btnCopy.setTitle("Copied", for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.btnCopy.setTitle("Copy to Clipboard", for: .normal)
        }
    }
    
    @IBAction func btnActionVerification(_ sender: UIButton) {
        let vc = VerificationVC()
        vc.mnemonicString = self.mnemonicString
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

