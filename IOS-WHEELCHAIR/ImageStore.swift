//
//  ImageStore.swift
//  Lidar
//
//  Created by Tarek Radwan on 01/08/2022.
//

import UIKit


class ImageStore{
    
    let cache=NSCache<NSString,UIImage>()
    
    
    func setImage(_ image:UIImage,for key:String){
        
        self.cache.setObject(image, forKey: key as NSString)
        
        let image_url=imageURL(for: key)
        
        if let data=image.jpegData(compressionQuality: 0.5){
            
            try? data.write(to: image_url)
        }
        
        
    }
    
    func retrieveimage(for key:String)->UIImage?{
        
        if let existingImage = cache.object(forKey: key as NSString) {
                return existingImage
            }

            let url = imageURL(for: key)
            guard let imageFromDisk = UIImage(contentsOfFile: url.path) else {
                return nil
            }

            cache.setObject(imageFromDisk, forKey: key as NSString)
            return imageFromDisk

        
    }
    
    
    
    func deleteimage(for key:String){
        
        self.cache.removeObject(forKey: key as NSString)
        
        let image_url=self.imageURL(for: key)
        do{
           try FileManager.default.removeItem(at: image_url)
        }
        
        catch{
            
            print("Error deleting the image:",error)
        }
        
    }
    
    func imageURL(for key:String)->URL {
        
        let documentdirectories=FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentdirectory=documentdirectories.first!
        let image_url=documentdirectory.appendingPathComponent(key)
        return image_url
    }
}
