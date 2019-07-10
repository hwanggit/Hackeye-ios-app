//
//  Models.swift
//  Hackeye
//
//  Created by Luhao Wang on 7/8/19.
//  Copyright © 2019 Luhao Wang. All rights reserved.
//

import Foundation

struct Root: Codable {
    let projects: [Project]
}

struct User: Codable {
    let location: String
    let screenName: String
    let url: String
    let imageUrl: String
}

struct Project: Codable {
    let id: Int
    let url: String
    let name: String
    let ownerId: Int
    let summary: String
    let imageUrl: String
}

struct ProjectListViewModel {
    let id: Int
    let url: String
    let name: String
    let ownerId: Int
    let summary: String
    let imageUrl: String
}

extension ProjectListViewModel {
    init(project: Project) {
        self.id = project.id
        self.url = project.url
        self.name = project.name
        self.ownerId = project.ownerId
        self.summary = project.summary
        self.imageUrl = project.imageUrl
    }
}
