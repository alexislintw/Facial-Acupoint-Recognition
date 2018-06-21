//
//  XueDaoDetailViewController.swift
//  XueDaoCare
//
//  Created by Alexis Lin on 2018/6/10.
//  Copyright © 2018年 Alexis Lin. All rights reserved.
//

import UIKit

class AllXueDaoViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "整體穴道圖";
        self.navigationController!.navigationBar.topItem!.title = "Back"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowAllXueDaoPosition" {
            print("ShowAllXueDaoPosition")
            let faceViewController = segue.destination as! FaceViewController
            faceViewController.xueDaoId = 1000
        }
    }
}
