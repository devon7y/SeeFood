//
//  ViewController.swift
//  SeeFood
//
//  Created by Devon Yanitski on 2018-11-14.
//  Copyright © 2018 Devon Yanitski. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var blurBar: UIVisualEffectView!
    @IBOutlet weak var hotdogLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
        blurBar.layer.cornerRadius = 35
        blurBar.clipsToBounds = true
        blurBar.isHidden = true
        
        hotdogLabel.text = ""
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert.")
            }
            
            detect(image: ciimage)
        
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading model failed.")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Failed to prosess image.")
            }
            
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.blurBar.isHidden = false
                    self.hotdogLabel.text = "Hotdog"
                    self.navigationItem.title = ""
                    self.navigationController?.navigationBar.barTintColor = UIColor.green
                } else {
                    self.blurBar.isHidden = false
                    self.hotdogLabel.text = "Not a hotdog"
                    self.navigationItem.title = ""
                    self.navigationController?.navigationBar.barTintColor = UIColor.red
                }
            }
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)

        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
}

