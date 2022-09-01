//
//  Datacontroller.swift
//  Lidar
//
//  Created by Tarek Radwan on 23/07/2022.
//

import UIKit

class DataViewController:UIViewController{
    
    var currentvalue:Float!
    

    
    var Arobject:ARViewController!
    @IBOutlet var my_label:UILabel!
    @IBOutlet var my_label2:UILabel!
    @IBAction func slider(_ sender:UISlider){
        self.my_label2.text=""
        currentvalue=sender.value
        let idx = Int(currentvalue)
        my_label.text="\(Arobject.finalarray[idx])"
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
}
