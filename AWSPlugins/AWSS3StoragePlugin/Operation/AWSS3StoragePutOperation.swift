//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import Amplify
import AWSS3

public class AWSS3StoragePutOperation: AmplifyOperation<Progress, StoragePutResult, StoragePutError>, StoragePutOperation {

    let request: AWSS3StoragePutRequest
    let service: AWSS3StorageServiceBehaviour
    let onComplete: ((CompletionEvent<StoragePutResult, StoragePutError>) -> Void)?
    
    var storageOperationReference: StorageOperationReference?
    
    init(_ request: AWSS3StoragePutRequest,
         service: AWSS3StorageServiceBehaviour,
         onComplete: ((CompletionEvent<CompletedType, ErrorType>) -> Void)?) {
        
        self.request = request
        self.service = service
        self.onComplete = onComplete
        super.init(categoryType: .storage)
    }
    
    public func pause() {
        storageOperationReference?.pause()
    }

    public func resume() {
        storageOperationReference?.resume()
    }
    
    override public func cancel() {
    
        storageOperationReference?.cancel()
        cancel()
    }
    
    override public func main() {
        self.service.execute(self.request, onEvent: { (event) in
            switch(event) {
            case .initiated(let reference):
                self.storageOperationReference = reference
                break
            case .inProcess(let progress):
                print("Amplify.Hub.dispatch(to: .storage, payload: AsyncEvent(AsyncEvent.inProcess(progress)))")
                break
            case .completed(let result):
                print(result)
                self.onComplete?(CompletionEvent.completed(result))
                self.finish()
                break
            case .failed(let error):
                self.onComplete?(CompletionEvent.failed(error))
                self.finish()
                break
            }
        })
    }
}
