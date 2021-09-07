//
//  CacheFileType.swift
//  HostingApp
//
//  Created by Serg Liamthev on 08.12.2019.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation

enum CacheFileType: String, CaseIterable {
    
    case none = "none"
    
    // Images
    case png = "png"
    case jpeg = "jpeg"
    case gif = "gif"
    
    // Audio
    case mp4Audio = "mp4a"
    
    // Video
    case mp4 = "mp4"
    
    // Documents
    case pdf = "pdf"
    case doc = "doc"
    case docx = "docx"
    
}
