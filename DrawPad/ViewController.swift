//
//  ViewController.swift
//  DrawPad
//
//  Created by Jean-Pierre Distler on 13.11.14.
//  Copyright (c) 2014 Ray Wenderlich. All rights reserved.
//

import UIKit
//import MobileCoreSerices

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var resetBtn: UIButton!
    
    var lastPoint = CGPoint.zeroPoint
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var swiped = false
    var startDraw = false
    var bgImage: UIImage?
    let TitleResetButton = "Reset"
    let TitleOpenButton = "Open"
    
    let colors: [(CGFloat, CGFloat, CGFloat)] = [
        (0, 0, 0),
        (105.0 / 255.0, 105.0 / 255.0, 105.0 / 255.0),
        (1.0, 0, 0),
        (0, 0, 1.0),
        (51.0 / 255.0, 204.0 / 255.0, 1.0),
        (102.0 / 255.0, 204.0 / 255.0, 0),
        (102.0 / 255.0, 1.0, 0),
        (160.0 / 255.0, 82.0 / 255.0, 45.0 / 255.0),
        (1.0, 102.0 / 255.0, 0),
        (1.0, 1.0, 0),
        (1.0, 1.0, 1.0),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.resetBtn.setTitle(TitleOpenButton, forState: UIControlState.Normal)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func reset(sender: AnyObject) {
        if self.resetBtn.titleForState(UIControlState.Normal) == TitleOpenButton {
            if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary )) {
                var picker: UIImagePickerController
                picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                self.presentViewController(picker, animated: true,completion: nil)
            }
        }else{
            mainImageView.image = nil
            bgImageView.image = bgImage;//TODO: why need assign again
            self.resetBtn.setTitle(TitleOpenButton, forState:UIControlState.Normal )
            self.startDraw = false
        }
    }
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!) {
        //TODO: adjust the image size
        self.bgImage = image
        bgImageView.image = image
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        //self.dismissModalViewControllerAnimated(true,completion:nil);
    }
    
    @IBAction func share(sender: AnyObject) {
        UIGraphicsBeginImageContext(mainImageView.bounds.size)
        //TODO: maybe need adjust
        bgImage?.drawInRect(CGRect(x: 0, y: 0,
            width: bgImageView.frame.size.width, height: bgImageView.frame.size.height))
        
        mainImageView.image?.drawInRect(CGRect(x: 0, y: 0,
            width: mainImageView.frame.size.width, height: mainImageView.frame.size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        presentViewController(activity, animated: true, completion: nil)
    }
    
    @IBAction func pencilPressed(sender: AnyObject) {
        
        var index = sender.tag ?? 0
        if index < 0 || index >= colors.count {
            index = 0
        }
        
        (red, green, blue) = colors[index]
        
        if index == colors.count - 1 {
            opacity = 1.0
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        swiped = false
        if let touch = touches.anyObject() as? UITouch {
            lastPoint = touch.locationInView(self.view)
        }
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        
        // 1
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        
        // 2
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
        
        // 3
        CGContextSetLineCap(context, kCGLineCapRound)
        CGContextSetLineWidth(context, brushWidth)
        CGContextSetRGBStrokeColor(context, red, green, blue, 1.0)
        CGContextSetBlendMode(context, kCGBlendModeNormal)
        
        // 4
        CGContextStrokePath(context)
        
        // 5
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        UIGraphicsEndImageContext()
        
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        // 6
        swiped = true
        if let touch = touches.anyObject() as? UITouch {
            let currentPoint = touch.locationInView(view)
            drawLineFrom(lastPoint, toPoint: currentPoint)
            
            // 7
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        if !swiped {
            // draw a single point
            drawLineFrom(lastPoint, toPoint: lastPoint)
        }
        
        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: kCGBlendModeNormal, alpha: 1.0)
        tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: kCGBlendModeNormal, alpha: opacity)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tempImageView.image = nil
        //
        if !startDraw {
            self.resetBtn.setTitle(TitleResetButton, forState:UIControlState.Normal )
            startDraw = true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let settingsViewController = segue.destinationViewController as SettingsViewController
        settingsViewController.delegate = self
        settingsViewController.brush = brushWidth
        settingsViewController.opacity = opacity
        settingsViewController.red = red
        settingsViewController.green = green
        settingsViewController.blue = blue
    }
    
}

extension ViewController: SettingsViewControllerDelegate {
    func settingsViewControllerFinished(settingsViewController: SettingsViewController) {
        self.brushWidth = settingsViewController.brush
        self.opacity = settingsViewController.opacity
        self.red = settingsViewController.red
        self.green = settingsViewController.green
        self.blue = settingsViewController.blue
    }
}

