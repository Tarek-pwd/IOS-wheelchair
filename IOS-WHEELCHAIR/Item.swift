//
//  Item .swift
//  sss
//
//  Created by Tarek Radwan on 27/07/2022.
//

import UIKit


class Item:Equatable,Codable{
    
    var name:String!
    var area:String!
    var postcode:String!
    var key:String!
   
    
    init(name:String,area:String,postcode:String){
        
        self.name=name
        self.area=area
        self.postcode=postcode
        self.key=UUID().uuidString
    }
    
    
    
    
    
    convenience init(flag:Bool){
        let unknown:String="Unknown"
        
        if flag==true{
            let my_names=["stairs","ramps","stairs"]
            let my_areas=["LONDON","manchester","Shefield"]
            let my_postcodes=["SWIWIW","SSIISIDSI","DLFMDK"]
            
            
            let rarea=my_areas.randomElement()
            let rname=my_names.randomElement()
            let rpostcode=my_postcodes.randomElement()
            self.init(name:rname!,area:rarea!,postcode:rpostcode!)
            
            
        }
        
        else{
            self.init(name:unknown,area:unknown,postcode:unknown)
        }
       
    }
    
    static func ==(lhs: Item, rhs: Item) -> Bool {
            return lhs.name == rhs.name
                && lhs.area == rhs.area
                && lhs.postcode == rhs.postcode
            
        }

    
    
    
    
}

