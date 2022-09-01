
//
//  ViewController.swift
//  sss
//
//  Created by Tarek Radwan on 27/07/2022.
//

import UIKit

class TableController: UITableViewController{
    var itemstore:Itemstore!
    var imagestore:ImageStore!
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        
        print("data reloaded success")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
    }
    

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemstore.itemsarray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        
        let item = itemstore.itemsarray[indexPath.row]
        cell.textLabel?.text=item.name
        
        return cell
    }
    
    

    @IBAction func addelement(_ sender: UIButton){
        
        let newelement=itemstore.createitem()
        let finalelm=tableView.numberOfRows(inSection: 0)
        let index=IndexPath(row:finalelm , section: 0)
        tableView.insertRows(at: [index], with: .automatic)
        
        
        
    }
        //Adding an element to the table


    @IBAction func removeelement(_ sender: UIButton){
        
        if isEditing{
            sender.setTitle("Edit", for: .normal)
            setEditing(false, animated: true)
           
        }
        
        else{
            sender.setTitle("Done", for: .normal)
            setEditing(true, animated: true)
                        
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier{
        case "myform":
            
            let formcontroller = segue.destination as! FormController
            
            
            guard let selectedrow=self.tableView.indexPathForSelectedRow?.row else{return}
            
            let my_item=itemstore.itemsarray[selectedrow]
            formcontroller.item=my_item
            formcontroller.imagestore=self.imagestore
        default:
                preconditionFailure("Unexpected segue identifier.")
            
            
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            
            
            let selected_item=itemstore.itemsarray[indexPath.row]
            itemstore.remove_item(selected_item)
            self.imagestore.deleteimage(for: selected_item.key)
            self.tableView.deleteRows(at:[indexPath], with: .automatic)
            
            
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView,
                            moveRowAt sourceIndexPath: IndexPath,
                            to destinationIndexPath: IndexPath) {
        // Update the model
        itemstore.moveelemenet(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }

    
    


}

