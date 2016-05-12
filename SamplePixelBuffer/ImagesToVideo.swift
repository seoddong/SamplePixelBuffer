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
        // UIImage를 쉽게 CGImage로 바꿀 수 없다는 것을 알았다. 아래의 과정을 거쳐야만 한다. 검은 화면이 나오는 것도 다 이런 이유였다.
        let ciimage = CIImage(image: image)
        let cgimage = convertCIImageToCGImage(ciimage!)

        // 아래 주석문의 Objective-C 구문을 swift로 변경하기 위해 이렇게 기나긴 코드를 작성해야 하다니!!
        // 오죽하면 아래 코드의 원작자도 stupid라는 주석을 달아놓았다!! ㅋㅋ
        /*
         NSDictionary *options = @{(id)kCVPixelBufferCGImageCompatibilityKey: @YES,
         (id)kCVPixelBufferCGBitmapContextCompatibilityKey: @YES};
        */
        // stupid CFDictionary stuff
        let keys: [CFStringRef] = [kCVPixelBufferCGImageCompatibilityKey, kCVPixelBufferCGBitmapContextCompatibilityKey]
        let values: [CFTypeRef] = [kCFBooleanTrue, kCFBooleanTrue]
        let keysPointer = UnsafeMutablePointer<UnsafePointer<Void>>.alloc(1)
        let valuesPointer =  UnsafeMutablePointer<UnsafePointer<Void>>.alloc(1)
        keysPointer.initialize(keys)
        valuesPointer.initialize(values)
        //let options = CFDictionaryCreate(kCFAllocatorDefault, keysPointer, valuesPointer, keys.count, UnsafePointer<CFDictionaryKeyCallBacks>(), UnsafePointer<CFDictionaryValueCallBacks>())
        // 원래 위 코드였는데 swift3에서 변경되었다고 한다.
        let options = CFDictionaryCreate(kCFAllocatorDefault, keysPointer, valuesPointer, keys.count, nil, nil)
        // 여기까지가 CFDictionary를 위한 코드

        let width = CGImageGetWidth(cgimage)
        let height = CGImageGetHeight(cgimage)
        
        let pxbuffer = UnsafeMutablePointer<CVPixelBuffer?>.alloc(width*height)
        // pxbuffer = nil 할 경우 status = -6661 에러 발생한다.
        var status = CVPixelBufferCreate(kCFAllocatorDefault, width, height,
                                         kCVPixelFormatType_32ARGB, options, pxbuffer)
        debugPrint("status = \(status)")
        status = CVPixelBufferLockBaseAddress(pxbuffer.memory!, 0);
        
        let bufferAddress = CVPixelBufferGetBaseAddress(pxbuffer.memory!);
        
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB();
        let context = CGBitmapContextCreate(bufferAddress, width,
                                            height, 8, 4 * width, rgbColorSpace,
                                            CGImageAlphaInfo.NoneSkipFirst.rawValue);
        //debugPrint("image = \(image)")
        CGContextDrawImage(context, CGRectMake(0, 0, CGFloat(width), CGFloat(height)), cgimage);
        

        // context에 그림이 제대로 그려졌는지 이미지로 변경하여 확인
        if let contextImage = CGBitmapContextCreateImage(context) {
            let checkImage1 = UIImage.init(CGImage: contextImage)
            let parentVC = sender as! ViewController
            //parentVC.animatedImageView.image = checkImage1
            
            let checkImage2 = CIImage.init(CVPixelBuffer: pxbuffer.memory!)
            parentVC.imageview.image = UIImage.init(CIImage: checkImage2)
            
            // 아래와 같이 비동기 방식을 이용하면 더 저장이 안 된다.
            //dispatch_async(dispatch_get_main_queue()) {
            
            // 이렇게 해도 카메라롤 가면 9장 저장 날렸는데 3~4장 밖에 저장이 안 된다.
            //UIImageWriteToSavedPhotosAlbum(checkImage, nil, nil, nil)
            //debugPrint("save..")
        }
        else {
            debugPrint("why context is null?")
        }

        
        status = CVPixelBufferUnlockBaseAddress(pxbuffer.memory!, 0);
        

        //return pxbuffer
        
    }
    
    func convertCIImageToCGImage(inputImage: CIImage) -> CGImage! {
        let context = CIContext(options: nil)
        
        return context.createCGImage(inputImage, fromRect: inputImage.extent)

    }

    /*
    // 아래 메소드들은 디버그용이다. 출력창에 이미지를 대충 그리기 위함
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