//
//  ViewController.swift
//  Apuntes
//
//  Created by David Garcia on 1/3/18.
//  Copyright © 2018 David Garcia. All rights reserved.
//

import UIKit
import PDFKit

class ViewController: UIViewController {

    let pdfView = PDFView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Se rellena todo el especio disponible con las constraints.
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pdfView)
        
        pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func load(_ filename: String) {
        print(filename)
    }

}

