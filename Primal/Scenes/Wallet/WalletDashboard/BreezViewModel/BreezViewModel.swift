//
//  BreezViewModel.swift
//  Crays
//
//  Created by Gurdeep Singh  on 29/11/25.
//

import BreezSdkSpark
import Foundation
import UIKit
import BigNumber

enum AddressType {
    case lightning
    case bitcoin
    case invalid
}

class BreezViewModel{
    static let shared =  BreezViewModel()
    var sdk:BreezSdk?
    
    
    func createWallet(keys:String) async {
        do {
            let seed = Seed.mnemonic(mnemonic: "segment stadium six initial surface raw cart large cram eyebrow squeeze kidney", passphrase: nil)
            
            var config = defaultConfig(network: Network.mainnet)
            config.apiKey = "MIIBdDCCASagAwIBAgIHPpfhotBcKzAFBgMrZXAwEDEOMAwGA1UEAxMFQnJlZXowHhcNMjUxMDMwMTcxMzExWhcNMzUxMDI4MTcxMzExWjAmMRIwEAYDVQQKEwlDb2RlIElkZWExEDAOBgNVBAMTB0d1cm5vb3IwKjAFBgMrZXADIQDQg/XL3yA8HKIgyimHU/Qbpxy0tvzris1fDUtEs6ldd6OBiDCBhTAOBgNVHQ8BAf8EBAMCBaAwDAYDVR0TAQH/BAIwADAdBgNVHQ4EFgQU2jmj7l5rSw0yVb/vlWAYkK/YBwkwHwYDVR0jBBgwFoAU3qrWklbzjed0khb8TLYgsmsomGswJQYDVR0RBB4wHIEac2luZ2hqYXNrYXJhbi5jaUBnbWFpbC5jb20wBQYDK2VwA0EA4PSjNi+1g8D+AIJQGGXS5va926BkffEJDi6ubz1A7/BiwzPRxLNZ/3n3FVvxaxHGLDKOJpGqwNtX+dUpNihIBg=="
            config.lnurlDomain = "pay.crays.net"
            
            // Get writable storage dir
            let storageDir = FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            ).first!.appendingPathComponent("breez_data").path
            
            // Create directory if needed
            if !FileManager.default.fileExists(atPath: storageDir) {
                try FileManager.default.createDirectory(atPath: storageDir, withIntermediateDirectories: true)
            }
            
            let builder = SdkBuilder(config: config, seed: seed)
            
            // Use correct writable path
            await builder.withDefaultStorage(storageDir: storageDir)
            
            self.sdk = try await builder.build()
            
            print("Wallet created successfully")
            
        } catch {
            print("❌ Failed to create wallet:", error.localizedDescription)
        }
        
    }
    
    func createBitcoinAddress() async -> String? {
        do {
            let response = try await self.sdk?.receivePayment(
                request: ReceivePaymentRequest(paymentMethod: .bitcoinAddress)
            )
            
            guard let paymentRequest = response?.paymentRequest else {
                print("❌ No payment request received")
                return nil
            }
            
            print("Payment Request:", paymentRequest)
            print("Fees:", response?.fee ?? 0)
            
            return paymentRequest
            
        } catch {
            print("❌ Failed to create bitcoin address:", error.localizedDescription)
            return nil
        }
    }
    
    
    func generateQRCode(from string: String, size: CGFloat = 300) -> UIImage? {
        let data = Data(string.utf8)
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")
        
        guard let outputImage = filter.outputImage else { return nil }
        
        // Scale the QR code to proper size
        let transform = CGAffineTransform(scaleX: size / outputImage.extent.size.width,
                                          y: size / outputImage.extent.size.height)
        
        let scaledImage = outputImage.transformed(by: transform)
        
        return UIImage(ciImage: scaledImage)
    }
    
    func createLightningAddress(username: String) async -> (invoice: String?, error: Error?) {
        do {
            let available = try await self.sdk?.checkLightningAddressAvailable(req: CheckLightningAddressRequest(username: username))
            if available == true{
                let request = RegisterLightningAddressRequest(username: username,description:"description")
                
                let addressInfo = try await self.sdk?.registerLightningAddress(request: request)
                if let lightningAddress = addressInfo?.lightningAddress{
                    return (lightningAddress, nil)
                }
                else{
                    return (nil, NSError(domain: "Breez", code: -1, userInfo: [NSLocalizedDescriptionKey: "\(username) is already taken"]))
                }
            }
            else{
                return (nil, NSError(domain: "Breez", code: -1, userInfo: [NSLocalizedDescriptionKey: "\(username) is already taken"]))
            }
        }
        catch {
            return (nil, error)
        }
    }
    
    func gettingLightningAddress() async -> (String,String)? {
        do {
            guard let addressInfo = try await self.sdk?.getLightningAddress() else {
                return nil
            }
            
            return (addressInfo.lightningAddress,addressInfo.username)
        } catch {
            print("❌ Failed to get lightning address:", error.localizedDescription)
            return nil
        }
    }
    
    func getWalletBalance() async -> UInt64? {
        do {
            if let info = try await self.sdk?.getInfo(request: .init(ensureSynced: true)) {
                let totalMsat = info.balanceSats
                return totalMsat
            }
            return nil
        } catch {
            print("❌ Failed to get node info:", error.localizedDescription)
            return nil
        }
    }
    
    func gettingTransactionsListing()async ->[Payment]{
        do{
            let response = try await self.sdk?.listPayments(
                request: ListPaymentsRequest())
            let payments = response?.payments
            return payments ?? []
        }catch{
            return []
        }
    }
    
    func isValidAddress(_ address: String) async -> (Bool,InputType?) {
        do {
            let parsed = try await self.sdk?.parse(input: address)
            return (parsed != nil,parsed)   // If it parsed, it's valid
        } catch {
            return (false,nil)
        }
    }
    
    func preparingPayment(invoice: String, sats: String) async ->(PrepareLnurlPayResponse?,PrepareSendPaymentResponse?,String?){
        do {
            let inputType = try await self.sdk?.parse(input: invoice)
            print(inputType,"inputType")
            if case .lightningAddress(v1: let details) = inputType {
                let amountSats: UInt64 = UInt64(sats) ?? 0
                let optionalComment = "<comment>"
                let payRequest = details.payRequest
                let optionalValidateSuccessActionUrl = true
                
                let request = PrepareLnurlPayRequest(
                    amountSats: amountSats,
                    payRequest: payRequest,
                    comment: optionalComment,
                    validateSuccessActionUrl: optionalValidateSuccessActionUrl
                )
                let response = try await self.sdk?.prepareLnurlPay(request: request)
                // If the fees are acceptable, continue to create the LNURL Pay
                let feesSat = response?.feeSats
                print("Fees: \(response?.successAction) sats")
                print("Fees: \(feesSat) sats")
                return (response,nil,nil)
            }
            else if case .bitcoinAddress(v1: let details) = inputType {
                let amountSats: BInt = BInt(sats) ?? 0
                let optionalComment = "<comment>"
                let optionalValidateSuccessActionUrl = true
                let response = try await self.sdk?.prepareSendPayment(request: .init(paymentRequest: details.address,amount: amountSats))
                return (nil,response,nil)
            }
            else if case .lnurlPay(v1: let details) = inputType {
                let amountSats: UInt64 = UInt64(sats) ?? 0
                let optionalComment = "<comment>"
                let optionalValidateSuccessActionUrl = true
                
                let request = PrepareLnurlPayRequest(
                    amountSats: amountSats,
                    payRequest: details,
                    comment: optionalComment,
                    validateSuccessActionUrl: optionalValidateSuccessActionUrl
                )
                let response = try await self.sdk?.prepareLnurlPay(request: request)
                // If the fees are acceptable, continue to create the LNURL Pay
                let feesSat = response?.feeSats
                print("Fees: \(response?.successAction) sats")
                print("Fees: \(feesSat) sats")
                return (response,nil,nil)
            }
            else{
                return (nil,nil,"This payment method is not supported")
            }
        } catch {
            print("❌ Failed to get node info:", error.localizedDescription)
            return (nil,nil,error.localizedDescription)
        }
    }
    
    func sendPayment(response:PrepareLnurlPayResponse) async{
        do {
            let response1 = try await sdk?.lnurlPay(
                request: LnurlPayRequest(
                    prepareResponse: response,
                    idempotencyKey: nil
                ))
            
        } catch {
            print("❌ Failed to get node info:", error.localizedDescription)
        }
    }
    
    func logOut(){
        do {
            Task{
                try await self.sdk?.disconnect()
                self.sdk = nil
                WalletManager1.shared.saveMnemonic(nil)
            }
        }
    }
}


