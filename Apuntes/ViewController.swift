//
//  ViewController.swift
//  Apuntes
//
//  Created by David Garcia on 1/3/18.
//  Copyright © 2018 David Garcia. All rights reserved.
//

import UIKit
import PDFKit
import SafariServices

class ViewController: UIViewController, PDFViewDelegate {

    let pdfView = PDFView()
    let textView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Configuracion de PDF View
        //Se rellena todo el especio disponible con las constraints.
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pdfView)
        
        pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        //Configuracion de Text View
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        
        textView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        textView.isEditable = false
        textView.isHidden = true
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        //Métodos de uso del PDF
        let search = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(promptForSearch))
        let share  = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareSelection))
        
        let previus = UIBarButtonItem(barButtonSystemItem: .rewind, target: self.pdfView, action: #selector(PDFView.goToPreviousPage(_:)))
        let next = UIBarButtonItem(barButtonSystemItem: .fastForward, target: self.pdfView, action: #selector(PDFView.goToNextPage(_:)))
        
        self.navigationItem.leftBarButtonItems = [search, share, previus, next]
        
        self.pdfView.autoScales = true
        self.pdfView.delegate = self
        
        let pdfMode = UISegmentedControl(items: ["PDF", "Solo Texto"])
        pdfMode.addTarget(self, action: #selector(changePDFMode), for: .valueChanged)
        pdfMode.selectedSegmentIndex = 0
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: pdfMode)
        self.navigationItem.rightBarButtonItem?.width = 160
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
            
            self.readText()
            
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

    @objc func shareSelection(sender: UIBarButtonItem){
        guard let selection = self.pdfView.currentSelection?.attributedString else {
            let alert = UIAlertController(title: "No hay nada seleccionado", message: "Selecciona un fragmento del archivo para compartir", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true)
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: [selection], applicationActivities: nil)
        activityVC.popoverPresentationController?.barButtonItem = sender
        present(activityVC, animated: true)
    }
    
    func pdfViewWillClick(onLink sender: PDFView, with url: URL) {
        let viewController = SFSafariViewController(url: url)
        viewController.modalPresentationStyle = .formSheet
        present(viewController, animated: true)
    }
    
    @objc func changePDFMode(segmentedControl: UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == 0 {
            //Mostrar PDF
            pdfView.isHidden = false
            textView.isHidden = true
        } else {
            //Mostrar texto
            pdfView.isHidden = true
            textView.isHidden = false
        }
    }
    
    func readText(){
        guard let pageCount = self.pdfView.document?.pageCount else { return }
        let pdfContent = NSMutableAttributedString()
        let space = NSAttributedString(string: "\n\n\n")
        for i in 1..<pageCount {
            guard let page = self.pdfView.document?.page(at: i) else { continue }
            guard let pageContent = page.attributedString else { continue }
            
            pdfContent.append(space)
            pdfContent.append(pageContent)
        }
        
        let pattern = "https://frogames.es[0-9a-z]"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSMakeRange(0, pdfContent.string.utf16.count)
        
        if let matches = regex?.matches(in: pdfContent.string, options: [], range: range) {
            for match in matches.reversed(){
                pdfContent.replaceCharacters(in: match.range, with: "")
            }
        }
        
        self.textView.attributedText = pdfContent
    }
}

