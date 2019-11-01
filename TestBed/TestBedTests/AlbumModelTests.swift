//
//  AlbumModelTests.swift
//  TestBedTests
//
//  Created by TinHuynh on 10/22/19.
//  Copyright © 2019 TinHuynh. All rights reserved.
//

import XCTest
@testable import TestBed
class AlbumModelTests: XCTestCase {



    func testAlbum()
    {
        //test default init
        let album = Album(title: "A",
                          artist: "B",
                          url: "C",
                          imageURL: "D",
                          thumbnailURL: "E")
                
        XCTAssertTrue(album.title == "A")
        XCTAssertTrue(album.artist == "B")
        XCTAssertTrue(album.url == "C")
        XCTAssertTrue(album.image == "D")
        XCTAssertTrue(album.image_thumbnail == "E")
        
        
        //test convenience init
        let album_NoLink = Album(title: "FF", artist: "VV")

        XCTAssertTrue(album_NoLink.url.isEmpty)
        XCTAssertTrue(album_NoLink.image.isEmpty)
        XCTAssertTrue(album_NoLink.image_thumbnail.isEmpty)
        
        
        //test init by JSONDecoder
        
        let jsonTest =
"""
{"title":"Taylor Swift","artist":"Taylor Swift","url":"https://www.amazon.com/Taylor-Swift/dp/B0014I4KH6","image":"https://images-na.ssl-images-amazon.com/images/I/61McsadO1OL.jpg","thumbnail_image":"https://i.imgur.com/K3KJ3w4h.jpg"}
"""
        
        let decoder = JSONDecoder()
        let jsonData = Data(jsonTest.utf8)
        
        XCTAssertNoThrow(try decoder.decode(Album.self,from: jsonData))
        
        do
        {
            let album_codable = try decoder.decode(Album.self, from: jsonData)
            
            XCTAssertEqual(album_codable.title, "Taylor Swift")
            XCTAssertEqual(album_codable.artist, "Taylor Swift")
            XCTAssertEqual(album_codable.url, "https://www.amazon.com/Taylor-Swift/dp/B0014I4KH6")
            XCTAssertEqual(album_codable.image, "https://images-na.ssl-images-amazon.com/images/I/61McsadO1OL.jpg")
            XCTAssertEqual(album_codable.image_thumbnail, "https://i.imgur.com/K3KJ3w4h.jpg")
        }
        catch
        {
            XCTFail(error.localizedDescription)
        }
        
        
    }



}
