//
//  ViewController.swift
//  Camera App
//
//  Created by Abdalrahman athamneh on 11/13/18.
//  Copyright © 2018 Abdalrahman athamneh. All rights reserved.
//

import UIKit
import CoreML
import Vision
class ViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    var imagePicker:UIImagePickerController!
    @IBOutlet weak var ImageViewObl: UIImageView!
    @IBOutlet weak var LaDiscription: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
       
        imagePicker=UIImagePickerController()
        imagePicker.delegate = self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
       imagePicker.sourceType = .camera
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func BuTakePic(_ sender: Any) {
   present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        ImageViewObl.image=info[UIImagePickerController.InfoKey.originalImage] as! UIImage
  imagePicker.dismiss(animated: true, completion: nil)
        pictureidentifierML(image: (info[UIImagePickerController.InfoKey.originalImage] as! UIImage))
    }
    func pictureidentifierML(image:UIImage){
        guard let model = try? VNCoreMLModel(for:Resnet50().model)  else {
            fatalError("cannot load ML model")
        }
        let request = VNCoreMLRequest(model:model){
            [weak self] request,Error in
        guard let result = request.results as? [VNClassificationObservation],
            let firstResult = result.first else {
                fatalError("cannot get result from VNCoreMLRequest ")
            }
            DispatchQueue.main.async {
                 self?.LaDiscription.text = "confidence =\(Int(firstResult.confidence*100))%,identifire)\((firstResult.identifier))"
            }
       
        }
        guard let ciImage = CIImage(image: image) else {
            fatalError("cannot convert to CIImage")
        }
        let imageHandler = VNImageRequestHandler(ciImage:ciImage)
        DispatchQueue.global(qos: .userInteractive).async {
            do{
               try imageHandler.perform([request])
            }catch {
                print("Error\(error)")
            }
        }
    }
}

