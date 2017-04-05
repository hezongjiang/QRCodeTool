//
//  ViewController.swift
//  QRCode
//
//  Created by he on 2017/4/1.
//  Copyright © 2017年 he. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = QRCodeTool.shared.createQRCodeImage(str: "https://www.baidu.com", size: imageView.frame.size.width, iconImage: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        QRCodeTool.shared.distinguishQRCodeFromImage(imageView.image!) { (str) in
            print(str)
        }
    }


}

