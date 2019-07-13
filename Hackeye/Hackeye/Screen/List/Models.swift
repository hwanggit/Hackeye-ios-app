//
//  Models.swift
//  Hackeye
//
//  Created by Luhao Wang on 7/8/19.
//  Copyright © 2019 Luhao Wang. All rights reserved.
//

import Foundation

// Root object to contain array of projects
struct Root: Codable {
    var projects: [Project]
}

// User object
struct User: Codable {
    let location: String
    let screenName: String
    let url: String
    let imageUrl: String
}

// ImageObject
struct ImageObject: Codable {
    let images: [Image]
}

// Single Image
struct Image: Codable {
    let url: String
}

// Project object
struct Project: Codable {
    let id: Int
    let url: String
    let name: String
    let ownerId: Int
    let summary: String
    let description : String
    let views : Int
    let comments: Int
    let followers: Int
    let skulls: Int
    let imageUrl: String?
    let images: Int
}

// Project list object
struct ProjectListViewModel {
    let id: Int
    let url: String
    let name: String
    let ownerId: Int
    let summary: String
    let description : String
    let views : Int
    let comments: Int
    let followers: Int
    let skulls: Int
    let imageUrl: String?
    let images: Int
}

// Copy Constructor for project list object
extension ProjectListViewModel {
    init(project: Project) {
        self.id = project.id
        self.url = project.url
        self.name = project.name
        self.ownerId = project.ownerId
        self.summary = project.summary
        self.description = project.description
        self.views = project.views
        self.comments = project.comments
        self.followers = project.followers
        self.skulls = project.skulls
        self.imageUrl = project.imageUrl
        self.images = project.images
    }
}
