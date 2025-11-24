//
// FingerprintView.swift
// Crays
//
// This is free and unencumbered software released into the public domain.
// For more information, see <https://unlicense.org>
//

import SwiftUI

struct FingerprintView: View {
    @ObservedObject var viewModel: ChatViewModel
    let peerID: String
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    private var textColor: Color {
        colorScheme == .dark ? Color.white : .black
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color.black : Color.white
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("SECURITY VERIFICATION")
                    .font(.custom("Poppins-Bold", size: 16))
                    .foregroundColor(textColor)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.custom("Poppins-SemiBold", size: 14))
                }
                .foregroundColor(textColor)
            }
            .padding()
            
            VStack(alignment: .leading, spacing: 16) {
                // Prefer short mesh ID for session/encryption status
                let statusPeerID: String = {
                    if peerID.count == 64, let short = viewModel.getShortIDForNoiseKey(peerID) { return short }
                    return peerID
                }()
                // Resolve a friendly name
                let peerNickname: String = {
                    if let p = viewModel.getPeer(byID: statusPeerID) { return p.displayName }
                    if let name = viewModel.meshService.peerNickname(peerID: statusPeerID) { return name }
                    if peerID.count == 64, let data = Data(hexString: peerID) {
                        if let fav = FavoritesPersistenceService.shared.getFavoriteStatus(for: data), !fav.peerNickname.isEmpty { return fav.peerNickname }
                        let fp = data.sha256Fingerprint()
                        if let social = SecureIdentityStateManager.shared.getSocialIdentity(for: fp) {
                            if let pet = social.localPetname, !pet.isEmpty { return pet }
                            if !social.claimedNickname.isEmpty { return social.claimedNickname }
                        }
                    }
                    return "Unknown"
                }()
                // Accurate encryption state based on short ID session
                let encryptionStatus = viewModel.getEncryptionStatus(for: statusPeerID)
                
                HStack {
                    if let icon = encryptionStatus.icon {
                        Image(systemName: icon)
                            .font(.system(size: 20))
                            .foregroundColor(encryptionStatus == .noiseVerified ? Color.white : textColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(peerNickname)
                            .font(.custom("Poppins-SemiBold", size: 18))
                            .foregroundColor(textColor)
                        
                        Text(encryptionStatus.description)
                            .font(.custom("Poppins-Regular", size: 12))
                            .foregroundColor(textColor.opacity(0.7))
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                // Their fingerprint
                VStack(alignment: .leading, spacing: 8) {
                    Text("THEIR FINGERPRINT:")
                        .font(.custom("Poppins-Bold", size: 12))
                        .foregroundColor(textColor.opacity(0.7))
                    
                    if let fingerprint = viewModel.getFingerprint(for: statusPeerID) {
                        Text(formatFingerprint(fingerprint))
                            .font(.custom("Poppins-Regular", size: 14))
                            .foregroundColor(textColor)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .contextMenu {
                                Button("Copy") {
                                    #if os(iOS)
                                    UIPasteboard.general.string = fingerprint
                                    #else
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(fingerprint, forType: .string)
                                    #endif
                                }
                            }
                    } else {
                        Text("Not available - handshake in progress")
                            .font(.custom("Poppins-Regular", size: 14))
                            .foregroundColor(Color.red)
                            .padding()
                    }
                }
                
                // My fingerprint
                VStack(alignment: .leading, spacing: 8) {
                    Text("YOUR FINGERPRINT:")
                        .font(.custom("Poppins-Bold", size: 12))
                        .foregroundColor(textColor.opacity(0.7))
                    
                    let myFingerprint = viewModel.getMyFingerprint()
                    Text(formatFingerprint(myFingerprint))
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(textColor)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .contextMenu {
                            Button("Copy") {
                                #if os(iOS)
                                UIPasteboard.general.string = myFingerprint
                                #else
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(myFingerprint, forType: .string)
                                #endif
                            }
                        }
                }
                
                // Verification status
                if encryptionStatus == .noiseSecured || encryptionStatus == .noiseVerified {
                    let isVerified = encryptionStatus == .noiseVerified
                    
                    VStack(spacing: 12) {
                        Text(isVerified ? "✓ VERIFIED" : "⚠️ NOT VERIFIED")
                            .font(.custom("Poppins-Bold", size: 14))
                            .foregroundColor(isVerified ? Color.red : Color.red)
                            .frame(maxWidth: .infinity)
                        
                        Text(isVerified ? 
                             "you have verified this person's identity." :
                             "compare these fingerprints with \(peerNickname) using a secure channel.")
                            .font(.custom("Poppins-Regular", size: 12))
                            .foregroundColor(textColor.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity)
                        
                        if !isVerified {
                            Button(action: {
                                viewModel.verifyFingerprint(for: peerID)
                                dismiss()
                            }) {
                                Text("MARK AS VERIFIED")
                                    .font(.custom("Poppins-Bold", size: 14))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color.white)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        } else {
                            Button(action: {
                                viewModel.unverifyFingerprint(for: peerID)
                                dismiss()
                            }) {
                                Text("REMOVE VERIFICATION")
                                    .font(.custom("Poppins-Bold", size: 14))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color.red)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.top)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .frame(maxWidth: 500) // Constrain max width for better readability
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
    
    private func formatFingerprint(_ fingerprint: String) -> String {
        // Convert to uppercase and format into 4 lines (4 groups of 4 on each line)
        let uppercased = fingerprint.uppercased()
        var formatted = ""
        
        for (index, char) in uppercased.enumerated() {
            // Add space every 4 characters (but not at the start)
            if index > 0 && index % 4 == 0 {
                // Add newline after every 16 characters (4 groups of 4)
                if index % 16 == 0 {
                    formatted += "\n"
                } else {
                    formatted += " "
                }
            }
            formatted += String(char)
        }
        
        return formatted
    }
}
