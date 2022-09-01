//
//  ViewController.swift
//  Lidar Distance
//
//  Created by Tarek Radwan on 03/07/2022.
//

import UIKit
import ARKit



class ARViewController: UIViewController,ARSCNViewDelegate {
    
    
    var depth_ui:UIImage!
    var my_image:UIImage?
    var my_depth_map:UIImage?
    var dummy:String = "hello dummy"
    var flag:Int=0
    var finalarray=[[Float32]]()
    
    @IBAction func show_data(_ sender:UIButton){
        print("preppp")
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        print("CURRENTLY SEGUEING ")
        if self.flag==1{
            
            switch segue.identifier{
                case "datasegue":
                
                let mydataobj=segue.destination as! DataViewController
                mydataobj.Arobject=self
                
                case "depthsegue":
                
                let depth_object=segue.destination as! DepthImageController
                depth_object.Arobject=self
                    
                
                default:
                    preconditionFailure("Unexpected segue identifier.")

        
                
            }
            
            
            
            
        }
    }
    
    
    func SetTouchFlag(){
        
        if self.flag==0{
                self.flag=1
        }
            
    }
    
   
//    
    
    
    @IBOutlet var SceneView:ARSCNView!
    
    let configuration = ARWorldTrackingConfiguration()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        

        self.SceneView.debugOptions=[ARSCNDebugOptions.showFeaturePoints,ARSCNDebugOptions.showWorldOrigin]
        
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth){
            print("LIDAR SENSOR PRESENT")
            configuration.frameSemantics = .sceneDepth
        }
        self.SceneView.session.run(configuration)
        let gesture_recognizer=UITapGestureRecognizer(target: self, action: #selector(save_frame))
        self.SceneView.addGestureRecognizer(gesture_recognizer)
        
    
        
        // Do any additional setup after loading the view.
    }
    
    @objc func save_frame(sender: UIGestureRecognizer){
        
        self.SetTouchFlag()
        finalarray=[]
       
        
      
        guard let sceneview = sender.view as? ARSCNView
        else{
            print("Failure")
            return
        }
        guard let current_frame=sceneview.session.currentFrame
        else{
            print("couldnt save frame")
            return
        }
        
        print("Acessing current image")
        let camera=current_frame.camera
        
        let image = current_frame.capturedImage
        let depth_map=current_frame.sceneDepth?.depthMap
        
        
        ////Converting the RGB frame CVpixelbuffer object to UIImage
        let image_size = CGSize(width: CVPixelBufferGetWidth(image), height: CVPixelBufferGetHeight(image))
        let ciImage = CIImage(cvPixelBuffer: image)
        let context=CIContext.init(options: nil)
        
        let my_rectangle=CGRect(x: 0, y: 0, width: image_size.width, height: image_size.height)
        guard let cgimage = context.createCGImage(ciImage, from: my_rectangle)
        else{
            print("cant convert to ciImage to cgImage")
            return}
    
        let image_UI=UIImage(cgImage: cgimage)
        
        ////Converting the depth map from CVpixelbuffer object to  Uimage too
        
        guard let depth_buffer=depth_map
        else{
            print("No depth map obtained")
            return
        }
        
        let depth_size=CGSize(width: CVPixelBufferGetWidth(depth_buffer), height: CVPixelBufferGetHeight(depth_buffer))
        
        let depth_ci_image=CIImage(cvPixelBuffer: depth_buffer)
        let context_depth=CIContext.init(options: nil)
        
        let my_rectangle_2=CGRect(x: 0, y: 0, width: depth_size.width, height: depth_size.height)

        guard let depth_cgimage=context_depth.createCGImage(depth_ci_image, from: my_rectangle_2) else {return}
        
        let Depth_uiImage=UIImage(cgImage: depth_cgimage)
        
        self.depth_ui=Depth_uiImage
        let transformation_matrix=camera.transform
        print("Transformation matrix::",transformation_matrix)
        print("transformation transpose",transformation_matrix.transpose)
        self.my_image=image_UI
        self.my_depth_map=Depth_uiImage
        
        
        
        
        
        print("Image",image_UI)
        
        
        
        guard let cg_image=image_UI.cgImage else{return}
        guard let pixel_array=pixelValues(fromCGImage: cg_image).0 else{return}
        
        
        
        if let depth=depth_map{
        
            
            
            
            let depth_image_width=CVPixelBufferGetWidth(depth)
            let depth_image_height=CVPixelBufferGetHeight(depth)
            CVPixelBufferLockBaseAddress(depth, CVPixelBufferLockFlags(rawValue: 0))
            let floatBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(depth),
                                            to: UnsafeMutablePointer<Float32>.self)
            

            
            for y in 0...depth_image_height-1{
                var distances_array=[Float32]()
                for x in 0...depth_image_width-1{
                    
                    var distanceatXYpoint=floatBuffer[y*depth_image_width+x]
                    
//                    print("Depth at x:\(x) and y\(y) is \(distanceatXYpoint)")
                    distances_array.append(distanceatXYpoint)
                    
                    
                }
                finalarray.append(distances_array)
                
               
            }
            
//            print("First row:",finalarray[0])
            print("number of columns:",finalarray[0].count)
            print("number of rows:",finalarray.count)
            
        
        }
        
        else{print("Failure occured")}
        

        ///Distances to the objects
        ///
        ///if let
        
     

    }
    ///calculatig ditances to the objects
    ///
    ///
    
    func pixelValues(fromCGImage imageRef: CGImage?) -> (pixelValues: [UInt8]?, width: Int, height: Int)
     {
         var width = 0
         var height = 0
         var pixelValues: [UInt8]?
         if let imageRef = imageRef {
             width = imageRef.width
             height = imageRef.height
             let bitsPerComponent = imageRef.bitsPerComponent
             let bytesPerRow = imageRef.bytesPerRow
             let totalBytes = height * bytesPerRow
             let colorSpace = CGColorSpaceCreateDeviceGray()
             var intensities = [UInt8](repeating: 0, count: totalBytes)
             let contextRef = CGContext(data: &intensities, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: 0)
             contextRef?.draw(imageRef, in: CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height)))
             pixelValues = intensities
         }
         return (pixelValues, width, height)
     }
    
    
    func display(array:[[Float32]]){
        print("KOSOM EL 5ARA",array[0])
    }
  
  
}

extension UIImage {
    func pixelData() -> [UInt8]? {
        let size = self.size
        let dataSize = size.width * size.height * 4
        var pixelData = [UInt8](repeating: 0, count: Int(dataSize))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: &pixelData,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: 4 * Int(size.width),
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
        guard let cgImage = self.cgImage else { return nil }
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))

        return pixelData
    }
    
    
}


