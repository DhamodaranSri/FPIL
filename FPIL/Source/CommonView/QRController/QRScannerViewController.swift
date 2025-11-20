//
//  QRScannerViewController.swift
//  FPIL
//
//  Created by OrganicFarmers on 02/10/25.
//

import SwiftUI
import AVFoundation

// MARK: - UIViewController that scans QR codes
final class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    private let session = AVCaptureSession()
    var onFound: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configureCaptureSession()
    }

    private func configureCaptureSession() {
        guard let videoDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }

        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        }

        let metadataOutput = AVCaptureMetadataOutput()
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
            metadataOutput.metadataObjectTypes = [.qr] // QR only
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        // simple overlay (optional)
        let border = CAShapeLayer()
        border.strokeColor = UIColor.systemOrange.cgColor
        border.fillColor = UIColor.clear.cgColor
        border.lineWidth = 3
        let insetRect = view.bounds.insetBy(dx: 40, dy: 120)
        border.path = UIBezierPath(roundedRect: insetRect, cornerRadius: 12).cgPath
        view.layer.addSublayer(border)
        
        DispatchQueue.main.async {
            self.session.startRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard let first = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let string = first.stringValue else { return }

        // prevent duplicates: stop session then call onFound
        session.stopRunning()
        onFound?(string)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if session.isRunning { session.stopRunning() }
    }
}


struct QRScannerRepresentable: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    var onFound: (String) -> Void

    func makeUIViewController(context: Context) -> QRScannerViewController {
        let vc = QRScannerViewController()
        vc.onFound = { result in
            // deliver result to SwiftUI and dismiss
            DispatchQueue.main.async {
                onFound(result)
                presentationMode.wrappedValue.dismiss()
            }
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) { }
}

