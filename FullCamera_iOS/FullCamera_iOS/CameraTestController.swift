//
//  CameraTestController.swift
//  OneQPlus
//
//  Created by SutieDev on 2020/04/02.
//

import UIKit

class CameraTestController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .landscape]
    }

    @IBAction func cameraFrontDeviceTapped(_ sender: Any) {
        let sb = UIStoryboard(name: "CameraMain", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "CameraOverlayController") as! CameraOverlayController
        
        vc.setupCamera(deviceType: .front, fileSize: 50)
        self.present(vc, animated: false)
    }
    
    @IBAction func cameraBackwardDeviceTapped(_ sender: Any) {
        let sb = UIStoryboard(name: "CameraMain", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "CameraOverlayController") as! CameraOverlayController
        
        vc.setupCamera(deviceType: .rear, fileSize: 50)
        self.present(vc, animated: false)
    }
    
    
    @IBAction func AVCaptureSessionButtonTapped(_ sender: Any) {
        let vc = CameraViewController.create()
        vc.position = .front
        self.present(vc, animated: false)
    }
    
    @IBAction func AVCaptureSessionRearButtonTapped(_ sender: Any) {
        let vc = CameraViewController.create()
        vc.position = .back
        self.present(vc, animated: false)
    }
    
    @IBAction func dismissSelf(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
