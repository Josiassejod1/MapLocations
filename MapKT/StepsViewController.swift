//
//  StepsViewController.swift
//  MapKT
//
//  Created by Dalvin Sejour on 1/17/19.
//  Copyright © 2019 Dalvin Sejour. All rights reserved.
//

import UIKit
import MapKit

class StepsViewController: UIViewController, UITableViewDataSource,UITableViewDelegate{
    
    
    @IBOutlet weak var mainTable: UITableView!
    var instructionArray: [[MKRoute.Step]] = [[]]

    override func viewWillAppear(_ animated: Bool) {
        mainTable.reloadData()
        super.viewWillAppear(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print(instructionArray)
        // Do any additional setup after loading the view.
    }


  
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
    return 90 ;//Choose your custom row height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //first array returning empty
        return instructionArray[1].count
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let instructionCell =  tableView.dequeueReusableCell(withIdentifier: "customcell", for: indexPath) as! CustomTableViewTableViewCell
        let idx: Int = indexPath.row
        instructionCell.instructions?.text = instructionArray[1][idx].instructions ?? ""
        return instructionCell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
