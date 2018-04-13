//
//  ViewController.swift
//  ResourceManageDemo
//
//  Created by damonwong on 2018/4/12.
//  Copyright © 2018年 damonwong. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let imageView = UIImageView(image: Asset.damonwong.image)
        imageView.center = view.center
        view.addSubview(imageView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

