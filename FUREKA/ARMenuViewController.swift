//
//  ARMenuViewController.swift
//  FUREKA
//
//  Created by Sherry Chen on 5/11/18.
//  Copyright © 2018 Sherry Chen. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import TesseractOCR

class ARMenuViewController: UIViewController {
    
    //IBOutlets
    @IBOutlet weak var MenuExplanationLabel: UILabel!
    @IBOutlet weak var RestaurantPageButton: UIButton!
    @IBOutlet weak var SharePhotoButton: UIButton!
    
    var session = AVCaptureSession()
    var requests = [VNRequest]()
    var textImages = [UIImage]()
    var imageLayer = AVCaptureVideoPreviewLayer();
    var markedImage: UIImage?;
    var isReadingImage = false;
    var tesseract : G8Tesseract? = G8Tesseract(language: "eng", engineMode: .tesseractOnly);
    // Text recognition every 10 counts to make the rendering smoother
    var recognition_speed_controller = 0
    var first_time = true
    var displayedBoxes = 0
    
    override func viewWillAppear(_ animated: Bool) {
        //If it's the first time initiating ARMenuVC, set up + start session.
        //Else, just start session
        if (first_time){
            startLiveVideo()
            print("viewWillAppear startLiveVideo")
            first_time = false
        } else {
            session.startRunning()
        }
        
        //Set navigation bar title
        let textAttributes = [NSAttributedStringKey.foregroundColor: FUREKA_LightOrange]
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        navigationController?.navigationBar.tintColor = .white
        navigationItem.title = "Little Italy"
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            navigationController?.navigationBar.prefersLargeTitles = false
        }
        
        //Set outlets - don't need to insert these subviews again! Storyboard has already inserted them - inspected from print out subviews and sublayers - 180527
        //Set menu explanation color
        MenuExplanationLabel.textColor = FUREKA_Pink
        
