//
//  QRCodeTool.swift
//  QRCode
//
//  Created by he on 2017/4/1.
//  Copyright © 2017年 he. All rights reserved.
//

import UIKit
import AVFoundation

typealias QRResultBlock = (_ strs: [String]) -> ()

class QRCodeTool: NSObject {

    /// 单利
    public static let shared: QRCodeTool = QRCodeTool()
    
    private override init() {
        super.init()
    }
    
    /// 输入设备
    fileprivate lazy var input: AVCaptureDeviceInput? = {
        
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        return try? AVCaptureDeviceInput(device: device)
    }()
    
    /// 输出
    fileprivate lazy var output: AVCaptureMetadataOutput = {
        
        var captureMetaDataOutput = AVCaptureMetadataOutput()
        // 设置元数据输出处理代理
        captureMetaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        return captureMetaDataOutput
    }()
    
    /// 会话
    fileprivate lazy var session: AVCaptureSession = AVCaptureSession()
    
    /// 预览图层
    fileprivate lazy var previewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.session)
    
    
    fileprivate var resultBlock: QRResultBlock?
}

// MARK: - 公共方法
extension QRCodeTool {
    
    /// 开始扫描
    ///
    /// - Parameters:
    ///   - inView: 展示视图
    ///   - result: 扫描结果
    public func begainScan(inView: UIView, result: @escaping QRResultBlock) {
        
        resultBlock = result
        
        if session.canAddInput(input) && session.canAddOutput(output) {
            session.addInput(input)
            session.addOutput(output)
        }
        
        //设置元数据处理类型(表示元数据输出对象, 可以处理什么样的数据, 比如二维码, 条形码, XX🐴)
        //    output.availableMetadataObjectTypes, 代表把能支持的, 都支持上, 其实我们使用的仅仅是二维码而已(AVMetadataObjectTypeQRCode)
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        previewLayer.frame = inView.bounds;
        inView.layer.insertSublayer(previewLayer, at: 0)
        
        session.startRunning()
    }
    
    /// 结束扫描
    public func endScan() {
        session.stopRunning()
    }
    
    /// 设置兴趣点
    public func setOriginRectOfInterest(_ originRect: CGRect) {
        // 设置兴趣点
        // 注意: 每个参数的取值都是对应的比例
        // 注意: 坐标系, 是横屏状态下的坐标系
        let screenBounds = UIScreen.main.bounds
        let x = originRect.origin.y / screenBounds.size.height
        let y = originRect.origin.x / screenBounds.size.width
        let width = originRect.size.height / screenBounds.size.height
        let height = originRect.size.width / screenBounds.size.width
        let rect = CGRect(x: x, y: y, width: width, height: height)
        output.rectOfInterest = rect
    }
    
    /** 从图片中识别二维码 */
    public class func distinguishQRCodeFromImage(_ sourceImage: UIImage, result: QRResultBlock) {
        
        // 创建一个上下文
        let context = CIContext()
        // 创建一个探测器
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        // 转换原图片为 CIImage
        let image = CIImage(cgImage: sourceImage.cgImage!)
        // 获取探测器识别的在图像中的类型
        let features = detector?.features(in: image)
        
        var results = [String]()
        
        guard features != nil else {
            result(results)
            return
        }
        
        for feature in features!
        {
            guard let resultFeature = feature as? CIQRCodeFeature else { continue }
            results.append(resultFeature.messageString!)
        }
        result(results)
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension QRCodeTool: AVCaptureMetadataOutputObjectsDelegate {

    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        var results = [String]()
        
        for result in metadataObjects {
            
            guard let metadataObject = result as? AVMetadataObject else { continue }
            
            let codeObj = previewLayer.transformedMetadataObject(for: metadataObject)
            
            guard let resultCodeObject = codeObj as? AVMetadataMachineReadableCodeObject else { continue }
            
            results.append(resultCodeObject.stringValue)
        }
        
        if resultBlock != nil { resultBlock!(results) }
    }
}
