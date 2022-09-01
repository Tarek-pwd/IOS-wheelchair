//
//  Detection.swift
//  Lidar
//
//  Created by Tarek Radwan on 24/07/2022.
//

import UIKit
import AVKit
import Vision


class DetectionController: UIViewController,AVCaptureVideoDataOutputSampleBufferDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let capturesession=AVCaptureSession()
        capturesession.sessionPreset = .photo
        
        
        guard let capturedevice=AVCaptureDevice.default(for: .video) else{return}
        
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: capturedevice) else {return}
        
        capturesession.addInput(deviceInput)
        
        capturesession.startRunning()
        
        let previewLayer=AVCaptureVideoPreviewLayer(session: capturesession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame=view.frame
        
        let dataoutput=AVCaptureVideoDataOutput()
        dataoutput.setSampleBufferDelegate(self, queue: DispatchQueue(label:"videoQueue" ))
        
        capturesession.addOutput(dataoutput)
        
       
        
        
//        VNImageRequestHandler(cgImage: <#T##CGImage#>, options: [:]).perform(<#T##requests: [VNRequest]##[VNRequest]#>)
        
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let date=Date()
        
        guard let pixelbuffer:CVPixelBuffer=CMSampleBufferGetImageBuffer(sampleBuffer) else{return}
        
       
        
        guard let model = try? VNCoreMLModel(for: MyObjectDetector5ARAnaik().model) else{return}
        
        let request=VNCoreMLRequest(model:model ) { (finalrequest, err) in
            
            
//            The first object in the labels array is the one with highest confidence
            print("RESULTS",finalrequest.results)
            
            
            
//
            guard let results = finalrequest.results as? [VNClassificationObservation] else {return}
//
            guard let firstobs=results.first else {return}
            print(firstobs.identifier,firstobs.confidence)
            
            
            
            
            
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelbuffer, options: [:]).perform([request])
        
    }
 
   
    
    
    
}
