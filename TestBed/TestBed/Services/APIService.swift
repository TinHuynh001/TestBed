//
//  API_Service.swift
//  TestBed
//
//  Created by TinHuynh on 10/31/19.
//  Copyright © 2019 TinHuynh. All rights reserved.
//

import Foundation

class APIService
{
    static let sharedInstance = APIService()
    private init() {}
    
    func fetchData(fromURL: URL, completion: @escaping (Data?, Error?)->Void)
    {
        URLSession.shared.dataTask(with: fromURL)
        { (data, response, error) in
            
            if let err = error
            {
                completion(nil, err)
            }
            else
            {
                completion(data, nil)
            }
        }.resume()
    }
}
