//
//  FormController.swift
//  Lidar
//
//  Created by Tarek Radwan on 28/07/2022.
//


import UIKit
import AVKit
import Vision
import MapKit
import CoreLocation

class FormController :UIViewController,UITextFieldDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,CLLocationManagerDelegate{
    
    var item:Item!
    var imagestore:ImageStore!
    
    var SQLcounter:Int=0
     
    var userlocation:CLLocationCoordinate2D!
    
    
    let locationmanager=CLLocationManager()
    
   
    @IBOutlet var namefield:UITextField!
    @IBOutlet var areafield:UITextField!
    @IBOutlet var pcodefield:UITextField!
    @IBOutlet var Image:UIImageView!
    @IBOutlet var predictionLabel:UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        namefield.delegate=self
        areafield.delegate=self
        pcodefield.delegate=self
       
        locationmanager.requestAlwaysAuthorization()
        locationmanager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            
            locationmanager.delegate=self
            locationmanager.desiredAccuracy=kCLLocationAccuracyKilometer
            locationmanager.startUpdatingLocation()
            print("location services enabled and delegate set")
          
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        namefield.text=item.name
        areafield.text=item.area
        pcodefield.text=item.postcode
        
        if let key=item.key{
        
         let image=self.imagestore.retrieveimage(for: key)
            self.Image.image=image
        }
        else {print("zebiiiiiiiii")}
        
        
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let name=namefield.text{
            item.name=name}
        print("done")
        
