//
//  AlbumModel.swift
//  TestBed
//
//  Created by TinHuynh on 10/22/19.
//  Copyright © 2019 TinHuynh. All rights reserved.
//

import Foundation

class Album : Codable
{
    var title : String!
    var artist : String!
    var url : String!
    var image : String!
    var image_thumbnail : String!
    
    
    
    init(title : String,
         artist : String,
         url : String,
         imageURL : String,
         thumbnailURL : String)
    {
        self.title = title
        self.artist = artist
        self.url = url
        self.image = imageURL
        self.image_thumbnail = thumbnailURL
    }
    
    convenience init(title: String,
                     artist: String)
    {
        self.init(title: title,
                  artist: artist,
                  url: "",
                  imageURL: "",
                  thumbnailURL: "")
    }
    
//    {"title":"Taylor Swift",
//    "artist":"Taylor Swift",
//    "url":"https://www.amazon.com/Taylor-Swift/dp/B0014I4KH6",
//    "image":"https://images-na.ssl-images-amazon.com/images/I/61McsadO1OL.jpg",
//    "thumbnail_image":"https://i.imgur.com/K3KJ3w4h.jpg"}
    
    enum CodingKeys: String, CodingKey
    {
        //syntax: case <property> = <JSON key name>
        case title = "title"
        case artist = "artist"
        case url = "url"
        case image = "image"
        case image_thumbnail = "thumbnail_image"
    }
    

}
