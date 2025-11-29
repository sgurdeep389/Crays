//
//  QRScannerView.swift
//  Crays
//
//  Created by Gurdeep Singh  on 29/11/25.
//

import UIKit
import AVFoundation

protocol QRScannerViewDelegate: AnyObject {
    func didScan(code: String)
}

class QRScannerView: UIView, AVCaptureMetadataOutputObjectsDelegate {

    // MARK: - Properties
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    weak var delegate: QRScannerViewDelegate?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSession()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSession()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }

    // MARK: - Setup
    private func setupSession() {
        let session = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              session.canAddInput(videoInput) else {
            print("Cannot access camera")
            return
        }

        session.addInput(videoInput)

        let metadataOutput = AVCaptureMetadataOutput()
        guard session.canAddOutput(metadataOutput) else { return }
        session.addOutput(metadataOutput)

        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]

        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = .resizeAspectFill
        if let preview = previewLayer {
            layer.addSublayer(preview)
        }

        captureSession = session
        session.startRunning()
    }

    // MARK: - Metadata Delegate
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let code = metadataObject.stringValue else { return }

        // Stop scanning temporarily
        captureSession?.stopRunning()
        delegate?.didScan(code: code)
    }

    // MARK: - Public
    func startScanning() {
        if captureSession?.isRunning == false {
            captureSession?.startRunning()
        }
    }

    func stopScanning() {
        if captureSession?.isRunning == true {
            captureSession?.stopRunning()
        }
    }
}
