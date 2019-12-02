//
//  ViewController.swift
//  TransliteratingKeyboard
//
//  Created by Alexei Baboulevitch on 6/9/14.
//  Copyright (c) 2014 Alexei Baboulevitch ("Archagon"). All rights reserved.
//

import UIKit
import WebKit


class HostingAppViewController: UIViewController {
    
    @IBOutlet weak var wkWebView: WKWebView!
    @IBOutlet var stats: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "pCloud"
        let url = URL(string: "https://www.pcloud.com/")
        wkWebView.load(URLRequest(url: url!))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}