        if let area = areafield.text
        {item.area=areafield.text}
       
//
        if let pcode = pcodefield.text
        {item.postcode=pcodefield.text}
//
//
    }
    
    
            
       
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    
        userlocation=manager.location?.coordinate
        
        print("LATITUDE is>>",userlocation.latitude)
        print("LONGITUDE is>>",userlocation.longitude)
        
        
        
    }
    
    
    
    
    
    
    //Dismissing the keyboard
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    
        return true
    }
    
   
    
    @IBAction func camerabutton(_ sender:UIBarButtonItem){
        
        let alertcontroller=UIAlertController(title:nil, message: nil, preferredStyle: .actionSheet)
        
        alertcontroller.modalPresentationStyle = .popover
        alertcontroller.popoverPresentationController?.barButtonItem = sender

      
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
        
        let cameraaction=UIAlertAction(title: "Camera", style: .default){_ in
            print("Camera present")
            let imagepickercontroller=self.imagepicker(for: .camera)
            self.present(imagepickercontroller, animated: true, completion: nil )
            
            
        }
        
            alertcontroller.addAction(cameraaction)
        }
            
        
        let galleryaction=UIAlertAction(title: "Gallery", style: .default){_ in
            print("Gallery present")
            
            let imagepickercontroller=self.imagepicker(for: .photoLibrary)
            self.present(imagepickercontroller, animated: true, completion: nil )
            self.present(imagepickercontroller, animated: true, completion: nil )
        }
         
        alertcontroller.addAction(galleryaction)
        
        let cancelaction=UIAlertAction(title: "Cancel", style: .cancel){_ in
            print("Cancel Action present")
            
            
            
        }
            
            alertcontroller.addAction(cancelaction)
        
        present(alertcontroller, animated: true, completion: nil)
            
    
    }
    
    
    //Image picker Controller creator
    
    func imagepicker(for sourcetype:UIImagePickerController.SourceType)->UIImagePickerController{
        let imagepickercnt=UIImagePickerController()
        imagepickercnt.sourceType=sourcetype
        imagepickercnt.delegate=self
        return imagepickercnt
    }
     
    //  Image Picker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selected_image = info[.originalImage] as! UIImage
        
        //add label to confirm the presence of an image
        
        self.imagestore.setImage(selected_image, for: item.key )
        
        self.Image.image=selected_image
        
        
        dismiss(animated: true, completion: nil)
        createClassificationsRequest(for: selected_image)
    }
    
    lazy var classificationRequest: VNCoreMLRequest = {
    do {
       let model = try VNCoreMLModel(for:MyImageClassifier_1().model)
       let request = VNCoreMLRequest(model: model, completionHandler: {   [weak self] request, error in
             self?.processClassifications(for: request, error: error)
    })
        request.imageCropAndScaleOption = .centerCrop
       return request
    } catch {
       fatalError("Failed to load Vision ML model: \(error)")
    }}()
    
    func createClassificationsRequest(for image: UIImage) {
    //predictionLabel.text = "Classifying..."
    let orientation = exifOrientationFromDeviceOrientation()
    guard let ciImage = CIImage(image: image)
    else {
      fatalError("Unable to create \(CIImage.self) from \(image).")
    }
    DispatchQueue.global(qos: .userInitiated).async {
       let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
       do {
        try handler.perform([self.classificationRequest])
       }catch {
        print("Failed to perform \n\(error.localizedDescription)")
       }
      }
    }
    
    
    
    
    func processClassifications(for request: VNRequest, error: Error?) {
    DispatchQueue.main.async {
       guard let results = request.results
       else {
         self.predictionLabel.text = "Unable to classify image.\n\(error!.localizedDescription)"
         return
       }
       let classifications = results as! [VNClassificationObservation]
       if classifications.isEmpty {
         self.predictionLabel.text = "Nothing recognized."
       } else {
         let topClassifications = classifications.prefix(2)
         let descriptions = topClassifications.map { classification in
           return String(format: "(%.2f) %@", classification.confidence, classification.identifier)
       }
       self.predictionLabel.text = descriptions.joined(separator: " |")
      }
    }
    }
    
    
    public func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
        let curDeviceOrientation = UIDevice.current.orientation
        let exifOrientation: CGImagePropertyOrientation
        
        switch curDeviceOrientation {
        case UIDeviceOrientation.portraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = .left
        case UIDeviceOrientation.landscapeLeft:       // Device oriented horizontally, home button on the right
            exifOrientation = .upMirrored
        case UIDeviceOrientation.landscapeRight:      // Device oriented horizontally, home button on the left
            exifOrientation = .down
        case UIDeviceOrientation.portrait:            // Device oriented vertically, home button on the bottom
            exifOrientation = .up
        default:
            exifOrientation = .up
        }
        return exifOrientation
    }
    
    
    
    @IBAction func UploadtoServer(_ sender:UIButton){
        
        print("Users location is \(userlocation.latitude),\(userlocation.longitude)>> Uploading to server" )
        sendtoserver(location: userlocation)
//        print("upload button")
//        guard let key = item.key else{return}
//        let my_image = self.imagestore.retrieveimage(for: key)
//        guard let imagdata:Data=my_image?.pngData() else {return}
//        let imgstring:String=imagdata.base64EncodedString()
//
//        let urlString:String = "Sending an image"
//        let alert=UIAlertController(title: "Loading", message: "Please wait", preferredStyle: .alert)
//        print("presenting")
//        self.present(alert, animated: true, completion: nil)
//
//
//        var request:URLRequest=URLRequest(url: URL(string:"http://www.tarekfinalproject.com/action.php")!)
//
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        request.httpMethod = "POST"
//        request.httpBody = urlString.data(using: .utf8)
//        print("test0")
//
//
//        NSURLConnection.sendAsynchronousRequest(request, queue: .main, completionHandler: { (request, data, error) in
//
//            print("test000")
//
//            guard let data = data else {
//
//                print("No data response recieved")
//                return
//            }
//
//            print("test1")
//
//            let responseString: String = String(data: data, encoding: .utf8)!
//            print("my_log = " + responseString)
//
//            print("test2")
//
//            alert.dismiss(animated: true, completion: {
//
//                let messageAlert = UIAlertController(title: "Success", message: responseString, preferredStyle: .alert)
//                messageAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
//
//                }))
//
//                self.present(messageAlert, animated: true, completion: nil)
//            })
//        })
    }
        
  
    
    func sendtoserver(location userloc:CLLocationCoordinate2D){
    
        
        let latitude=userloc.latitude
        let longitude=userloc.longitude
        
        let alertloading=UIAlertController(title: "Loading", message: "Please wait", preferredStyle: .alert)
        print("presenting")
        self.present(alertloading, animated: true, completion: nil)
        
        let myUrl = URL(string: "http://www.tarekfinalproject.com/data.php");
 
        var request = URLRequest(url:myUrl!)
         
        request.httpMethod = "POST"// Compose a query string
         
        let postString = "latitude=\(latitude)&longitude=\(longitude)";
         
        request.httpBody = postString.data(using: String.Encoding.utf8);
         
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
             
             if error != nil
             {
                 print("error=\(error)")
                 return
             }
            
            
            
        
             print("response = \(response)")
             let responseString: String = String(data: data!, encoding: .utf8)!
                         print("my_log = " + responseString)
            
            DispatchQueue.main.async {
                alertloading.dismiss(animated: true, completion: {
                    
                    let messagealert=UIAlertController(title: "Success" , message: responseString, preferredStyle: .alert)
                    let okaction=UIAlertAction(title: "OK", style: .default) { _ in
                        messagealert.dismiss(animated: true)
                    }
                    messagealert.addAction(okaction)
                    
                    self.present(messagealert, animated: true, completion: nil)
                    
                    
                    
                    
                })
            }
            
            
             
          
            
            
            
            
         }
         task.resume()
            }
}


