//
//  CameraViewController.swift
//  OneQPlus
//
//  Created by SutieDev on 2020/04/03.
//

import UIKit
import AVFoundation

@available(iOS 10.0, *)
class CameraViewController: UIViewController {

    @IBOutlet weak var overlayCameraView: UIView!
    @IBOutlet var previewContainerView: UIView!
    @IBOutlet weak var preview: UIView!
    @IBOutlet var overlayView: UIView!
    
    @IBOutlet weak var previewImageView: UIImageView!
    
    var position: AVCaptureDevice.Position!
    private var photoData: Data?
    private var videoUrl: URL?
        
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer?
    private var photoOutput: AVCapturePhotoOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        previewContainerView.frame = self.view.frame
        overlayView.frame = self.view.frame
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let value = UIDeviceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        // 1. Setup session
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = .photo
        
        // 2. Setup camera preview
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer!.videoGravity = .resizeAspectFill
        previewLayer!.connection?.videoOrientation = .portrait
        previewLayer?.frame = overlayCameraView.frame
        overlayCameraView.layer.addSublayer(previewLayer!)
        
        guard let backDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: backDevice) else {
            return
        }
        
        //3-1. Setup Input
        captureSession.beginConfiguration()
        captureSession.addInput(deviceInput)
        captureSession.commitConfiguration()
        
        // 3-2. Setup Output
        captureSession.beginConfiguration()
        photoOutput = AVCapturePhotoOutput()
        photoOutput!.isHighResolutionCaptureEnabled = true
        captureSession.addOutput(photoOutput!)
        captureSession.commitConfiguration()

        overlayCameraView.addSubview(self.overlayView)
        
        captureSession!.startRunning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer?.frame = overlayCameraView.frame
        
    }
    
    @IBAction func cancelCaptureButtonTapped(_ sender: Any) {
        previewLayer?.removeFromSuperlayer()
        overlayCameraView.removeFromSuperview()
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func captureButtonTapped(_ sender: Any) {
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.isHighResolutionPhotoEnabled = true // default is false
        photoOutput!.capturePhoto(with: photoSettings, delegate: self)
    }
    
    @IBAction func retakeButtonTapped(_ sender: Any) {
        self.photoData = nil
        previewImageView.image = nil
        previewContainerView.removeFromSuperview()
    }
    
    @IBAction func outputPNGButtonTapped(_ sender: Any) {
        // return self.photoData
    }
    
    static func create() -> CameraViewController {
        let sb = UIStoryboard(name: "CameraMain", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
        return vc
    }

}

@available(iOS 11.0, *)
extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        // Get the main image
        guard let photoData = photo.fileDataRepresentation() else {
            return
        }
        let mainImage = UIImage(data: photoData)
        
        // Get the Preview
        // 1. Get the preview photo orientation from metadata
        var previewPhotoOrientation: CGImagePropertyOrientation?
        if let orientationNum = photo.metadata[kCGImagePropertyOrientation as String] as? NSNumber {
            previewPhotoOrientation = CGImagePropertyOrientation(rawValue: orientationNum.uint32Value)
        }
        
        // 2. Try get the photo preview
        var previewImage: UIImage?
        if let previewPixelBuffer = photo.previewPixelBuffer {
            var previewCiImage = CIImage(cvPixelBuffer: previewPixelBuffer)
            
            // If we managed to get the oreintation, update the image
            if let previewPhotoOrientation = previewPhotoOrientation {
                previewCiImage = previewCiImage.oriented(previewPhotoOrientation)
            }
            
            if let previewCgImage = CIContext().createCGImage(previewCiImage, from: previewCiImage.extent) {
                previewImage = UIImage(cgImage: previewCgImage)
            }
        }
        
        guard let image = previewImage ?? mainImage else {
            return
        }
        
        // Keep photo data & enable the save Button
        self.photoData = photoData
        
        previewImageView.image = image
        self.view.addSubview(self.previewContainerView)
    }
}
 
