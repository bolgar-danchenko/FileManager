//
//  FileManagerService.swift
//  FileManager
//
//  Created by Konstantin Bolgar-Danchenko on 22.10.2022.
//

import Foundation
import UIKit

protocol FileManagerServiceProtocol {
    func contentsOfDirectory(currentDirectory: URL) -> [URL]
    func createDirectory(currentDirectory: URL, newDirectoryName: String)
    func createFile(currentDirectory: URL, newFile: URL, image: UIImage)
    func removeContent(currentDirectory: URL, toDelete: URL)
}

class FileManagerService: FileManagerServiceProtocol {
    
    func contentsOfDirectory(currentDirectory: URL) -> [URL] {
        var contents: [URL] = []
        do {
            let files = try FileManager.default.contentsOfDirectory(
                at: currentDirectory,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles
            )
            contents = files
        } catch {
            print(error.localizedDescription)
        }
        return contents
    }

    func createDirectory(currentDirectory: URL, newDirectoryName: String
    ) {
        let newDirectoryURL = currentDirectory.appendingPathComponent(newDirectoryName)
        do {
            try FileManager.default.createDirectory(
                atPath: newDirectoryURL.path,
                withIntermediateDirectories: false
            )
        } catch {
            print(error.localizedDescription)
        }
    }

    func createFile(currentDirectory: URL, newFile: URL, image: UIImage) {
        let fileURL = currentDirectory.appendingPathComponent(newFile.lastPathComponent)
        do {
            FileManager.default.createFile(atPath: fileURL.path, contents: image.jpegData(compressionQuality: 1))
        }
    }

    func removeContent(currentDirectory: URL, toDelete: URL
    ) {
        do {
            try FileManager.default.removeItem(at: toDelete)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func sizeOfFolder(_ folderPath: String) -> String {
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: folderPath)
            var folderSize: Int64 = 0
            for content in contents {
                do {
                    let fullContantPath = folderPath + "/" + content
                    let fileAttributes = try FileManager.default.attributesOfItem(atPath: fullContantPath)
                    folderSize += fileAttributes[FileAttributeKey.size] as? Int64 ?? 0
                } catch _ {
                    continue
                }
            }
            let fileSizeString = ByteCountFormatter.string(fromByteCount: folderSize, countStyle: .file)
            return fileSizeString
        } catch let error {
            print(error.localizedDescription)
            return "Zero KB"
        }
    }
}

extension URL {
    var attributes: [FileAttributeKey : Any]? {
        do {
            return try FileManager.default.attributesOfItem(atPath: path)
        } catch let error as NSError {
            print("FileAttribute error: \(error.localizedDescription)")
        }
        return nil
    }
    
    var fileSize: UInt64 {
        return attributes?[.size] as? UInt64 ?? UInt64(0)
    }
    
    var fileSizeString: String {
        return ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
    }
}
