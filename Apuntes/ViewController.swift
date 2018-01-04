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
        
        //Métodos de uso del PDF
        let search = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(promptForSearch))
        self.navigationItem.leftBarButtonItems = [search]
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func load(_ name: String) {
        //Convertir el nombre del libro al nombre del fichero
        let filename = name.replacingOccurrences(of: " ", with: "_").lowercased()
        
        //Buscar dentro del paquete de recursos (bundle) el archivo de extensión pdf
        guard let path = Bundle.main.url(forResource: filename, withExtension: "pdf") else { return }
        
        //Cargar el PDF usando la clase PDFDocument, con una URL
        if let document = PDFDocument(url: path) {
            //Asignar el PDFDocument a la PDFView de nuestra app
            self.pdfView.document = document
            
            //Llamar al metodo goToFirstPage()
            self.pdfView.goToFirstPage(nil)
            
            //Mostrar el nombre del fichero en la barra de título del iPad.
            if UIDevice.current.userInterfaceIdiom == .pad {
                title = name
            }
        }
    }
    
    @objc func promptForSearch() {
        let alert = UIAlertController(title: "Buscar", message: nil, preferredStyle: .alert)
        alert.addTextField()
        
        alert.addAction(UIAlertAction(title: "Buscar", style: .default, handler: { (action) in
            guard let searchText = alert.textFields?[0].text else { return }
            guard let match = self.pdfView.document?.findString(searchText, fromSelection: self.pdfView.highlightedSelections?.first, withOptions: .caseInsensitive) else { return }
            self.pdfView.go(to: match)
            
            self.pdfView.highlightedSelections = [match]
        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }

}

