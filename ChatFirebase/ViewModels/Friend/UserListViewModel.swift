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
                    var data = diff.document.data()
                    data[KeyPath.kDocumentID] = diff.document.documentID
                    let user = User(from: data)
                    switch diff.type {
                        case .added:
                            if user.documentID != auth.currentUser?.uid {
                                currents.append(user)
                            }
                        case .modified:
                            if let index = currents.firstIndex(where: { $0.documentID == user.documentID }) {
                                currents[index] = user
                            }
                        case .removed:
                            if let index = currents.firstIndex(where: { $0.documentID == user.documentID }) {
                                currents.remove(at: index)
                        }
                    }
                }
                self.setUsers(users: currents)
                }, onError: { (error) in
                    Logger.error(error.localizedDescription)
            })
            .disposed(by: bag)
    }
    
    private func setUsers(users: [User]) {
        let list = users.sorted { (u1, u2) -> Bool in
            u1.createdAt > u2.createdAt
        }
        self.members.accept(list)
    }
}
