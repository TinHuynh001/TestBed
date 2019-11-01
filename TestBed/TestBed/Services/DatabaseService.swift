//
//  Database_Service.swift
//  TestBed
//
//  Created by TinHuynh on 10/31/19.
//  Copyright © 2019 TinHuynh. All rights reserved.
//

import Foundation
import CoreData

enum DatabaseError: Error
{
    case InsertError
    case RemoveError
    case EntityDoesNotExist
    case EntityAlreadyExist
    case ContextHasNotChanged
    case NoError
    
}

class DatabaseService
{
    
    static let sharedInstance = DatabaseService()
    private init() {}
    
    var databaseError = DatabaseError.EntityAlreadyExist
    
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer =
    {
        let container = NSPersistentContainer(name: "TestBed")
        
        container.loadPersistentStores(completionHandler:
        { (storeDescription, error) in
            if let error = error as NSError?
            {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext ()
    {
        let context = persistentContainer.viewContext
        if context.hasChanges
        {
            do
            {
                try context.save()
            }
            catch
            {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    func saveContext (context: NSManagedObjectContext) -> Error?
    {
        if context.hasChanges
        {
            do
            {
                try context.save()
                return nil
            }
            catch
            {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
                return error
            }
        }
        else
        {
            return DatabaseError.ContextHasNotChanged
        }
    }
    
    func clearDB()
    {
        let context = persistentContainer.viewContext
        let requestClearAll : NSFetchRequest<CDAlbum> = CDAlbum.fetchRequest()
        let batchDelete = NSBatchDeleteRequest(fetchRequest: requestClearAll as! NSFetchRequest<NSFetchRequestResult>)
        do
        {
            try context.execute(batchDelete)
            saveContext()
        }
        catch
        {
            print(error.localizedDescription)
        }
    }
    
    //MARK: public functions
    
    func checkExist(album: Album) -> Bool
    {
        let request: NSFetchRequest<CDAlbum> = CDAlbum.fetchRequest()
        let predicate = NSPredicate(format: "title = %@ AND artist = %@", album.title, album.artist)
        //let predicateArtist = NSPredicate(format: "artist = %@", album.artist)
        //let cmpPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateTitle, predicateArtist])
        
        request.predicate = predicate
        
        let backgroundContext = persistentContainer.newBackgroundContext()
        do
        {
            let results = try backgroundContext.fetch(request)
            if results.count != 0
            {
                return true
            }
            else
            {
                return false
            }
        }
        catch
        {
            print(error.localizedDescription)
            return false
        }
    }
    
    func insertAlbum(_ album: Album, completion: @escaping (Error?) -> Void)
    {
        if checkExist(album: album)
        {
            completion(DatabaseError.EntityAlreadyExist)
        }
        else
        {
        
            let backgroundContext = persistentContainer.newBackgroundContext()
            
            let newAlbum = CDAlbum(context: backgroundContext)
            
            newAlbum.title = album.title
            newAlbum.artist = album.artist
            newAlbum.urlStore = album.url
            newAlbum.urlImage = album.image
            newAlbum.urlThumbnail = album.image_thumbnail
            
            let result = saveContext(context: backgroundContext)
            
            completion(result)
        }
        
    }
    
    
    func removeAlbum(_ album: Album, completion: @escaping (Error?) -> Void)
    {
        if checkExist(album: album)
        {
            let request: NSFetchRequest<CDAlbum> = CDAlbum.fetchRequest()
            let predicate = NSPredicate(format: "title = %@ AND artist = %@", album.title, album.artist)
            
            request.predicate = predicate
            
            let backgroundContext = persistentContainer.newBackgroundContext()
            do
            {
                let results = try backgroundContext.fetch(request)
                if results.count != 0
                {
                    backgroundContext.delete(results[0])
                    let err = saveContext(context: backgroundContext)
                    completion(err)
                }
                else
                {
                    completion(DatabaseError.RemoveError)
                }
            }
            catch
            {
                print(error.localizedDescription)
                completion(error)
            }
        }
        else
        {
            completion(DatabaseError.EntityDoesNotExist)
        }
    }
    
    func fetchAllAlbum(completion: ([Album]?, Error?) -> Void)
    {
        let context = persistentContainer.newBackgroundContext()
        let request : NSFetchRequest<CDAlbum> = CDAlbum.fetchRequest()
        
        do
        {
            let results = try context.fetch(request)
            var resultAlbums : [Album] = []
            
            for r in results
            {
                let alb = Album(title: r.title!,
                                artist: r.artist!,
                                url: r.urlStore ?? "",
                                imageURL: r.urlImage ?? "",
                                thumbnailURL: r.urlThumbnail ?? "")
                
                resultAlbums.append(alb)
            }
            
            completion(resultAlbums, nil)
        }
        catch
        {
            completion(nil, error)
        }
    }
}
