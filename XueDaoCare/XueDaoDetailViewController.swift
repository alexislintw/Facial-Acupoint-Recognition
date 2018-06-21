//
//  XueDaoDetailViewController.swift
//  XueDaoCare
//
//  Created by Alexis Lin on 2018/6/10.
//  Copyright © 2018年 Alexis Lin. All rights reserved.
//

import UIKit

class XueDaoDetailViewController: UIViewController {

    var xueDaoData: NSDictionary!
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController!.navigationBar.topItem!.title = "Back"
        
        // Do any additional setup after loading the view.
        print(self.xueDaoData)
    }

    override func viewWillAppear(_ animated: Bool) {
        let title:String = self.xueDaoData.object(forKey: "title") as! String
        let imageName:String = self.xueDaoData.object(forKey: "image") as! String
        let body:String = self.xueDaoData.object(forKey: "body") as! String
        
        self.labelTitle.text = title
        self.imageView.image = UIImage.init(named: imageName)
        self.textView.text = body
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ShowOneXueDaoPosition" {
            guard (sender as? UIButton) != nil else {
                fatalError("Mis-configured storyboard! The sender should be a button.")
            }
            
            let faceViewController = segue.destination as! FaceViewController
            let xueDaoIdNumber = self.xueDaoData.object(forKey: "id") as! NSNumber
            let xueDaoId = xueDaoIdNumber.intValue
            faceViewController.xueDaoId = xueDaoId
        }
    }
}
