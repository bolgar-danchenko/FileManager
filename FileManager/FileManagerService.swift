//
//  FileManagerService.swift
//  FileManager
//
//  Created by Konstantin Bolgar-Danchenko on 22.10.2022.
//

import Foundation

protocol FileManagerServiceProtocol {
    func contentsOfDirectory(currentDirectory: URL) -> [URL]
    func createDirectory(currentDirectory: URL, newDirectoryName: String)
    func createFile(currentDirectory: URL, newFile: URL)
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

    func createDirectory(
        currentDirectory: URL,
        newDirectoryName: String
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

    func createFile(
        currentDirectory: URL,
        newFile: URL
    ) {
        let fileURL = currentDirectory.appendingPathComponent(newFile.lastPathComponent)
        do {
            FileManager.default.createFile(
                atPath: fileURL.path,
                contents: Data()
            )
        }
    }

    func removeContent(
        currentDirectory: URL,
        toDelete: URL
    ) {
        do {
            try FileManager.default.removeItem(at: toDelete)
        } catch {
            print(error.localizedDescription)
        }
    }
}
