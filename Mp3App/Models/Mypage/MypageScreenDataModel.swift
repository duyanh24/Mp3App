//
//  MypageScreenDataModel.swift
//  Mp3App
//
//  Created by AnhLD on 10/13/20.
//  Copyright © 2020 AnhLD. All rights reserved.
//

import Foundation

class MypageScreenDataModel {
    var playlists: [String] = []
    
    init (playlists: [String]) {
        self.playlists = playlists
    }
    
    func toDataSource() -> [MypageSectionModel] {
        var sectionModels = [MypageSectionModel]()
        sectionModels.append(.favourite(type: .favourite, items: [MypageSectionItem.favourite(type: .favourite, library: Strings.favouriteSong)]))
        if !playlists.isEmpty {
            sectionModels.append(.playlist(
                type: .playlist,
                items: playlists.map { MypageSectionItem.playlist(type: .playlist, playlist: $0)})
            )
        }
        return sectionModels
    }
}