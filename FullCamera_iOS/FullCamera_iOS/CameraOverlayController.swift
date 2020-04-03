//
//  CameraOverlayController.swift
//  OneQPlus
//
//  Created by SutieDev on 2020/04/02.
//

import UIKit

class CameraOverlayController: UIViewController, UINavigationControllerDelegate {
    
    private var imagePickerVC = UIImagePickerController()
    private var deviceType: UIImagePickerController.CameraDevice = .rear
    private var fileSize: Int = 0
    
    @IBOutlet var overlayView: UIView!
    @IBOutlet var preview: UIView!
    @IBOutlet weak var previewImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preview.frame = self.view.frame
        overlayView.frame = self.view.frame
        
        self.perform(#selector(presentCamera), with: nil, afterDelay: 0.0)
        
    }
    
    @objc func presentCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            if UIImagePickerController.availableMediaTypes(for: .camera) != nil {
                imagePickerVC.sourceType = .camera
                imagePickerVC.delegate = self
                imagePickerVC.showsCameraControls = false
                imagePickerVC.cameraDevice = deviceType
                
                imagePickerVC.setToolbarHidden(true, animated: false)
                imagePickerVC.navigationController?.navigationBar.isHidden = true
                
                imagePickerVC.view.frame = self.view.frame
                imagePickerVC.cameraViewTransform = CGAffineTransform(translationX: 0, y: 80)
                imagePickerVC.cameraOverlayView = overlayView
                imagePickerVC.modalPresentationStyle = .overFullScreen
                
                // Handling camera in full screen in a custom view
                let screenSize = UIScreen.main.bounds.size
                let cameraAspectRatio = CGFloat(4.0 / 4.0)
                let cameraImageHeight = screenSize.width * cameraAspectRatio
                let scale = screenSize.height / cameraImageHeight
                imagePickerVC.cameraViewTransform = CGAffineTransform(translationX: 0,
                                                                      y: (screenSize.height - cameraImageHeight)/2)
                imagePickerVC.cameraViewTransform = imagePickerVC.cameraViewTransform.scaledBy(x: scale, y: scale)
                
                self.present(imagePickerVC, animated: true, completion: nil)
            }
            
        } else {
            print("No camera device found")
        }
    }
    
    func setupCamera(deviceType: UIImagePickerController.CameraDevice, fileSize: Int) {
        self.deviceType = deviceType
    }
    
    // Camera Module Control
    @IBAction func cancelCameraButtonTapped(_ sender: Any) {
        imagePickerVC.dismiss(animated: false, completion: {
            self.navigationController?.popViewController(animated: false)
        })
    }
    
    @IBAction func takingPictureButtonTapped(_ sender: Any) {
        imagePickerVC.takePicture()
    }
    
    // Preview Control
    @IBAction func closePreviewButtonTapped(_ sender: Any) {
        previewImageView.image = nil
        preview.removeFromSuperview()
        self.present(imagePickerVC, animated: false, completion: nil)
    }
    
    @IBAction func saveImageButtonTapped(_ sender: Any) {
        // 1) File type
        // 2) Data type
    }
    
    static func create() -> CameraOverlayController {
        let sb = UIStoryboard(name: "CameraOverlayController", bundle: nil)
        return sb.instantiateViewController(withIdentifier: "CameraOverlayController") as! CameraOverlayController
    }

}

extension CameraOverlayController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Add the preview
        print("Add the Preview")
        self.view.addSubview(self.preview)
        self.previewImageView.image = info[.originalImage] as? UIImage
        
        imagePickerVC.dismiss(animated: false, completion: {
            self.overlayView.removeFromSuperview()
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePickerVC.dismiss(animated: false, completion: {
            
        })
    }
}
