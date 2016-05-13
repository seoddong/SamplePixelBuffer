//
//  File.swift
//  BurstAnimator
//
//  Created by SeoDongHee on 2016. 5. 2..
//  Copyright © 2016년 SeoDongHee. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class ImagesToVideo {
    
    var sender: AnyObject
    
    init(sender: AnyObject) {
        self.sender = sender
    }
    
    
    func pixelBufferFromImage(image: UIImage) {
        var outputSize: CGSize
        
        outputSize = CGSizeMake(image.size.width, image.size.height)
        
        debugPrint("arrayImages[0] = \(image)")
        debugPrint("outputSize = \(outputSize)")
        
        let tempPath = NSTemporaryDirectory().stringByAppendingString("temp.mp4")
        do {
            try NSFileManager.defaultManager().removeItemAtPath(tempPath)
            debugPrint("removeItemAtPath = success..")
        }
        catch {
            debugPrint("removeItemAtPath = error occured...")
        }
        // It's not easy that "Change UIImage to CGImage", if you would try even to change NSArray to CGImage, you get black screen finally. so you have to step below.
        let ciimage = CIImage(image: image)
        let cgimage = convertCIImageToCGImage(ciimage!)

        /*
         NSDictionary *options = @{(id)kCVPixelBufferCGImageCompatibilityKey: @YES,
         (id)kCVPixelBufferCGBitmapContextCompatibilityKey: @YES};
        */
        // stupid CFDictionary stuff
        let cfnumPointer = UnsafeMutablePointer<UnsafePointer<Void>>.alloc(1)
        let cfnum = CFNumberCreate(kCFAllocatorDefault, .IntType, cfnumPointer)
        let keys: [CFStringRef] = [kCVPixelBufferCGImageCompatibilityKey, kCVPixelBufferCGBitmapContextCompatibilityKey, kCVPixelBufferBytesPerRowAlignmentKey]
        let values: [CFTypeRef] = [kCFBooleanTrue, kCFBooleanTrue, cfnum]
        let keysPointer = UnsafeMutablePointer<UnsafePointer<Void>>.alloc(1)
        let valuesPointer =  UnsafeMutablePointer<UnsafePointer<Void>>.alloc(1)
        keysPointer.initialize(keys)
        valuesPointer.initialize(values)

        let options = CFDictionaryCreate(kCFAllocatorDefault, keysPointer, valuesPointer, keys.count, nil, nil)


        let width = CGImageGetWidth(cgimage)
        let height = CGImageGetHeight(cgimage)
        
        let pxbuffer = UnsafeMutablePointer<CVPixelBuffer?>.alloc(1)
        // if pxbuffer = nil, you will get status = -6661
        var status = CVPixelBufferCreate(kCFAllocatorDefault, width, height,
                                         kCVPixelFormatType_32ARGB, options, pxbuffer)
        debugPrint("status = \(status)")
        status = CVPixelBufferLockBaseAddress(pxbuffer.memory!, 0);
        
        let bufferAddress = CVPixelBufferGetBaseAddress(pxbuffer.memory!);
        debugPrint("pxbuffer.memory = \(pxbuffer.memory)")
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB();
        //debugPrint("rgbColorSpace = \(rgbColorSpace)")
        let bytesperrow = CVPixelBufferGetBytesPerRow(pxbuffer.memory!)
        let context = CGBitmapContextCreate(bufferAddress, width,
                                            height, 8, bytesperrow, rgbColorSpace,
                                            CGImageAlphaInfo.NoneSkipFirst.rawValue);
        //debugPrint("context = \(context.debugDescription)")
        CGContextDrawImage(context, CGRectMake(0, 0, CGFloat(width), CGFloat(height)), cgimage);
        

        // check context
        if let contextImage = CGBitmapContextCreateImage(context) {
            let checkImage1 = UIImage.init(CGImage: contextImage)
            let parentVC = sender as! ViewController
            //parentVC.imageview.image = checkImage1
            
            let checkImage2 = CIImage.init(CVPixelBuffer: pxbuffer.memory!)
            parentVC.imageview.image = UIImage.init(CIImage: checkImage2)
            
            //UIImageWriteToSavedPhotosAlbum(checkImage1, nil, nil, nil)
            //debugPrint("save..")
        }
        else {
            debugPrint("why context is null?")
        }

        status = CVPixelBufferUnlockBaseAddress(pxbuffer.memory!, 0);
        
    }
    
    func convertCIImageToCGImage(inputImage: CIImage) -> CGImage! {
        let context = CIContext(options: nil)
        
        return context.createCGImage(inputImage, fromRect: inputImage.extent)

    }

    /*
    // below is for debug, it's not working
    func drawOutput(pixelbuffer: UnsafeMutablePointer<CVPixelBuffer?>, width: Int, height: Int) {
        let pixels = pixelbuffer
        for var ii in 0...height {
            for var jj in 0...width {
                let color = pixels.memory! as Int
                print("\(r8(color)+g8(color)+b8(color)/3.0)")
                pixels ++
            }
            print("\n");
        }
    }
    func mask8(int: Int) -> Int {
        return int & 0xFF
    }
    func r8(int: Int) -> Int {
        return mask8(int)
    }
    func g8(int: Int) -> Int {
        return mask8(int) >> 8
    }
    func b8(int: Int) -> Int {
        return mask8(int) >> 16
    }
    */
    
}