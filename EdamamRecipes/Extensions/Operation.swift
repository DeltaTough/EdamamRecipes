//
//  Operation.swift
//  EdamamRecipes
//
//  Created by Dimitrios Tsoumanis on 05/10/2024.
//

import Foundation

extension Operation {
    func asyncStart(on queue: OperationQueue) async {
        await withCheckedContinuation { continuation in
            self.completionBlock = {
                continuation.resume()
            }
            queue.addOperation(self)
        }
    }
}
