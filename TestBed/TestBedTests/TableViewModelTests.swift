//
//  TableViewModelTests.swift
//  TestBedTests
//
//  Created by TinHuynh on 10/22/19.
//  Copyright © 2019 TinHuynh. All rights reserved.
//

import XCTest
@testable import TestBed

class TableViewModelTests: XCTestCase
{
    var VM : TableViewModel!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        VM = TableViewModel()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        VM = nil
    }

    func testAlbumArrayFunctions()
    {
        XCTAssertNotNil(VM.albumArray)
        
        let sampleArray = setupAlbumArray()
        
        //test adding a new album
        VM.addAlbum(album: Album(title: "Something", artist: "Someone"))
        
        XCTAssertEqual(VM.albumArray[0].title, "Something")
        XCTAssertEqual(VM.albumArray[0].artist, "Someone")
        XCTAssertEqual(VM.albumArray[0].url, "")
        
        
        //test adding multiple album
        VM.addAlbum(album: Album(title: "Anything", artist: "Anyone"))
        VM.addAlbum(album: Album(title: "Nothing", artist: "NoOne"))
        VM.addAlbum(album: Album(title: "Fight Club", artist: "Louna"))
        
        //make sure both the array and the VM function return the same thing
        XCTAssertEqual(VM.albumArray.count, sampleArray.count)
        XCTAssertEqual(VM.getAlbumCount(), sampleArray.count)
        
        
        //test adding duplicated album name
        VM.addAlbum(album: Album(title: "Nothing", artist: "NoOne"))
        XCTAssertEqual(VM.albumArray.count, sampleArray.count)
        
        
        //access album array
        let tlt = VM.getAlbumTitle(forIndex: 2)
        let art = VM.getAlbumArtist(forIndex: 3)
        
        XCTAssertEqual(tlt, sampleArray[2].title)
        XCTAssertEqual(art, sampleArray[3].artist)
        
        
    }
    
    func setupAlbumArray() -> [Album]
    {
        let album1 = Album(title: "Something", artist: "Someone")
        let album2 = Album(title: "Anything", artist: "Anyone")
        let album3 = Album(title: "Nothing", artist: "NoOne")
        let album4 = Album(title: "Fight Club", artist: "Louna")
        
        let array : [Album] = [album1, album2, album3, album4]
        
        return array
    }
    
    func testURLAssembly()
    {
        XCTAssertNotNil(VM.APIHandler)
        //test URL assembly
        let url = VM.assembleURL(fromString: STRING_URL_ALBUM)
        XCTAssertNotNil(url!)
        XCTAssertTrue(type(of: url!) == URL.self)
    }
    
    func testAPIcall()
    {
        
        //setup
        let url = VM.assembleURL(fromString: STRING_URL_ALBUM)
        
        let expect = XCTestExpectation(description: "Test network async call")

        //test API call in success case
        VM.fetchAlbumData(fromURL: url!)
        { (data, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(data)
            do
            {
                let results = try JSONDecoder().decode([Album].self, from: data!)
                if results.count == 5
                {
                    expect.fulfill()
                }
            }
            catch
            {
                XCTFail(error.localizedDescription)
            }

        }
        
        wait(for: [expect], timeout: 10)
        
        
        
        
    }
    
    func testDataParsing()
    {
        //test data parsing
        //slightly different from that of the album data model since we expect the JSON to contain an array of Album
        //even in edge case that only one album is presented.
        let jsonTest =
"""
[{"title":"Taylor Swift","artist":"Taylor Swift","url":"https://www.amazon.com/Taylor-Swift/dp/B0014I4KH6","image":"https://images-na.ssl-images-amazon.com/images/I/61McsadO1OL.jpg","thumbnail_image":"https://i.imgur.com/K3KJ3w4h.jpg"}]
"""
                
        
        let jsonData = Data(jsonTest.utf8)
        
        VM.parseJSON(dat: jsonData)
        
        XCTAssertTrue(VM.albumArray.count == 1)
        
        let album = VM.albumArray[0]
        XCTAssertEqual(album.title, "Taylor Swift")
        XCTAssertEqual(album.artist, "Taylor Swift")
        XCTAssertEqual(album.url, "https://www.amazon.com/Taylor-Swift/dp/B0014I4KH6")
        XCTAssertEqual(album.image, "https://images-na.ssl-images-amazon.com/images/I/61McsadO1OL.jpg")
        XCTAssertEqual(album.image_thumbnail, "https://i.imgur.com/K3KJ3w4h.jpg")
        
        //WRITE test for parsing from a String:Any dict
    }
    
    
    func testDatabase()
    {
        //check singleton
        XCTAssertNotNil(VM.databaseManager)
        
        //flush the DB
        VM.databaseManager.clearDB()
        
        VM.albumArray = setupAlbumArray()
        
        //test saving album in the memory into CoreData storage
        VM.saveAlbumArray()
        { (error) in
            
            XCTAssertNil(error)
            XCTAssertTrue(self.VM.databaseManager.checkExist(album: self.VM.albumArray[0]))
            XCTAssertTrue(self.VM.databaseManager.checkExist(album: self.VM.albumArray[1]))
            XCTAssertTrue(self.VM.databaseManager.checkExist(album: self.VM.albumArray[2]))
            XCTAssertTrue(self.VM.databaseManager.checkExist(album: self.VM.albumArray[3]))
        }
        
        //test fetching album from CoreData back into memory
        VM.albumArray = []
        
//        VM.fetchAlbumDataOffline()
//        { (error) in
//            XCTAssertNil(error)
//            XCTAssert(self.VM.albumArray.count == 4)
//        }
        
        
    }


}
