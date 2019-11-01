//
//  TableViewModel.swift
//  TestBed
//
//  Created by TinHuynh on 10/22/19.
//  Copyright © 2019 TinHuynh. All rights reserved.
//

import Foundation

class TableViewModel : NSObject
{
    var albumArray : [Album] = []
    
    let APIHandler = APIService.sharedInstance
    let databaseManager = DatabaseService.sharedInstance
    
    //MARK: View-ViewModel interactions
    
    func getAlbumCount() -> Int
    {
        return albumArray.count
    }
    
    func getAlbumTitle(forIndex: Int) -> String
    {
        return albumArray[forIndex].title
    }
    
    func getAlbumArtist(forIndex: Int) -> String
    {
        return albumArray[forIndex].artist
    }
    
    func getAlbumArray(completion: @escaping (String?) -> Void )
    {
        let url = assembleURL(fromString: STRING_URL_ALBUM)
        
        fetchAlbumData(fromURL: url!)
        { (data, error) in
            
            if error == nil,
                let dat = data
            {
                self.parseJSON(dat: dat)
                completion(nil)
            }
            else
            {
                completion(error?.localizedDescription)
            }
            
        }
    }
    
    // MARK: ViewModel internal functions
    
    
    func addAlbum(album: Album)
    {
        if !checkExistAlbum(album: album)
        {
            albumArray.append(album)
        }
        
    }
    
    func checkExistAlbum(album: Album) -> Bool
    {
        let found = albumArray.contains(where:
        { (alb) -> Bool in
            return alb.title == album.title
        })
        
        return found
    }
    
    func parseJSON(dat: Data)
    {
        do
        {
            self.albumArray = try JSONDecoder().decode([Album].self, from: dat)
            //print(albumArray)
        }
        catch
        {
            print(error.localizedDescription)
            return
        }
    }
    
    
    func assembleURL(fromString: String) -> URL?
    {
        let fullstring = STRING_URL_BASE + fromString
        if let url = URL(string: fullstring)
        {
            return url
        }
        else
        {
            return nil
        }
    }
    
    
    func fetchAlbumData(fromURL: URL, completion: @escaping (Data?, Error?)->Void)
    {
        APIHandler.fetchData(fromURL: fromURL, completion: completion)
    }
    
    
    func saveAlbumArray(completion: @escaping (Error?) -> Void )
    {
        
        for album in albumArray
        {
            databaseManager.insertAlbum(album)
            { (error) in
                if let err = error as? DatabaseError,
                    err == DatabaseError.InsertError
                {
                    //if it wasnt a duplicate error, end the loop and report error
                    completion(err)
                }
                else
                {
                    
                }
            }
        }
        completion(nil)
    }
    
    func fetchDataOffline(completion: (Error?) -> (Void) )
    {
        
    }
    
    
}
