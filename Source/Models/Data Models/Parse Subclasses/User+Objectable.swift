//
//  User+Objectable.swift
//  Benji
//
//  Created by Benji Dodgson on 11/3/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse

extension User: Objectable {
    typealias KeyType = UserKey

    func saveObject() -> Future<User> {
        let promise = Promise<User>()

        self.saveInBackground { (success, error) in
            if let error = error {
                promise.reject(with: error)
            } else {
                promise.resolve(with: self)
            }
        }

        return promise
    }

    static func cachedQuery(for objectID: String) -> Future<User> {
        let promise = Promise<User>()

        if let query = self.query() {
            query.cachePolicy = .cacheThenNetwork
            query.whereKey(ObjectKey.objectId.rawValue, equalTo: objectID)
            query.getFirstObjectInBackground { (object, error) in
                if let obj = object as? User {
                    promise.resolve(with: obj)
                } else if let error = error {
                    promise.reject(with: error)
                } else {
                    promise.reject(with: ClientError.generic)
                }
            }
        }

        return promise
    }

    static func cachedArrayQuery(with identifiers: [String]) -> Future<[User]> {
        let promise = Promise<[User]>()

        if let query = self.query() {
            query.cachePolicy = .cacheThenNetwork
            query.whereKey(ObjectKey.objectId.rawValue, containedIn: identifiers)
            query.findObjectsInBackground { (objects, error) in
                if let objs = objects as? [User] {
                    promise.resolve(with: objs)
                } else if let error = error {
                    promise.reject(with: error)
                } else {
                    promise.reject(with: ClientError.generic)
                }
            }
        }

        return promise
    }

    static func initializeArrayQuery(notEqualTo identifier: String,
                                     cachePolicy: PFCachePolicy = .cacheThenNetwork) -> Future<[User]> {
        
        let promise = Promise<[User]>()

        if let query = self.query() {
            query.cachePolicy = cachePolicy
            query.whereKey(ObjectKey.objectId.rawValue, notEqualTo: identifier)
            query.findObjectsInBackground { (objects, error) in
                if let objs = objects as? [User] {
                    promise.resolve(with: objs)
                } else if let error = error {
                    promise.reject(with: error)
                } else {
                    promise.reject(with: ClientError.generic)
                }
            }
        }

        return promise
    }


    func getObject<Type>(for key: UserKey) -> Type? {
        return self.object(forKey: key.rawValue) as? Type
    }

    func setObject<Type>(for key: UserKey, with newValue: Type) {
        self.setObject(newValue, forKey: key.rawValue)
    }

    func getRelationalObject<PFRelation>(for key: UserKey) -> PFRelation? {
        return self.relation(forKey: key.rawValue) as? PFRelation
    }
}