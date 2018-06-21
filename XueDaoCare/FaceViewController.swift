//
//  FaceViewController.swift
//  XueDaoCare
//
//  Created by Alexis Lin on 2018/6/10.
//  Copyright © 2018年 Alexis Lin. All rights reserved.
//

import UIKit
import Vision
import CoreImage

class FaceViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    var arrXueDao:NSArray!
    var xueDaoId: Int!
    var image: UIImage!
    var imagePicker: UIImagePickerController!
    let radius: CGFloat = 10
    let margin: CGFloat = 30.0 //轉換後的數值
    let unit: CGFloat = 30.0 //轉換後的數值
    let lineWidth: CGFloat = 10.0
    let fontSize: CGFloat = 75.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
        self.title = "顯示我的穴道";
        self.navigationController!.navigationBar.topItem!.title = "Back"
        //print(self.xueDaoId)
    }

    func loadData() {
        if let path = Bundle.main.path(forResource: "XueDaoList", ofType: "plist"), let array = NSArray(contentsOfFile: path) as? [NSDictionary] {
            self.arrXueDao = array as NSArray
        }
    }
    
    @IBAction func takePhoto(_ sender: UIButton) {
        
        let alert:UIAlertController = UIAlertController(title: "Choose Image",
                                                        message: nil,
                                                        preferredStyle: UIAlertControllerStyle.actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default) { UIAlertAction in self.useCamera()
        }
        let photoAction = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.default) { UIAlertAction in self.usePhotoLibrary()
        }
        
        alert.addAction(cameraAction)
        alert.addAction(photoAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func useCamera() {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    func usePhotoLibrary() {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: - Done image capture here
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        image = info[UIImagePickerControllerOriginalImage] as? UIImage
        imageView.image = image
        process()
        print("OK")
    }
    
    func process() {
        var orientation:Int32 = 0
        switch image.imageOrientation {
        case .up:
            orientation = 1
        case .right:
            orientation = 6
        case .down:
            orientation = 3
        case .left:
            orientation = 8
        default:
            orientation = 1
        }
        
        let faceLandmarksRequest = VNDetectFaceLandmarksRequest(completionHandler: self.handleFaceFeatures)
        let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, orientation: CGImagePropertyOrientation(rawValue: CGImagePropertyOrientation.RawValue(orientation))! ,options: [:])
        do {
            try requestHandler.perform([faceLandmarksRequest])
        } catch {
            print(error)
        }
    }
    
    func handleFaceFeatures(request: VNRequest, errror: Error?) {
        guard let observations = request.results as? [VNFaceObservation] else {
            fatalError("unexpected result type!")
        }
        
        for face in observations {
            addFaceLandmarksToImage(face)
        }
    }
    
    func addFaceLandmarksToImage(_ face: VNFaceObservation) {
        
        UIGraphicsBeginImageContextWithOptions(image.size, true, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        // draw the image
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        
        // draw xuedao text
        if self.xueDaoId == 1000 {
            for theId in 0...12 {
                let theXueDao:NSDictionary = self.arrXueDao.object(at: theId) as! NSDictionary
                let theName:String = theXueDao.object(forKey: "title") as! String
                self.drawXueDaoText(context: context!, face: face, xueDaoId: theId, xueDaoName: theName)
            }
        }
        else {
            let theId:Int = self.xueDaoId
            let theXueDao:NSDictionary = self.arrXueDao.object(at: theId) as! NSDictionary
            let theName:String = theXueDao.object(forKey: "title") as! String
            self.drawXueDaoText(context: context!, face: face, xueDaoId: theId, xueDaoName: theName)
        }
        
        // flip
        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        // draw xuedao point
        if self.xueDaoId == 1000 {
            for theId in 0...12 {
                drawXueDaoPoint(context: context!, face: face, xueDaoId: theId)
            }
        }
        else {
            let theId:Int = self.xueDaoId
            drawXueDaoPoint(context: context!, face: face, xueDaoId: theId)
        }
        
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        imageView.image = finalImage
    }
    
    func drawXueDaoText(context:CGContext,face:VNFaceObservation,xueDaoId:Int,xueDaoName:String) {
        
        // text style setting
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        let attributes = [
            NSAttributedStringKey.paragraphStyle: paragraphStyle,
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: self.fontSize),
            NSAttributedStringKey.foregroundColor: UIColor.blue
        ]
        context.setStrokeColor(UIColor.blue.cgColor)
        context.setFillColor(UIColor.blue.cgColor)
        
        // face rect
        let w = face.boundingBox.size.width * image.size.width
        let h = face.boundingBox.size.height * image.size.height
        let x = face.boundingBox.origin.x * image.size.width
        let y = face.boundingBox.origin.y * image.size.height
        
        //禾髎
        if xueDaoId == 0  {
            guard let landmark1 = face.landmarks?.nose,let landmark2 = face.landmarks?.outerLips else {
                print("error")
                return
            }
            let point1 = landmark1.normalizedPoints[4]
            let point2 = landmark2.normalizedPoints[2]
            let point3 = landmark1.normalizedPoints[2]
            let x_ = x + point3.x * w + margin
            let y_ = y + (point1.y - (point1.y-point2.y) / 3) * h
            let stringPosition = CGPoint(x:x_,y:y_)
            let rect = CGRect(x: stringPosition.x, y: image.size.height - stringPosition.y, width: 250, height: 100)
            let string = xueDaoName
            string.draw(in: rect, withAttributes: attributes)
        }
        
        //迎香
        if xueDaoId  == 1 {
            guard let landmark1 = face.landmarks?.nose else {
                print("error")
                return
            }
            let point1 = landmark1.normalizedPoints[6]
            let point2 = landmark1.normalizedPoints[7]
            let x_ = x + point1.x * w + margin
            let y_ = y + (point1.y + (point2.y-point1.y) / 2) * h
            let stringPosition = CGPoint(x:x_,y:y_)
            let rect = CGRect(x: stringPosition.x, y: image.size.height - stringPosition.y, width: 250, height: 100)
            let string = xueDaoName
            string.draw(in: rect, withAttributes: attributes)
        }
        
        //承泣
        if xueDaoId == 2 {
            guard let landmark1 = face.landmarks?.rightPupil,let landmark2 = face.landmarks?.noseCrest else {
                print("error")
                return
            }
            let point1 = landmark1.normalizedPoints[0]
            let point2 = landmark2.normalizedPoints[1]
            let x_ = x + point1.x * w + margin
            let y_ = y + point2.y * h
            let stringPosition = CGPoint(x:x_,y:y_)
            let rect = CGRect(x: stringPosition.x, y: image.size.height - stringPosition.y, width: 250, height: 100)
            let string = xueDaoName
            string.draw(in: rect, withAttributes: attributes)
        }
        
        //四白
        if xueDaoId == 3 {
            guard let landmark1 = face.landmarks?.rightPupil,let landmark2 = face.landmarks?.noseCrest else {
                print("error")
                return
            }
            let point1 = landmark1.normalizedPoints[0]
            let point2 = landmark2.normalizedPoints[2]
            let x_ = x + point1.x * w + margin
            let y_ = y + point2.y * h
            let stringPosition = CGPoint(x:x_,y:y_)
            let rect = CGRect(x: stringPosition.x, y: image.size.height - stringPosition.y, width: 250, height: 100)
            let string = xueDaoName
            string.draw(in: rect, withAttributes: attributes)
        }
        
        //地倉
        if xueDaoId == 4 {
            guard let landmark1 = face.landmarks?.outerLips else {
                print("error")
                return
            }
            let point1 = landmark1.normalizedPoints[5]
            let x_ = x + point1.x * w + margin
            let y_ = y + point1.y * h
            let stringPosition = CGPoint(x:x_,y:y_)
            let rect = CGRect(x: stringPosition.x, y: image.size.height - stringPosition.y, width: 250, height: 100)
            let string = xueDaoName
            string.draw(in: rect, withAttributes: attributes)
        }
        
        //攢竹
        if xueDaoId == 5 {
            guard let landmark1 = face.landmarks?.rightEyebrow else {
                print("error")
                return
            }
            let point1 = landmark1.normalizedPoints[0]
            let x_ = x + point1.x * w + margin
            let y_ = y + point1.y * h
            let stringPosition = CGPoint(x:x_,y:y_)
            let rect = CGRect(x: stringPosition.x, y: image.size.height - stringPosition.y, width: 250, height: 100)
            let string = xueDaoName
            string.draw(in: rect, withAttributes: attributes)
        }
        
        //睛明
        if xueDaoId == 6 {
            guard let landmark1 = face.landmarks?.rightEye else {
                print("error")
                return
            }
            let point1 = landmark1.normalizedPoints[0]
            let x_ = x + point1.x * w + margin
            let y_ = y + point1.y * h
            let stringPosition = CGPoint(x:x_,y:y_)
            let rect = CGRect(x: stringPosition.x, y: image.size.height - stringPosition.y, width: 250, height: 100)
            let string = xueDaoName
            string.draw(in: rect, withAttributes: attributes)
        }
        
        //絲竹空
        if xueDaoId == 7 {
            guard let landmark1 = face.landmarks?.rightEyebrow else {
                print("error")
                return
            }
            let point1 = landmark1.normalizedPoints[3]
            let x_ = x + point1.x * w + margin
            let y_ = y + point1.y * h
            let stringPosition = CGPoint(x:x_,y:y_)
            let rect = CGRect(x: stringPosition.x, y: image.size.height - stringPosition.y, width: 250, height: 100)
            let string = xueDaoName
            string.draw(in: rect, withAttributes: attributes)
        }
        
        //陽白
        if xueDaoId == 8 {
            guard let landmark1 = face.landmarks?.rightPupil,let landmark2 = face.landmarks?.rightEyebrow else {
                print("error")
                return
            }
            
            let point1 = landmark1.normalizedPoints[0]
            let point2 = landmark2.normalizedPoints[1]
            let x_ = x + point1.x * w + margin
            let y_ = y + point2.y * h + unit * 4
            let stringPosition = CGPoint(x:x_,y:y_)
            let rect = CGRect(x: stringPosition.x, y: image.size.height - stringPosition.y, width: 250, height: 100)
            let string = xueDaoName
            string.draw(in: rect, withAttributes: attributes)
        }
        
        //素髎
        if xueDaoId == 9 {
            guard let landmark1 = face.landmarks?.nose,let landmark2 = face.landmarks?.noseCrest else {
                print("error")
                return
            }
            
            let point1 = landmark1.normalizedPoints[4]
            let point2 = landmark2.normalizedPoints[2]
            let x_ = x + CGFloat(point1.x) * w + margin
            var y_ = CGFloat(point2.y - (point2.y - point1.y)/2)
            y_ = y + y_ * h
            let stringPosition = CGPoint(x:x_,y:y_)
            let rect = CGRect(x: stringPosition.x, y: image.size.height - stringPosition.y, width: 250, height: 100)
            let string = xueDaoName
            string.draw(in: rect, withAttributes: attributes)
        }
        
        //人中(水溝)
        if xueDaoId == 10 {
            guard let landmark1 = face.landmarks?.medianLine,let landmark2 = face.landmarks?.nose,let landmark3 = face.landmarks?.outerLips else {
                print("error")
                return
            }
            let point1 = landmark1.normalizedPoints[4]
            let point2 = landmark2.normalizedPoints[4]
            let point3 = landmark3.normalizedPoints[2]
            let x_ = x + point1.x * w + margin
            let y_ = y + (point2.y - (point2.y-point3.y) / 3) * h
            let stringPosition = CGPoint(x:x_,y:y_)
            let rect = CGRect(x: stringPosition.x, y: image.size.height - stringPosition.y, width: 250, height: 100)
            let string = xueDaoName
            string.draw(in: rect, withAttributes: attributes)
        }
        
        //兌端
        if xueDaoId == 11 {
            guard let landmark1 = face.landmarks?.outerLips else {
                print("error")
                return
            }
            let point1 = landmark1.normalizedPoints[2]
            let x_ = x + point1.x * w + margin
            let y_ = y + point1.y * h
            let stringPosition = CGPoint(x:x_,y:y_)
            let rect = CGRect(x: stringPosition.x, y: image.size.height - stringPosition.y, width: 250, height: 100)
            let string = xueDaoName
            string.draw(in: rect, withAttributes: attributes)
        }
        
        //承漿
        if xueDaoId == 12 {
            guard let landmark1 = face.landmarks?.outerLips else {
                print("error")
                return
            }
            let point1 = landmark1.normalizedPoints[7]
            let x_ = x + point1.x * w + margin
            let y_ = y + (point1.y * 0.8) * h
            let stringPosition = CGPoint(x:x_,y:y_)
            let rect = CGRect(x: stringPosition.x, y: image.size.height - stringPosition.y, width: 250, height: 100)
            let string = xueDaoName
            string.draw(in: rect, withAttributes: attributes)
        }
    }
    
    func drawXueDaoPoint(context:CGContext,face:VNFaceObservation,xueDaoId:Int) {
        
        context.setStrokeColor(UIColor.blue.cgColor)
        context.setFillColor(UIColor.blue.cgColor)
        context.setLineWidth(self.lineWidth)
        
        // face rect
        let w = face.boundingBox.size.width * image.size.width
        let h = face.boundingBox.size.height * image.size.height
        let x = face.boundingBox.origin.x * image.size.width
        let y = face.boundingBox.origin.y * image.size.height
        let faceRect = CGRect(x: x, y: y, width: w, height: h)
        context.addRect(faceRect)
        context.drawPath(using: .stroke)
        
        //原點位置(左下)
        let pointRect = CGRect(x: x-radius, y: y-radius, width: radius*2, height: radius*2)
        context.addEllipse(in: pointRect)
        context.drawPath(using: .fillStroke)
        
        //禾髎
        if xueDaoId == 0  {
            guard let landmark1 = face.landmarks?.nose,let landmark2 = face.landmarks?.outerLips else {
                print("error")
                return
            }
            let point1 = landmark1.normalizedPoints[4]
            let point2 = landmark2.normalizedPoints[2]
            let point3 = landmark1.normalizedPoints[2]
            let x_ = x + point3.x * w - radius
            let y_ = y + (point1.y - (point1.y - point2.y) / 3) * h - radius
            let rect = CGRect(x: x_, y: y_, width: radius*2, height: radius*2)
            context.addEllipse(in: rect)
            context.drawPath(using: .fillStroke)
        }
        
        //迎香
        if xueDaoId  == 1 {
            guard let landmark1 = face.landmarks?.nose else {
                print("error")
                return
            }
            let point1 = landmark1.normalizedPoints[6]
            let point2 = landmark1.normalizedPoints[7]
            let x_ = x + point1.x * w - radius + unit
            let y_ = y + (point1.y + (point2.y-point1.y) / 2) * h - radius
            let rect = CGRect(x: x_, y: y_, width: radius*2, height: radius*2)
            context.addEllipse(in: rect)
            context.drawPath(using: .fillStroke)
        }
        
        //承泣
        if xueDaoId == 2 {
            guard let landmark1 = face.landmarks?.rightPupil,let landmark2 = face.landmarks?.noseCrest else {
                print("error")
                return
            }
            let point1 = landmark1.normalizedPoints[0]
            let point2 = landmark2.normalizedPoints[1]
            let x_ = x + point1.x * w - radius
            let y_ = y + point2.y * h - radius - unit
            let rect = CGRect(x: x_, y: y_, width: radius*2, height: radius*2)
            context.addEllipse(in: rect)
            context.drawPath(using: .fillStroke)
        }
        
        //四白
        if xueDaoId == 3 {
            guard let landmark1 = face.landmarks?.rightPupil,let landmark2 = face.landmarks?.noseCrest else {
                print("error")
                return
            }
            let point1 = landmark1.normalizedPoints[0]
            let point2 = landmark2.normalizedPoints[2]
            let x_ = x + point1.x * w - radius
            let y_ = y + point2.y * h - radius
            let rect = CGRect(x: x_, y: y_, width: radius*2, height: radius*2)
            context.addEllipse(in: rect)
            context.drawPath(using: .fillStroke)
        }
        
        //地倉
        if xueDaoId == 4 {
            guard let landmark1 = face.landmarks?.outerLips else {
                print("error")
                return
            }
            let point1 = landmark1.normalizedPoints[5]
            let x_ = x + point1.x * w - radius + unit
            let y_ = y + point1.y * h - radius
            let rect = CGRect(x: x_, y: y_, width: radius*2, height: radius*2)
            context.addEllipse(in: rect)
            context.drawPath(using: .fillStroke)
        }
        
        //攢竹
        if xueDaoId == 5 {
            guard let landmark1 = face.landmarks?.rightEyebrow else {
                print("error")
                return
            }
            let point1 = landmark1.normalizedPoints[0]
            let x_ = x + point1.x * w - radius
            let y_ = y + point1.y * h - radius
            let rect = CGRect(x: x_, y: y_, width: radius*2, height: radius*2)
            context.addEllipse(in: rect)
            context.drawPath(using: .fillStroke)
        }
        
        //睛明
        if xueDaoId == 6 {
            guard let landmark1 = face.landmarks?.rightEye else {
                print("error")
                return
            }
            let point1 = landmark1.normalizedPoints[0]
            let x_ = x + point1.x * w - radius - unit
            let y_ = y + point1.y * h - radius
            let rect = CGRect(x: x_, y: y_, width: radius*2, height: radius*2)
            context.addEllipse(in: rect)
            context.drawPath(using: .fillStroke)
        }
        
        //絲竹空
        if xueDaoId == 7 {
            guard let landmark1 = face.landmarks?.rightEyebrow else {
                print("error")
                return
            }
            let point1 = landmark1.normalizedPoints[3]
            let x_ = x + point1.x * w - radius
            let y_ = y + point1.y * h - radius
            let rect = CGRect(x: x_, y: y_, width: radius*2, height: radius*2)
            context.addEllipse(in: rect)
            context.drawPath(using: .fillStroke)
        }
        
        //陽白
        if xueDaoId == 8 {
            guard let landmark1 = face.landmarks?.rightPupil,let landmark2 = face.landmarks?.rightEyebrow else {
                print("error")
                return
            }
            
            let point1 = landmark1.normalizedPoints[0]
            let point2 = landmark2.normalizedPoints[1]
            let x_ = x + point1.x * w - radius
            let y_ = y + point2.y * h - radius + unit * 4
            let rect = CGRect(x: x_, y: y_, width: radius*2, height: radius*2)
            context.addEllipse(in: rect)
            context.drawPath(using: .fillStroke)
        }
        
        //素髎
        if xueDaoId == 9 {
            guard let landmark1 = face.landmarks?.nose,let landmark2 = face.landmarks?.noseCrest else {
                print("error")
                return
            }
            
            let point1 = landmark1.normalizedPoints[4]
            let point2 = landmark2.normalizedPoints[2]
            let x_ = x + point1.x * w - radius
            let y_ = y + (point2.y - (point2.y - point1.y)/2) * h - radius
            let rect = CGRect(x: x_, y: y_, width: radius*2, height: radius*2)
            context.addEllipse(in: rect)
            context.drawPath(using: .fillStroke)
        }
        
        //人中(水溝)
        if xueDaoId == 10 {
            if let landmark1 = face.landmarks?.medianLine, let landmark2 = face.landmarks?.nose, let landmark3 = face.landmarks?.outerLips {
                
                let point1 = landmark1.normalizedPoints[4]
                let point2 = landmark2.normalizedPoints[4]
                let point3 = landmark3.normalizedPoints[2]
                let x_ = x + point1.x * w - radius
                let y_ = y + (point2.y - (point2.y-point3.y) / 3) * h - radius
                let rect = CGRect(x: x_, y: y_, width: radius*2, height: radius*2)
                context.addEllipse(in: rect)
                context.drawPath(using: .fillStroke)
            }
        }
        
        //兌端
        if xueDaoId == 11 {
            guard let landmark1 = face.landmarks?.outerLips else {
                print("error")
                return
            }
            let point1 = landmark1.normalizedPoints[2]
            let x_ = x + point1.x * w - radius
            let y_ = y + point1.y * h - radius
            let rect = CGRect(x: x_, y: y_, width: radius*2, height: radius*2)
            context.addEllipse(in: rect)
            context.drawPath(using: .fillStroke)
        }
        
        //承漿
        if xueDaoId == 12 {
            guard let landmark1 = face.landmarks?.outerLips else {
                print("error")
                return
            }
            let point1 = landmark1.normalizedPoints[7]
            let x_ = x + point1.x * w - radius
            let y_ = y + (point1.y * 0.8) * h - radius
            let rect = CGRect(x: x_, y: y_, width: radius*2, height: radius*2)
            context.addEllipse(in: rect)
            context.drawPath(using: .fillStroke)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
