//
//  ItemStore.swift
//  sss
//
//  Created by Tarek Radwan on 27/07/2022.
//

import UIKit

class Itemstore{
    
   
    init(){
        
        
        
        
        do{
            let data=try Data(contentsOf: itemsArchiveuRL)
            let decoder=PropertyListDecoder()
            let items = try decoder.decode([Item].self, from:data )
            
            self.itemsarray=items
        }
        
        catch{
            
            print("Error loading data:",error)
        }
        
        let notificationcenter=NotificationCenter.default
        notificationcenter.addObserver(self, selector: #selector(savechanges), name: UIScene.didEnterBackgroundNotification, object: nil)
        
//        for i in 0..<3{
//
//            self.createitem()
//        }
        
        print("Final Items array is:",itemsarray)
        
    }
    var itemsarray:[Item]=[]
    
  
   
    

    @discardableResult func createitem()->Item{
        let item=Item(flag: true)
        self.itemsarray.append(item)
        return item
    }
    
    func remove_item(_ item:Item){
        if let index=self.itemsarray.firstIndex(of: item){
            itemsarray.remove(at: index)
        }
        
    }
    
    func moveelemenet(from index:Int,to indx:Int){
        
        let moveditem = itemsarray[index]
        itemsarray.remove(at: index)
        itemsarray.insert(moveditem, at: indx)
        
    }
    
    
    ///function that saves the changes as a property list i the document directory of the applicatons sandbox
    
    @objc func savechanges()->Bool{
        
        do{
            let encoder=PropertyListEncoder()
            let data = try encoder.encode(self.itemsarray)
            try data.write(to: itemsArchiveuRL, options: [.atomic])
            
            print("Items saved sucessfully to disk")
            return true
            
        }
        
        catch{
            print("Error was found",error)
            return false
            
        }
    
      
    }
    
    //ItemarchiveURL WHERE THE ITEMS will be saved to!
    let itemsArchiveuRL:URL={
        let documentDirectories=FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        let documentDirectory=documentDirectories.first!
        let full_url = documentDirectory.appendingPathComponent("items.plist")
        print("document directory path is::",full_url)
        return full_url
    }()
    
}

