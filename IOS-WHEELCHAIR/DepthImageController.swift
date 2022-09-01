//
//  DepthImageController.swift
//  Lidar
//
//  Created by Tarek Radwan on 29/08/2022.
//

import UIKit



class DepthImageController: UIViewController {
    
    var Arobject:ARViewController!
    @IBOutlet var imageview:UIImageView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.imageview.image=Arobject.depth_ui
        
    }
    
    
}
    
    
