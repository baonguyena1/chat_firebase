//
//  UserListViewModel.swift
//  ChatFirebase
//
//  Created by Bao Nguyen on 12/25/19.
//  Copyright © 2019 Bao Nguyen. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class UserListViewModel {
    
    private let bag = DisposeBag()
    
    private(set) var members = BehaviorRelay<[User]>(value: [])
    
    func observeMembers() {
        let auth = FireBaseManager.shared.auth
        let usersCollection = FireBaseManager.shared.usersCollection
        usersCollection.rx
            .listen()
            .subscribe(onNext: { [weak self] (snapshot) in
                guard let `self` = self else { return }
                var currents = self.members.value
                snapshot.documentChanges.forEach { (diff) in
                    let member = User(json: diff.document.data())
                    switch diff.type {
                        case .added:
                            if member.id != auth.currentUser?.uid {
                                currents.append(member)
                            }
                        case .modified:
                            if let index = currents.firstIndex(where: { $0.id == member.id }) {
                                currents[index] = member
                            }
                        case .removed:
                            if let index = currents.firstIndex(where: { $0.id == member.id }) {
                                currents.remove(at: index)
                        }
                    }
                    self.members.accept(currents)
                }
                }, onError: { (error) in
                    Logger.error(error.localizedDescription)
            })
            .disposed(by: bag)
    }
}
