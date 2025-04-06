//
//  RealmDatabaseForDest.swift
//  Disaster App
//
//  Created by Neel Arora on 4/6/25.
//
import RealmSwift
import Foundation
class DisasterReportModel: Object,ObjectKeyIdentifiable{
    @Persisted var disaster: String
}

