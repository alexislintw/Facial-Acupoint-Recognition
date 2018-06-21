//
//  XueDaoListTableViewController.swift
//  XueDaoCare
//
//  Created by Alexis Lin on 2018/6/10.
//  Copyright © 2018年 Alexis Lin. All rights reserved.
//

import UIKit


class XueDaoListTableViewController: UITableViewController {

    var arrXueDao:NSArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.title = "穴道清單";
        self.navigationController!.navigationBar.topItem!.title = "Back"
        
        if let path = Bundle.main.path(forResource: "XueDaoList", ofType: "plist"), let array = NSArray(contentsOfFile: path) as? [NSDictionary] {
            self.arrXueDao = array as NSArray
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return arrXueDao.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let xueDao:NSDictionary = self.arrXueDao.object(at: indexPath.row) as! NSDictionary
        cell.textLabel?.text = xueDao.object(forKey: "title") as? String

        return cell
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ShowXueDao" {
            guard (sender as? UITableViewCell) != nil else {
                fatalError("Mis-configured storyboard! The sender should be a cell.")
            }
            
            let xueDaoDetailViewController = segue.destination as! XueDaoDetailViewController
            let senderIndexPath = self.tableView.indexPath(for: sender as! UITableViewCell)!
            let selectedXueDao = self.arrXueDao[senderIndexPath.row]
            xueDaoDetailViewController.xueDaoData = selectedXueDao as! NSDictionary
        }
    }
}
