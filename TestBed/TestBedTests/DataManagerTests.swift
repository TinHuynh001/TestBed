//
//  DatabaseServiceTests.swift
//  TestBedTests
//
//  Created by TinHuynh on 10/31/19.
//  Copyright © 2019 TinHuynh. All rights reserved.
//

import XCTest
import CoreData
@testable import TestBed

class DatabaseServiceTests: XCTestCase
{
    let database = DatabaseService.sharedInstance
    
    
    override func setUp()
    {
        let context = database.persistentContainer.viewContext
        let requestClearAll : NSFetchRequest<CDAlbum> = CDAlbum.fetchRequest()
        let batchDelete = NSBatchDeleteRequest(fetchRequest: requestClearAll as! NSFetchRequest<NSFetchRequestResult>)
        do
        {
            try context.execute(batchDelete)
        }
        catch
        {
            print(error.localizedDescription)
        }
        
    }

    func testCheckExist()
    {
        let mainContext = database.persistentContainer.viewContext
        
        let alb1 = Album(title: "Album 1",
                        artist: "B",
                        url: "C",
                        imageURL: "D",
                        thumbnailURL: "E")
        
        let alb2 = Album(title: "Album 2",
                         artist: "B",
                         url: "C",
                         imageURL: "D",
                         thumbnailURL: "E")
        
        let alb2CD = CDAlbum(context: mainContext)
        alb2CD.title = alb2.title
        alb2CD.artist = alb2.artist
        alb2CD.urlStore = alb2.url
        alb2CD.urlImage = alb2.image
        alb2CD.urlThumbnail = alb2.image_thumbnail
        database.saveContext()
        
        
        XCTAssertFalse(database.checkExist(album: alb1))
        XCTAssertTrue(database.checkExist(album: alb2))
        
    }
    
    func testInsertion()
    {
        let alb1 = Album(title: "Album 1",
                        artist: "B",
                        url: "C",
                        imageURL: "D",
                        thumbnailURL: "E")
        
        
        let expectInsertSuccess = XCTestExpectation(description: "Test insertion ffrom background queue")
        
        //check success insertion
        database.insertAlbum(alb1)
        { (error) in
            XCTAssertNil(error)
            XCTAssertTrue(self.database.checkExist(album: alb1))
            expectInsertSuccess.fulfill()
        }
        
        let expectInsertFail = XCTestExpectation(description: "Test fail insertion")
        //check failed insertion
        database.insertAlbum(alb1)
        { (error) in
            XCTAssertTrue(self.database.checkExist(album: alb1))
            
            XCTAssertNotNil(error!)
            if let err = error as? DatabaseError,
                err == DatabaseError.EntityAlreadyExist
            {
                expectInsertFail.fulfill()
            }
        }
    }
    
    func testRemove()
    {
        let alb1 = Album(title: "Album 1",
                        artist: "B",
                        url: "C",
                        imageURL: "D",
                        thumbnailURL: "E")
        
        let alb2 = Album(title: "Album 2",
                         artist: "B",
                         url: "C",
                         imageURL: "D",
                         thumbnailURL: "E")
        
        
        database.insertAlbum(alb1)
        { (err1) in
            //
        }
        
        database.insertAlbum(alb2)
        { (err2) in
            //
        }
        
        let expectRemoveSuccess = XCTestExpectation(description: "Test removing object, success")
        
        database.removeAlbum(alb2)
        { (error) in
            XCTAssertNil(error)
            XCTAssertFalse(self.database.checkExist(album: alb2))
            expectRemoveSuccess.fulfill()
        }
        
        let expectRemoveFail = XCTestExpectation(description: "Test removing object, fail")
        
        database.removeAlbum(alb2)
        { (error) in
            XCTAssertNotNil(error)
            if let err = error as? DatabaseError,
                err == DatabaseError.EntityDoesNotExist
            {
                expectRemoveFail.fulfill()
            }
        }
    }


}