        //Set styles of RestaurantPageButton & SharePhotoButton
        RestaurantPageButton.backgroundColor = FUREKA_Orange
        RestaurantPageButton.tintColor = UIColor.white
        RestaurantPageButton.layer.cornerRadius = 25
        RestaurantPageButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 19)
        SharePhotoButton.backgroundColor = FUREKA_Orange
        SharePhotoButton.tintColor = UIColor.white
        SharePhotoButton.layer.cornerRadius = 25
        SharePhotoButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 19)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Set up navigation bar title
        
        //UINavigationBar.appearance().tintColor = .white
        
        //The following block might be necessary if the video view doesn't align to the top
        /**/
        
        //startLiveVideo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        //print("session stopped running")
    }
    
    //MARK: Buttons
    //The right bar button target function
    @objc func ProfilePicButtonTapped(_ sender: UIButton){ //<- needs `@objc`
        print("\(sender)")
    }
    
    @IBAction func RestaurantPageButtonPressed(_ sender: Any) {
        session.stopRunning()
        self.performSegue(withIdentifier: "ARMenuToRestaurantPage", sender: nil)
    }
    
    @IBAction func SharePhotoButtonPressed(_ sender: Any) {
        session.stopRunning()
        self.performSegue(withIdentifier: "ARMenuToSharePhoto", sender: nil)
    }
    
    //MARK: text detection & recognition
    func startLiveVideo() {
        //Modify settings for AVCaptureSession
        session.sessionPreset = AVCaptureSession.Preset.photo
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        //Define device input and output
        let deviceInput = try! AVCaptureDeviceInput(device: captureDevice!)
        let deviceOutput = AVCaptureVideoDataOutput()
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        session.addInput(deviceInput)
        session.addOutput(deviceOutput)
        
        //Add a sublayer containing the video preview to the imageView
        imageLayer = AVCaptureVideoPreviewLayer(session: session)
        imageLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.insertSublayer(imageLayer, at: 0)
        imageLayer.frame = view.layer.bounds
        
        //Get the session running
        session.startRunning()
    }
    
    func detectAndDisplayText(forImage image: UIImage) {
        // Remove preview text markings if needed
        self.textImages.removeAll()
        
        // Create the Vision request handler
        let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [VNImageOption:Any]())
        
        // Setup text recognition request
        let request = VNDetectTextRectanglesRequest(completionHandler: { (request, error) in
            if error != nil {
                print("Error in text detection: \(String(describing: error?.localizedDescription))")
            } else {
                // Add text outlines to the image on screen
                
                //observations will contain all the results of our VNDetectTextRectanglesRequest
                guard let observations = request.results else {
                    print("no result")
                    return
                }
                //go through all the results of the request and transform them into VNTextObservation
                let result = observations.map({$0 as? VNTextObservation})
               
                //An indicator variable to check if all detection has finished
                let num_results = result.count
                var indicator_v = Array(repeating: 1, count: num_results)
                
                //Clean the existing word box sublayers
                let total_sublayers = self.view.layer.sublayers?.count
                let start_cut_index = total_sublayers! - self.displayedBoxes
                let end_cut_index = total_sublayers!
                self.view.layer.sublayers?.removeSubrange(start_cut_index..<end_cut_index)
                
                //Clear the recorded number of displayed boxes
                self.displayedBoxes = 0
                
                //Draw out and save each word
                for region in result {
                    guard let rg = region else {
                        continue
                    }
                    
                    //highlight words and change rg (VNTextObservation) to image
                    //Set the corresponding slot in the indicator_v to be 0
                    self.highlightandRecognizeWord(box: rg, entireScreen: image, completion_handler: {
                        indicator_v[result.index(of: region)!] = 0
                    })
                }
                
                //At this time, all the words detected in the image have been saved to textImages
                
                //Spin lock to wait until all highlightandSaveWord functions have finished
                while(indicator_v.reduce(0,+)>0){};
                //Finished reading images. Open the access to captureOutput again.
                self.isReadingImage = false
                
            }
        })
        
        request.reportCharacterBoxes = true
        
        do {
            try handler.perform([request])
        } catch {
            print("Unable to detect text")
        }
    }
    
    func highlightandRecognizeWord(box: VNTextObservation, entireScreen: UIImage, completion_handler: @escaping (()->())) {
        //1. Get detected regions
        guard let boxes = box.characterBoxes else {
            return
        }
        
        var xMin: CGFloat = 9999.0
        var xMax: CGFloat = 0.0
        var yMin: CGFloat = 9999.0
        var yMax: CGFloat = 0.0
        
        //variables to save an average char width
        var sum_char_width = CGFloat(0.0);
        var counter = 0;
        for char in boxes {
            sum_char_width = sum_char_width + char.bottomRight.x - char.bottomLeft.x;
            counter = counter + 1;
            if char.bottomLeft.x < xMin {xMin = char.bottomLeft.x}
            if char.bottomRight.x > xMax {xMax = char.bottomRight.x}
            if char.bottomRight.y < yMin {yMin = char.bottomRight.y}
            if char.topRight.y > yMax {yMax = char.topRight.y}
        }
        
        let average_char_width = sum_char_width / CGFloat(counter)
        
        let xCoord = (xMin - CGFloat(2) * average_char_width) * view.frame.size.width
        let yCoord = (1 - yMax) * view.frame.size.height
        let width = (xMax - xMin + CGFloat(4)*average_char_width) * view.frame.size.width
        let height = (yMax - yMin) * view.frame.size.height
        
        //2. Highlight the words
        let layer = CALayer()
        let pct = 0.1 as CGFloat
        let boundingBox = CGRect(x: xCoord, y: yCoord, width: width, height: height)
        let expandedBboundingBox = boundingBox.insetBy(dx: -boundingBox.width*pct/2, dy: -boundingBox.height*pct/2)
        layer.frame = expandedBboundingBox
        layer.borderWidth = 2.0
        layer.borderColor = UIColor.green.cgColor
        
        if (width > 7.4 && height > 4.1){
            //DEBUG
            /*
             print("xCoord = " + String(describing: xCoord) + "; yCoord = " + String(describing: yCoord) + "; width = " + String(describing: width) + "; height = " + String(describing: height));
            print("view.frame.size.height: " + String(describing: view.frame.size.height) + "; view.frame.size.width: " + String(describing: view.frame.size.width)); //736 * 414
            print("image height: " + String(describing: entireScreen.size.height) + "; image width: " + String(describing: entireScreen.size.width)); //1440 * 1080
             */
            
            DispatchQueue.main.async() {
                self.view.layer.insertSublayer(layer, above: self.view.layer)
                //DEBUG
                self.displayedBoxes += 1
            }
            
            //addCroppedImageToTextImages(sourceImage: entireScreen, boundingBox: layer.frame, completion_handler: completion_handler)
            
            //3. Save cropped images to textImages
            let scale : CGFloat = entireScreen.size.height/view.frame.size.height //Scale (=1440/736=810/414~=1.956)
            
            let imageCropX = layer.frame.origin.x * scale + 135.0;
            let imageCropY = layer.frame.origin.y * scale;
            let imageCropWidth : CGFloat = layer.frame.width * scale;
            let imageCropHeight : CGFloat = layer.frame.height * scale;
            
            let croppingBox : CGRect = CGRect(x: imageCropX, y: imageCropY, width:imageCropWidth, height: imageCropHeight)
            
            let pct = 0.2 as CGFloat
            let expandedCroppingBox = croppingBox.insetBy(dx: -croppingBox.width*pct/2, dy: -croppingBox.height*pct/2)
            
            if let imageRef = entireScreen.cgImage!.cropping(to: expandedCroppingBox) { //if the cropped image is within bound
                let croppedImage = UIImage(cgImage: imageRef, scale: entireScreen.scale, orientation: entireScreen.imageOrientation)
                textImages.append(croppedImage)
                
                //4. Recognize text
                if (recognition_speed_controller % 10 == 0){
                    tesseract?.image = croppedImage.g8_blackAndWhite()
                    tesseract?.recognize()
                    if var text = tesseract?.recognizedText {
                        text = text.trimmingCharacters(in: CharacterSet.newlines)
                        print(text)
                    }
                }
                
                completion_handler()
            }
        }
        
    }
    
    //ADDED: add cropped images to text images
    /*func addCroppedImageToTextImages(sourceImage image: UIImage, boundingBox: CGRect, completion_handler: @escaping (()->())) {
        
        //DEBUG
        //print("boundingBox: " + String(describing: boundingBox));
        //print("newRect: " + String(describing: newRect));
        
        let scale : CGFloat = image.size.height/view.frame.size.height //Scale (=1440/736=810/414~=1.956)
        
        let imageCropX = boundingBox.origin.x * scale + 135.0;
        let imageCropY = boundingBox.origin.y * scale;
        let imageCropWidth : CGFloat = boundingBox.width * scale;
        let imageCropHeight : CGFloat = boundingBox.height * scale;
        
        let croppingBox : CGRect = CGRect(x: imageCropX, y: imageCropY, width:imageCropWidth, height: imageCropHeight)
        
        let pct = 0.2 as CGFloat
        let expandedCroppingBox = croppingBox.insetBy(dx: -croppingBox.width*pct/2, dy: -croppingBox.height*pct/2)
        
        if let imageRef = image.cgImage!.cropping(to: expandedCroppingBox) { //if the cropped image is within bound
            let croppedImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
            
            //Recognize text from the image
            //let result_text = performImageRecognition(croppedImage)
            //print(result_text)
            
            textImages.append(croppedImage)
            
            completion_handler()
        }
        
    }*/
    
    //Helper method for image rotation
    func imageRotatedBy90Degrees(oldImage: UIImage, deg degrees: CGFloat) -> UIImage {
        //Calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: oldImage.size.height, height: oldImage.size.width))
        let t: CGAffineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat.pi / 180)
        rotatedViewBox.transform = t
        let rotatedSize: CGSize = rotatedViewBox.frame.size
        //Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap: CGContext = UIGraphicsGetCurrentContext()!
        //Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        //Rotate the image context
        bitmap.rotate(by: (degrees * CGFloat.pi / 180))
        //Now, draw the rotated/scaled image into the context
        bitmap.scaleBy(x: 1.0, y: -1.0)
        bitmap.draw(oldImage.cgImage!, in: CGRect(x: -oldImage.size.height / 2, y: -oldImage.size.width / 2, width: oldImage.size.height, height: oldImage.size.width))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    // Tesseract Image Recognition
    /*func performImageRecognition(_ image: UIImage) -> String {
        var result_text:String = ""
        //Initialize a new G8Tesseract object with the English and French data.
        if let tesseract = G8Tesseract(language: "eng+fra") {
            //Choose the most accurate (but slowest) OCR engine mode.
            tesseract.engineMode = .tesseractCubeCombined
            //Set pageSegmentationMode to .auto so Tesseract can automatically recognize paragraph breaks.
            tesseract.pageSegmentationMode = .auto
            //Use Tesseract’s built-in filter to desaturate, increase the contrast, and reduce the exposure
            tesseract.image = image.g8_blackAndWhite()
            //Perform the optical character recognition.
            tesseract.recognize()
            //Put the recognized text into textView.
            result_text = tesseract.recognizedText
        }
        return result_text
    }*/
    
    //MARK: segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //session.stopRunning()
        //print("session stopped running")
        navigationItem.title = " "
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ARMenuViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    //MARK: captureVideoOutput
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        //If other processes are not reading the image
        if (!isReadingImage){
            isReadingImage = true
            //ADDED: change pixelBuffer to UIImage and process it
            CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
            let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
            let width = CVPixelBufferGetWidth(pixelBuffer)
            let height = CVPixelBufferGetHeight(pixelBuffer)
            let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
            if let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) {
                if let cgImage = context.makeImage() {
                    let currImage = UIImage(cgImage: cgImage, scale: 1, orientation:.right)
                    let rotatedImage = imageRotatedBy90Degrees(oldImage: currImage, deg: CGFloat(90.0))
                    //process image
                    detectAndDisplayText(forImage: rotatedImage)
                }
            }
            recognition_speed_controller = recognition_speed_controller + 1
            
            CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        }
    }
}
