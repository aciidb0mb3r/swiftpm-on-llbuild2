// This source file is part of the Swift.org open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors

import ArgumentParser
import LLBCAS
import NIO
import TSCBasic

import class Foundation.ProcessInfo

struct Options: ParsableArguments {

    @Option()
    var packagePath: String?
}

extension Options {
    func db() throws -> LLBCASDatabase {
        let buildDir = try self.buildDir()
        return LLBFileBackedCASDatabase(
            group: group,
            path: buildDir.appending(component: "cas")
        )
    }

    func getPackagePath() throws -> AbsolutePath {
        if let packagePath = self.packagePath {
            return try AbsolutePath(validating: packagePath)
        } else {
            return try cwd()
        }
    }

    func buildDir() throws -> AbsolutePath {
        try getPackagePath().appending(component: ".build")
    }

    private func cwd() throws -> AbsolutePath {
        guard let cwd = localFileSystem.currentWorkingDirectory else {
            throw StringError("unable to find current working directory")
        }
        return cwd
    }

    static let group = MultiThreadedEventLoopGroup(
        numberOfThreads: ProcessInfo.processInfo.processorCount
    )
    var group: MultiThreadedEventLoopGroup { Self.group }
}
