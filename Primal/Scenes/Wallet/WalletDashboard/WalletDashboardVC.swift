//
//  WalletDashboardVC.swift
//  Crays
//
//  Created by Gurdeep Singh  on 26/11/25.
//

import UIKit
import BreezSdkSpark

class WalletDashboardVC: UIViewController {
    @IBOutlet weak var viewTransactions: UIView!
    @IBOutlet weak var viewMoney: UIView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnReceive: UIButton!
    @IBOutlet weak var btnRefresh: UIButton!
    @IBOutlet weak var lblSatTotal: UILabel!
    @IBOutlet weak var tblTransactions: UITableView!
    
    var payment = [Payment]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        self.tblTransactions.delegate = self
        self.tblTransactions.dataSource = self
        self.tblTransactions.register(UINib(nibName: "TransactionsTableViewCell", bundle: nil), forCellReuseIdentifier: "TransactionsTableViewCell")
        self.btnReceive.layer.cornerRadius = 8
        self.btnSend.layer.cornerRadius = 8
        self.btnRefresh.layer.cornerRadius = 8
        self.btnRefresh.layer.borderWidth = 1
        self.btnRefresh.layer.borderColor = #colorLiteral(red: 0.8862745098, green: 0.9098039216, blue: 0.9411764706, alpha: 1)
        
        self.viewTransactions.layer.cornerRadius = 15
        self.viewMoney.layer.cornerRadius = 15
        self.setShadow(yourView: self.viewTransactions)
        self.setShadow(yourView: self.viewMoney)
        self.title = "Lightning Wallet"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout",style: .plain,target: self,action: #selector(self.logoutTapped))
        self.createWallet()
    }
    
    @objc func logoutTapped() {
        BreezViewModel.shared.logOut()
        self.navigationController?.popViewController(animated: true)
    }
    
    func setShadow(yourView:UIView){
        yourView.layer.shadowColor = UIColor.black.cgColor
        yourView.layer.shadowOpacity = 0.3
        yourView.layer.shadowOffset = CGSize(width: 0, height: 20)
        yourView.layer.shadowRadius = 30   // blur 60px ≈ radius 30
        yourView.layer.masksToBounds = false
    }
    
    @IBAction func btnSend(_ sender: UIButton) {
        self.sendPayment(address: "")
    }
    
    @IBAction func btnRefreash(_ sender: UIButton) {
        self.getWalletDetails()
    }
    
    func sendPayment(address:String){
        let vc = SendPaymentVC()
        vc.modalPresentationStyle = .overFullScreen
        vc.sendSats = { address,type in
            let vc = EnterSatsVC()
            vc.modalPresentationStyle = .overFullScreen
            vc.back = { address in
                self.sendPayment(address: address)
            }
            vc.address = address
            vc.inputType = type
            self.present(vc, animated: false)
        }
        vc.address = address
        self.present(vc, animated: false)
    }
    
    @IBAction func btnReceive(_ sender: UIButton) {
        let vc = ReceivePaymentVC()
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false)
    }
    
    func createWallet() {
        if let key = WalletManager1.shared.getSavedMnemonic(){
            if BreezViewModel.shared.sdk == nil{
                Task{
                    await BreezViewModel.shared.createWallet(keys: key)
                    self.getWalletDetails()
                }
            }
            else{
                self.getWalletDetails()
            }
        }
    }
    
    func getWalletDetails(){
        Task{
            self.getSatBalance()
            self.payment = await BreezViewModel.shared.gettingTransactionsListing()
            self.tblTransactions.reloadData()
        }
    }
    
    func getSatBalance(){
        Task {
            if let sats = await BreezViewModel.shared.getWalletBalance() {
                print("💰 Wallet Balance: \(sats) sats")
                self.lblSatTotal.text = sats.description
            }
        }
    }
}

extension WalletDashboardVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.payment.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionsTableViewCell", for: indexPath) as! TransactionsTableViewCell
        let dict = self.payment[indexPath.row]
        cell.lblAmount.text = (dict.paymentType == .receive ? "+" : "-") + dict.amount.description + " sats"
        cell.lblAmount.textColor = dict.paymentType == .receive ? #colorLiteral(red: 0.2803755403, green: 0.7351059914, blue: 0.4710562229, alpha: 1) : #colorLiteral(red: 0.8962805271, green: 0.2416780293, blue: 0.243843168, alpha: 1)
        cell.lblPaymentType.text = dict.paymentType == .receive ? "Received" : "Sent"
        cell.imgPayment.image = UIImage(named: "icons8-send-letter-100")?.rotated(by: dict.paymentType == .receive ? 180 : 0)
        cell.lblPaymentTime.text = Date(timeIntervalSince1970: TimeInterval(dict.timestamp)).formatDate()
        cell.viewPayment.backgroundColor = #colorLiteral(red: 0.9707724452, green: 0.9807206988, blue: 0.9891526103, alpha: 1)
        cell.viewPayment.layer.borderColor = #colorLiteral(red: 0.884686172, green: 0.9095019698, blue: 0.9390266538, alpha: 1)
        cell.viewPayment.layer.borderWidth = 1
        cell.viewPayment.layer.cornerRadius = 15
        
        return cell
    }
}


extension UIImage {
    func rotated(by degrees: CGFloat) -> UIImage? {
        let radians = degrees * .pi / 180
        
        let newSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: radians))
            .integral.size
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Move origin to middle
        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        // Rotate
        context.rotate(by: radians)
        // Draw the image centered
        draw(in: CGRect(x: -size.width / 2, y: -size.height / 2,
                        width: size.width, height: size.height))
        
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return rotatedImage
    }
}

extension Date{
    func formatDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM dd, hh:mm a"
        return formatter.string(from: self)
    }
}
