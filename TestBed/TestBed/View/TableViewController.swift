//
//  TableViewController.swift
//  TestBed
//
//  Created by TinHuynh on 10/30/19.
//  Copyright © 2019 TinHuynh. All rights reserved.
//

import UIKit

class TableViewController: UIViewController
{
    
    @IBOutlet weak var tableview: UITableView!
    var tableVM = TableViewModel()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        //tell VM to fetch
        tableVM.getAlbumArray
        { (errorString) in
            if let error = errorString
            {
                DispatchQueue.main.async
                {
                    self.showSimpleAlerts(title: "Data fetch error",
                                          reason: error)
                }
            }
            else
            {
                DispatchQueue.main.async
                {
                    self.tableview.reloadData()
                }
            }
        }

    }
    
    func showSimpleAlerts(title: String, reason: String)
    {
        let alert = UIAlertController(title: title,
                                      message: reason,
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK",
                                   style: .default,
                                   handler: nil)
        
        alert.addAction(action)
        
        self.present(alert, animated: true)
    }

}

extension TableViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        tableVM.getAlbumCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellAlbum")!
        
        cell.textLabel?.text = tableVM.getAlbumTitle(forIndex: indexPath.row)
        cell.detailTextLabel?.text = tableVM.getAlbumArtist(forIndex: indexPath.row)
        
        
        return cell
    }
    
    
}
