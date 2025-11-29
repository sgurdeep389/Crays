//
//  PaidPostEncryptor.swift
//  Primal
//
//  Created by GPT on 2025-11-28.
//

import Foundation
import Security
import CommonCrypto

struct PaidPostEncryptionResult {
    let ciphertextBase64: String
    let ivBase64: String
    let keyBase64: String
}

enum PaidPostEncryptionError: Error {
    case randomBytesFailed
    case encryptionFailed(CCCryptorStatus)
}

enum PaidPostEncryptor {
    static func randomBytes(count: Int) throws -> Data {
        var data = Data(count: count)
        let result = data.withUnsafeMutableBytes { mutableBytes in
            SecRandomCopyBytes(kSecRandomDefault, count, mutableBytes.baseAddress!)
        }
        guard result == errSecSuccess else { throw PaidPostEncryptionError.randomBytesFailed }
        return data
    }
    
    static func encrypt(plaintext: Data) throws -> PaidPostEncryptionResult {
        let key = try randomBytes(count: kCCKeySizeAES256)
        let iv = try randomBytes(count: kCCBlockSizeAES128)
        
        var output = Data(count: plaintext.count + kCCBlockSizeAES128)
        let outputLength = output.count
        var numBytesEncrypted: size_t = 0
        
        var status: CCCryptorStatus = CCCryptorStatus(kCCSuccess)
        output.withUnsafeMutableBytes { outputPointer in
            guard let outputBytes = outputPointer.baseAddress else {
                status = CCCryptorStatus(kCCMemoryFailure)
                return
            }
            plaintext.withUnsafeBytes { plaintextPointer in
                guard let plaintextBytes = plaintextPointer.baseAddress else {
                    status = CCCryptorStatus(kCCMemoryFailure)
                    return
                }
                key.withUnsafeBytes { keyPointer in
                    guard let keyBytes = keyPointer.baseAddress else {
                        status = CCCryptorStatus(kCCMemoryFailure)
                        return
                    }
                    iv.withUnsafeBytes { ivPointer in
                        guard let ivBytes = ivPointer.baseAddress else {
                            status = CCCryptorStatus(kCCMemoryFailure)
                            return
                        }
                        
                        status = CCCrypt(
                            CCOperation(kCCEncrypt),
                            CCAlgorithm(kCCAlgorithmAES),
                            CCOptions(kCCOptionPKCS7Padding),
                            keyBytes,
                            kCCKeySizeAES256,
                            ivBytes,
                            plaintextBytes,
                            plaintext.count,
                            outputBytes,
                            outputLength,
                            &numBytesEncrypted
                        )
                    }
                }
            }
        }
        
        guard status == kCCSuccess else {
            throw PaidPostEncryptionError.encryptionFailed(status)
        }
        
        output.count = numBytesEncrypted
        
        return PaidPostEncryptionResult(
            ciphertextBase64: output.base64EncodedString(),
            ivBase64: iv.base64EncodedString(),
            keyBase64: key.base64EncodedString()
        )
    }
}


